class ThrowStatement extends Statement {
	private {
		_value = null
	}
	ThrowStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._value = $compile.expression(this._data.value, this)
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code('throw ')
			.compile(this._value)
			.done()
	} // }}}
}