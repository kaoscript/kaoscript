class OmittedExpression extends Expression {
	OmittedExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
	} // }}}
}