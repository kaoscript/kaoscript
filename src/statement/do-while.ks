class DoWhileStatement extends Statement {
	private {
		_body
		_condition
	}
	analyse() { // {{{
		@body = $compile.block(@data.body, this)
		@body.analyse()

		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()

		this.assignTempVariables(@scope)

		@body.prepare()
	} // }}}
	translate() { // {{{
		@body.translate()
		@condition.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(@body)
			.step()
			.code('while(')
			.compileBoolean(@condition)
			.code(')')
			.done()
	} // }}}
}