enum OrderKind {
	Ascending
	Descending
	None
}

enum LoopKind {
	Ordered
	Static
	Unknown
}

class ForFromStatement extends Statement {
	private late {
		@ascending: Boolean					= true
		@bindingScope
		@body
		@bodyScope
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declared: Boolean					= false
		@else
		@elseScope
		@from
		@fromAssert: Boolean				= false
		@fromBallpark: Boolean
		@fromName: String
		@immutable: Boolean					= false
		@loopKind: LoopKind					= LoopKind::Unknown
		@order: OrderKind					= OrderKind::None
		@outerScope
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
	analyse() { # {{{
		var mut rename = false
		var variable = @scope.getVariable(@data.variable.name)

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

		@declared = @declaration || variable == null

		// @outerScope = @newScope(@scope, ScopeType::Hollow)

		if @declared {
			@bindingScope = @newScope(@scope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = @scope
			// @bindingScope = @newScope(@scope, ScopeType::Bleeding)
		}

		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		@from = $compile.expression(@data.from, this, @scope)
		@from.analyse()

		@fromBallpark = $ast.hasModifier(@data.from, ModifierKind::Ballpark)

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

		@toBallpark = $ast.hasModifier(@data.to, ModifierKind::Ballpark)

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
		else if variable.isImmutable() {
			ReferenceException.throwImmutable(@data.variable.name, this)
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

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		if ?@data.else {
			@elseScope = @newScope(@scope, ScopeType::InlineBlock)

			@else = $compile.block(@data.else, this, @elseScope)
			@else.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless @declared {
			@bindingScope.replaceVariable(@data.variable.name, @bindingScope.reference('Number'), this)
		}

		@variable.prepare()

		@from.prepare(@scope.reference('Number'), TargetMode::Permissive)
		@to.prepare(@scope.reference('Number'), TargetMode::Permissive)
		@step?.prepare(@scope.reference('Number'), TargetMode::Permissive)

		if @from is NumberLiteral && @to is NumberLiteral {
			if ?@else {
				SyntaxException.throwForFromDeadElse(this)
			}

			if !?@step || @step is NumberLiteral {
				@loopKind = LoopKind::Static

				if @order == OrderKind::None {
					if ?@step {
						if @step.value() == 0 {
							SyntaxException.throwForFromBadStep(this)
						}
						else if @step.value() > 0 {
							unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
								SyntaxException.throwForFromNoMatch(this)
							}
						}
						else {
							unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
								SyntaxException.throwForFromNoMatch(this)
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
						SyntaxException.throwForFromBadStep(this)
					}

					if @order == OrderKind::Ascending {
						unless (@fromBallpark || @toBallpark) ? @from.value() < @to.value() : @from.value() <= @to.value() {
							SyntaxException.throwForFromNoMatch(this)
						}
					}
					else {
						unless (@fromBallpark || @toBallpark) ? @from.value() > @to.value() : @from.value() >= @to.value() {
							SyntaxException.throwForFromNoMatch(this)
						}

						@ascending = false
					}
				}
			}
			else {
				@loopKind = LoopKind::Ordered

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
			if @order != OrderKind::None {
				@loopKind = LoopKind::Ordered
			}

			if ?@step {
				unless @step.type().canBeNumber() {
					TypeException.throwInvalidArgument('for/from', 'step', @scope.reference('Number'), @step.type(), this)
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

			unless @from.type().canBeNumber() {
				TypeException.throwInvalidArgument('for/from', 'from', @scope.reference('Number'), @from.type(), this)
			}

			if !@from.type().isNumber() {
				@fromAssert = true
			}

			if @loopKind == LoopKind::Unknown || (@fromAssert && @from.isLooseComposite()) {
				@fromName = @scope.acquireTempName()
			}

			unless @to.type().canBeNumber() {
				TypeException.throwInvalidArgument('for/from', 'to', @scope.reference('Number'), @to.type(), this)
			}

			if !@to.type().isNumber() {
				@toAssert = true
			}

			if @loopKind == LoopKind::Unknown || (@toAssert && @to.isLooseComposite()) {
				@toName = @scope.acquireTempName()
			}
			else if @to.isLooseComposite() {
				@toName = @bindingScope.acquireTempName()
			}
			// if @loopKind == LoopKind::Unknown || @to.isLooseComposite() {
			// 	@toName = @bindingScope.acquireTempName()
			// }

			if @loopKind == LoopKind::Unknown {
				@stepName ??= @scope.acquireTempName()
				@unknownTranslator = @scope.acquireTempName()
				@unknownIndex = @bindingScope.acquireTempName(false)
			}
		}

		@assignTempVariables(@scope)
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

		@body.prepare(target)

		if ?@else {
			@else.prepare(target)
		}

		@scope.releaseTempName(@fromName) if ?@toName
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

		if ?@else {
			var trueInferables = @bodyScope.listUpdatedInferables()
			var falseInferables = @elseScope.listUpdatedInferables()

			for var inferable, name of trueInferables {
				var trueType = inferable.type

				if ?falseInferables[name] {
					var falseType = falseInferables[name].type

					if trueType.equals(falseType) {
						@scope.updateInferable(name, inferable, this)
					}
					else {
						@scope.updateInferable(name, {
							isVariable: inferable.isVariable
							type: Type.union(@scope, trueType, falseType)
						}, this)
					}
				}
				else if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}

			for var inferable, name of falseInferables when !?trueInferables[name] {
				if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}
		}
		else {
			for var inferable, name of @bodyScope.listUpdatedInferables() {
				if inferable.isVariable && @scope.hasVariable(name) {
					@scope.replaceVariable(name, inferable.type, true, false, this)
				}
			}
		}
	} # }}}
	translate() { # {{{
		@variable.translate()
		@from.translate()
		@to.translate()
		@step?.translate()
		@until?.translate()
		@while?.translate()
		@when?.translate()
		@body.translate()
		@else?.translate()
	} # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => # {{{
			@from.isUsingVariable(name)
		||	@to.isUsingVariable(name)
		||	@step?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
		||	@else?.isUsingVariable(name)
	# }}}
	toBodyFragments(fragments) { # {{{
		if ?@data.when {
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
	toOrderedFragments(fragments, mode) { # {{{
		// var mut fromDecl = !?@fromName
		var mut toDecl = !?@toName
		var mut stepDecl = !?@stepName

		var assert = @fromAssert || @toAssert || @stepAssert
		// console.log(assert, @fromName)

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
					line.code(`, \(@to.toQuote(true)), `).compile(@toName ?? @to)
				}
				else {
					line.code(`, "", 0`)
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

		// if !fromDecl {
		// 	ctrl.line(@fromName, $equals).compile(@from)
		// }

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
				.code('if(')
				.compile(@fromName ?? @from)

			if @fromBallpark {
				if stepDecl {
					if @step is NumberLiteral {
						if @step.value() > 0 {
							ifCtrl.code(` + \(@step.value())`)
						}
						else {
							ifCtrl.code(` - \(-@step.value())`)
						}
					}
					else if ?@step {
						ifCtrl.code(' + ').compile(@stepName ?? @step)
					}
					else {
						ifCtrl.code(@ascending ? ' + 1' : ' - 1')
					}
				}
				else {
					throw new NotImplementedException()
				}
			}

			ifCtrl.code(comparator)
				.compile(@toName ?? @to)
				.code(')')
				.step()
		}

		var mut ctrl = (ifCtrl ?? fragments).newControl().code('for(')

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
				throw new NotImplementedException()
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
			ctrl.code(' && ').wrapCondition(@while, Mode::None, Junction::AND)
		}

		ctrl.code('; ')

		if ?@step {
			if @data.step.kind == NodeKind::NumericExpression && @data.step.value == 1 {
				ctrl.code(@order == OrderKind::None || @ascending ? '++' : '--').compile(@variable)
			}
			else if @data.step.kind == NodeKind::NumericExpression && @data.step.value == -1 {
				ctrl.code('--').compile(@variable)
			}
			else {
				ctrl.compile(@variable).code(@order == OrderKind::None || @ascending ? ' += ' : ' -= ').compile(@stepName ?? @step)
			}
		}
		else {
			ctrl.code(@ascending ? '++' : '--').compile(@variable)
		}

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
		// var mut fromDecl = false
		// var mut toDecl = false
		// var mut stepDecl = false

		// if @fromAssert {
		// 	if ?@fromName {
		// 		fragments.newLine().compile(@fromName).code($equals).compile(@from).done()

		// 		fromDecl = true
		// 	}

		// 	fragments.newLine().code(`\($runtime.helper(this)).assertNumber(\(@from.toQuote(true)), `).compile(@fromName ?? @from).code(')').done()
		// }

		// if @toAssert {
		// 	if ?@toName {
		// 		fragments.newLine().compile(@toName).code($equals).compile(@to).done()

		// 		toDecl = true
		// 	}

		// 	fragments.newLine().code(`\($runtime.helper(this)).assertNumber(\(@to.toQuote(true)), `).compile(@toName ?? @to).code(')').done()
		// }

		// if @stepAssert {
		// 	if ?@stepName {
		// 		fragments.newLine().compile(@stepName).code($equals).compile(@step).done()

		// 		stepDecl = true
		// 	}

		// 	if @order == OrderKind::None {
		// 		fragments.newLine().code(`\($runtime.helper(this)).assertNumber(\(@step.toQuote(true)), `).compile(@stepName ?? @step).code(')').done()
		// 	}
		// 	else {
		// 		fragments.newLine().code(`\($runtime.helper(this)).assertNonNegative(\(@step.toQuote(true)), `).compile(@stepName ?? @step).code(')').done()
		// 	}
		// }

		// var mut ctrl = fragments.newControl().code('for(')

		// if @declared {
		// 	ctrl.code($runtime.scope(this))
		// }

		// ctrl.compile(@variable).code($equals).compile(@from)

		// if ?@toName {
		// 	ctrl.code($comma, @toName, $equals).compile(@to)
		// }

		// if ?@stepName {
		// 	ctrl.code($comma, @stepName, $equals).compile(@step)
		// }

		// ctrl.code('; ')

		// ctrl.compile(@variable)

		// if $ast.hasModifier(@data.to, ModifierKind::Ballpark) {
		// 	ctrl.code(@ascending ? ' < ' : ' > ')
		// }
		// else {
		// 	ctrl.code(@ascending ? ' <= ' : ' >= ')
		// }

		// ctrl.compile(@toName ?? @to)

		// if ?@until {
		// 	ctrl.code(' && !(').compileCondition(@until).code(')')
		// }
		// else if ?@while {
		// 	ctrl.code(' && ').wrapCondition(@while, Mode::None, Junction::AND)
		// }

		// ctrl.code('; ')

		// if @order == OrderKind::None {
		// 	if ?@step {
		// 		if @data.step.kind == NodeKind::NumericExpression {
		// 			if @data.step.value == 1 {
		// 				ctrl.code('++').compile(@variable)
		// 			}
		// 			else if @data.step.value == -1 {
		// 				ctrl.code('--').compile(@variable)
		// 			}
		// 			else if @data.step.value >= 0 {
		// 				ctrl.compile(@variable).code(' += ').compile(@step)
		// 			}
		// 			else {
		// 				ctrl.compile(@variable).code(' -= ', -@data.step.value)
		// 			}
		// 		}
		// 		else {
		// 			ctrl.compile(@variable).code(' += ').compile(@stepName ?? @step)
		// 		}
		// 	}
		// 	else if @ascending {
		// 		ctrl.code('++').compile(@variable)
		// 	}
		// 	else {
		// 		ctrl.code('--').compile(@variable)
		// 	}
		// }
		// else {
		// 	if ?@step {
		// 		if @data.step.kind == NodeKind::NumericExpression && @data.step.value == 1 {
		// 			ctrl.code(@ascending ? '++' : '--').compile(@variable)
		// 		}
		// 		else {
		// 			ctrl.compile(@variable).code(@ascending ? ' += ' : ' -= ').compile(@stepName ?? @step)
		// 		}
		// 	}
		// 	else {
		// 		ctrl.code(@ascending ? '++' : '--').compile(@variable)
		// 	}
		// }

		// ctrl.code(')').step()

		// @toBodyFragments(ctrl)

		// ctrl.done()
	} # }}}
	toStaticFragments(fragments, mode) { # {{{
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
			ctrl.code(' && ').wrapCondition(@while, Mode::None, Junction::AND)
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

		@toBodyFragments(ctrl)

		ctrl.done()
	} # }}}
	toUnknownFragments(fragments, mode) { # {{{
		var comparator = @toBallpark ? '<' : '<='

		fragments
			.newLine()
			.code(`[\(@fromName), \(@toName), \(@stepName), \(@unknownTranslator)] = \($runtime.helper(this)).assertLoop(0, \(@fromAssert ? @from.toQuote(true) : '""'), `)
			.compile(@from)
			.code(`, \(@toAssert ? @to.toQuote(true) : '""'), `)
			.compile(@to)
			.code(`, \(@stepAssert ? @step.toQuote(true) : '""'), `)
			.compile(@step ?? '1')
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
