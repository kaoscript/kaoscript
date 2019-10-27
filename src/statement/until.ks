class UntilStatement extends Statement {
	private {
		_body
		_condition
	}
	analyse() { // {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@body = $compile.block(@data.body, this)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		this.assignTempVariables(@scope)

		@body.prepare()
	} // }}}
	translate() { // {{{
		@condition.translate()
		@body.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable()
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('while(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@body)
			.done()
	} // }}}
}