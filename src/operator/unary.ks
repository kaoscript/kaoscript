class UnaryOperatorExpression extends Expression {
	private {
		_argument
		_right
	}
	analyse() { // {{{
		@argument = $compile.expression(@data.argument, this)
	} // }}}
	fuse() { // {{{
		@argument.fuse()
	} // }}}
}

class UnaryOperatorBitwiseNot extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('~', @data.operator)
			.wrap(@argument)
	} // }}}
}

class UnaryOperatorDecrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@argument)
			.code('--', @data.operator)
	} // }}}
}

class UnaryOperatorDecrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('--', @data.operator)
			.wrap(@argument)
	} // }}}
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	isComputed() => @argument.isNullable()
	toFragments(fragments, mode) { // {{{
		if @argument.isNullable() {
			fragments
				.wrapNullable(@argument)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(',  @data.operator)
				.compile(@argument)
				.code(')',  @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(',  @data.operator)
				.compile(@argument)
				.code(')',  @data.operator)
		}
	} // }}}
}

class UnaryOperatorIncrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@argument)
			.code('++', @data.operator)
	} // }}}
}

class UnaryOperatorIncrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('++', @data.operator)
			.wrap(@argument)
	} // }}}
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!', @data.operator)
			.wrapBoolean(@argument)
	} // }}}
}

class UnaryOperatorNegative extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('-', @data.operator)
			.wrap(@argument)
	} // }}}
}