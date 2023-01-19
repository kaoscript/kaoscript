class UnlessExpression extends Expression {
	private late {
		@condition
		@type: Type
		@whenFalse
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'))
		@whenFalse.prepare(target)

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
			.wrapCondition(@condition)
			.code(' ? ', @whenFalse.getDefaultValue(), ' : ')
			.compile(@whenFalse)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapCondition(@condition)
			.code(')')
			.step()
			.line(@whenFalse)
			.done()
	} # }}}
	type() => @type
}
