class ForInStatement extends Statement {
	private late {
		_bindingScope: Scope
		_bindingValue						= null
		_body
		_bodyScope: Scope
		_boundName: String
		_by
		_byName: String
		_conditionalTempVariables: Array	= []
		_declaration: Boolean				= false
		_declared: Boolean					= false
		_declaredVariables: Array			= []
		_declareIndex: Boolean				= false
		_declareValue: Boolean				= false
		_descending: Boolean				= false
		_expression
		_expressionName: String
		_from
		_fromDesc: Boolean					= false
		_immutable: Boolean					= false
		_index								= null
		_indexName: String
		_loopTempVariables: Array			= []
		_until
		_useBreak: Boolean					= false
		_value								= null
		_when
		_while
		_til
		_to
	}
	analyse() { # {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

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

		if @data.index? {
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

		if @data.value? {
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

		this.checkForRenamedVariables(@expression, variables)

		if @data.from? {
			@from = $compile.expression(@data.from, this, @scope)
			@from.analyse()

			this.checkForRenamedVariables(@from, variables)
		}

		if @data.til? {
			@til = $compile.expression(@data.til, this, @scope)
			@til.analyse()

			this.checkForRenamedVariables(@til, variables)
		}
		else if @data.to? {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			this.checkForRenamedVariables(@to, variables)
		}

		if @data.by? {
			@by = $compile.expression(@data.by, this, @scope)
			@by.analyse()

			this.checkForRenamedVariables(@by, variables)
		}

		for var variable in variables {
			@bindingScope.rename(variable)
		}

		if @data.until? {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()

			this.checkForBreak(@until)
		}
		else if @data.while? {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()

			this.checkForBreak(@while)
		}

		if @data.when? {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		@fromDesc = @data.by?.kind == NodeKind::NumericExpression && @data.by.value < 0

		if @descending && @fromDesc {
			@descending = @fromDesc = false
		}
	} # }}}
	override prepare(target) { # {{{
		@expression.prepare()

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

			@index.prepare()
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

		if @from? {
			@from.prepare(@scope.reference('Number'))
		}

		if @til? {
			@til.prepare(@scope.reference('Number'))
		}
		else if @to? {
			@to.prepare(@scope.reference('Number'))
		}

		if @by? {
			@by.prepare(@scope.reference('Number'))

			@byName = @bindingScope.acquireTempName(false) if @by.isComposite()
		}

		this.assignTempVariables(@bindingScope)

		if @until? {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				this.assignTempVariables(@bodyScope)
			}
		}
		else if @while? {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				this.assignTempVariables(@bodyScope)
			}
		}

		if @when? {
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

		@bindingScope.releaseTempName(@expressionName) if @expressionName?
		@bindingScope.releaseTempName(@indexName) if @indexName?
		@bindingScope.releaseTempName(@boundName)

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()

		if @value? {
			@value.translate()
		}

		if @from? {
			@from.translate()
		}

		if @til? {
			@til.translate()
		}
		else if @to? {
			@to.translate()
		}

		@by.translate() if @by?

		if @until? {
			@until.translate()
		}
		else if @while? {
			@while.translate()
		}

		if @when? {
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
	// checkReturnType(type: Type) { # {{{
	// 	@body.checkReturnType(type)
	// } # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => # {{{
			@expression.isUsingVariable(name)
		||	@from?.isUsingVariable(name)
		||	@til?.isUsingVariable(name)
		||	@to?.isUsingVariable(name)
		||	@by?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	# }}}
	toBoundFragments(fragments) { # {{{
		if @descending {
			if @from? {
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
			if @til? {
				if @fromDesc {
					fragments.compile(@til)
				}
				else {
					if @til is NumberLiteral && @til.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(-@til.value())`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code('.length, ')
							.compile(@til)
							.code(')')
					}
				}
			}
			else if @to? {
				if @fromDesc {
					fragments.compile(@to)
				}
				else {
					if @to is NumberLiteral {
						if @to.value() < 0 {
							fragments
								.compile(@expressionName ?? @expression)
								.code(`.length - \(-@to.value() - 1)`)
						}
						else {
							fragments
								.code('Math.min(')
								.compile(@expressionName ?? @expression)
								.code(`.length, \(@to.value() + 1))`)
						}
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code('.length, ')
							.compile(@to)
							.code(' + 1)')
					}
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
			if @til? {
				if @til is NumberLiteral && @til.value() < 0 {
					fragments
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@til.value() + 1)`)
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@til)
						.code(') - 1')
				}
			}
			else if @to? {
				if @to is NumberLiteral {
					if @to.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(-@to.value())`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length - 1, \(@to.value()))`)
					}
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length - 1, ')
						.compile(@to)
						.code(')')
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
				if @from? {
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
				if @from? {
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
		var mut ctrl

		if @index != null && !@declaration && !@declareIndex {
			var line = fragments
				.newLine()
				.compile(@index)
				.code($equals)

			this.toFromFragments(line)

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

			this.toFromFragments(ctrl)

			ctrl.code($comma)
		}

		if @expressionName? {
			ctrl.code(@expressionName, $equals).compile(@expression).code($comma)
		}

		ctrl.code(@boundName, $equals)

		this.toBoundFragments(ctrl)

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
			if @until? {
				ctrl.code(' && !(').compileBoolean(@until).code(')')
			}
			else if @while? {
				ctrl.code(' && ').wrapBoolean(@while, Mode::None, Junction::AND)
			}
		}

		ctrl.code('; ')

		if @descending || @fromDesc {
			if @data.by? {
				if @data.by.kind == NodeKind::NumericExpression {
					if Math.abs(@data.by.value) == 1 {
						ctrl.code('--').compile(@indexName ?? @index)
					}
					else {
						ctrl.compile(@indexName ?? @index).code(' -= ', Math.abs(@data.by.value))
					}
				}
				else {
					ctrl.compile(@indexName ?? @index).code(' -= ').compile(@byName ?? @by)
				}
			}
			else {
				ctrl.code('--').compile(@indexName ?? @index)
			}
		}
		else {
			if @data.by? {
				if @data.by.kind == NodeKind::NumericExpression {
					if Math.abs(@data.by.value) == 1 {
						ctrl.code('++').compile(@indexName ?? @index)
					}
					else {
						ctrl.compile(@indexName ?? @index).code(' += ', Math.abs(@data.by.value))
					}
				}
				else {
					ctrl.compile(@indexName ?? @index).code(' += ').compile(@byName ?? @by)
				}
			}
			else {
				ctrl.code('++').compile(@indexName ?? @index)
			}
		}

		ctrl.code(')').step()

		if @value? {
			var line = ctrl.newLine()

			@value.toAssignmentFragments(line, @bindingValue)

			line.done()

			if @useBreak {
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
			}
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
	} # }}}
}
