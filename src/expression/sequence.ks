class SequenceExpression extends Expression {
	private late {
		_expressions: Array<Expression>		= []
		_last: Number
		_type: Type
	}
	analyse() { # {{{
		for var data in @data.expressions {
			var expression = $compile.expression(data, this)

			expression.analyse()

			@expressions.push(expression)
		}
	} # }}}
	override prepare(target) { # {{{
		@last = @expressions.length - 1

		for var expression in @expressions til -1 {
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
