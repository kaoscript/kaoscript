class OmittedExpression extends Expression {
	analyse()
	prepare()
	translate()
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
	} // }}}
	type() => Type.Any
}