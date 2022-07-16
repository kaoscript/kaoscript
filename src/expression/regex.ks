class RegularExpression extends Expression {
	analyse()
	prepare()
	translate()
	isUsingVariable(name) => false
	toFragments(fragments, mode) { // {{{
		fragments.code(@data.value)
	} // }}}
	type() => @scope.reference('RegExp')
}
