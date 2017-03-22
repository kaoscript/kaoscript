class ThrowStatement extends Statement {
	private {
		_value = null
	}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
		
		if (variable ?= $variable.fromAST(@data.value, this)) && variable.type && (variable ?= $variable.fromType(variable.type, this)) {
			Exception.validateReportedError(variable, this)
		}
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code('throw ')
			.compile(@value)
			.done()
	} // }}}
}