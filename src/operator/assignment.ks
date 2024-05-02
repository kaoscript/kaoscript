abstract class AssignmentOperatorExpression extends Expression {
	private late {
		@await: Boolean				= false
		@bindingScope: Scope
		@declaration: Boolean		= false
		@left						= null
		@right						= null
		@type: Type
		@valueScope: Scope?
	}
	constructor(@data, @parent, @scope, @valueScope = null) { # {{{
		super(data, parent, scope)
	} # }}}
	analyse() { # {{{
		@left = $compile.expression(@data.left, this)

		if !@isAssigningBinding() && (@left is ArrayBinding || @left is ObjectBinding) {
			SyntaxException.throwUnsupportedDestructuringAssignment(this)
		}

		if @isDeclararing() {
			@left.setAssignment(AssignmentType.Expression)
		}

		@left.analyse()

		@bindingScope = @newScope(@valueScope ?? @scope!?, ScopeType.Hollow)

		@right = $compile.expression(@data.right, this, @bindingScope)

		@right.analyse()

		@await = @right.isAwait()

		if @isDeclararing() {
			@defineVariables(@left)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if !@declaration {
			@left.flagAssignable()
		}

		@validate(target)

		@left.prepare(target, targetMode)

		if var variable ?= @left.variable() {
			@type = variable.getDeclaredType()
		}
		else {
			@type = @left.type()
		}

		if !target.isVoid() {
			if @type.isAssignableToVariable(target, false, false, false) {
				pass
			}
			else if target.isAssignableToVariable(@type, true, true, false) {
				@type = target
			}
		}

		@right.prepare(@type, targetMode)

		if @right.isDerivative() {
			TypeException.throwNotUniqueValue(@right, this)
		}

		var type = @right.type().discardValue()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}

		if !target.isVoid() && !type.isAssignableToVariable(target, true, false, false) {
			TypeException.throwUnexpectedExpression(this, target, this)
		}

		if @left.isLiberal() {
			@left.setPropertyType(type)
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
	flagDeclaration() { # {{{
		@declaration = true
	} # }}}
	getRightType() => @type
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
	left(): valueof @left
	listAssignments(array: Array) => @left.listAssignments(@right.listAssignments(array))
	right(): valueof @right
	setAssignment(assignment)
	toNullableFragments(fragments) { # {{{
		fragments.compileNullable(@right)
	} # }}}
	type() => Type.Void
	validate(target: Type) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || @parent is ExpressionStatement
	} # }}}
	variable() => @left.variable()
	protected isInDestructor() { # {{{
		if @parent is not ExpressionStatement {
			return false
		}

		var dyn parent = @parent

		while ?parent {
			parent = parent.parent()

			if parent is ClassDestructorDeclaration {
				return true
			}
		}

		return false
	} # }}}
}

abstract class NumericAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean				= false
		@bitmask: Boolean				= false
		@expectingBitmask: Boolean		= true
		@native: Boolean				= false
		@tests: Boolean[]				= []
	}
	abstract {
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

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()!!
				}

				var newLeft = BinaryOperatorSubtraction.new(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), bitmask: true, expectingBitmask: false)

				leftMost.left(newLeft)

				@adjusted = true
			}
		}
		else {
			for var operand in [@left, @right] {
				@tests.push(operand.type().isNumber() && !operand.type().isNullable() ? '0' : '1')
			}

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
	isAcceptingBitmask() => false
	native() => @symbol()
	toBitmaskFragments(fragments)
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @bitmask && @expectingBitmask {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @bitmask {
			@toBitmaskFragments(fragments)
		}
		else if @native {
			@toNativeFragments(fragments)
		}
		else {
			fragments
				.compile(@left)
				.code(' = ')
				.code(`\($runtime.operator(this)).\(@runtime())(`)
				.compile(@left)
				.code($comma)

			@right.toOperandFragments(fragments, @operator(), OperandType.Number)

			fragments.code(')')
		}
	} # }}}
	toNativeFragments(fragments) { # {{{
		fragments.compile(@left).code($space).code(@native(), @data.operator).code($space).compile(@right)
	} # }}}
	toQuote() => `\(@left.toQuote()) \(@symbol()) \(@right.toQuote())`
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	private late {
		@adjusted: Boolean				= false
		@bitmask: Boolean				= false
		@expectingBitmask: Boolean		= true
		@native: Boolean				= false
		@number: Boolean				= false
		@string: Boolean				= false
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		if !target.isVoid() && !target.canBeBitmask() {
			@expectingBitmask = false
		}

		if @left.type().isBitmask() && @right.type().isBitmask() && @left.type().discardValue().name() == @right.type().discardValue().name() {
			@bitmask = true

			if @expectingBitmask {
				@type = @left.type().discardValue()
			}
			else {
				@type = @left.type().discard().type()
			}

			@left.unflagExpectingBitmask()
			@right.unflagExpectingBitmask()

			if @right is BinaryOperatorExpression | PolyadicOperatorExpression {
				var mut leftMost = @right

				while leftMost.left() is BinaryOperatorExpression | PolyadicOperatorExpression {
					leftMost = leftMost.left()!!
				}

				var newLeft = BinaryOperatorAddition.new(@data, leftMost, @scope)

				newLeft.setOperands(@left, leftMost.left(), bitmask: true, number: @number, expectingBitmask: false)

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
						TypeException.throwInvalidOperand(@right, Operator.Addition, this)
					}
				}
			}
			else {
				TypeException.throwInvalidOperand(@left, Operator.Addition, this)
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

				@type = UnionType.new(@scope, [numberType, @scope.reference('String')], false)
			}
		}

		if @left is IdentifierLiteral {
			@left.type(@type, @scope, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @adjusted {
			if @bitmask && @expectingBitmask {
				fragments.compile(@left).code($equals, @type.name(), '(').compile(@right).code(')')
			}
			else {
				fragments.compile(@left).code($equals).compile(@right)
			}
		}
		else if @bitmask {
			fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' | ')

			@right.toOperandFragments(fragments, Operator.Addition, OperandType.Bitmask)

			fragments.code(')')
		}
		else if @native {
			fragments.compile(@left).code(' += ').compile(@right)
		}
		else {
			fragments.compile(@left).code($equals)

			var late type
			if @number {
				fragments.code($runtime.operator(this), '.addNum(')

				type = OperandType.Number
			}
			else if @string {
				fragments.code($runtime.helper(this), '.concatString(')

				type = OperandType.String
			}
			else {
				fragments.code($runtime.operator(this), '.add(')

				type = OperandType.Any
			}

			fragments.compile(@left).code($comma)

			@right.toOperandFragments(fragments, Operator.Addition, type)

			fragments.code(')')
		}
	} # }}}
	toQuote() => `\(@left.toQuote()) += \(@right.toQuote())`
}

