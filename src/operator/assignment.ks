class AssignmentOperatorExpression extends Expression {
	private {
		_await: Boolean				= false
		_left						= null
		_right						= null
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)

		if this.isDeclararing() {
			@left.setAssignment(AssignmentType::Expression)
		}

		@left.analyse()

		@right = $compile.expression(@data.right, this)

		@right.setAssignment(AssignmentType::Expression)

		@right.analyse()

		@await = @right.isAwait()

		if this.isDeclararing() {
			this.defineVariables(@left)
		}
		else {
			if @left is IdentifierLiteral {
				if const variable = @scope.getVariable(@left.name()) {
					if variable.isImmutable() {
						ReferenceException.throwImmutable(@left.name(), this)
					}
				}
			}
		}
	} // }}}
	prepare() { // {{{
		@left.prepare()

		unless @left.isAssignable() {
			ReferenceException.throwInvalidAssignment(this)
		}

		@right.prepare()

		if @right.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	defineVariables(left) { // {{{
		let leftMost = true
		let expression = this

		while expression.parent() is not Statement {
			expression = expression.parent()
			leftMost = false
		}

		expression.parent().defineVariables(left, @scope, expression, leftMost)
	} // }}}
	isAwait() => @await
	isAwaiting() => @right.isAwaiting()
	isComputed() => true
	isDeclararing() => false
	isDeclararingVariable(name: String) => this.isDeclararing() && @left.isDeclararingVariable(name)
	isNullable() => @right.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	listAssignments(array) => @left.listAssignments(@right.listAssignments(array))
	setAssignment(assignment)
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(@right)
	} // }}}
	variable() => @left.variable()
}

