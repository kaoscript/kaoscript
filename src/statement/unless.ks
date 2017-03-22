class UnlessStatement extends Statement {
	private {
		_condition
		_whenFalse
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
		
		@whenFalse = $compile.expression($block(@data.whenFalse), this)
		@whenFalse.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		@whenFalse.prepare()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenFalse.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@whenFalse)
			.done()
	} // }}}
}