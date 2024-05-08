class ArrayIteration extends IterationNode {
	private late {
		@ascending: Boolean					= true
		@bindingValue						= null
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declaredVariables: Array			= []
		@declareIndex: Boolean				= false
		@declareValue: Boolean				= false
		@expression
		@expressionName: String
		@from
		@fromAssert: Boolean				= false
		@fromBallpark: Boolean
		@fromName: String
		@immutable: Boolean					= true
		@index								= null
		@indexName: String
		@loopKind: LoopKind					= .Unknown
		@loopTempVariables: Array			= []
		@nullable: Boolean					= false
		@order: OrderKind					= .None
		@split
		@splitName: String
		@step
		@stepAssert: Boolean				= false
		@stepName: String
		@to
		@toAssert: Boolean					= false
		@toBallpark: Boolean
		@toName: String
		@unknownIndex: String
		@unknownTranslator: String
		@until
		@useBreak: Boolean					= false
		@value								= null
		@when
		@while
	}
	override analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType.InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)

		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.Ascending {
					@order = OrderKind.Ascending
				}
				ModifierKind.Declarative {
					@declaration = true
				}
				ModifierKind.Descending {
					@order = OrderKind.Descending
					@ascending = false
				}
				ModifierKind.Mutable {
					@immutable = false
				}
			}
		}

		var overwrite = @declaration && @hasAttribute('overwrite')

		if ?@data.index {
			if @declaration {
				@bindingScope.define(@data.index.name, @immutable, @bindingScope.reference('Number'), true, overwrite, this)

				@declareIndex = true
			}
			else {
				@bindingScope.checkVariable(@data.index.name, true, this)
			}

			@index = $compile.expression(@data.index, this, @bindingScope)
			@index.analyse()
		}

		if ?@data.value {
			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.setAssignment(AssignmentType.Expression)
			@value.analyse()

			for var { name } in @value.listAssignments([]) {
				if @declaration {
					@declareValue = true

					@declaredVariables.push(@bindingScope.define(name, @immutable, AnyType.NullableUnexplicit, true, overwrite, this))
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

		if ?@data.from {
			@from = $compile.expression(@data.from, this, @scope)
			@from.analyse()

			@checkForRenamedVariables(@from, variables)

			@fromBallpark = $ast.hasModifier(@data.from, ModifierKind.Ballpark)
		}

		if ?@data.to {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			@checkForRenamedVariables(@to, variables)

			@toBallpark = $ast.hasModifier(@data.to, ModifierKind.Ballpark)
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

	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression
			..unflagAssertable()
			..prepare(@scope.reference('Array').setNullable(true))

		var type = @expression.type()

		unless type.isAny() || type.isArray() {
			TypeException.throwInvalidForInExpression(this)
		}

		@nullable = type.isNullable()

		if ?@value {
			var parameterType = if ?@split set Type.arrayOf(type.parameter(), @scope) else type.parameter()
			var valueType = Type.fromAST(@data.type, this)

			unless parameterType.isAssignableToVariable(valueType, true, true, false) {
				TypeException.throwInvalidAssignment(@value, valueType, parameterType, this)
			}

			var realType = valueType.merge(parameterType, null, null, false, this)

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
			else if @value is ArrayBinding | ObjectBinding {
				@value.type(realType)
			}
			else {
				for var { name } in @value.listAssignments([]) {
					@bindingScope.replaceVariable(name, realType.getProperty(name), this)
				}
			}

			@value.prepare()
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
				@loopKind = LoopKind.Static

				if @order == OrderKind.None {
					if ?@step {
						if @step.value() == 0 {
							SyntaxException.throwForBadStep('for/in', this)
						}
						else if validate {
							if @step.value() > 0 {
								unless if @fromBallpark || @toBallpark set @from.value() < @to.value() else @from.value() <= @to.value() {
									SyntaxException.throwForNoMatch('for/in', this)
								}
							}
							else {
								unless if @fromBallpark || @toBallpark set @from.value() > @to.value() else @from.value() >= @to.value() {
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
						@ascending = @order == OrderKind.Ascending
					}
					else if @order == OrderKind.Ascending {
						unless if @fromBallpark || @toBallpark set @from.value() < @to.value() else @from.value() <= @to.value() {
							SyntaxException.throwForNoMatch('for/in', this)
						}
					}
					else {
						unless if @fromBallpark || @toBallpark set @from.value() > @to.value() else @from.value() >= @to.value() {
							SyntaxException.throwForNoMatch('for/in', this)
						}

						@ascending = false
					}
				}
			}
			else {
				if @order != OrderKind.None {
					@loopKind = LoopKind.Ordered
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

			if @loopKind != LoopKind.Unknown {
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
			if @order != OrderKind.None {
				@loopKind = LoopKind.Ordered
			}

			if ?@step {
				unless @step.type().canBeNumber() {
					TypeException.throwInvalidArgument('for/in', 'step', @scope.reference('Number'), @step.type(), this)
				}

				if @step is NumberLiteral {
					@loopKind = LoopKind.Ordered

					if @order == OrderKind.None {
						if @step.value() == 0 {
							throw NotImplementedException.new()
						}
						else if @step.value() < 0 {
							@ascending = false
						}
					}
					else {
						if @step.value() <= 0 {
							throw NotImplementedException.new()
						}
					}
				}
				else {
					if @loopKind == LoopKind.Unknown || @step.isComposite() {
						@stepName = @scope.acquireTempName()
					}

					@stepAssert = true
				}
			}
			else {
				if !?@to {
					if !?@from {
						@loopKind = LoopKind.Static
					}

					@toBallpark = true
				}
			}
		}

		if @loopKind == LoopKind.Unknown {
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

		@bindingValue = TempMemberExpression.new(@expressionName ?? @expression, @indexName ?? @index, true, this, @bindingScope)

		if ?@value {
			@bindingValue.acquireReusable(@value.isSplitAssignment())
		}

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
	} # }}}
	override translate() { # {{{
		@expression.translate()

		@value?.translate()
		@from?.translate()
		@to?.translate()
		@step?.translate()
		@split?.translate()

		if ?@until {
			@until.translate()
		}
		else if ?@while {
			@while.translate()
		}

		@when?.translate()
	} # }}}
	checkForBreak(expression) { # {{{
		if !@useBreak && @value != null {
			for var { name } in @value.listAssignments([]) until @useBreak {
				if expression.isUsingVariable(name) {
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
			for var { name } in @value.listAssignments([]) {
				if expression.isUsingVariable(name) {
					if @declareValue {
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
				@from?.isUsingVariable(name) ||
				@to?.isUsingVariable(name) ||
				@step?.isUsingVariable(name) ||
				@split?.isUsingVariable(name) ||
				@until?.isUsingVariable(name) ||
				@while?.isUsingVariable(name) ||
				@when?.isUsingVariable(name)
	} # }}}
	override releaseVariables() { # {{{
		if ?@expressionName {
			if @loopKind == LoopKind.Unknown {
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
			if @loopKind == LoopKind.Unknown || @toAssert {
				@scope.releaseTempName(@toName)
			}
			else {
				@bindingScope.releaseTempName(@toName)
			}
		}

		@bindingValue.releaseReusable()
	} # }}}
	toBodyFragments(fragments, elseCtrl?) { # {{{
		if ?@value {
			if !?@split {
				if @value is ArrayBinding | ObjectBinding {
					@value.toAssertFragments(fragments, @bindingValue, false)
				}

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
					var value = if !?@step set @split.value() else Math.max(@step.value(), @split.value())

					line.code(value)
				}
				else {
					line.compile(@splitName ?? @split)
				}

				line.code(')').done()
			}

			if @useBreak {
				if ?@until {
					@parent.toDeclarationFragments(@loopTempVariables, fragments)

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
					@parent.toDeclarationFragments(@loopTempVariables, fragments)

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
			@parent.toDeclarationFragments(@conditionalTempVariables, fragments)

			var ctrl = fragments
				.newControl()
				.code('if(')
				.compileCondition(@when)
				.code(')')
				.step()

			return {
				fragments: ctrl
				close: () => {
					ctrl.done()

					return @close(fragments, elseCtrl)
				}
			}
		}
		else {
			return {
				fragments
				close: () => @close(fragments, elseCtrl)
			}
		}
	} # }}}
	toBoundFragments(fragments) { # {{{
		if @to is NumberLiteral {
			var value = @to.value()

			if value >= 0 {
				if @ascending {
					if @nullable {
						fragments
							.code('Math.min(')
							.code(`\($runtime.helper(this)).length(`)
							.compile(@expressionName ?? @expression)
							.code(`)\(if @toBallpark set '' else ' - 1'), \(value))`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length\(if @toBallpark set '' else ' - 1'), \(value))`)
					}
				}
				else {
					fragments.code(value)
				}
			}
			else {
				if @nullable {
					fragments
						.code(`\($runtime.helper(this)).length(`)
						.compile(@expressionName ?? @expression)
						.code(`) - \(-value)`)
				}
				else {
					fragments
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-value)`)
				}
			}
		}
		else if ?@to {
			fragments.compile(@to)
		}
		else {
			if @ascending {
				if @nullable {
					fragments
						.code(`\($runtime.helper(this)).length(`)
						.compile(@expressionName ?? @expression)
						.code(`)`)
				}
				else {
					fragments
						.compile(@expressionName ?? @expression)
						.code('.length')
				}
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
					fragments.code(if @fromBallpark set value + 1 else value)
				}
				else {
					if @nullable {
						fragments
							.code('Math.min(')
							.code(`\($runtime.helper(this)).length(`)
							.compile(@expressionName ?? @expression)
							.code(`) - 1, \(if @fromBallpark set value - 1 else value))`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length - 1, \(if @fromBallpark set value - 1 else value))`)
					}
				}
			}
			else {
				if @nullable {
					fragments
						.code('Math.max(0, ')
						.code(`\($runtime.helper(this)).length(`)
						.compile(@expressionName ?? @expression)
						.code(`) - \(if @fromBallpark set 1 - value else -value))`)
				}
				else {
					fragments
						.code('Math.max(0, ')
						.compile(@expressionName ?? @expression)
						.code(`.length - \(if @fromBallpark set 1 - value else -value))`)
				}
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
				if @nullable {
					fragments
						.code(`\($runtime.helper(this)).length(`)
						.compile(@expressionName ?? @expression)
						.code(`) - 1`)
				}
				else {
					fragments
						.compile(@expressionName ?? @expression)
						.code(`.length - 1`)
				}
			}
		}
	} # }}}
	override toIterationFragments(fragments) { # {{{
		if @loopKind == LoopKind.Unknown {
			return @toUnknownFragments(fragments)
		}
		else if @loopKind == LoopKind.Static {
			return @toStaticFragments(fragments)
		}
		else {
			return @toOrderedFragments(fragments)
		}
	} # }}}
	toOrderedFragments(fragments) { # {{{
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
					.code(`\($runtime.helper(this)).assertLoopBoundsEdge(\(@step.toQuote(true)), `)
					.compile(@stepName ?? @step)
					.code(`, \(if @order != OrderKind.None || @ascending set 2 else 1))`)
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

				var line = fragments.newLine().code(`\($runtime.helper(this)).assertLoopBounds(1`)

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
			comparator = if @ascending set ' < ' else ' > '
		}
		else {
			comparator = if @ascending set ' <= ' else ' >= '
		}

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments
				.newControl()
				.code(`if(\(@fromName)\(if @fromBallpark set ` + \(@stepName)` else '') \(comparator) \(@toName))`)
				.step()

			if @elseTest == .Setter {
				elseCtrl.line(`\(@parent.getElseName()) = false`)
			}
		}

		var ctrl = (elseCtrl ?? fragments)
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
				ctrl.code(' && ').wrapCondition(@while, Mode.None, Junction.AND)
			}
		}

		ctrl.code('; ')

		@toStepFragments(ctrl)

		ctrl.code(')').step()

		return @toBodyFragments(ctrl, elseCtrl)
	} # }}}
	toStaticFragments(fragments) { # {{{
		var comparator = if @toBallpark {
			set if @ascending set ' < ' else ' > '
		}
		else {
			set if @ascending set ' <= ' else ' >= '
		}

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments.newControl().code(`if(`)

			@toFromFragments(elseCtrl)

			elseCtrl.code(comparator)

			@toBoundFragments(elseCtrl)

			elseCtrl.code(`)`).step()

			if @elseTest == .Setter {
				elseCtrl.line(`\(@parent.getElseName()) = false`)
			}
		}

		var declareIndex = !?@index || @declaration || @declareIndex

		if !declareIndex {
			var line = (elseCtrl ?? fragments).newLine()

			line.compile(@index).code($equals)

			@toFromFragments(line)

			line.done()
		}

		var ctrl = (elseCtrl ?? fragments).newControl().code('for(')

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
				ctrl.code(' && ').wrapCondition(@while, Mode.None, Junction.AND)
			}
		}

		ctrl.code('; ')

		@toStepFragments(ctrl)

		ctrl.code(')').step()

		return @toBodyFragments(ctrl, elseCtrl)
	} # }}}
	toStepFragments(fragments) { # {{{
		if ?@step {
			if @step is NumberLiteral && (!?@split || @split is NumberLiteral) {
				var value = if !?@split set @step.value() else Math.max(@step.value(), @split.value())

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
	toUnknownFragments(fragments) { # {{{
		var comparator = if @toBallpark set '<' else '<='

		if ?@expressionName {
			fragments.newLine().code(@expressionName, $equals).compile(@expression).done()
		}

		fragments
			.newLine()
			.code(`[\(@fromName), \(@toName), \(@stepName), \(@unknownTranslator)] = \($runtime.helper(this)).assertLoopBounds(0, \(if @fromAssert set @from.toQuote(true) else '""'), `)
			.compile(@from ?? 0)
			.code(`, \(if @toAssert set @to.toQuote(true) else '""'), `)
			.compile(@to ?? 'Infinity')
			.code(`, `)
			.compile(@expressionName ?? @expression)
			.code(`.length\(if @toBallpark set '' else ' - 1')`)
			.code(`, \(if @stepAssert set @step.toQuote(true) else '""'), `)
			.compile(@step ?? 1)
			.code(')')
			.done()

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments
				.newControl()
				.code(`if(\(@fromName)\(if @fromBallpark set ` + \(@stepName)` else '') \(comparator) \(@toName))`)
				.step()

			if @elseTest == .Setter {
				elseCtrl.line(`\(@parent.getElseName()) = false`)
			}
		}

		var ctrl = (elseCtrl ?? fragments)
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

		return @toBodyFragments(ctrl, elseCtrl)
	} # }}}
}
