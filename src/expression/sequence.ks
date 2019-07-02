class SequenceExpression extends Expression {
	private {
		_expressions
	}
	analyse() { // {{{
		@expressions = []
		for expression in @data.expressions {
			@expressions.push(expression = $compile.expression(expression, this))

			expression.analyse()
		}
	} // }}}
	prepare() { // {{{
		for expression in @expressions {
			expression.prepare()
		}
	} // }}}
	translate() { // {{{
		for expression in @expressions {
			expression.translate()
		}
	} // }}}
	isUsingVariable(name) { // {{{
		for const expression in @expressions {
			if expression.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('(')

		for i from 0 til @expressions.length {
			fragments.code($comma) if i != 0

			fragments.compile(@expressions[i])
		}

		fragments.code(')')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		fragments.code('(')

		for i from 0 til @expressions.length {
			fragments.code($comma) if i != 0

			fragments.compileBoolean(@expressions[i])
		}

		fragments.code(')')
	} // }}}
	type() => @expressions[@expressions.length - 1].type()
}