class ThrowStatement extends Statement {
	private {
		_value = null
	}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
		
		if (type ?= @value.type().unalias()) && type is ClassType {
			Exception.validateReportedError(type, this)
		}
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