class AssignmentOperatorDivision extends NumericAssignmentOperatorExpression {
	operator() => Operator.Division
	runtime() => 'division'
	symbol() => '/='
}

class AssignmentOperatorDivisionInteger extends NumericAssignmentOperatorExpression {
	operator() => Operator.DivisionInteger
	runtime() => 'division'
	symbol() => '/#='
	override toFragments(fragments, mode) { # {{{
		if @native {
			fragments.compile(@left).code($equals).code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
		}
		else {
			fragments.compile(@left).code(' = ').code(`\($runtime.operator(this)).modulus(`)

			for var operand, index in [@left, @right] {
				fragments
					.code($comma) if index != 0
					.code(@tests[index])
					.code($comma).compile(operand)
			}

			fragments.code(')')
		}
	} # }}}
}

class AssignmentOperatorModulus extends NumericAssignmentOperatorExpression {
	operator() => Operator.Modulus
	runtime() => 'modulus'
	symbol() => '%%='
	override toFragments(fragments, mode) { # {{{
		fragments.compile(@left).code(' = ').code(`\($runtime.operator(this)).modulus(`)

		for var operand, index in [@left, @right] {
			fragments
				.code($comma) if index != 0
				.code(@tests[index])
				.code($comma).compile(operand)
		}

		fragments.code(')')
	} # }}}
}

class AssignmentOperatorMultiplication extends NumericAssignmentOperatorExpression {
	operator() => Operator.Multiplication
	runtime() => 'multiplication'
	symbol() => '*='
}

class AssignmentOperatorPower extends NumericAssignmentOperatorExpression {
	operator() => Operator.Power
	runtime() => 'power'
	symbol() => '**='
}

class AssignmentOperatorRemainder extends NumericAssignmentOperatorExpression {
	operator() => Operator.Remainder
	runtime() => 'remainder'
	symbol() => '%='
}

class AssignmentOperatorSubtraction extends NumericAssignmentOperatorExpression {
	isAcceptingBitmask() => true
	operator() => Operator.Subtraction
	runtime() => 'subtraction'
	symbol() => '-='
	toBitmaskFragments(fragments) { # {{{
		fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code(' & ~')

		@right.toOperandFragments(fragments, Operator.Subtraction, OperandType.Bitmask)

		fragments.code(')')
	} # }}}
}
