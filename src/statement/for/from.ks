class FromIteration extends IterationNode {
	private late {
		@ascending: Boolean					= true
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declared: Boolean					= false
		@from
		@fromAssert: Boolean				= false
		@fromBallpark: Boolean
		@fromName: String
		@immutable: Boolean					= true
		@loopKind: LoopKind					= .Unknown
		@order: OrderKind					= .None
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
		@variable
		@when
		@while
	}
	override analyse() { # {{{
		var mut rename = false
		var variable = @scope.getVariable(@data.variable.name)

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

		@declared = @declaration || variable == null

		if @declared {
			@bindingScope = @newScope(@scope!?, ScopeType.InlineBlock)
		}
		else {
			@bindingScope = @scope!?
		}

		@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)

		@from = $compile.expression(@data.from, this, @scope)
		@from.analyse()

		@fromBallpark = $ast.hasModifier(@data.from, ModifierKind.Ballpark)

		if @from.isUsingVariable(@data.variable.name) {
			if @declared {
				rename = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
			}
		}

		@to = $compile.expression(@data.to, this, @scope)
		@to.analyse()

		@toBallpark = $ast.hasModifier(@data.to, ModifierKind.Ballpark)

		if @to.isUsingVariable(@data.variable.name) {
			if @declared {
				rename = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
			}
		}

		if ?@data.step {
			@step = $compile.expression(@data.step, this, @scope)
			@step.analyse()

			if @step.isUsingVariable(@data.variable.name) {
				if @declared {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @declared {
			@bindingScope.define(@data.variable.name, @immutable, @bindingScope.reference('Number'), true, this)

			if rename {
				@bindingScope.rename(@data.variable.name)
			}
		}
		else {
			@bindingScope.checkVariable(@data.variable.name, true, this)
		}

		@variable = $compile.expression(@data.variable, this, @bindingScope)
		@variable.analyse()

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
		unless @declared {
			@bindingScope.replaceVariable(@data.variable.name, @bindingScope.reference('Number'), this)
		}

		@variable.prepare()

		@from.prepare(@scope.reference('Number'), TargetMode.Permissive)
		@to.prepare(@scope.reference('Number'), TargetMode.Permissive)
		@step?.prepare(@scope.reference('Number'), TargetMode.Permissive)

		if @from is NumberLiteral && @to is NumberLiteral {
			if @hasElse() {
				SyntaxException.throwForDeadElse('for/from', this)
			}

			if !?@step || @step is NumberLiteral {
				@loopKind = LoopKind.Static

				if @order == OrderKind.None {
					if ?@step {
						if @step.value() == 0 {
							SyntaxException.throwForBadStep('for/from', this)
						}
						else if @step.value() > 0 {
							unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
								SyntaxException.throwForNoMatch('for/from', this)
							}
						}
						else {
							unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
								SyntaxException.throwForNoMatch('for/from', this)
							}

							@ascending = false
						}
					}
					else {
						if @from.value() > @to.value() {
							@ascending = false
						}
					}
				}
				else {
					if @step?.value() <= 0 {
						SyntaxException.throwForBadStep('for/from', this)
					}

					if @order == OrderKind.Ascending {
						unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
							SyntaxException.throwForNoMatch('for/from', this)
						}
					}
					else {
						unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
							SyntaxException.throwForNoMatch('for/from', this)
						}

						@ascending = false
					}
				}
			}
			else {
				@loopKind = LoopKind.Ordered

				if @from.value() > @to.value() {
					@ascending = false
				}

				if @step.isComposite() {
					@stepName = @bindingScope.acquireTempName()
				}

				@stepAssert = true
			}
		}
		else {
			if @order != OrderKind.None {
				@loopKind = LoopKind.Ordered
			}

			if ?@step {
				unless @step.type().canBeNumber() {
					TypeException.throwInvalidArgument('for/from', 'step', @scope.reference('Number'), @step.type(), this)
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

			unless @from.type().canBeNumber() {
				TypeException.throwInvalidArgument('for/from', 'from', @scope.reference('Number'), @from.type(), this)
			}

			if !@from.type().isNumber() {
				@fromAssert = true
			}

			if @loopKind == LoopKind.Unknown || (@fromAssert && @from.isLooseComposite()) {
				@fromName = @scope.acquireTempName()
			}

			unless @to.type().canBeNumber() {
				TypeException.throwInvalidArgument('for/from', 'to', @scope.reference('Number'), @to.type(), this)
			}

			if !@to.type().isNumber() {
				@toAssert = true
			}

			if @loopKind == LoopKind.Unknown || (@toAssert && @to.isLooseComposite()) {
				@toName = @scope.acquireTempName()
			}
			else if @to.isLooseComposite() {
				@toName = @bindingScope.acquireTempName()
			}

			if @loopKind == LoopKind.Unknown {
				@stepName ??= @scope.acquireTempName()
				@unknownTranslator = @scope.acquireTempName()
				@unknownIndex = @bindingScope.acquireTempName(false)
			}
		}

		@assignTempVariables(@scope!?)
		@assignTempVariables(@bindingScope)

		if ?@until {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			@assignTempVariables(@bodyScope)
		}
		else if ?@while {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			@assignTempVariables(@bodyScope)
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}
	} # }}}
	override translate() { # {{{
		@variable.translate()
		@from.translate()
		@to.translate()
		@step?.translate()
		@until?.translate()
		@while?.translate()
		@when?.translate()
	} # }}}
	override releaseVariables() { # {{{
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
	} # }}}
	toBodyFragments(fragments, elseCtrl?) { # {{{
		if ?@data.when {
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
	override toIterationFragments(fragments) { # {{{
		return match @loopKind {
			.Ordered => @toOrderedFragments(fragments)
			.Static => @toStaticFragments(fragments)
			.Unknown => @toUnknownFragments(fragments)
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
					.code(`, \(@order != OrderKind.None || @ascending ? 2 : 1))`)
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
			comparator = @ascending ? ' < ' : ' > '
		}
		else {
			comparator = @ascending ? ' <= ' : ' >= '
		}

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments
				.newControl()
				.code('if(')
				.compile(@fromName ?? @from)

			if @fromBallpark {
				if stepDecl {
					if @step is NumberLiteral {
						if @step.value() > 0 {
							elseCtrl.code(` + \(@step.value())`)
						}
						else {
							elseCtrl.code(` - \(-@step.value())`)
						}
					}
					else if ?@step {
						elseCtrl.code(' + ').compile(@stepName ?? @step)
					}
					else {
						elseCtrl.code(@ascending ? ' + 1' : ' - 1')
					}
				}
				else {
					throw NotImplementedException.new()
				}
			}

			elseCtrl.code(comparator)
				.compile(@toName ?? @to)
				.code(')')
				.step()

			if @elseTest == .Setter {
				elseCtrl.line(`\(@parent.getElseName()) = false`)
			}
		}

		var mut ctrl = (elseCtrl ?? fragments).newControl().code('for(')

		if @declared {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@variable).code($equals).compile(@fromName ?? @from)

		if @fromBallpark {
			if stepDecl {
				if @step is NumberLiteral {
					if @step.value() > 0 {
						ctrl.code(` + \(@step.value())`)
					}
					else {
						ctrl.code(` - \(-@step.value())`)
					}
				}
				else if ?@step {
					ctrl.code(' + ').compile(@stepName ?? @step)
				}
				else {
					ctrl.code(@ascending ? ' + 1' : ' - 1')
				}
			}
			else {
				throw NotImplementedException.new()
			}
		}

		if !toDecl {
			ctrl.code($comma, @toName, $equals).compile(@to)
		}

		if !stepDecl {
			ctrl.code($comma, @stepName, $equals).compile(@step)
		}

		ctrl.code('; ')

		ctrl.compile(@variable).code(comparator).compile(@toName ?? @to)

		if ?@until {
			ctrl.code(' && !(').compileCondition(@until).code(')')
		}
		else if ?@while {
			ctrl.code(' && ').wrapCondition(@while, Mode.None, Junction.AND)
		}

		ctrl.code('; ')

		if ?@step {
			if @data.step.kind == NodeKind.NumericExpression && @data.step.value == 1 {
				ctrl.code(@order == OrderKind.None || @ascending ? '++' : '--').compile(@variable)
			}
			else if @data.step.kind == NodeKind.NumericExpression && @data.step.value == -1 {
				ctrl.code('--').compile(@variable)
			}
			else {
				ctrl.compile(@variable).code(@order == OrderKind.None || @ascending ? ' += ' : ' -= ').compile(@stepName ?? @step)
			}
		}
		else {
			ctrl.code(@ascending ? '++' : '--').compile(@variable)
		}

		ctrl.code(')').step()

		return @toBodyFragments(ctrl, elseCtrl)
	} # }}}
	toStaticFragments(fragments) { # {{{
		var mut ctrl = fragments.newControl().code('for(')

		if @declared {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@variable).code($equals)

		if @fromBallpark {
			if ?@step {
				ctrl.code(@from.value() + @step.value())
			}
			else if @ascending {
				ctrl.code(@from.value() + 1)
			}
			else {
				ctrl.code(@from.value() - 1)
			}
		}
		else {
			ctrl.compile(@from)
		}

		ctrl.code('; ').compile(@variable)

		if @toBallpark {
			ctrl.code(@ascending ? ' < ' : ' > ')
		}
		else {
			ctrl.code(@ascending ? ' <= ' : ' >= ')
		}

		ctrl.compile(@to)

		if ?@until {
			ctrl.code(' && !(').compileCondition(@until).code(')')
		}
		else if ?@while {
			ctrl.code(' && ').wrapCondition(@while, Mode.None, Junction.AND)
		}

		ctrl.code('; ')

		if ?@step {
			if @data.step.value == 1 {
				ctrl.code('++').compile(@variable)
			}
			else if @data.step.value == -1 {
				ctrl.code('--').compile(@variable)
			}
			else if @data.step.value >= 0 {
				ctrl.compile(@variable).code(' += ').compile(@step)
			}
			else {
				ctrl.compile(@variable).code(' -= ', -@data.step.value)
			}
		}
		else if @ascending {
			ctrl.code('++').compile(@variable)
		}
		else {
			ctrl.code('--').compile(@variable)
		}

		ctrl.code(')').step()

		return @toBodyFragments(ctrl, null)
	} # }}}
	toUnknownFragments(fragments) { # {{{
		var comparator = @toBallpark ? '<' : '<='

		fragments
			.newLine()
			.code(`[\(@fromName), \(@toName), \(@stepName), \(@unknownTranslator)] = \($runtime.helper(this)).assertLoopBounds(0, \(@fromAssert ? @from.toQuote(true) : '""'), `)
			.compile(@from)
			.code(`, \(@toAssert ? @to.toQuote(true) : '""'), `)
			.compile(@to)
			.code(`, \(@to is NumberLiteral ? @to.value() : 'Infinity'), \(@stepAssert ? @step.toQuote(true) : '""'), `)
			.compile(@step ?? 1)
			.code(')')
			.done()

		var mut elseCtrl = null
		if @parent.hasElse() {
			elseCtrl = fragments
				.newControl()
				.code(`if(\(@fromName)\(@fromBallpark ? ` + \(@stepName)` : '') \(comparator) \(@toName))`)
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

		if @declared {
			ctrl.code($comma).compile(@variable)
		}

		ctrl
			.code('; ')
			.code(`\(@unknownIndex) \(comparator) \(@toName)`)
			.code('; ')
			.code(`\(@unknownIndex) += \(@stepName)`)
			.code(')')
			.step()

		ctrl.newLine().compile(@variable).code(` = \(@unknownTranslator)(\(@unknownIndex))`).done()

		if ?@until {
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
			ctrl
				.newControl()
				.code('if(!(')
				.compileCondition(@while)
				.code('))')
				.step()
				.line('break')
				.done()
		}

		return @toBodyFragments(ctrl, elseCtrl)
	} # }}}
}
