class UnlessStatement extends Statement {
	private lateinit {
		_body
		_bodyScope: Scope
		_condition
	}
	analyse() { // {{{
		@bodyScope = this.newScope(@scope, ScopeType::InlineBlock)

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()

		@body = $compile.block(@data.whenFalse, this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
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
			for const inferable, name of @bodyScope.listUpdatedInferables() when inferable.isVariable {
				if const variable = @scope.getVariable(name) {
					@scope.updateInferable(name, {
						isVariable: true
						type: @scope.inferVariableType(variable, inferable.type)
					}, this)
				}
			}
		}
	} // }}}
	translate() { // {{{
		@condition.translate()
		@body.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isJumpable() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable()
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@body)
			.done()
	} // }}}
}