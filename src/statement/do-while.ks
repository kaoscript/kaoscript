class DoWhileStatement extends Statement {
	private lateinit {
		_body
		_bodyScope: Scope
		_condition
	}
	analyse() { // {{{
		@bodyScope = this.newScope(@scope, ScopeType::InlineBlock)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()
	} // }}}
	prepare() { // {{{
		@condition.prepare()

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		this.assignTempVariables(@scope)

		@body.prepare()

		for const inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
	} // }}}
	translate() { // {{{
		@body.translate()
		@condition.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isExit() => @body.isExit()
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable()
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