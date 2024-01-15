class UnlessStatement extends Statement {
	private late {
		@body: Block
		@bodyScope: Scope
		@condition
	}
	analyse() { # {{{
		@bodyScope = @newScope(@scope!?, ScopeType.InlineBlock)

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()

		@body = $compile.block(@data.whenFalse, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition
			..prepare(@scope.reference('Boolean'), TargetMode.Permissive)
			..acquireReusable(false)
			..releaseReusable()

		var conditionType = @condition.type()

		unless conditionType.canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		// TODO
		// if conditionType is ValueType && conditionType.type().isBoolean() {
		// 	TypeException.throwUnnecessaryCondition(@condition, this)
		// }

		@assignTempVariables(@scope!?)

		@body.prepare(target)

		if @body.isExit(.Statement + .Always) {
			for var data, name of @condition.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}
		else {
			var conditionInferables = @condition.inferWhenTrueTypes({})
			var trueInferables = @bodyScope.listUpdatedInferables()

			for var inferable, name of trueInferables {
				var trueType = inferable.type

				if ?conditionInferables[name] {
					var conditionType = conditionInferables[name].type

					if trueType.equals(conditionType) {
						@scope.updateInferable(name, inferable, this)
					}
					else {
						@scope.updateInferable(name, {
							isVariable: inferable.isVariable
							type: Type.union(@scope, trueType, conditionType)
						}, this)
					}
				}
				else if inferable.isVariable {
					@scope.replaceVariable(name, trueType, true, false, this)
				}
			}
		}
	} # }}}
	translate() { # {{{
		@condition.translate()
		@body.translate()
	} # }}}
	isJumpable() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable(name)
	toStatementFragments(fragments, mode) { # {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapCondition(@condition)
			.code(')')
			.step()
			.compile(@body)
			.done()
	} # }}}
}
