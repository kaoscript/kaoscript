abstract class PolyadicOperatorExpression extends Expression {
	private {
		@operands			= []
		@tested: Boolean	= false
	}
	abstract {
		symbol(): String
		operator(): Operator
	}
	analyse() { # {{{
		for var data in @data.operands ?? [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var operand in @operands {
			operand.prepare(target, targetMode)

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
		for var operand in @operands {
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
	left() => @operands[0]
	left(left): valueof this { # {{{
		@operands[0] = left
	} # }}}
	listAssignments(array: Array) { # {{{
		for var operand in @operands {
			operand.listAssignments(array)
		}

		return array
	} # }}}
	native() => @symbol()
	toFragments(fragments, mode) { # {{{
		var test = @isNullable() && !@tested
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
	toQuote() { # {{{
		var mut fragments = ''

		for var operand, index in @operands {
			if index != 0 {
				fragments += ` \(@symbol()) `
			}

			if operand.isComputed() {
				fragments += `(\(operand.toQuote()))`
			}
			else {
				fragments += operand.toQuote()
			}
		}

		return fragments
	} # }}}
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	private late {
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@number: Boolean			= false
		@string: Boolean			= false
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @operands[0].type().isEnum() {
			var name = @operands[0].type().discardValue().name()

			@enum = true

			for var operand in @operands from 1 {
				if !operand.type().isEnum() || operand.type().discardValue().name() != name {
					@enum = false

					break
				}
			}

			if @enum {
				@enum = true
				@number = @left().type().discard().isFlags()

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

				if operand.type().isString() {
					@string = true
				}
				else if operand.type().canBeString(false) && !operand.type().canBeNumber(false) {
					@string = true
					@native = false
				}
			}

			if !@string {
				@number = true

				var mut notNumber = null

				for var operand in @operands while @native || @number {
					if operand.type().isNumber() {
						pass
					}
					else if operand.type().isAny() {
						@number = false
						@native = false
					}
					else if operand.type().canBeNumber(false) {
						@native = false

						if operand.type().canBeString(false) {
							@number = false
						}
					}
					else if notNumber == null {
						notNumber = operand
					}
				}

				if @number && notNumber != null {
					TypeException.throwInvalidOperand(notNumber, Operator.Addition, this)
				}
			}

			if @number {
				@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
			}
			else if @string {
				@type = @scope.reference('String')
			}
			else {
				var numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

				@type = UnionType.new(@scope, [numberType, @scope.reference('String')], false)
			}
		}
	} # }}}
	isComputed() => @native
	operator() => Operator.Addition
	symbol() => '+'
	toOperandFragments(fragments, operator, type) { # {{{
		if operator == Operator.Addition {
			if type == OperandType.Enum && (@enum || @number) {
				for var operand, index in @operands {
					if index != 0 {
						fragments.code(' | ')
					}

					fragments.wrap(operand)
				}
			}
			else if ((@number && type == OperandType.Number) || (@string && type == OperandType.String)) {
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
		if @enum {
			var late operator: String

			if @number {
				operator = ' | '
			}
			else {
				operator = ' + '
			}

			if @expectingEnum {
				fragments.code(@type.name(), '(')
			}

			for var operand, index in @operands {
				if index != 0 {
					fragments.code(operator)
				}

				fragments.wrap(operand)
			}

			if @expectingEnum {
				fragments.code(')')
			}
		}
		else if @native {
			for var operand, index in @operands {
				if index != 0 {
					fragments.code($space).code('+', @data.operator).code($space)
				}

				fragments.wrap(operand)
			}
		}
		else {
			if @number {
				fragments.code($runtime.operator(this), '.addNum(')
			}
			else if @string {
				fragments.code($runtime.helper(this), '.concatString(')
			}
			else {
				fragments.code($runtime.operator(this), '.add(')
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
	type() => @type
	unflagExpectingEnum() { # {{{
		@expectingEnum = false
	} # }}}
}
