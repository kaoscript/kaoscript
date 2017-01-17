class SequenceExpression extends Expression {
	private {
		_expressions
	}
	analyse() { // {{{
		@expressions = [$compile.expression(expression, this) for expression in @data.expressions]
	} // }}}
	fuse() { // {{{
		for expression in @expressions {
			expression.fuse()
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