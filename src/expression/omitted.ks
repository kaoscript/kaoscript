class OmittedExpression extends Expression {
	analyse()
	override prepare(target, targetMode)
	translate()
	isRedeclared() => false
	listAssignments(array: Array) => array
	setAssignment(...)
	toFragments(fragments) { # {{{
		if this._data.spread {
			fragments.code('...')
		}
	} # }}}
}
