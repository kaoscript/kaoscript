class UnlessStatement extends Statement {
	private lateinit {
		_body
		_bodyScope: Scope
		_condition
	}
	analyse() { # {{{
		@bodyScope = this.newScope(@scope, ScopeType::InlineBlock)

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()

		@body = $compile.block(@data.whenFalse, this, @bodyScope)
		@body.analyse()
	} # }}}
	prepare() { # {{{
		@condition.prepare()

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		this.assignTempVariables(@scope)

		@body.prepare()

		if @body.isExit() {
			for const data, name of @condition.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}
		else {
			const conditionInferables = @condition.inferWhenTrueTypes({})
			const trueInferables = @bodyScope.listUpdatedInferables()

			for const inferable, name of trueInferables {
				const trueType = inferable.type

				if conditionInferables[name]? {
					const conditionType = conditionInferables[name].type

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
	checkReturnType(type: Type) { # {{{
		@body.checkReturnType(type)
	} # }}}
	isJumpable() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable()
	toStatementFragments(fragments, mode) { # {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@body)
			.done()
	} # }}}
}
