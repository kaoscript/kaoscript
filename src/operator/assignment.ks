abstract class AssignmentOperatorExpression extends Expression {
	private late {
		@await: Boolean				= false
		@bindingScope: Scope
		@left						= null
		@right						= null
		@type: Type
	}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)

		if !@isAssigningBinding() && (@left is ArrayBinding || @left is ObjectBinding) {
			SyntaxException.throwUnsupportedDestructuringAssignment(this)
		}

		if @isDeclararing() {
			@left.setAssignment(AssignmentType::Expression)
		}

		@left.analyse()

		@bindingScope = @newScope(@scope, ScopeType::Hollow)

		@right = $compile.expression(@data.right, this, @bindingScope)

		@right.analyse()

		@await = @right.isAwait()

		if @isDeclararing() {
			@defineVariables(@left)
		}
	} # }}}
	override prepare(target) { # {{{
		@left.flagAssignable()

		@validate(target)

		@left.prepare(target)

		if var variable ?= @left.variable() {
			@type = variable.getDeclaredType()
		}
		else {
			@type = @left.type()
		}

		if !target.isVoid() {
			if @type.isAssignableToVariable(target, false, false, false) {
				// do nothing
			}
			else if target.isAssignableToVariable(@type, true, true, false) {
				@type = target
			}
			else {
				TypeException.throwUnexpectedExpression(this, target, this)
			}
		}

		@right.prepare(@type)

		var type = @right.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}
	} # }}}
	translate() { # {{{
		@left.translate()
		@right.translate()
	} # }}}
	defineVariables(left) { # {{{
		var statement = @statement()

		statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
	} # }}}
	isAssigningBinding() => false
	isAwait() => @await
	isAwaiting() => @right.isAwaiting()
	isComputed() => true
	isDeclararing() => false
	isDeclararingVariable(name: String) => @isDeclararing() && @left.isDeclararingVariable(name)
	isExpectingType() => @left.isExpectingType()
	isImmutable(variable) => variable.isImmutable()
	isNullable() => @right.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	isUsingInstanceVariable(name) => @left.isUsingInstanceVariable(name) || @right.isUsingInstanceVariable(name)
	isUsingStaticVariable(class, varname) => @left.isUsingStaticVariable(class, varname) || @right.isUsingStaticVariable(class, varname)
	listAssignments(array: Array<String>) => @left.listAssignments(@right.listAssignments(array))
	setAssignment(assignment)
	toNullableFragments(fragments) { # {{{
		fragments.compileNullable(@right)
	} # }}}
	validate(target: Type) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || @parent is ExpressionStatement
	} # }}}
	variable() => @left.variable()
}

abstract class NumericAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean			= false
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
	}
	override prepare(target) { # {{{
		super(target)

		if !target.isVoid() && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@enum = true

			@type = @left.type()

			if @expectingEnum {
				@type = @left.type()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingEnum()
			@right.unflagExpectingEnum()

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()
				}

				var newLeft = new BinaryOperatorSubtraction(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), enum: true, expectingEnum: false)

				leftMost.left(newLeft)

				@adjusted = true
			}
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

			if @left is IdentifierLiteral {
				@left.type(@type, @scope, this)
			}
		}
	} # }}}
	isAcceptingEnum() => false
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @enum && @expectingEnum {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @enum {
			@toEnumFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			fragments
				.compile(@left)
				.code(' = ')
				.code($runtime.operator(this), `.\(@runtime())(`)
				.compile(@left)
				.code($comma)

			@right.toOperandFragments(fragments, this.operator(), OperandType::Number)

			fragments.code(')')
		}
	} # }}}
	toEnumFragments(fragments)
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(@symbol(), @data.operator).code($space).compile(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean			= false
		@enum: Boolean				= false
		@expectingEnum: Boolean		= true
		@native: Boolean			= false
		@number: Boolean			= false
		@string: Boolean			= false
	}
	override prepare(target) { # {{{
		super(target)

		if !target.isVoid() && !target.canBeEnum() {
			@expectingEnum = false
		}

		if @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@enum = true
			@number = @left.type().discard().isFlags()

			if @expectingEnum {
				@type = @left.type()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingEnum()
			@right.unflagExpectingEnum()

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()
				}

				var newLeft = new BinaryOperatorAddition(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), enum: true, number: @number, expectingEnum: false)

				leftMost.left(newLeft)

				@adjusted = true
			}
		}
		else {
			if @left.type().isString() || @right.type().isString() {
				@string = true
				@native = true
			}
			else if @left.type().isNumber() && @right.type().isNumber() {
				@number = true
				@native = true
			}
			else if (@left.type().canBeString(false) && !@left.type().canBeNumber(false)) || (@right.type().canBeString(false) && !@right.type().canBeNumber(false)) {
				@string = true
			}
			else if @left.type().isAny() || @right.type().isAny() {
			}
			else if @left.type().canBeNumber() {
				if !@left.type().canBeString(false) {
					if @right.type().canBeNumber() {
						if !@right.type().canBeString(false) {
							@number = true
						}
					}
					else {
						TypeException.throwInvalidOperand(@right, Operator::Addition, this)
					}
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, Operator::Addition, this)
			}

			var nullable = @left.type().isNullable() || @right.type().isNullable()
			if nullable {
				@native = false
			}

			if @number {
				@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
			}
			else if @string {
				@type = @scope.reference('String')
			}
			else {
				var numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

				@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
			}
		}

		if @left is IdentifierLiteral {
			@left.type(@type, @scope, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @enum && @expectingEnum {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @enum {
			fragments.compile(@left).code($equals, @type.name(), '(').compile(@left)

			if @number {
				fragments.code(' | ')
			}
			else {
				fragments.code(' + ')
			}

			@right.toOperandFragments(fragments, Operator::Addition, OperandType::Enum)

			fragments.code(')')
		}
		else if @native {
			fragments.compile(@left).code(' += ').compile(@right)
		}
		else {
			fragments.compile(@left).code($equals)

			var mut type
			if @number {
				fragments.code($runtime.operator(this), '.addNum(')

				type = OperandType::Number
			}
			else if @string {
				fragments.code($runtime.helper(this), '.concatString(')

				type = OperandType::String
			}
			else {
				fragments.code($runtime.operator(this), '.add(')

				type = OperandType::Any
			}

			fragments.compile(@left).code($comma)

			@right.toOperandFragments(fragments, Operator::Addition, type)

			fragments.code(')')
		}
	} # }}}
	type() => @type
}

class AssignmentOperatorDivision extends NumericAssignmentOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/='
}


class AssignmentOperatorLeftShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::LeftShift
	runtime() => 'leftShift'
	symbol() => '<<='
}

class AssignmentOperatorModulo extends NumericAssignmentOperatorExpression {
	operator() => Operator::Modulo
	runtime() => 'modulo'
	symbol() => '%='
}

class AssignmentOperatorMultiplication extends NumericAssignmentOperatorExpression {
	operator() => Operator::Multiplication
	runtime() => 'multiplication'
	symbol() => '*='
}

class AssignmentOperatorQuotient extends NumericAssignmentOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.='
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($equals).code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} # }}}
}
class AssignmentOperatorRightShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::RightShift
	runtime() => 'rightShift'
	symbol() => '>>='
}

class AssignmentOperatorSubtraction extends NumericAssignmentOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-='
	toEnumFragments(fragments) { # {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ~')

		@right.toOperandFragments(fragments, Operator::Subtraction, OperandType::Enum)

		fragments.code(')')
	} # }}}
}
