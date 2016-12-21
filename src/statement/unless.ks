class UnlessStatement extends Statement {
	private {
		_body
		_then
	}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression($block(this._data.then), this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(this._condition)
			.code(')')
			.step()
			.compile(this._then)
			.done()
	} // }}}
}