class DestroyStatement extends Statement {
	private {
		_variable
	}
	analyse() { // {{{
		this._variable = $compile.expression(this._data.variable, this)
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		console.log(this._data)
	} // }}}
}