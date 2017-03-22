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
	toFragments(fragments, mode) { // {{{
		fragments.code('(')
		
		for i from 0 til @expressions.length {
			fragments.code($comma) if i != 0
			
			fragments.compile(@expressions[i])
		}
		
		fragments.code(')')
	} // }}}
}