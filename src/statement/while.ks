class WhileStatement extends Statement {
	private {
		_body
		_condition
	}
	analyse() { // {{{
		this._body = $compile.expression(this._data.body, this)
		this._condition = $compile.expression(this._data.condition, this)
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		this._condition.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('while(')
			.compileBoolean(this._condition)
			.code(')')
			.step()
			.compile(this._body)
			.done()
	} // }}}
}