abstract class NumericAssignmentOperatorExpression extends AssignmentOperatorExpression {
	private {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if this.isAcceptingEnum() && @left.type().isEnum() && @right.type().isEnum() && @left.type().name() == @right.type().name() {
			@isEnum = true

			@type = @left.type()
		}
		else {
			if @left.type().isNumber() && @right.type().isNumber() {
				@isNative = true
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

				@isNative = false
			}
			else {
				@type = @scope.reference('Number')
			}

			if @left is IdentifierLiteral {
				@left.type(@type, @scope, this)
			}
		}
	} // }}}
	getBinarySymbol() => ''
	isAcceptingEnum() => false
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toFragments(fragments, mode) { // {{{
		if @isEnum {
			fragments.compile(@left).code($equals, @type.name(), '(').compile(@left).code($space, this.getBinarySymbol(), $space).compile(@right).code(')')
		}
		else if @isNative {
			this.toNativeFragments(fragments)
		}
		else {
			fragments
				.compile(@left)
				.code(' = ')
				.code($runtime.operator(this), `.\(this.runtime())(`)
				.compile(@left)
				.code($comma)

			@right.toOperandFragments(fragments, this.operator(), OperandType::Number)

			fragments.code(')')
		}
	} // }}}
	toNativeFragments(fragments) { // {{{
		fragments.compile(@left).code($space).code(this.symbol(), @data.operator).code($space).compile(@right)
	} // }}}
	toQuote() => `\(@left.toQuote()) \(this.symbol()) \(@right.toQuote())`
	type() => @type
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	private {
		_isNative: Boolean		= false
		_isNumber: Boolean		= false
		_isString: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if @left.type().isString() || @right.type().isString() {
			@isString = true
			@isNative = true
		}
		else if @left.type().isNumber() && @right.type().isNumber() {
			@isNumber = true
			@isNative = true
		}
		else if (@left.type().canBeString(false) && !@left.type().canBeNumber(false)) || (@right.type().canBeString(false) && !@right.type().canBeNumber(false)) {
			@isString = true
		}
		else if @left.type().isAny() || @right.type().isAny() {
		}
		else if @left.type().canBeNumber() {
			if !@left.type().canBeString(false) {
				if @right.type().canBeNumber() {
					if !@right.type().canBeString(false) {
						@isNumber = true
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

		const nullable = @left.type().isNullable() || @right.type().isNullable()
		if nullable {
			@isNative = false
		}

		if @isNumber {
			@type = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')
		}
		else if @isString {
			@type = @scope.reference('String')
		}
		else {
			const numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

			@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
		}

		if @left is IdentifierLiteral {
			@left.type(@type, @scope, this)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @isNative {
			fragments.compile(@left).code(' += ').compile(@right)
		}
		else {
			fragments.compile(@left).code(' = ')

			let type
			if @isNumber {
				fragments.code($runtime.operator(this), '.addition(')

				type = OperandType::Number
			}
			else if @isString {
				fragments.code($runtime.helper(this), '.concatString(')

				type = OperandType::String
			}
			else {
				fragments.code($runtime.operator(this), '.addOrConcat(')

				type = OperandType::Any
			}

			fragments.compile(@left).code($comma)

			@right.toOperandFragments(fragments, Operator::Addition, type)

			fragments.code(')')
		}
	} // }}}
	type() => @type
}

class AssignmentOperatorBitwiseAnd extends NumericAssignmentOperatorExpression {
	getBinarySymbol() => '&'
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&='
}

class AssignmentOperatorBitwiseLeftShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseLeftShift
	runtime() => 'bitwiseLeftShift'
	symbol() => '<<='
}

class AssignmentOperatorBitwiseOr extends NumericAssignmentOperatorExpression {
	getBinarySymbol() => '|'
	isAcceptingEnum() => true
	operator() => Operator::BitwiseOr
	runtime() => 'bitwiseOr'
	symbol() => '|='
}

class AssignmentOperatorBitwiseRightShift extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseRightShift
	runtime() => 'bitwiseRightShift'
	symbol() => '>>='
}

class AssignmentOperatorBitwiseXor extends NumericAssignmentOperatorExpression {
	operator() => Operator::BitwiseXor
	runtime() => 'bitwiseXor'
	symbol() => '^='
}

class AssignmentOperatorDivision extends NumericAssignmentOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/='
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	private {
		_ignorable: Boolean		= false
	}
	prepare() { // {{{
		super()

		if @left is IdentifierLiteral {
			@left.type(@right.type(), @scope, this)

			if @right is IdentifierLiteral || @right is BinaryOperatorTypeCasting {
				@ignorable = @left.name() == @right.name()
			}
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@right.acquireReusable(@left.isSplitAssignment())
	} // }}}
	hasExceptions() => @right.isAwaiting() && @right.hasExceptions()
	isAssignable() => @left.isAssignable()
	isDeclarable() => @left.isDeclarable()
	isDeclararing() => true
	isIgnorable() => @ignorable
	releaseReusable() { // {{{
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @right.isAwaiting() {
			return @right.toFragments(fragments, mode)
		}
		else if @left.isUsingSetter() {
			@left.toSetterFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		fragments.compile(@left).code($equals).wrap(@right)
	} // }}}
	toQuote() => `\(@left.toQuote()) = \(@right.toQuote())`
	type() => @left.type()
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	prepare() { // {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			@left.type(@right.type().setNullable(false), @scope, this)
		}
	} // }}}
	inferTypes() { // {{{
		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} // }}}
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments.code(' ? ')

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments.code(' ? (')

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} // }}}
	toQuote() { // {{{
		return `\(@left.toQuote()) ?= \(@right.toQuote())`
	} // }}}
	type() => @scope.reference('Boolean')
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

class AssignmentOperatorNonExistential extends AssignmentOperatorExpression {
	prepare() { // {{{
		super()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			@left.type(@right.type().setNullable(false), @scope, this)
		}
	} // }}}
	inferContraryTypes(isExit) { // {{{
		if !isExit {
			return {}
		}

		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @right.type().setNullable(false)
			}
		}

		return inferables
	} // }}}
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(' : null')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? (')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(', false) : true')
	} // }}}
	type() => @scope.reference('Boolean')
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
		}

		fragments
			.code(' ? null : ')
			.compile(@left)
			.code($equals)
			.compile(@right)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

		ctrl.code('if(!')

		if @left.isNullable() {
			ctrl.code('(')

			@left.toNullableFragments(ctrl)

			ctrl
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
		}

		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} // }}}
}

class AssignmentOperatorQuotient extends NumericAssignmentOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.='
	toNativeFragments(fragments) { // {{{
		fragments.compile(@left).code($equals).code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} // }}}
}

class AssignmentOperatorSubtraction extends NumericAssignmentOperatorExpression {
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-='
}