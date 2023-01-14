class ForOfStatement extends Statement {
	private late {
		@bindingScope: Scope
		@bindingValue						= null
		@bodyScope: Scope
		@body
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@defineKey: Boolean					= false
		@defineValue: Boolean				= false
		@else
		@elseScope
		@expression
		@expressionName: String
		@key								= null
		@keyName: String
		@immutable: Boolean					= false
		@loopTempVariables: Array			= []
		@until
		@value								= null
		@when
		@while
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		if ?@data.key {
			var keyVariable = @scope.getVariable(@data.key.name)

			if @declaration || keyVariable == null {
				@bindingScope.define(@data.key.name, @immutable, @bindingScope.reference('String'), true, this)

				@defineKey = true
			}
			else if keyVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.key.name, this)
			}

			@key = $compile.expression(@data.key, this, @bindingScope)
			@key.analyse()
		}

		if ?@data.value {
			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.setAssignment(AssignmentType::Expression)
			@value.analyse()

			for var name in @value.listAssignments([]) {
				var variable = @bindingScope.getVariable(name)

				if @declaration || variable == null {
					@defineValue = true

					@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, this)
				}
				else if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}
			}
		}

		var variables = []

		@expression = $compile.expression(@data.expression, this, @scope)
		@expression.analyse()

		@checkForRenamedVariables(@expression, variables)

		for var variable in variables {
			@bindingScope.rename(variable)
		}

		if ?@data.until {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()
		}
		else if ?@data.while {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()
		}

		if ?@data.when {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		if ?@data.else {
			@elseScope = @newScope(@scope, ScopeType::InlineBlock)

			@else = $compile.block(@data.else, this, @elseScope)
			@else.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(AnyType.NullableUnexplicit)

		var type = @expression.type()
		unless type.canBeObject(true) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if @expression.isLooseComposite() {
			@expressionName = @bindingScope.acquireTempName(false)
		}

		if @value != null {
			var parameterType = type.parameter()
			var valueType = Type.fromAST(@data.type, this)

			unless parameterType.isAssignableToVariable(valueType, true, true, false) {
				TypeException.throwInvalidAssignement(@value, valueType, parameterType, this)
			}

			var realType = parameterType.isMorePreciseThan(valueType) ? parameterType : valueType

			if @value is IdentifierLiteral {
				if @defineValue {
					@value.type(realType, @bindingScope, this)
				}
				else {
					@bindingScope.replaceVariable(@value.name(), realType, this)
				}
			}
			else {
				for var name in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}
		}

		if @key != null {
			unless @defineKey {
				@bindingScope.replaceVariable(@data.key.name, @bindingScope.reference('String'), this)
			}

			@key.prepare(@scope.reference('String'))
		}
		else {
			@keyName = @bindingScope.acquireTempName(false)
		}

		if @options.format.destructuring == 'es5' && @value is not IdentifierLiteral {
			@bindingValue = new TempMemberExpression(@expressionName ?? @expression, @key ?? @keyName, true, this, @bindingScope)

			@bindingValue.acquireReusable(true)
		}

		@assignTempVariables(@bindingScope)

		if ?@until {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			@bodyScope.commitTempVariables(@loopTempVariables)
		}
		else if ?@while {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			@bodyScope.commitTempVariables(@loopTempVariables)
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}

			for var data, name of @when.inferWhenTrueTypes({}) {
				@bodyScope.updateInferable(name, data, this)
			}

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}

		@body.prepare(target)

		@else?.prepare(target)

		@bindingScope.releaseTempName(@expressionName) if ?@expressionName
		@bindingScope.releaseTempName(@keyName) if ?@keyName

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()

		@key.translate() if ?@key

		if ?@until {
			@until.translate()
		}
		else if ?@while {
			@while.translate()
		}

		@when.translate() if ?@when

		@body.translate()

		@else?.translate()
	} # }}}
	checkForRenamedVariables(expression, variables: Array) { # {{{
		if @key != null && expression.isUsingVariable(@data.key.name) {
			if @defineKey {
				variables.pushUniq(@data.key.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.key.name, this)
			}
		}

		if @value != null {
			for var variable in @value.listAssignments([]) {
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
	} # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => # {{{
			@expression.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
		||	@else?.isUsingVariable(name)
	# }}}
	toStatementFragments(fragments, mode) { # {{{
		if ?@expressionName {
			fragments
				.newLine()
				.code($runtime.scope(this), @expressionName, $equals)
				.compile(@expression)
				.done()

			@toLoopFragments(fragments, mode)
		}
		else {
			@toLoopFragments(fragments, mode)
		}
	} # }}}
	toLoopFragments(fragments, mode) { # {{{
		var mut ifCtrl = null
		if ?@else {
			ifCtrl = fragments
				.newControl()
				.code(`if(\($runtime.type(this)).isNotEmpty(`)
				.compile(@expressionName ?? @expression)
				.code('))')
				.step()
		}

		var ctrl = (ifCtrl ?? fragments).newControl().code('for(')

		if @key != null {
			if @declaration || @defineKey {
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
			var mut line = ctrl.newLine()

			if @declaration || @defineValue {
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

		if ?@until {
			@toDeclarationFragments(@loopTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(')
				.compileCondition(@until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if ?@while {
			@toDeclarationFragments(@loopTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(!(')
				.compileCondition(@while)
				.code('))')
				.step()
				.line('break')
				.done()
		}

		if ?@when {
			@toDeclarationFragments(@conditionalTempVariables, ctrl)

			ctrl
				.newControl()
				.code('if(')
				.compileCondition(@when)
				.code(')')
				.step()
				.compile(@body)
				.done()
		}
		else {
			ctrl.compile(@body)
		}

		ctrl.done()

		if ?ifCtrl {
			ifCtrl
				.step()
				.code('else')
				.step()
				.compile(@else)
				.done()
		}
	} # }}}
}
