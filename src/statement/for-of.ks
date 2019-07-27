class ForOfStatement extends Statement {
	private {
		_bindingScope: Scope
		_bindingValue						= null
		_bleeding: Boolean					= false
		_bodyScope: Scope
		_body
		_conditionalTempVariables: Array	= []
		_defineKey: Boolean					= false
		_defineValue: Boolean				= false
		_expression
		_expressionName: String
		_key								= null
		_keyName: String
		_immutable: Boolean					= false
		_loopTempVariables: Array			= []
		_until
		_value								= null
		_when
		_while
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@immutable = @data.declaration && !@data.rebindable

		if @data.key? {
			const keyVariable = @scope.getVariable(@data.key.name)

			if @data.declaration || keyVariable == null {
				@bindingScope.define(@data.key.name, @immutable, @bindingScope.reference('String'), this)

				@defineKey = true
			}
			else if keyVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.key.name, this)
			}
			else {
				@bindingScope.replaceVariable(@data.key.name, @bindingScope.reference('String'), this)
			}

			@key = $compile.expression(@data.key, this, @bindingScope)
			@key.analyse()
		}

		if @data.value? {
			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.setAssignment(AssignmentType::Expression)
			@value.analyse()

			for const name in @value.listAssignments([]) {
				const variable = @bindingScope.getVariable(name)

				if @data.declaration || variable == null {
					@defineValue = true

					@bindingScope.define(name, @immutable, Type.Any, this)
				}
				else if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}
			}
		}

		const variables = []

		@expression = $compile.expression(@data.expression, this, @scope)
		@expression.analyse()

		this.checkForRenamedVariables(@expression, variables)

		for const variable in variables {
			@bindingScope.rename(variable)
		}

		if @data.until {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()
		}
		else if @data.while {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()
		}

		if @data.when {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		const type = @expression.type()
		if !(type.isAny() || type.isObject()) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if @expression.isLooseComposite() {
			@expressionName = @bindingScope.acquireTempName(false)

			@bleeding = @bindingScope.isBleeding()
		}

		if @defineValue {
			@value.type(type.parameter(), @bindingScope, this)
		}

		if @key? {
			@key.prepare()
		}
		else {
			@keyName = @bindingScope.acquireTempName(false)
		}

		if @options.format.destructuring == 'es5' && @value is not IdentifierLiteral {
			@bindingValue = new TempMemberExpression(@expressionName ?? @expression, @key ?? @keyName, true, this, @bindingScope)

			@bindingValue.acquireReusable(true)
		}

		this.assignTempVariables(@bindingScope)

		if @until? {
			@until.prepare()

			@bodyScope.commitTempVariables(@loopTempVariables)
		}
		else if @while? {
			@while.prepare()

			@bodyScope.commitTempVariables(@loopTempVariables)
		}

		if @when? {
			@when.prepare()

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}

		@body.prepare()

		@bindingScope.releaseTempName(@expressionName) if @expressionName?
		@bindingScope.releaseTempName(@keyName) if @keyName?
	} // }}}
	translate() { // {{{
		@expression.translate()

		@key.translate() if @key?

		if @until? {
			@until.translate()
		}
		else if @while? {
			@while.translate()
		}

		@when.translate() if @when?

		@body.translate()
	} // }}}
	checkForRenamedVariables(expression, variables: Array) { // {{{
		if @key != null && expression.isUsingVariable(@data.key.name) {
			if @defineKey {
				variables.pushUniq(@data.key.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.key.name, this)
			}
		}

		if @value != null {
			for const variable in @value.listAssignments([]) {
				if expression.isUsingVariable(variable) {
					if @defineValue {
						variables.pushUniq(variable)
					}
					else {
						SyntaxException.throwAlreadyDeclared(variable, this)
					}
				}
			}
		}
	} // }}}
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isUsingVariable(name) => // {{{
			@expression.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	// }}}
	toStatementFragments(fragments, mode) { // {{{
		if @expressionName? {
			if @bleeding {
				fragments
					.newLine()
					.code($runtime.scope(this), @expressionName, $equals)
					.compile(@expression)
					.done()

				this.toLoopFragments(fragments, mode)
			}
			else {
				const block = fragments.newBlock()

				block
					.newLine()
					.code($runtime.scope(this), @expressionName, $equals)
					.compile(@expression)
					.done()

				this.toLoopFragments(block, mode)

				block.done()
			}
		}
		else {
			this.toLoopFragments(fragments, mode)
		}
	} // }}}
	toLoopFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl().code('for(')

		if @key != null {
			if @data.declaration || @defineKey {
				if @options.format.variables == 'es5' {
					ctrl.code('var ')
				}
				else if @immutable {
					ctrl.code('const ')
				}
				else {
					ctrl.code('let ')
				}
			}

			ctrl.compile(@key)
		}
		else {
			ctrl.code($runtime.scope(this), @keyName)
		}

		ctrl.code(' in ').compile(@expressionName ?? @expression).code(')').step()

		if @value != null {
			let line = ctrl.newLine()

			if @data.declaration || @defineValue {
				if @options.format.variables == 'es5' {
					line.code('var ')
				}
				else if @immutable {
					line.code('const ')
				}
				else {
					line.code('let ')
				}
			}

			if @bindingValue == null {
				line
					.compile(@value)
					.code($equals)
					.compile(@expressionName ?? @expression)
					.code('[')
					.compile(@key ?? @keyName)
					.code(']')
			}
			else {
				@value.toAssignmentFragments(line, @bindingValue)
			}

			line.done()
		}

		if @until? {
			this.toDeclarationFragments(@loopTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(@until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if @while? {
			this.toDeclarationFragments(@loopTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(!(')
				.compileBoolean(@while)
				.code('))')
				.step()
				.line('break')
				.done()
		}

		if @when? {
			this.toDeclarationFragments(@conditionalTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(@when)
				.code(')')
				.step()
				.compile(@body)
				.done()
		}
		else {
			ctrl.compile(@body)
		}

		ctrl.done()
	} // }}}
}