class RestrictiveExpression extends Expression {
	private late {
		@condition
		@expression
		@type: Type
	}
	override analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@expression = $compile.expression(@data.expression, this)
		@expression.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'))
		@expression.prepare(target)

		@type = @expression.type().setNullable(true)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@expression.translate()
	} # }}}
	isComputed() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @expression.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition.listNonLocalVariables(scope, variables)
		@expression.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @data.operator.kind == RestrictiveOperatorKind::If {
			fragments
				.wrapCondition(@condition)
				.code(' ? ')
				.compile(@expression)
				.code(' : ', @expression.getDefaultValue())
		}
		else {
			fragments
				.wrapCondition(@condition)
				.code(' ? ', @expression.getDefaultValue(), ' : ')
				.compile(@expression)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @data.operator.kind == RestrictiveOperatorKind::If {
			fragments
				.newControl()
				.code('if(')
				.compileCondition(@condition)
				.code(')')
				.step()
				.line(@expression)
				.done()
		}
		else {
			fragments
				.newControl()
				.code('if(!')
				.wrapCondition(@condition)
				.code(')')
				.step()
				.line(@expression)
				.done()
		}
	} # }}}
	type() => @type
}
