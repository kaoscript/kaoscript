class IfExpression extends Expression {
	private {
		_condition
		_type
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

		if @whenFalse? {
			@whenFalse.prepare()

			const t = @whenTrue.type()
			const f = @whenFalse.type()

			if t.equals(f) {
				@type = t
			}
			else if f.isNull() {
				@type = t.setNullable(true)
			}
			else if t.isNull() {
				@type = f.setNullable(true)
			}
			else {
				@type = Type.union(@scope, t, f)
			}
		}
		else {
			@type = @whenTrue.type()
		}
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate() if @whenFalse?
	} // }}}
	isComputed() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenTrue.isUsingVariable(name) || @whenFalse?.isUsingVariable(name)
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

		ctrl.compileBoolean(@condition)

		ctrl.code(')').step().line(@whenTrue).done()
	} // }}}
	type() => @type
}