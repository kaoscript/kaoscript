class OmittedExpression extends Expression {
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