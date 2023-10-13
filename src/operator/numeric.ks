abstract class NumericBinaryOperatorExpression extends BinaryOperatorExpression {
	private late {
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@type: Type
	}
	abstract {
		operator(): Operator
		runtime(): String
		symbol(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().discardValue().name() == @right.type().discardValue().name() {
			@enum = true

			if @expectingEnum {
				@type = @left.type().discardValue()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingEnum()
			@right.unflagExpectingEnum()
		}
		else {
			if @left.type().isNumber() && @right.type().isNumber() {
				@native = true
			}
			else if @left.type().canBeNumber() {
				unless @right.type().canBeNumber() {
					TypeException.throwInvalidOperand(@right, this.operator(), this)
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, this.operator(), this)
			}

			if @left.type().isNullable() || @right.type().isNullable() {
				@type = @scope.reference('Number').setNullable(true)

				@native = false
			}
			else {
				@type = @scope.reference('Number')
			}
		}
	} # }}}
	isAcceptingEnum() => false
	isComputed() => @native || (@enum && !@expectingEnum)
	native() => @symbol()
	setOperands(@left, @right, @enum = false, @expectingEnum = false): valueof this
	toEnumFragments(fragments)
	toNativeFragments(fragments) { # {{{
		fragments.wrap(@left).code($space).code(@native(), @data.operator).code($space).wrap(@right)
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == this.operator() && type == OperandType.Number {
			fragments.compile(@left).code($comma).compile(@right)
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @enum {
			@toEnumFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			fragments
				.code($runtime.operator(this), `.\(@runtime())(`)
				.compile(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
	type() => @type
	unflagExpectingEnum() { # {{{
		@expectingEnum = false
	} # }}}
}

abstract class NumericPolyadicOperatorExpression extends PolyadicOperatorExpression {
	private late {
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@type: Type
	}
	abstract {
		runtime(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @isAcceptingEnum() && @operands[0].type().isEnum() {
			var name = @operands[0].type().discardValue().name()

			@enum = true

			for var operand in @operands from 1 {
				if (operand.type().isEnum() && operand.type().discardValue().name() != name) || !operand.type().isNumber() {
					@enum = false

					break
				}
			}

			if @enum {
				@native = true

				if @expectingEnum {
					@type = @left().type().discardValue()
				}
				else {
					@type = @left().type().discard().type()
				}

				for var operand in @operands {
					operand.unflagExpectingEnum()
				}
			}
		}

		if !@enum {
			var mut nullable = false

			@native = true

			for var operand in @operands {
				if operand.type().isNullable() {
					nullable = true
					@native = false
				}

				if operand.type().isNumber() {
					pass
				}
				else if operand.type().canBeNumber() {
					@native = false
				}
				else {
					TypeException.throwInvalidOperand(operand, this.operator(), this)
				}
			}

			@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
		}
	} # }}}
	isAcceptingEnum() => false
	isComputed() => @native
	toEnumFragments(fragments) { # {{{
		fragments.code(@type.name(), '(')

		if @native {
			@toNativeFragments(fragments)
		}
		else {
			@toRuntimeFragments(fragments)
		}

		fragments.code(')')
	} # }}}
	toNativeFragments(fragments) { # {{{
		for var operand, index in @operands {
			if index != 0 {
				fragments.code($space).code(@native(), @data.operator).code($space)
			}

			fragments.wrap(operand)
		}
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if @enum {
			@toEnumFragments(fragments)
		}
		else if operator == @operator() && type == OperandType.Number {
			for var operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}
		}
		else {
			@toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @enum {
			@toEnumFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			@toRuntimeFragments(fragments)
		}
	} # }}}
	toRuntimeFragments(fragments) { # {{{
		fragments.code($runtime.operator(this), `.\(@runtime())(`)

		for var operand, index in @operands {
			if index != 0 {
				fragments.code($comma)
			}

			fragments.compile(operand)
		}

		fragments.code(')')
	} # }}}
	type() => @type
	unflagExpectingEnum() { # {{{
		@expectingEnum = false
	} # }}}
}

abstract class NumericUnaryOperatorExpression extends UnaryOperatorExpression {
	private late {
		@isEnum: Boolean		= false
		@isNative: Boolean		= false
		@type: Type
	}
	abstract {
		operator(): Operator
		runtime(): String
		symbol(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if @isAcceptingEnum() && @argument.type().isEnum() {
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
	} # }}}
	isAcceptingEnum() => false
	native() => @symbol()
	toFragments(fragments, mode) { # {{{
		if @isEnum {
			fragments.code(@native(), @data.operator).wrap(@argument)
		}
		else if @isNative {
			fragments.code(@native(), @data.operator).wrap(@argument)
		}
		else {
			fragments.code($runtime.operator(this), `.\(@runtime())(`).compile(@argument).code(')')
		}
	} # }}}
	toQuote() => `\(@symbol())\(@argument.toQuote())`
	type() => @type
}

class BinaryOperatorDivision extends NumericBinaryOperatorExpression {
	operator() => Operator.Division
	runtime() => 'division'
	symbol() => '/'
}

class PolyadicOperatorDivision extends NumericPolyadicOperatorExpression {
	operator() => Operator.Division
	runtime() => 'division'
	symbol() => '/'
}

class BinaryOperatorModulo extends NumericBinaryOperatorExpression {
	operator() => Operator.Modulo
	runtime() => 'modulo'
	symbol() => '%'
}

class PolyadicOperatorModulo extends NumericPolyadicOperatorExpression {
	operator() => Operator.Modulo
	runtime() => 'modulo'
	symbol() => '%'
}

class BinaryOperatorMultiplication extends NumericBinaryOperatorExpression {
	operator() => Operator.Multiplication
	runtime() => 'multiplication'
	symbol() => '*'
}

class PolyadicOperatorMultiplication extends NumericPolyadicOperatorExpression {
	operator() => Operator.Multiplication
	runtime() => 'multiplication'
	symbol() => '*'
}

class BinaryOperatorQuotient extends NumericBinaryOperatorExpression {
	operator() => Operator.Quotient
	runtime() => 'quotient'
	symbol() => '/.'
	toNativeFragments(fragments) { # {{{
		fragments.code('Number.parseInt(').wrap(@left).code(' / ').wrap(@right).code(')')
	} # }}}
}

class PolyadicOperatorQuotient extends NumericPolyadicOperatorExpression {
	operator() => Operator.Quotient
	runtime() => 'quotient'
	symbol() => '/.'
	toNativeFragments(fragments) { # {{{
		var l = @operands.length - 1
		fragments.code('Number.parseInt('.repeat(l))

		fragments.wrap(@operands[0])

		for var operand in @operands from 1 {
			fragments.code(' / ').wrap(operand).code(')')
		}
	} # }}}
}

class BinaryOperatorSubtraction extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator.Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Subtraction {
			if type == OperandType.Enum {
				fragments.wrap(@left).code(' & ~').wrap(@right)
			}
			else {
				fragments.compile(@left).code($comma).compile(@right)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toEnumFragments(fragments) { # {{{
		if @expectingEnum {
			fragments.code(@type.name(), '(').wrap(@left).code(' & ~').wrap(@right).code(')')
		}
		else {
			fragments.wrap(@left).code(' & ~').wrap(@right)
		}
	} # }}}
}

class PolyadicOperatorSubtraction extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator.Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Subtraction {
			if type == OperandType.Enum {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code(' & ~')
					}

					fragments.wrap(operand)
				}
			}
			else {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code($comma)
					}

					fragments.compile(operand)
				}
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toEnumFragments(fragments) { # {{{
		if @expectingEnum {
			fragments.code(@type.name(), '(')
		}

		for var operand, index in @operands {
			if index != 0 {
				fragments.code(' & ~')
			}

			fragments.wrap(operand)
		}

		if @expectingEnum {
			fragments.code(')')
		}
	} # }}}
}

class UnaryOperatorNegative extends NumericUnaryOperatorExpression {
	operator() => Operator.Negative
	runtime() => 'negative'
	symbol() => '-'
}
