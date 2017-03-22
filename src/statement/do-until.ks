class DoUntilStatement extends Statement {
	private {
		_body
		_condition
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
		
		@body = $compile.expression(@data.body, this)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		@body.prepare()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@body.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(@body)
			.step()
			.code('while(!(')
			.compileBoolean(@condition)
			.code('))')
			.done()
	} // }}}
}