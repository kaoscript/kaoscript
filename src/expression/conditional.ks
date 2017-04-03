class ConditionalExpression extends Expression {
	private {
		_condition
		_whenFalse
		_whenTrue
		_type: Type
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
		
		const t = @whenTrue.type()
		const f = @whenFalse.type()
		
		@type = t.equals(f) ? t : new UnionType([t, f])
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
	type() => @type
}