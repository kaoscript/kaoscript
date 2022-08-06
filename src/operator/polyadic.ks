class PolyadicOperatorExpression extends Expression {
	private {
		_operands			= []
		_tested: Boolean	= false
	}
	analyse() { # {{{
		for var data in @data.operands {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
	prepare() { # {{{
		for var operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}
		}
	} # }}}
	translate() { # {{{
		for var operand in @operands {
			operand.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		for var operand in @operands {
			operand.acquireReusable(false)
			operand.releaseReusable()
		}
	} # }}}
	releaseReusable() { # {{{
	} # }}}
	hasExceptions() => false
	isComputed() => true
	isNullable() { # {{{
		for operand in @operands {
			if operand.isNullable() {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariable(name) { # {{{
		for var operand in @operands {
			if operand.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	listAssignments(array: Array<String>) { # {{{
		for var operand in @operands {
			operand.listAssignments(array)
		}

		return array
	} # }}}
	toFragments(fragments, mode) { # {{{
		var test = this.isNullable() && !@tested
		if test {
			fragments
				.compileNullable(this)
				.code(' ? ')
		}

		this.toOperatorFragments(fragments)

		if test {
			fragments.code(' : false')
		}
	} # }}}
	toNullableFragments(fragments) { # {{{
		if !@tested {
			var mut nf = false
			for var operand in @operands {
				if operand.isNullable() {
					if nf {
						fragments.code(' && ')
					}
					else {
						nf = true
					}

					fragments.compileNullable(operand)
				}
			}

			@tested = true
		}
	} # }}}
}

abstract class NumericPolyadicOperatorExpression extends PolyadicOperatorExpression {
	private late {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_type: Type
	}
	prepare() { # {{{
		super()

		if this.isAcceptingEnum() && @operands[0].type().isEnum() {
			var name = @operands[0].type().name()

			@isEnum = true

			for var operand in @operands from 1 {
				if !operand.type().isEnum() || operand.type().name() != name {
					@isEnum = false

					break
				}
			}

			if @isEnum {
				@type = @operands[0].type()
			}
		}

		if !@isEnum {
			var mut nullable = false

			@isNative = true

			for var operand in @operands {
				if operand.type().isNullable() {
					nullable = true
					@isNative = false
				}

				if operand.type().isNumber() {
				}
				else if operand.type().canBeNumber() {
					@isNative = false
				}
				else {
					TypeException.throwInvalidOperand(operand, this.operator(), this)
				}
			}

			@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
		}
	} # }}}
	translate() { # {{{
		super()

		if @isEnum {
			var type = @parent.type()

			if @parent is AssignmentOperatorEquality || @parent is VariableDeclaration {
				if type.isEnum() {
					if @type.name() != type.name() {
						@isEnum = false
						@isNative = true
					}
				}
				else if type.isNumber() {
					@isEnum = false
					@isNative = true
				}
			}
			else if type.isBoolean() || (type.isEnum() && @type.name() == type.name()) {
				@isEnum = false
				@isNative = true
			}
		}
	} # }}}
	isAcceptingEnum() => false
	isComputed() => @isNative
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toEnumFragments(fragments)
	toNativeFragments(fragments) { # {{{
		for var operand, index in @operands {
			if index != 0 {
				fragments.code($space).code(this.symbol(), @data.operator).code($space)
			}

			fragments.wrap(operand)
		}
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if @isEnum {
			this.toEnumFragments(fragments)
		}
		else if operator == this.operator() && type == OperandType::Number {
			for var operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @isEnum {
			fragments.code(@type.name(), '(')

			this.toEnumFragments(fragments)

			fragments.code(')')
		}
		else if @isNative {
			this.toNativeFragments(fragments)
		}
		else {
			fragments.code($runtime.operator(this), `.\(this.runtime())(`)

			for var operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		for var operand, index in @operands {
			if index != 0 {
				fragments += ` \(this.symbol()) `
			}

			fragments += operand.toQuote()
		}

		return fragments
	} # }}}
	type() => @type
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	private late {
		_expectingEnum: Boolean		= true
		_isEnum: Boolean			= false
		_isNative: Boolean			= false
		_isNumber: Boolean			= false
		_isString: Boolean			= false
		_type: Type
	}
	prepare() { # {{{
		super()

		if @operands[0].type().isEnum() {
			var name = @operands[0].type().name()

			@isEnum = true

			for var operand in @operands from 1 {
				if !operand.type().isEnum() || operand.type().name() != name {
					@isEnum = false

					break
				}
			}

			if @isEnum {
				if @expectingEnum {
					@type = @operands[0].type()
				}
				else {
					@type = @operands[0].type().discard().type()
				}
			}
		}

		if !@isEnum {
			var mut nullable = false

			@isNative = true

			for var operand in @operands {
				if operand.type().isNullable() {
					nullable = true
					@isNative = false
				}

				if operand.type().isString() {
					@isString = true
				}
				else if operand.type().canBeString(false) && !operand.type().canBeNumber(false) {
					@isString = true
					@isNative = false
				}
			}

			if !@isString {
				@isNumber = true

				var mut notNumber = null

				for var operand in @operands while @isNative || @isNumber {
					if operand.type().isNumber() {
					}
					else if operand.type().isAny() {
						@isNumber = false
						@isNative = false
					}
					else if operand.type().canBeNumber(false) {
						@isNative = false

						if operand.type().canBeString(false) {
							@isNumber = false
						}
					}
					else if notNumber == null {
						notNumber = operand
					}
				}

				if @isNumber && notNumber != null {
					TypeException.throwInvalidOperand(notNumber, Operator::Addition, this)
				}
			}

			if @isNumber {
				@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
			}
			else if @isString {
				@type = @scope.reference('String')
			}
			else {
				var numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

				@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
			}
		}
	} # }}}
	isComputed() => @isNative
	override setExpectedType(type) { # {{{
		if !type.isEnum() && (type.isNumber() || type.isString()) {
			@expectingEnum = false
		}
	} # }}}
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator::Addition {
			if type == OperandType::Enum && (@isEnum || @isNumber) {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code(' | ')
					}

					fragments.wrap(operand)
				}
			}
			else if ((@isNumber && type == OperandType::Number) || (@isString && type == OperandType::String)) {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code($comma)
					}

					fragments.compile(operand)
				}
			}
			else {
				this.toOperatorFragments(fragments)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} # }}}
	toOperatorFragments(fragments) { # {{{
		if @isEnum {
			var late operator: String

			if @operands[0].type().discard().isFlags() {
				operator = ' | '
			}
			else {
				operator = ' + '
			}

			if @expectingEnum {
				fragments.code(@type.name(), '(')

				for var operand, index in @operands {
					if index != 0 {
						fragments.code(operator)
					}

					fragments.wrap(operand)
				}

				fragments.code(')')
			}
			else {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code(operator)
					}

					fragments.wrap(operand)
				}
			}
		}
		else if @isNative {
			for var operand, index in @operands {
				if index != 0 {
					fragments.code($space).code('+', @data.operator).code($space)
				}

				fragments.wrap(operand)
			}
		}
		else {
			if @isNumber {
				fragments.code($runtime.operator(this), '.addition(')
			}
			else if @isString {
				fragments.code($runtime.helper(this), '.concatString(')
			}
			else {
				fragments.code($runtime.operator(this), '.addOrConcat(')
			}

			for var operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		for var operand, index in @operands {
			if index != 0 {
				fragments += ' + '
			}

			fragments += operand.toQuote()
		}

		return fragments
	} # }}}
	type() => @type
}

class PolyadicOperatorBitwiseAnd extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&'
	toEnumFragments(fragments) { # {{{
		for var operand, index in @operands {
			if index != 0 {
				fragments.code(' & ')
			}

			fragments.wrap(operand)
		}
	} # }}}
}

class PolyadicOperatorBitwiseLeftShift extends NumericPolyadicOperatorExpression {
	operator() => Operator::BitwiseLeftShift
	runtime() => 'bitwiseLeftShift'
	symbol() => '<<'
}

class PolyadicOperatorBitwiseOr extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseOr
	runtime() => 'bitwiseOr'
	symbol() => '|'
	toEnumFragments(fragments) { # {{{
		for var operand, index in @operands {
			if index != 0 {
				fragments.code(' & ')
			}

			fragments.wrap(operand)
		}
	} # }}}
}

class PolyadicOperatorBitwiseRightShift extends NumericPolyadicOperatorExpression {
	operator() => Operator::BitwiseRightShift
	runtime() => 'bitwiseRightShift'
	symbol() => '>>'
}

class PolyadicOperatorBitwiseXor extends NumericPolyadicOperatorExpression {
	operator() => Operator::BitwiseXor
	runtime() => 'bitwiseXor'
	symbol() => '^'
}

class PolyadicOperatorDivision extends NumericPolyadicOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/'
}

class PolyadicOperatorModulo extends NumericPolyadicOperatorExpression {
	operator() => Operator::Modulo
	runtime() => 'modulo'
	symbol() => '%'
}

class PolyadicOperatorMultiplication extends NumericPolyadicOperatorExpression {
	operator() => Operator::Multiplication
	runtime() => 'multiplication'
	symbol() => '*'
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	private late {
		_type: Type
	}
	analyse() { # {{{
		@operands = []
		for operand in @data.operands {
			@operands.push(operand = $compile.expression(operand, this))

			operand.analyse()
		}
	} # }}}
	prepare() { # {{{
		var types = []
		var last = @operands.length - 1

		var mut operandType, type, ne
		for operand, index in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if index < last {
				operand.acquireReusable(true)
				operand.releaseReusable()

				operandType = operand.type()
				if operandType.isNull() {
					operandType = operand.getDeclaredType().setNullable(false)
				}
				else {
					operandType = operandType.setNullable(false)
				}
			}
			else {
				operandType = operand.type()
			}

			ne = true

			for type in types while ne {
				if type.equals(operandType) {
					ne = false
				}
			}

			if ne {
				types.push(operandType)
			}
		}

		if types.length == 1 {
			@type = types[0]
		}
		else {
			@type = Type.union(@scope, ...types)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		this.module().flag('Type')

		var mut l = @operands.length - 1

		var mut operand
		for i from 0 til l {
			operand = @operands[i]

			if operand.isNullable() {
				fragments.code('(')

				operand.toNullableFragments(fragments)

				fragments
					.code(' && ' + $runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code('))')
			}
			else {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code(')')
			}

			fragments
				.code(' ? ')
				.compile(operand)
				.code(' : ')
		}

		fragments.compile(@operands[l])
	} # }}}
	type() => @type
}

class PolyadicOperatorQuotient extends NumericPolyadicOperatorExpression {
	operator() => Operator::Quotient
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

class PolyadicOperatorSubtraction extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator::Subtraction {
			if type == OperandType::Enum {
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
		for var operand, index in @operands {
			if index != 0 {
				fragments.code(' & ~')
			}

			fragments.wrap(operand)
		}
	} # }}}
}
