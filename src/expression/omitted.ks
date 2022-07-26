class OmittedExpression extends Expression {
	analyse()
	prepare()
	translate()
	isRedeclared() => false
	listAssignments(array: Array<String>) => array
	setAssignment(...)
	toFragments(fragments) { # {{{
		if this._data.spread {
			fragments.code('...')
		}
	} # }}}
}
