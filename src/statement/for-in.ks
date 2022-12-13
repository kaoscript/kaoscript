class ForInStatement extends Statement {
	private late {
		@bindingScope: Scope
		@bindingValue						= null
		@body
		@bodyScope: Scope
		@boundName: String
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declared: Boolean					= false
		@declaredVariables: Array			= []
		@declareIndex: Boolean				= false
		@declareValue: Boolean				= false
		@descending: Boolean				= false
		@expression
		@expressionName: String
		@from
		@fromDesc: Boolean					= false
		@immutable: Boolean					= false
		@index								= null
		@indexName: String
		@loopTempVariables: Array			= []
		@step
		@stepName: String
		@until
		@useBreak: Boolean					= false
		@value								= null
		@when
		@while
		@to
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
			else if modifier.kind == ModifierKind::Descending {
				@descending = true
			}
		}

		if ?@data.index {
			var variable = @bindingScope.getVariable(@data.index.name)

			if @declaration || variable == null {
				@bindingScope.define(@data.index.name, @immutable, @bindingScope.reference('Number'), true, this)

				@declareIndex = true
			}
			else if variable.isImmutable() {
				ReferenceException.throwImmutable(@data.index.name, this)
			}

			@index = $compile.expression(@data.index, this, @bindingScope)
			@index.analyse()
		}

		if ?@data.value {
			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.setAssignment(AssignmentType::Expression)
			@value.analyse()

			for var name in @value.listAssignments([]) {
				var variable = @scope.getVariable(name)

				if @declaration || variable == null {
					@declareValue = true

					@declaredVariables.push(@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, this))
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

		if ?@data.from {
			@from = $compile.expression(@data.from, this, @scope)
			@from.analyse()

			@checkForRenamedVariables(@from, variables)
		}

		if ?@data.to {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			@checkForRenamedVariables(@to, variables)
		}

		if ?@data.step {
			@step = $compile.expression(@data.step, this, @scope)
			@step.analyse()

			@checkForRenamedVariables(@step, variables)
		}

		for var variable in variables {
			@bindingScope.rename(variable)
		}

		if ?@data.until {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()

			@checkForBreak(@until)
		}
		else if ?@data.while {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()

			@checkForBreak(@while)
		}

		if ?@data.when {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		@fromDesc = @data.step?.kind == NodeKind::NumericExpression && @data.step.value < 0

		if @descending && @fromDesc {
			@descending = @fromDesc = false
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(@scope.reference('Array'))

		var type = @expression.type()
		if !(type.isAny() || type.isArray()) {
			TypeException.throwInvalidForInExpression(this)
		}

		if @value != null {
			var parameterType = type.parameter()
			var valueType = Type.fromAST(@data.type, this)

			unless parameterType.isAssignableToVariable(valueType, true, true, false) {
				TypeException.throwInvalidAssignement(@value, valueType, parameterType, this)
			}

			var realType = parameterType.isMorePreciseThan(valueType) ? parameterType : valueType

			if @value is IdentifierLiteral {
				if @declareValue {
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

		if @index != null {
			unless @declareIndex {
				@bindingScope.replaceVariable(@data.index.name, @bindingScope.reference('Number'), this)
			}

			@index.prepare(@scope.reference('Number'))
		}
		else {
			@indexName = @bindingScope.acquireTempName(false)
		}

		if @expression.isLooseComposite() {
			@expressionName = @bindingScope.acquireTempName(false)
		}

		@boundName = @bindingScope.acquireTempName(false)

		@bindingValue = new TempMemberExpression(@expressionName ?? @expression, @indexName ?? @index, true, this, @bindingScope)

		if @options.format.destructuring == 'es5' && @value is not IdentifierLiteral {
			@bindingValue.acquireReusable(true)
		}

		if ?@from {
			@from.prepare(@scope.reference('Number'))
		}

		if ?@to {
			@to.prepare(@scope.reference('Number'))
		}

		if ?@step {
			@step.prepare(@scope.reference('Number'))

			@stepName = @bindingScope.acquireTempName(false) if @step.isComposite()
		}

		@assignTempVariables(@bindingScope)

		if ?@until {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				@assignTempVariables(@bodyScope)
			}
		}
		else if ?@while {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				@assignTempVariables(@bodyScope)
			}
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}

			for var data, name of @when.inferWhenTrueTypes({}) {
				@bodyScope.updateInferable(name, data, this)
			}

			@when.acquireReusable(false)
			@when.releaseReusable()

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}

		@body.prepare(target)

		@bindingScope.releaseTempName(@expressionName) if ?@expressionName
		@bindingScope.releaseTempName(@indexName) if ?@indexName
		@bindingScope.releaseTempName(@boundName)

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()

		if ?@value {
			@value.translate()
		}

		if ?@from {
			@from.translate()
		}

		if ?@to {
			@to.translate()
		}

		@step.translate() if ?@step

		if ?@until {
			@until.translate()
		}
		else if ?@while {
			@while.translate()
		}

		if ?@when {
			@when.translate()
		}

		@body.translate()
	} # }}}
	checkForBreak(expression) { # {{{
		if !@useBreak && @value != null {
			for var variable in @value.listAssignments([]) until @useBreak {
				if expression.isUsingVariable(variable) {
					@useBreak = true
				}
			}
		}
	} # }}}
	checkForRenamedVariables(expression, variables: Array) { # {{{
		if @index != null && expression.isUsingVariable(@data.index.name) {
			if @declareIndex {
				variables.pushUniq(@data.index.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.index.name, this)
			}
		}

		if @value != null {
			for var variable in @value.listAssignments([]) {
				if expression.isUsingVariable(variable) {
					if @declareValue {
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
		||	@from?.isUsingVariable(name)
		||	@to?.isUsingVariable(name)
		||	@step?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	# }}}
	toBoundFragments(fragments) { # {{{
		if @descending {
			if ?@from {
				if @from is NumberLiteral && @from.value() < 0 {
					fragments
						.code('Math.max(0, ')
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@from.value()))`)
				}
				else {
					fragments.compile(@from)
				}
			}
			else {
				fragments.code('0')
			}
		}
		else {
			if ?@to {
				var ballpark = $ast.hasModifier(@data.to, ModifierKind::Ballpark)

				if @fromDesc {
					fragments.compile(@to)
				}
				else if @to is NumberLiteral {
					if @to.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(ballpark ? -@to.value() : -@to.value() - 1)`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length, \(ballpark ? @to.value() : @to.value() + 1))`)
					}
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@to)
						.code(ballpark ? ')' : ' + 1)')
				}
			}
			else {
				if @fromDesc {
					fragments.code('0')
				}
				else {
					fragments
						.compile(@expressionName ?? @expression)
						.code('.length')
				}
			}
		}
	} # }}}
	toFromFragments(fragments) { # {{{
		if @descending {
			if ?@to {
				var ballpark = $ast.hasModifier(@data.to, ModifierKind::Ballpark)

				if @to is NumberLiteral {
					if @to.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(ballpark ? -@to.value() + 1 : -@to.value())`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length - 1, \(ballpark ? @to.value() - 1 : @to.value()))`)
					}
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length - 1, ')
						.compile(@to)
						.code(ballpark ? ') - 1' : ')')
				}
			}
			else {
				fragments
					.compile(@expressionName ?? @expression)
					.code('.length - 1')
			}
		}
		else {
			if @fromDesc {
				if ?@from {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code(`.length - 1, `)
						.compile(@from)
						.code(`)`)
				}
				else {
					fragments.compile(@expressionName ?? @expression).code('.length - 1')
				}
			}
			else {
				if ?@from {
					if @from is NumberLiteral && @from.value() < 0 {
						fragments
							.code('Math.max(0, ')
							.compile(@expressionName ?? @expression)
							.code(`.length - \(-@from.value()))`)
					}
					else {
						fragments.compile(@from)
					}
				}
				else {
					fragments.code('0')
				}
			}
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var late ctrl

		if @index != null && !@declaration && !@declareIndex {
			var line = fragments
				.newLine()
				.compile(@index)
				.code($equals)

			@toFromFragments(line)

			line.done()

			ctrl = fragments
				.newControl()
				.code('for(', $runtime.scope(this))
		}
		else {
			ctrl = fragments
				.newControl()
				.code('for(', $runtime.scope(this))
				.compile(@indexName ?? @index)
				.code($equals)

			@toFromFragments(ctrl)

			ctrl.code($comma)
		}

		if ?@expressionName {
			ctrl.code(@expressionName, $equals).compile(@expression).code($comma)
		}

		ctrl.code(@boundName, $equals)

		@toBoundFragments(ctrl)

		if @declareValue {
			for var variable in @declaredVariables {
				ctrl.code($comma).compile(variable)
			}
		}

		ctrl.code('; ')

		if @descending || @fromDesc {
			ctrl
				.compile(@indexName ?? @index)
				.code(' >= ' + @boundName)
		}
		else {
			ctrl
				.compile(@indexName ?? @index)
				.code(' < ' + @boundName)
		}

		if !@useBreak {
			if ?@until {
				ctrl.code(' && !(').compileCondition(@until).code(')')
			}
			else if ?@while {
				ctrl.code(' && ').wrapCondition(@while, Mode::None, Junction::AND)
			}
		}

		ctrl.code('; ')

		if @descending || @fromDesc {
			if ?@data.step {
				if @data.step.kind == NodeKind::NumericExpression {
					if Math.abs(@data.step.value) == 1 {
						ctrl.code('--').compile(@indexName ?? @index)
					}
					else {
						ctrl.compile(@indexName ?? @index).code(' -= ', Math.abs(@data.step.value))
					}
				}
				else {
					ctrl.compile(@indexName ?? @index).code(' -= ').compile(@stepName ?? @step)
				}
			}
			else {
				ctrl.code('--').compile(@indexName ?? @index)
			}
		}
		else {
			if ?@data.step {
				if @data.step.kind == NodeKind::NumericExpression {
					if Math.abs(@data.step.value) == 1 {
						ctrl.code('++').compile(@indexName ?? @index)
					}
					else {
						ctrl.compile(@indexName ?? @index).code(' += ', Math.abs(@data.step.value))
					}
				}
				else {
					ctrl.compile(@indexName ?? @index).code(' += ').compile(@stepName ?? @step)
				}
			}
			else {
				ctrl.code('++').compile(@indexName ?? @index)
			}
		}

		ctrl.code(')').step()

		if ?@value {
			var line = ctrl.newLine()

			@value.toAssignmentFragments(line, @bindingValue)

			line.done()

			if @useBreak {
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
			}
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
	} # }}}
}
