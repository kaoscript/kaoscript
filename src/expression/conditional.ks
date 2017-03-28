class ConditionalExpression extends Expression {
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
		
		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		@whenTrue.prepare()
		@whenFalse.prepare()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate()
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@condition)
			.code(' ? ')
			.compile(@whenTrue)
			.code(' : ')
			.compile(@whenFalse)
	} // }}}
	type() { // {{{
		const t = @whenTrue.type()
		const f = @whenFalse.type()
		
		return Type.equals(t, f) ? t : Type.union(this, t, f)
	} // }}}
}