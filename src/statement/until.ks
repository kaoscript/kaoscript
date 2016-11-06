class UntilStatement extends Statement {
	private {
		_body
		_condition
	}
	UntilStatement(data, parent) { // {{{
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
			.code('while(!(')
			.compileBoolean(this._condition)
			.code('))')
			.step()
			.compile(this._body)
			.done()
	} // }}}
}