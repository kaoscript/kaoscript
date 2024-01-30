class ObjectIteration extends IterationNode {
	private late {
		@bindingValue						= null
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declareExpression: Boolean			= false
		@defineKey: Boolean					= false
		@defineValue: Boolean				= false
		@expression
		@expressionName: String
		@key								= null
		@keyName: String
		@immutable: Boolean					= true
		@loopTempVariables: Array			= []
		@until
		@value								= null
		@when
		@while
	}
	override analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType.InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)

		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.Declarative {
					@declaration = true
				}
				ModifierKind.Mutable {
					@immutable = false
				}
			}
		}

		if ?@data.key {
			if @declaration {
				@bindingScope.define(@data.key.name, @immutable, AnyType.Unexplicit, true, this)

				@defineKey = true
			}
			else {
				@bindingScope.checkVariable(@data.key.name, true, this)
			}

			@key = $compile.expression(@data.key, this, @bindingScope)
			@key.analyse()
		}

		if ?@data.value {
			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.setAssignment(AssignmentType.Expression)
			@value.analyse()

			for var { name } in @value.listAssignments([]) {
				if @declaration {
					@defineValue = true

					@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, this)
				}
				else {
					@bindingScope.checkVariable(name, true, this)
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
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(AnyType.NullableUnexplicit)

		var type = @expression.type()

		unless type.canBeObject(true) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if @expression.isLooseComposite() {
			if @expressionName !?= @scope.acquireUnusedTempName() {
				@expressionName = @scope.acquireTempName(false)
				@declareExpression = true
			}
		}

		if ?@value {
			var parameterType = type.parameter()
			var valueType = Type.fromAST(@data.type, this)

			unless parameterType.isAssignableToVariable(valueType, true, true, false) {
				TypeException.throwInvalidAssignment(@value, valueType, parameterType, this)
			}

			var realType = valueType.merge(parameterType, null, null, false, this)

			if @value is IdentifierLiteral {
				if @defineValue {
					@value.type(realType, @bindingScope, this)
				}
				else {
					@bindingScope.replaceVariable(@value.name(), realType, this)
				}
			}
			else if @value is ArrayBinding | ObjectBinding {
				@value.setAssignment(.Declaration)
				@value.type(realType)
			}
			else {
				for var { name } in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}

			@value.prepare()
		}

		if ?@key {
			var keyType =
				if type.hasKeyType() {
					set type.getKeyType()
				}
				else {
					set @scope.reference('String')
				}

			if @defineKey -> !@key.type().isExplicit() {
				@bindingScope.replaceVariable(@data.key.name, keyType, this)
			}

			@key.prepare(keyType)
		}
		else {
			@keyName = @bindingScope.acquireTempName(false)
		}

		@bindingValue = TempMemberExpression.new(@expressionName ?? @expression, @key ?? @keyName, true, this, @bindingScope)

		if ?@value {
			@bindingValue.acquireReusable(@value.isSplitAssignment())
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
	} # }}}
	override translate() { # {{{
		@expression.translate()

		@key?.translate()

		if ?@until {
			@until.translate()
		}
		else if ?@while {
			@while.translate()
		}

		@when?.translate()
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
			for var { name } in @value.listAssignments([]) {
				if expression.isUsingVariable(name) {
					if @defineValue {
						variables.pushUniq(name)
					}
					else {
						SyntaxException.throwAlreadyDeclared(name, this)
					}
				}
			}
		}
	} # }}}
	isUsingVariable(name) { # {{{
		return	@expression.isUsingVariable(name) ||
				@until?.isUsingVariable(name) ||
				@while?.isUsingVariable(name) ||
				@when?.isUsingVariable(name)
	} # }}}
	override releaseVariables() { # {{{
		@scope.releaseTempName(@expressionName) if ?@expressionName
		@bindingScope.releaseTempName(@keyName) if ?@keyName

		@bindingValue.releaseReusable()
	} # }}}
	override toIterationFragments(fragments) { # {{{
		if ?@expressionName {
			fragments
				.newLine()
				.code($runtime.scope(this)) if @declareExpression
				.code(@expressionName, $equals)
				.compile(@expression)
				.done()
		}

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments
				.newControl()
				.code(`if(\($runtime.type(this)).isNotEmpty(`)
				.compile(@expressionName ?? @expression)
				.code('))')
				.step()

			if @elseTest == .Setter {
				elseCtrl.line(`\(@parent.getElseName()) = false`)
			}
		}

		var ctrl = (elseCtrl ?? fragments).newControl().code('for(')

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

		if ?@value {
			if @value is ArrayBinding | ObjectBinding {
				@value.toAssertFragments(ctrl, @bindingValue, false)
			}

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

			@value.toAssignmentFragments(line, @bindingValue)

			line.done()
		}

		if ?@until {
			@parent.toDeclarationFragments(@loopTempVariables, ctrl)

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
			@parent.toDeclarationFragments(@loopTempVariables, ctrl)

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
			@parent.toDeclarationFragments(@conditionalTempVariables, ctrl)

			var ctrl2 = ctrl
				.newControl()
				.code('if(')
				.compileCondition(@when)
				.code(')')
				.step()

			return {
				fragments: ctrl2
				close: () => {
					ctrl2.done()

					return @close(ctrl, elseCtrl)
				}
			}
		}
		else {
			return {
				fragments: ctrl
				close: () => @close(ctrl, elseCtrl)
			}
		}
	} # }}}
}
