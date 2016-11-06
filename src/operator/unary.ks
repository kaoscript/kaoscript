class UnaryOperatorExpression extends Expression {
	private {
		_argument
		_right
	}
	analyse() { // {{{
		this._argument = $compile.expression(this._data.argument, this)
	} // }}}
	fuse() { // {{{
		this._argument.fuse()
	} // }}}
}

class UnaryOperatorDecrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(this._argument)
			.code('--', this._data.operator)
	} // }}}
}

class UnaryOperatorDecrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('--', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		if this._argument.isNullable() {
			fragments
				.wrapNullable(this._argument)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(',  this._data.operator)
				.compile(this._argument)
				.code(')',  this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(',  this._data.operator)
				.compile(this._argument)
				.code(')',  this._data.operator)
		}
	} // }}}
}

class UnaryOperatorIncrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(this._argument)
			.code('++', this._data.operator)
	} // }}}
}

class UnaryOperatorIncrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('++', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!', this._data.operator)
			.wrapBoolean(this._argument)
	} // }}}
}

class UnaryOperatorNegative extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('-', this._data.operator)
			.wrap(this._argument)
	} // }}}
}

class UnaryOperatorNew extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('new', this._data.operator, $space)
			.wrap(this._argument)
	} // }}}
}