class UnlessStatement extends Statement {
	private {
		_condition
		_whenFalseExpression
		_whenFalseScope: Scope
	}
	analyse() { // {{{
		@whenFalseScope = this.newScope(@scope, ScopeType::InlineBlock)

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()

		@whenFalseExpression = $compile.block(@data.whenFalse, this, @whenFalseScope)
		@whenFalseExpression.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		this.assignTempVariables(@scope)

		@whenFalseExpression.prepare()

		if @whenFalseExpression.isExit() {
			for const data, name of @condition.inferTypes() {
				@scope.updateInferable(name, data, this)
			}
		}
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenFalseExpression.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@whenFalseExpression.checkReturnType(type)
	} // }}}
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenFalseExpression.isUsingVariable()
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@whenFalseExpression)
			.done()
	} // }}}
}