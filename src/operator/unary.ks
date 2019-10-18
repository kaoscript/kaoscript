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

		if @argument.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}
	} // }}}
	translate() { // {{{
		@argument.translate()
	} // }}}
	argument() => @argument
	hasExceptions() => false
	isUsingVariable(name) => @argument.isUsingVariable(name)
}

abstract class NumericUnaryOperatorExpression extends UnaryOperatorExpression {
	private {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if this.isAcceptingEnum() && @argument.type().isEnum() {
			@isEnum = true

			@type = @argument.type()
		}
		else {
			if @argument.type().isNumber() {
				if @argument.type().isNullable() {
					TypeException.throwNotNullableOperand(@argument, this.operator(), this)
				}

				@isNative = true
			}
			else if !@argument.type().canBeNumber() {
				TypeException.throwInvalidOperand(@argument, this.operator(), this)
			}

			@type = @scope.reference('Number')
		}
	} // }}}
	isAcceptingEnum() => false
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { // {{{
		if @isEnum {
			fragments.code(this.symbol(), @data.operator).wrap(@argument)
		}
		else if @isNative {
			fragments.code(this.symbol(), @data.operator).wrap(@argument)
		}
		else {
			fragments.code($runtime.operator(this), `.\(this.runtime())(`).compile(@argument).code(')')
		}
	} // }}}
	toQuote() => `\(this.symbol())\(@argument.toQuote())`
	type() => @type
}

class UnaryOperatorBitwiseNot extends NumericUnaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseNot
	runtime() => 'bitwiseNot'
	symbol() => '~'
}

class UnaryOperatorDecrementPostfix extends NumericUnaryOperatorExpression {
	operator() => Operator::DecrementPostfix
	runtime() => 'decrementPostfix'
	symbol() => '--'
	toFragments(fragments, mode) { // {{{
		fragments.compile(@argument).code(this.symbol(), @data.operator)
	} // }}}
	toQuote() => `\(@argument.toQuote())\(this.symbol())`
}

class UnaryOperatorDecrementPrefix extends NumericUnaryOperatorExpression {
	operator() => Operator::DecrementPrefix
	runtime() => 'decrementPrefix'
	symbol() => '--'
	toFragments(fragments, mode) { // {{{
		fragments.code(this.symbol(), @data.operator).compile(@argument)
	} // }}}
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	private {
		_type: Type
	}
	inferTypes() { // {{{
		const inferables = @argument.inferTypes()

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

		if !@argument.type().isNullable() && !@options.rules.ignoreMisfit {
			TypeException.throwNotNullableExistential(@argument, this)
		}

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

class UnaryOperatorForcedTypeCasting extends UnaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@argument)
	} // }}}
	type() => AnyType.Unexplicit
}

class UnaryOperatorIncrementPostfix extends NumericUnaryOperatorExpression {
	operator() => Operator::IncrementPostfix
	runtime() => 'incrementPostfix'
	symbol() => '++'
	toFragments(fragments, mode) { // {{{
		fragments.compile(@argument).code(this.symbol(), @data.operator)
	} // }}}
	toQuote() => `\(@argument.toQuote())\(this.symbol())`
}

class UnaryOperatorIncrementPrefix extends NumericUnaryOperatorExpression {
	operator() => Operator::IncrementPrefix
	runtime() => 'incrementPrefix'
	symbol() => '++'
	toFragments(fragments, mode) { // {{{
		fragments.code(this.symbol(), @data.operator).compile(@argument)
	} // }}}
}

class UnaryOperatorNegation extends UnaryOperatorExpression {
	prepare() { // {{{
		super()

		if @argument.type().isBoolean() {
			if @argument.type().isNullable() {
				TypeException.throwNotNullableOperand(@argument, Operator::Negation, this)
			}
		}
		else if !@argument.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@argument, Operator::Negation, this)
		}
	} // }}}
	inferTypes() => @argument.inferContraryTypes(false)
	inferContraryTypes(isExit) => @argument.inferTypes()
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!', @data.operator)
			.wrapBoolean(@argument)
	} // }}}
	type() => @scope.reference('Boolean')
}

class UnaryOperatorNegative extends NumericUnaryOperatorExpression {
	operator() => Operator::Negative
	runtime() => 'negative'
	symbol() => '-'
}

class UnaryOperatorNullableTypeCasting extends UnaryOperatorExpression {
	private {
		_type: Type
	}
	prepare() { // {{{
		super()

		@type = @argument.type().setNullable(false)
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@argument)
	} // }}}
	type() => @type
}

class UnaryOperatorSpread extends UnaryOperatorExpression {
	prepare() { // {{{
		super()

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