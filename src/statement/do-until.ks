class DoUntilStatement extends Statement {
	private {
		_body
		_condition
	}
	DoUntilStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression(this._data.body, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(this._body)
			.step()
			.code('while(!(')
			.compileBoolean(this._condition)
			.code('))')
			.done()
	} // }}}
}