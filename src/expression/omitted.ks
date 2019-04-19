class OmittedExpression extends Expression {
	analyse()
	prepare()
	translate()
	isRedeclared() => false
	toFragments(fragments) { // {{{
		if this._data.spread {
			fragments.code('...')
		}
	} // }}}
}