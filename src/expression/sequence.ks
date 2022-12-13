class SequenceExpression extends Expression {
	private late {
		@expressions: Array<Expression>		= []
		@last: Number
		@type: Type
	}
	analyse() { # {{{
		for var data in @data.expressions {
			var expression = $compile.expression(data, this)

			expression.analyse()

			@expressions.push(expression)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@last = @expressions.length - 1

		for var expression in @expressions to~ -1 {
			expression.prepare(Type.Void)
		}

		@expressions[@last].prepare(target)

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
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments.code('(')

		for var expression, index in @expressions to~ @last {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(expression)
		}

		fragments.code($comma).compileCondition(@expressions[@last])

		fragments.code(')')
	} # }}}
	toQuote() { # {{{
		var mut fragments = '('

		for var expression, index in @expressions {
				if index != 0 {
					fragments += ', '
				}

				fragments += expression.toQuote()
			}

		fragments += ')'

		return fragments
	} # }}}
	type() => @type
}
