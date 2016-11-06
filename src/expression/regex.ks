class RegularExpression extends Expression {
	private {
		_value
	}
	RegularExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(this._data.value)
	} // }}}
}