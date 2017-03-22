class DoWhileStatement extends Statement {
	private {
		_body
		_condition
	}
	analyse() { // {{{
		@body = $compile.expression(@data.body, this)
		@body.analyse()
		
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
	} // }}}
	prepare() { // {{{
		@body.prepare()
		@condition.prepare()
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