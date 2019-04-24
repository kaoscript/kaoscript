class ForOfStatement extends Statement {
	private {
		_bindingScope
		_bleeding: Boolean					= false
		_bodyScope
		_body
		_conditionalTempVariables: Array	= []
		_defineKey: Boolean					= false
		_defineValue: Boolean				= false
		_expression
		_expressionName: String
		_key								= null
		_keyName: String
		_keyVariable: Variable
		_immutable: Boolean					= false
		_loopTempVariables: Array			= []
		_until
		_value								= null
		_valueVariable: Variable
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
				@keyVariable = @bindingScope.define(@data.key.name, @immutable, @bindingScope.reference('String'), this)

				@defineKey = true
			}
			else if keyVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.key.name, this)
			}

			@key = $compile.expression(@data.key, this, @bindingScope)
			@key.analyse()
		}

		if @data.value? {
			const valueVariable = @scope.getVariable(@data.value.name)

			if @data.declaration || valueVariable == null {
				@valueVariable = @bindingScope.define(@data.value.name, @immutable, Type.Any, this)

				@defineValue = true
			}
			else if valueVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.value.name, this)
			}

			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.analyse()
		}

		@expression = $compile.expression(@data.expression, this, @scope)
		@expression.analyse()

		if @key != null && @expression.isUsingVariable(@data.key.name) {
			if @defineKey {
				@bindingScope.rename(@data.key.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.key.name, this)
			}
		}
		if @value != null && @expression.isUsingVariable(@data.value.name) {
			if @defineValue {
				@bindingScope.rename(@data.value.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.value.name, this)
			}
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

		@body = $compile.expression($ast.block(@data.body), this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		const type = @expression.type()
		if !(type.isAny() || type.isObject()) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if @expression.isEntangled() {
			@expressionName = @bindingScope.acquireTempName(false)

			@bleeding = @bindingScope.isBleeding()
		}

		if @defineValue {
			@valueVariable.setRealType(type.parameter())
		}

		if @key? {
			@key.prepare()
		}
		else {
			@keyName = @bindingScope.acquireTempName(false)
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

			line.compile(@value).code($equals).compile(@expressionName ?? @expression).code('[').compile(@key ?? @keyName).code(']').done()
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