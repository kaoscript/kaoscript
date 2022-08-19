class RegularExpression extends Expression {
	analyse()
	override prepare(target)
	translate()
	isUsingVariable(name) => false
	toFragments(fragments, mode) { # {{{
		fragments.code(@data.value)
	} # }}}
	type() => @scope.reference('RegExp')
}
