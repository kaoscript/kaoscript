class CurryExpression extends CallExpression {
	makeCallee(type) { // {{{
		this.addCallee(new DefaultCallee(@data, @object, this))
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		if @callees.length == 1 {
			@callees[0].toCurryFragments(fragments, mode, this)
		}
		else if @callees.length == 2 {
			this.module().flag('Type')
			
			@callees[0].toTestFragments(fragments, this)
			
			fragments.code(' ? ')
			
			@callees[0].toCurryFragments(fragments, mode, this)
			
			fragments.code(') : ')
			
			@callees[1].toCurryFragments(fragments, mode, this)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	type() => @scope.reference('Function')
}