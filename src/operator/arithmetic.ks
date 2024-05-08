abstract class NumericBinaryOperatorExpression extends BinaryOperatorExpression {
	private late {
		@bitmask: Boolean				= false
		@expectingBitmask: Boolean		= true
		@native: Boolean				= false
		@type: Type
	}
	abstract {
		operator(): Operator
		runtime(): String
		symbol(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeBitmask() {
			@expectingBitmask = false
		}

		if @isAcceptingBitmask() && @left.type().isBitmask() && @right.type().isBitmask() && @left.type().discardValue().name() == @right.type().discardValue().name() {
			@bitmask = true

			if @expectingBitmask {
				@type = @left.type().discardValue()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingBitmask()
			@right.unflagExpectingBitmask()
		}
		else {
			if @left.type().isNumber() && @right.type().isNumber() {
				@native = true
			}
			else if @left.type().canBeNumber() {
				unless @right.type().canBeNumber() {
					TypeException.throwInvalidOperand(@right, @operator(), this)
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, @operator(), this)
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
	isAcceptingBitmask() => false
	isComputed() => @native || (@bitmask && !@expectingBitmask)
	native() => @symbol()
	setOperands(@left, @right, @bitmask = false, @expectingBitmask = false): valueof this
	toBitmaskFragments(fragments)
	toNativeFragments(fragments) { # {{{
		fragments.wrap(@left).code($space).code(@native(), @data.operator).code($space).wrap(@right)
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == @operator() && type == OperandType.Number {
			fragments.compile(@left).code($comma).compile(@right)
		}
		else {
			@toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @bitmask {
			@toBitmaskFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			fragments
				.code(`\($runtime.operator(this)).\(@runtime())(`)
				.compile(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
	type() => @type
	unflagExpectingBitmask() { # {{{
		@expectingBitmask = false
	} # }}}
}

abstract class NumericPolyadicOperatorExpression extends PolyadicOperatorExpression {
	private late {
		@bitmask: Boolean				= false
		@expectingBitmask: Boolean		= true
		@native: Boolean				= false
		@reusable: Boolean				= false
		@reuseName: String?				= null
		@type: Type
	}
	abstract {
		runtime(): String
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeBitmask() {
			@expectingBitmask = false
		}

		if @isAcceptingBitmask() && @operands[0].type().isBitmask() {
			var name = @operands[0].type().discardValue().name()

			@bitmask = true

			for var operand in @operands from 1 {
				if (operand.type().isBitmask() && operand.type().discardValue().name() != name) || !operand.type().isNumber() {
					@bitmask = false

					break
				}
			}

			if @bitmask {
				@native = true

				if @expectingBitmask {
					@type = @left().type().discardValue()
				}
				else {
					@type = @left().type().discard().type()
				}

				for var operand in @operands {
					operand.unflagExpectingBitmask()
				}
			}
		}

		if !@bitmask {
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
					TypeException.throwInvalidOperand(operand, @operator(), this)
				}
			}

			@type = if nullable set @scope.reference('Number').setNullable(true) else @scope.reference('Number')
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	isAcceptingBitmask() => false
	isComposite() => !@reusable
	isComputed() => !@reusable && (@native || ?@reuseName)
	releaseReusable() { # {{{
		@scope.releaseTempName(@reuseName) if ?@reuseName
	} # }}}
	toBitmaskFragments(fragments) { # {{{
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
		if @bitmask {
			@toBitmaskFragments(fragments)
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
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @bitmask {
			@toBitmaskFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			@toRuntimeFragments(fragments)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if ?@reuseName {
			fragments
				.code(@reuseName, $equals)
				.compile(this)

			@reusable = true
		}
		else {
			@toOperatorFragments(fragments)
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
	unflagExpectingBitmask() { # {{{
		@expectingBitmask = false
	} # }}}
}

abstract class NumericUnaryOperatorExpression extends UnaryOperatorExpression {
	private late {
		@isBitmask: Boolean		= false
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

		if @isAcceptingBitmask() && @argument.type().isBitmask() {
			@isBitmask = true

			@type = @argument.type()
		}
		else {
			if @argument.type().isNumber() {
				if @argument.type().isNullable() {
					TypeException.throwNotNullableOperand(@argument, @symbol(), this)
				}

				@isNative = true
			}
			else if !@argument.type().canBeNumber() {
				TypeException.throwInvalidOperand(@argument, @operator(), this)
			}

			@type = @scope.reference('Number')
		}
	} # }}}
	isAcceptingBitmask() => false
	native() => @symbol()
	toFragments(fragments, mode) { # {{{
		if @isBitmask {
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

class BinaryOperatorDivisionEuclidean extends NumericBinaryOperatorExpression {
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		@type = ArrayType.new(@scope)
			..addProperty(@scope.reference('Number'))
			..addProperty(@scope.reference('Number'))

		if !@native {
			@type = @type.setNullable(true)
		}
	} # }}}
	operator() => Operator.DivisionEuclidean
	runtime() => 'divisionEuclidean'
	symbol() => '/&'
	override toOperatorFragments(fragments) { # {{{
		fragments.code(`\($runtime.operator(this)).divisionEuclidean(`)

		for var operand, index in [@left, @right] {
			fragments
				.code($comma) if index != 0
				.code(if operand.type().isNumber() && !operand.type().isNullable() set '0' else '1')
				.code($comma).compile(operand)
		}

		fragments.code(')')
	} # }}}
}

class BinaryOperatorDivisionInteger extends NumericBinaryOperatorExpression {
	operator() => Operator.DivisionInteger
	runtime() => 'divisionInteger'
	symbol() => '/#'
	override toOperatorFragments(fragments) { # {{{
		if @native {
			fragments.code('Number.parseInt(').wrap(@left).code(' / ').wrap(@right).code(')')
		}
		else {
			fragments.code(`\($runtime.operator(this)).divisionInteger(`)

			for var operand, index in [@left, @right] {
				fragments
					.code($comma) if index != 0
					.code(if operand.type().isNumber() && !operand.type().isNullable() set '0' else '1')
					.code($comma).compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
}

class PolyadicOperatorDivisionInteger extends NumericPolyadicOperatorExpression {
	operator() => Operator.DivisionInteger
	runtime() => 'divisionInteger'
	symbol() => '/#'
	override toOperatorFragments(fragments) { # {{{
		fragments.code(`\($runtime.operator(this)).divisionInteger(`)

		for var operand, index in @operands {
			fragments
				.code($comma) if index != 0
				.code(if operand.type().isNumber() && !operand.type().isNullable() set '0' else '1')
				.code($comma).compile(operand)
		}

		fragments.code(')')
	} # }}}
}

class BinaryOperatorModulus extends NumericBinaryOperatorExpression {
	operator() => Operator.Modulus
	runtime() => 'modulus'
	symbol() => '%%'
	override toOperatorFragments(fragments) { # {{{
		fragments.code(`\($runtime.operator(this)).modulus(`)

		for var operand, index in [@left, @right] {
			fragments
				.code($comma) if index != 0
				.code(if operand.type().isNumber() && !operand.type().isNullable() set '0' else '1')
				.code($comma).compile(operand)
		}

		fragments.code(')')
	} # }}}
}

class PolyadicOperatorModulus extends NumericPolyadicOperatorExpression {
	operator() => Operator.Modulus
	runtime() => 'modulus'
	symbol() => '%%'
	override toOperatorFragments(fragments) { # {{{
		fragments.code(`\($runtime.operator(this)).modulus(`)

		for var operand, index in @operands {
			fragments
				.code($comma) if index != 0
				.code(if operand.type().isNumber() && !operand.type().isNullable() set '0' else '1')
				.code($comma).compile(operand)
		}

		fragments.code(')')
	} # }}}
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

class BinaryOperatorPower extends NumericBinaryOperatorExpression {
	operator() => Operator.Power
	runtime() => 'power'
	symbol() => '**'
}

class PolyadicOperatorPower extends NumericPolyadicOperatorExpression {
	operator() => Operator.Power
	runtime() => 'power'
	symbol() => '**'
}

class BinaryOperatorRemainder extends NumericBinaryOperatorExpression {
	operator() => Operator.Remainder
	runtime() => 'remainder'
	symbol() => '%'
}

class PolyadicOperatorRemainder extends NumericPolyadicOperatorExpression {
	operator() => Operator.Remainder
	runtime() => 'remainder'
	symbol() => '%'
}

class BinaryOperatorSubtraction extends NumericBinaryOperatorExpression {
	isAcceptingBitmask() => true
	operator() => Operator.Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toBitmaskFragments(fragments) { # {{{
		if @expectingBitmask {
			fragments.code(@type.name(), '(').wrap(@left).code(' & ~').wrap(@right).code(')')
		}
		else {
			fragments.wrap(@left).code(' & ~').wrap(@right)
		}
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Subtraction {
			if type == OperandType.Bitmask {
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
}

class PolyadicOperatorSubtraction extends NumericPolyadicOperatorExpression {
	isAcceptingBitmask() => true
	operator() => Operator.Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toBitmaskFragments(fragments) { # {{{
		if @expectingBitmask {
			fragments.code(@type.name(), '(')
		}

		for var operand, index in @operands {
			if index != 0 {
				fragments.code(' & ~')
			}

			fragments.wrap(operand)
		}

		if @expectingBitmask {
			fragments.code(')')
		}
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Subtraction {
			if type == OperandType.Bitmask {
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
}

class UnaryOperatorNegative extends NumericUnaryOperatorExpression {
	operator() => Operator.Negative
	runtime() => 'negative'
	symbol() => '-'
}
