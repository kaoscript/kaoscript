class UnaryOperatorExpression extends Expression {
	private {
		_argument
	}
	analyse() { // {{{
		@argument = $compile.expression(@data.argument, this)
		@argument.analyse()
	} // }}}
	prepare() { // {{{
		@argument.prepare()
	} // }}}
	translate() { // {{{
		@argument.translate()
	} // }}}
	argument() => @argument
	hasExceptions() => false
	isUsingVariable(name) => @argument.isUsingVariable(name)
}

class UnaryOperatorBitwiseNot extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('~', @data.operator)
			.wrap(@argument)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorDecrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@argument)
			.code('--', @data.operator)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorDecrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('--', @data.operator)
			.wrap(@argument)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	private {
		_type: Type
	}
	inferTypes() { // {{{
		const inferables = {}

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument is IdentifierLiteral
				type: @type
			}
		}

		return inferables
	} // }}}
	isComputed() => @argument.isNullable()
	prepare() { // {{{
		@argument.prepare()

		@type = @argument.type().setNullable(false)
	} // }}}
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
	type() => @scope.reference('Boolean')
}

class UnaryOperatorIncrementPostfix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrap(@argument)
			.code('++', @data.operator)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorIncrementPrefix extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('++', @data.operator)
			.wrap(@argument)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	inferTypes() => @argument.inferContraryTypes()
	inferContraryTypes() => @argument.inferTypes()
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!', @data.operator)
			.wrapBoolean(@argument)
	} // }}}
	type() => @scope.reference('Boolean')
}

class UnaryOperatorNegative extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.code('-', @data.operator)
			.wrap(@argument)
	} // }}}
	type() => @scope.reference('Number')
}

class UnaryOperatorSpread extends UnaryOperatorExpression {
	prepare() { // {{{
		@argument.prepare()

		const type = @argument.type()

		unless type.isArray() || type.isAny() {
			TypeException.throwInvalidSpread(this)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @options.format.spreads == 'es5' {
			throw new NotSupportedException(this)
		}

		fragments
			.code('...', @data.operator)
			.wrap(@argument)
	} // }}}
	type() => @scope.reference('Array')
}