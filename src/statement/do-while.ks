class DoWhileStatement extends Statement {
	private {
		_body
		_condition
	}
	DoWhileStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
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
			.code('do')
			.step()
			.compile(this._body)
			.step()
			.code('while(')
			.compileBoolean(this._condition)
			.code(')')
			.done()
	} // }}}
}