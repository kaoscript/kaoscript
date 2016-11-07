class RegularExpression extends Expression {
	private {
		_value
	}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(this._data.value)
	} // }}}
}