class EnumExpression extends Expression {
	private {
		_enum
	}
	analyse() { // {{{
		this._enum = $compile.expression(this._data.enum, this)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._enum).code('.', this._data.member.name)
	} // }}}
}