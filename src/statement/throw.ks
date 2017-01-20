class ThrowStatement extends Statement {
	private {
		_value = null
	}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		
		if @options.error == 'fatal' && (variable ?= $variable.fromAST(@data.value, this)) && variable.type && (variable ?= $variable.fromType(variable.type, this)) {
			if !@parent.isConsumedError(variable.name.name, variable) {
				SyntaxException.throwUnreportedError(variable.name.name, this)
			}
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