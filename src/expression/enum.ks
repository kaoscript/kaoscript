class EnumExpression extends Expression {
	private {
		_enum
	}
	EnumExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._enum = $compile.expression(this._data.enum, this)
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._enum).code('.', this._data.member.name)
	} // }}}
}