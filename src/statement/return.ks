class ReturnStatement extends Statement {
	private {
		_value = null
	}
	ReturnStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		if this._data.value? {
			this._value = $compile.expression(this._data.value, this)
		}
	} // }}}
	fuse() { // {{{
		if this._value != null && this._value.fuse? {
			this._value.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			if this._value != null {
				fragments
					.newLine()
					.code('return __ks_cb(null, ')
					.compile(this._value)
					.code(')')
					.done()
			}
			else {
				fragments.line('return __ks_cb()')
			}
		}
		else {
			if this._value != null {
				fragments
					.newLine()
					.code('return ')
					.compile(this._value)
					.done()
			}
			else {
				fragments.line('return', this._data)
			}
		}
	} // }}}
}