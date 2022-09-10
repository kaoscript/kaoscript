class CurryExpression extends CallExpression {
	makeCallee(type, name) { # {{{
		@addCallee(new DefaultCallee(@data, @object, null, this))
	} # }}}
	toCallFragments(fragments, mode) { # {{{
		if @callees.length == 1 {
			@callees[0].toCurryFragments(fragments, mode, this)
		}
		else if @callees.length == 2 {
			@module().flag('Type')

			@callees[0].toPositiveTestFragments(fragments, this)

			fragments.code(' ? ')

			@callees[0].toCurryFragments(fragments, mode, this)

			fragments.code(') : ')

			@callees[1].toCurryFragments(fragments, mode, this)
		}
		else {
			throw new NotImplementedException(this)
		}
	} # }}}
	type() => @scope.reference('Function')
}
