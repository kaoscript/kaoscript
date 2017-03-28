class IfExpression extends Expression {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
		
		@whenTrue = $compile.expression(@data.whenTrue, this)
		@whenTrue.analyse()
		
		if @data.whenFalse? {
			@whenFalse = $compile.expression(@data.whenFalse, this)
			@whenFalse.analyse()
		}
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		@whenTrue.prepare()
		@whenFalse.prepare() if @whenFalse?
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate() if @whenFalse?
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		if @whenFalse? {
			fragments
				.wrapBoolean(@condition)
				.code(' ? ')
				.compile(@whenTrue)
				.code(' : ')
				.compile(@whenFalse)
		}
		else {
			fragments
				.wrapBoolean(@condition)
				.code(' ? ')
				.compile(@whenTrue)
				.code(' : undefined')
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(')
		
		if @condition.isAssignable() {
			ctrl.code('(').compileBoolean(@condition).code(')')
		}
		else {
			ctrl.compileBoolean(@condition)
		}
		
		ctrl.code(')').step().line(@whenTrue).done()
	} // }}}
	type() { // {{{
		const t = @whenTrue.type()
		
		if @whenFalse? {
			const f = @whenFalse.type()
			
			return Type.equals(t, f) ? t : Type.union(this, t, f)
		}
		else {
			return t
		}
	} // }}}
}