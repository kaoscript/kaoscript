class ThrowStatement extends Statement {
	private {
		_value = null
	}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		
		if (variable ?= $variable.fromAST(@data.value, this)) && variable.type && (variable ?= $variable.fromType(variable.type, this)) {
			Exception.validateReportedError(variable, this)
		}
	} // }}}
	fuse() { // {{{
		@value.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code('throw ')
			.compile(@value)
			.done()
	} // }}}
}