class UnlessStatement extends Statement {
	private {
		_condition
		_whenFalse
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@whenFalse = $compile.expression($block(@data.whenFalse), this)
	} // }}}
	fuse() { // {{{
		@condition.fuse()
		@whenFalse.fuse()
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