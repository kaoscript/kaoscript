class SequenceExpression extends Expression {
	private late {
		_expressions: Array<Expression>		= []
		_last: Number
		_type: Type
	}
	analyse() { # {{{
		for expression in @data.expressions {
			@expressions.push(expression = $compile.expression(expression, this))

			expression.analyse()
		}
	} # }}}
	override prepare(target) { # {{{
		for expression in @expressions {
			expression.prepare()
		}

		@last = @expressions.length - 1
		@type = @expressions[@last].type()
	} # }}}
	translate() { # {{{
		for expression in @expressions {
			expression.translate()
		}
	} # }}}
	isUsingVariable(name) { # {{{
		for var expression in @expressions {
			if expression.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		for var expression in @expressions {
			expression.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.code('(')

		for var expression, index in @expressions {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(expression)
		}

		fragments.code(')')
	} # }}}
	toBooleanFragments(fragments, mode, junction) { # {{{
		fragments.code('(')

		for var expression, index in @expressions til @last {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(expression)
		}

		fragments.code($comma).compileBoolean(@expressions[@last])

		fragments.code(')')
	} # }}}
	type() => @type
}
