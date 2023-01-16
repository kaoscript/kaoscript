class ForInStatement extends Statement {
	private late {
		@ascending: Boolean					= true
		@bindingScope: Scope
		@bindingValue						= null
		@body
		@bodyScope: Scope
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declared: Boolean					= false
		@declaredVariables: Array			= []
		@declareIndex: Boolean				= false
		@declareValue: Boolean				= false
		@else
		@elseScope
		@expression
		@expressionName: String
		@from
		@fromAssert: Boolean				= false
		@fromBallpark: Boolean
		@fromName: String
		@immutable: Boolean					= false
		@index								= null
		@indexName: String
		@loopKind: LoopKind					= LoopKind::Unknown
		@loopTempVariables: Array			= []
		@order: OrderKind					= OrderKind::None
		@split
		@splitAssert: Boolean				= false
		@splitName: String
		@step
		@stepAssert: Boolean				= false
		@stepName: String
		@to
		@toAssert: Boolean					= false
		@toBallpark: Boolean
		@toName: String
		@until
		@unknownIndex: String
		@unknownTranslator: String
		@useBreak: Boolean					= false
		@value								= null
		@when
		@while
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Ascending {
				@order = OrderKind::Ascending
			}
			else if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Descending {
				@order = OrderKind::Descending
				@ascending = false
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		if ?@data.index {
			var variable = @bindingScope.getVariable(@data.index.name)

			if @declaration || !?variable {
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

				if @declaration || !?variable {
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

			@fromBallpark = $ast.hasModifier(@data.from, ModifierKind::Ballpark)
		}

		if ?@data.to {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			@checkForRenamedVariables(@to, variables)

			@toBallpark = $ast.hasModifier(@data.to, ModifierKind::Ballpark)
		}

		if ?@data.step {
			@step = $compile.expression(@data.step, this, @scope)
			@step.analyse()

			@checkForRenamedVariables(@step, variables)
		}

		if ?@data.split {
			@split = $compile.expression(@data.split, this, @scope)
			@split.analyse()

			@checkForRenamedVariables(@split, variables)
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

		if ?@data.else {
			@elseScope = @newScope(@scope!?, ScopeType::InlineBlock)

			@else = $compile.block(@data.else, this, @elseScope)
			@else.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(@scope.reference('Array'))

		var type = @expression.type()
		if !(type.isAny() || type.isArray()) {
			TypeException.throwInvalidForInExpression(this)
		}

		if ?@value {
			var parameterType = ?@split ? Type.arrayOf(type.parameter(), @scope) : type.parameter()
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
			else if ?@split {
				for var element, index in @value.elements() {
					element.type(realType.getProperty(index))
				}
			}
			else {
				for var name in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}
		}

		if ?@from {
			@from.prepare(@scope.reference('Number'))
		}

		if ?@to {
			@to.prepare(@scope.reference('Number'))
		}

		if ?@step {
			@step.prepare(@scope.reference('Number'))
		}

		if ?@split {
			@split.prepare(@scope.reference('Number'))

			if @split is NumberLiteral {
				unless @split.value() > 0 {
					SyntaxException.throwForBadSplit('for/in', this)
				}

				if @step is NumberLiteral {
					unless @step.value() >= @split.value() {
						SyntaxException.throwForStepLtSplit('for/in', this)
					}
				}
			}
			else {
				unless !?@value || @value is not ArrayBinding {
					SyntaxException.throwForUndeterminedSplit('for/in', this)
				}
			}
		}

		if (!?@from || @from is NumberLiteral) && (!?@to || @to is NumberLiteral) {
			var validate = @from is NumberLiteral && @to is NumberLiteral

			if !?@step || @step is NumberLiteral {
				@loopKind = LoopKind::Static

				if @order == OrderKind::None {
					if ?@step {
						if @step.value() == 0 {
							SyntaxException.throwForBadStep('for/in', this)
						}
						else if validate {
							if @step.value() > 0 {
								unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
									SyntaxException.throwForNoMatch('for/in', this)
								}
							}
							else {
								unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
									SyntaxException.throwForNoMatch('for/in', this)
								}

								@ascending = false
							}
						}
						else {
							if @step.value() < 0 {
								@ascending = false
							}
						}
					}
					else {
						if !validate {
							pass
						}
						else if @from.value() >= 0 {
							if @to.value() >= 0 {
								@ascending = @from.value() < @to.value()
							}
						}
						else {
							if @to.value() < 0 {
								@ascending = @from.value() < @to.value()
							}
						}
					}
				}
				else {
					if @step?.value() <= 0 {
						SyntaxException.throwForBadStep('for/in', this)
					}

					if !validate {
						@ascending = @order == OrderKind::Ascending
					}
					else if @order == OrderKind::Ascending {
						unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
							SyntaxException.throwForNoMatch('for/in', this)
						}
					}
					else {
						unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
							SyntaxException.throwForNoMatch('for/in', this)
						}

						@ascending = false
					}
				}
			}
			else {
				if @order != OrderKind::None {
					@loopKind = LoopKind::Ordered
				}

				if !validate {
					pass
				}
				else if @from.value() >= 0 {
					if @to.value() >= 0 {
						@ascending = @from.value() < @to.value()
					}
				}
				else {
					if @to.value() < 0 {
						@ascending = @from.value() < @to.value()
					}
				}

				@stepAssert = true
			}

			if @loopKind != LoopKind::Unknown {
				if !?@to {
					@toName = @bindingScope.acquireTempName(false)
					@toBallpark = @ascending
				}
				else if @ascending || @to.value() < 0 {
					@toName = @bindingScope.acquireTempName(false)
				}

				if @step?.isComposite() {
					@stepName = @bindingScope.acquireTempName()
				}
			}
		}
		else {
			if @order != OrderKind::None {
				@loopKind = LoopKind::Ordered
			}

			if ?@step {
				unless @step.type().canBeNumber() {
					TypeException.throwInvalidArgument('for/in', 'step', @scope.reference('Number'), @step.type(), this)
				}

				if @step is NumberLiteral {
					@loopKind = LoopKind::Ordered

					if @order == OrderKind::None {
						if @step.value() == 0 {
							throw new NotImplementedException()
						}
						else if @step.value() < 0 {
							@ascending = false
						}
					}
					else {
						if @step.value() <= 0 {
							throw new NotImplementedException()
						}
					}
				}
				else {
					if @loopKind == LoopKind::Unknown || @step.isComposite() {
						@stepName = @scope.acquireTempName()
					}

					@stepAssert = true
				}
			}
			else {
				if !?@to {
					if !?@from {
						@loopKind = LoopKind::Static
					}

					@toBallpark = true
				}
			}
		}

		if @loopKind == LoopKind::Unknown {
			if @expression.isLooseComposite() {
				@expressionName = @scope.acquireTempName()
			}

			@fromName ??= @scope.acquireTempName()
			@toName ??= @scope.acquireTempName()
			@stepName ??= @scope.acquireTempName()
			@unknownTranslator = @scope.acquireTempName()
			@unknownIndex = @bindingScope.acquireTempName(false)
		}

		if ?@index {
			unless @declareIndex {
				@bindingScope.replaceVariable(@data.index.name, @bindingScope.reference('Number'), this)
			}

			@index.prepare(@scope.reference('Number'))
		}
		else {
			@indexName = @bindingScope.acquireTempName(false)
		}

		if @expression.isLooseComposite() {
			@expressionName ??= @bindingScope.acquireTempName(false)
		}

		if ?@split && @split is not NumberLiteral {
			@splitName = @bindingScope.acquireTempName(false)
		}

		@bindingValue = new TempMemberExpression(@expressionName ?? @expression, @indexName ?? @index, true, this, @bindingScope)

		@assignTempVariables(@scope!?)
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

		@else?.prepare(target)

		if ?@expressionName {
			if @loopKind == LoopKind::Unknown {
				@scope.releaseTempName(@expressionName)
			}
			else {
				@bindingScope.releaseTempName(@expressionName)
			}
		}

		@bindingScope.releaseTempName(@indexName) if ?@indexName
		@bindingScope.releaseTempName(@splitName) if ?@splitName

		@scope.releaseTempName(@fromName) if ?@fromName
		@scope.releaseTempName(@stepName) if ?@stepName
		@scope.releaseTempName(@unknownTranslator) if ?@unknownTranslator

		if ?@toName {
			if @loopKind == LoopKind::Unknown || @toAssert {
				@scope.releaseTempName(@toName)
			}
			else {
				@bindingScope.releaseTempName(@toName)
			}
		}

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
		@split.translate() if ?@split

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

		@else?.translate()
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
		||	@split?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
		||	@else?.isUsingVariable(name)
	# }}}
	toBodyFragments(fragments) { # {{{
		if ?@value {
			if !?@split {
				var line = fragments.newLine()

				@value.toAssignmentFragments(line, @bindingValue)

				line.done()
			}
			else if @value is ArrayBinding {
				for var element, index in @value.elements() {
					var line = fragments.newLine()

					@bindingValue.offset(index)

					element.toAssignmentFragments(line, @bindingValue)

					line.done()
				}
			}
			else {
				var line = fragments
					.newLine()
					.compile(@value)
					.code($equals)
					.compile(@expressionName ?? @expression)
					.code(`.slice(`)
					.compile(@indexName ?? @index)
					.code($comma)
					.compile(@indexName ?? @index)
					.code(` + `)

				if @split is NumberLiteral && (!?@step || @step is NumberLiteral) {
					var value = !?@step ? @split.value() : Math.max(@step.value(), @split.value())

					line.code(value)
				}
				else {
					line.compile(@splitName ?? @split)
				}

				line.code(')').done()
			}

			if @useBreak {
				if ?@until {
					@toDeclarationFragments(@loopTempVariables, fragments)

					fragments
						.newControl()
						.code('if(')
						.compileCondition(@until)
						.code(')')
						.step()
						.line('break')
						.done()
				}
				else if ?@while {
					@toDeclarationFragments(@loopTempVariables, fragments)

					fragments
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
			@toDeclarationFragments(@conditionalTempVariables, fragments)

			fragments
				.newControl()
				.code('if(')
				.compileCondition(@when)
				.code(')')
				.step()
				.compile(@body)
				.done()
		}
		else {
			fragments.compile(@body)
		}
	} # }}}
	toBoundFragments(fragments) { # {{{
		if @to is NumberLiteral {
			var value = @to.value()

			if value >= 0 {
				if @ascending {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code(`.length\(@toBallpark ? '' : ' - 1'), \(value))`)
				}
				else {
					fragments.code(value)
				}
			}
			else {
				fragments
					.compile(@expressionName ?? @expression)
					.code(`.length - \(-value)`)
			}
		}
		else if ?@to {
			fragments.compile(@to)
		}
		else {
			if @ascending {
				fragments
					.compile(@expressionName ?? @expression)
					.code('.length')
			}
			else {
				fragments.code('0')
			}
		}
	} # }}}
	toFromFragments(fragments) { # {{{
		if @from is NumberLiteral {
			var value = @from.value()

			if value >= 0 {
				if @ascending {
					fragments.code(@fromBallpark ? value + 1 : value)
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code(`.length - 1, \(@fromBallpark ? value - 1 : value))`)
				}
			}
			else {
				fragments
					.code('Math.max(0, ')
					.compile(@expressionName ?? @expression)
					.code(`.length - \(@fromBallpark ? 1 - value : -value))`)
			}
		}
		else if ?@from {
			fragments.compile(@from)
		}
		else {
			if @ascending {
				fragments.code('0')
			}
			else {
				fragments
					.compile(@expressionName ?? @expression)
					.code(`.length - 1`)
			}
		}
	} # }}}
	toOrderedFragments(fragments, mode) { # {{{
		var mut toDecl = !?@toName
		var mut stepDecl = !?@stepName

		var assert = @fromAssert || @toAssert || @stepAssert

		if assert {
			if !@fromAssert && !@toAssert && @stepAssert {
				if ?@stepName {
					fragments.newLine().compile(@stepName).code($equals).compile(@step).done()

					stepDecl = true
				}

				fragments
					.newLine()
					.code(`\($runtime.helper(this)).assertNumber(\(@step.toQuote(true)), `)
					.compile(@stepName ?? @step)
					.code(`, \(@order != OrderKind::None || @ascending ? 2 : 1))`)
					.done()
			}
			else {
				if ?@fromName {
					fragments.newLine().compile(@fromName).code($equals).compile(@from).done()
				}

				if ?@toName {
					fragments.newLine().compile(@toName).code($equals).compile(@to).done()

					toDecl = true
				}

				if ?@stepName {
					fragments.newLine().compile(@stepName).code($equals).compile(@step).done()

					stepDecl = true
				}

				var line = fragments.newLine().code(`\($runtime.helper(this)).assertLoop(1`)

				if @fromAssert {
					line.code(`, \(@from.toQuote(true)), `).compile(@fromName ?? @from)
				}
				else {
					line.code(`, "", 0`)
				}

				if @toAssert {
					line.code(`, \(@to.toQuote(true)), `).compile(@toName ?? @to).code(`, 0`)
				}
				else {
					line.code(`, "", 0, 0`)
				}

				if @stepAssert {
					line.code(`, \(@step.toQuote(true)), `).compile(@stepName ?? @step)
				}
				else {
					line.code(`, "", 0`)
				}

				line.code(')').done()
			}
		}

		var late comparator: String
		if @toBallpark {
			comparator = @ascending ? ' < ' : ' > '
		}
		else {
			comparator = @ascending ? ' <= ' : ' >= '
		}

		var mut ifCtrl = null
		if ?@else {
			ifCtrl = fragments
				.newControl()
				.code(`if(\(@fromName)\(@fromBallpark ? ` + \(@stepName)` : '') \(comparator) \(@toName))`)
				.step()
		}

		var ctrl = (ifCtrl ?? fragments)
			.newControl()
			.code('for(')

		if @declareIndex {
			ctrl.code($runtime.scope(this))
		}

		if ?@expressionName {
			ctrl.code(@expressionName, $equals).compile(@expression).code($comma)
		}

		ctrl.compile(@indexName ?? @index).code($equals)

		@toFromFragments(ctrl)

		if ?@toName {
			ctrl.code($comma).code(@toName, $equals)

			@toBoundFragments(ctrl)
		}

		if @declareValue {
			for var variable in @declaredVariables {
				ctrl.code($comma).compile(variable)
			}
		}

		ctrl.code('; ').compile(@indexName ?? @index).code(comparator)

		if ?@toName {
			ctrl.code(@toName)
		}
		else {
			@toBoundFragments(ctrl)
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

		@toStepFragments(ctrl)

		ctrl.code(')').step()

		@toBodyFragments(ctrl)

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
	toStatementFragments(fragments, mode) { # {{{
		if @loopKind == LoopKind::Unknown {
			@toUnknownFragments(fragments, mode)
		}
		else if @loopKind == LoopKind::Static {
			@toStaticFragments(fragments, mode)
		}
		else {
			@toOrderedFragments(fragments, mode)
		}
	} # }}}
	toStaticFragments(fragments, mode) { # {{{
		var late comparator: String
		if @toBallpark {
			comparator = @ascending ? ' < ' : ' > '
		}
		else {
			comparator = @ascending ? ' <= ' : ' >= '
		}

		var mut ifCtrl = null
		if ?@else {
			ifCtrl = fragments.newControl().code(`if(`)

			@toFromFragments(ifCtrl)

			ifCtrl.code(comparator)

			@toBoundFragments(ifCtrl)

			ifCtrl.code(`)`).step()
		}

		var declareIndex = !?@index || @declaration || @declareIndex

		if !declareIndex {
			var line = (ifCtrl ?? fragments).newLine()

			line.compile(@index).code($equals)

			@toFromFragments(line)

			line.done()
		}

		var ctrl = (ifCtrl ?? fragments).newControl().code('for(')

		if @declaration || @declareIndex || @declareValue || ?@indexName || ?@toName || ?@splitName || ?@expressionName {
			ctrl.code($runtime.scope(this))
		}

		var mut comma = false

		if ?@expressionName {
			ctrl.code(@expressionName, $equals).compile(@expression)

			comma = true
		}

		if declareIndex {
			ctrl.code($comma) if comma

			ctrl.compile(@indexName ?? @index).code($equals)

			@toFromFragments(ctrl)

			comma = true
		}

		if ?@toName {
			ctrl.code($comma) if comma

			ctrl.code(@toName, $equals)

			@toBoundFragments(ctrl)

			comma = true
		}

		if ?@splitName {
			ctrl.code($comma) if comma

			ctrl.code(`\(@splitName) = \($runtime.helper(this)).assertSplit(\(@split.toQuote(true)), `).compile(@split).code($comma).compile(@stepName ?? @step ?? 1).code(')')

			comma = true
		}

		if @declareValue {
			for var variable in @declaredVariables {
				ctrl.code($comma) if comma

				ctrl.compile(variable)

				comma = true
			}
		}

		ctrl.code('; ').compile(@indexName ?? @index).code(comparator)

		if ?@toName {
			ctrl.code(@toName)
		}
		else {
			@toBoundFragments(ctrl)
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

		@toStepFragments(ctrl)

		ctrl.code(')').step()

		@toBodyFragments(ctrl)

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
	toStepFragments(fragments) { # {{{
		if ?@step {
			if @step is NumberLiteral && (!?@split || @split is NumberLiteral) {
				var value = !?@split ? @step.value() : Math.max(@step.value(), @split.value())

				if value == 1 {
					fragments.code('++').compile(@indexName ?? @index)
				}
				else if value == -1 {
					fragments.code('--').compile(@indexName ?? @index)
				}
				else if value >= 0 {
					fragments.compile(@indexName ?? @index).code(' += ', value)
				}
				else {
					fragments.compile(@indexName ?? @index).code(' -= ', -value)
				}
			}
			else {
				fragments.compile(@indexName ?? @index).code(' += ').compile(@stepName ?? @step)
			}
		}
		else {
			if !?@split || (@split is NumberLiteral && @split.value() == 1) {
				if @ascending {
					fragments.code('++').compile(@indexName ?? @index)
				}
				else {
					fragments.code('--').compile(@indexName ?? @index)
				}
			}
			else if @split is NumberLiteral {
				var value = @split.value()

				if value >= 0 {
					fragments.compile(@indexName ?? @index).code(' += ', value)
				}
				else {
					fragments.compile(@indexName ?? @index).code(' -= ', -value)
				}
			}
			else {
				fragments.compile(@indexName ?? @index).code(' += ').compile(@splitName ?? @split)
			}
		}
	} # }}}
	toUnknownFragments(fragments, mode) { # {{{
		var comparator = @toBallpark ? '<' : '<='

		if ?@expressionName {
			fragments.newLine().code(@expressionName, $equals).compile(@expression).done()
		}

		fragments
			.newLine()
			.code(`[\(@fromName), \(@toName), \(@stepName), \(@unknownTranslator)] = \($runtime.helper(this)).assertLoop(0, \(@fromAssert ? @from.toQuote(true) : '""'), `)
			.compile(@from ?? 0)
			.code(`, \(@toAssert ? @to.toQuote(true) : '""'), `)
			.compile(@to ?? 'Infinity')
			.code(`, `)
			.compile(@expressionName ?? @expression)
			.code(`.length\(@toBallpark ? '' : ' - 1')`)
			.code(`, \(@stepAssert ? @step.toQuote(true) : '""'), `)
			.compile(@step ?? 1)
			.code(')')
			.done()

		var mut ifCtrl = null
		if ?@else {
			ifCtrl = fragments
				.newControl()
				.code(`if(\(@fromName)\(@fromBallpark ? ` + \(@stepName)` : '') \(comparator) \(@toName))`)
				.step()
		}

		var ctrl = (ifCtrl ?? fragments)
			.newControl()
			.code('for(let ')
			.code(`\(@unknownIndex) = \(@fromName)`)

		if @fromBallpark {
			ctrl.code(` + \(@stepName)`)
		}

		if @declareIndex {
			ctrl.code($comma).compile(@index)
		}
		else if ?@indexName {
			ctrl.code($comma, @indexName)
		}

		if @declareValue {
			for var variable in @declaredVariables {
				ctrl.code($comma).compile(variable)
			}
		}

		ctrl
			.code('; ')
			.code(`\(@unknownIndex) \(comparator) \(@toName)`)
			.code('; ')
			.code(`\(@unknownIndex) += \(@stepName)`)
			.code(')')
			.step()

		ctrl.newLine().compile(@indexName ?? @index).code(` = \(@unknownTranslator)(\(@unknownIndex))`).done()

		@toBodyFragments(ctrl)

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
