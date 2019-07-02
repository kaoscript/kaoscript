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

		this.assignTempVariables(@scope)

		@whenFalseExpression.prepare()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenFalseExpression.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@whenFalseExpression.checkReturnType(type)
	} // }}}
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