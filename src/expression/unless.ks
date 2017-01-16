class UnlessExpression extends Expression {
	private {
		_condition
		_whenFalse
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@whenFalse = $compile.expression(@data.whenFalse, this)
	} // }}}
	fuse() { // {{{
		@condition.fuse()
		@whenFalse.fuse()
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@condition)
			.code(' ? undefined : ')
			.compile(@whenFalse)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.line(@whenFalse)
			.done()
	} // }}}
}