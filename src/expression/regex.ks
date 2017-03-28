class RegularExpression extends Expression {
	analyse()
	prepare()
	translate()
	toFragments(fragments, mode) { // {{{
		fragments.code(@data.value)
	} // }}}
	type() => Type.RegExp
}