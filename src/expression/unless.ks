class UnlessExpression extends Expression {
	private {
		_condition
		_type: Type
		_whenFalse
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		@whenFalse.prepare()

		@type = @whenFalse.type().flagNullable()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenFalse.translate()
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@condition)
			.code(' ? undefined : ')
			.compile(@whenFalse)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.line(@whenFalse)
			.done()
	} // }}}
	type() => @type
}