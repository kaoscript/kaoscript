class UnlessExpression extends Expression {
	private late {
		_condition
		_type: Type
		_whenFalse
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} # }}}
	prepare() { # {{{
		@condition.prepare()
		@whenFalse.prepare()

		@type = @whenFalse.type().setNullable(true)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@whenFalse.translate()
	} # }}}
	isComputed() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenFalse.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition.listNonLocalVariables(scope, variables)
		@whenFalse.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.wrapBoolean(@condition)
			.code(' ? null : ')
			.compile(@whenFalse)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.line(@whenFalse)
			.done()
	} # }}}
	type() => @type
}
