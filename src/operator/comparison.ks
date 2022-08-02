class ComparisonExpression extends Expression {
	private {
		_await: Boolean				= false
		_composite: Boolean			= false
		_computed: Boolean			= true
		_junction: String			= ' && '
		_junctive: Boolean			= false
		_operands					= []
		_operators					= []
		_reuseName: String?			= null
		_tested: Boolean			= false
	}
	analyse() { # {{{
		var mut operand1, operand2, operator

		operand1 = this.addOperand(@data.values[0])

		if @data.values.length == 3 {
			var value = @data.values[2]

			if value.kind == NodeKind::JunctionExpression {
				@junctive = true

				for var operand in value.operands {
					this.addOperator(@data.values[1], operand1, this.addOperand(operand))
				}

				if value.operator.kind == BinaryOperatorKind::And {
					@junction = ' && '
				}
				else if value.operator.kind == BinaryOperatorKind::Or {
					@junction = ' || '
				}
				else {
					@junction = 'xor'
				}
			}
			else {
				this.addOperator(@data.values[1], operand1, this.addOperand(@data.values[2]))
			}
		}
		else {
			for var i from 1 til @data.values.length by 2 {
				operand2 = this.addOperand(@data.values[i + 1])

				this.addOperator(@data.values[i], operand1, operand2)

				operand1 = operand2
			}
		}
	} # }}}
	prepare() { # {{{
		for var operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}
		}

		for var operator in @operators {
			operator.prepare()
		}

		if @operators.length == 1 {
			@computed = @operators[0].isComputed()
		}
	} # }}}
	translate() { # {{{
		for var operand in @operands {
			operand.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if @junctive {
			if @operands[0].isComposite() {
				@composite = true

				@reuseName = @scope.acquireTempName()
			}
		}
		else {
			if @operators.length > 1 {
				for var operand in @operands from 1 til -1 until @composite {
					@composite = operand.isComposite()
				}

				if @composite {
					@reuseName = @scope.acquireTempName()
				}
			}
		}

		for var operand in @operands {
			operand.acquireReusable(acquire)
		}
	} # }}}
	private addOperand(data) { # {{{
		var operand = $compile.expression(data, this)

		operand.analyse()

		@operands.push(operand)

		if operand.isAwait() {
			@await = true
		}

		return operand
	} # }}}
	private addOperator(data, operand1, operand2) { # {{{
		var operator = this.getOperator(data, operand1, operand2)

		@operators.push(operator)
	} # }}}
	private getOperator(data, operand1, operand2) { # {{{
		switch data.kind {
			BinaryOperatorKind::Equality => return new EqualityOperator(this, operand1, operand2)
			BinaryOperatorKind::GreaterThan => return new GreaterThanOperator(this, operand1, operand2)
			BinaryOperatorKind::GreaterThanOrEqual => return new GreaterThanOrEqualOperator(this, operand1, operand2)
			BinaryOperatorKind::Inequality => return new InequalityOperator(this, operand1, operand2)
			BinaryOperatorKind::LessThan => return new LessThanOperator(this, operand1, operand2)
			BinaryOperatorKind::LessThanOrEqual => return new LessThanOrEqualOperator(this, operand1, operand2)
		}
	} # }}}
	hasExceptions() => false
	inferTypes(inferables) { # {{{
		if @operators.length == 1 {
			return @operators[0].inferTypes(inferables)
		}
		else {
			return inferables
		}
	} # }}}
	inferWhenFalseTypes(inferables) { # {{{
		if @operators.length == 1 {
			return @operators[0].inferWhenFalseTypes(inferables)
		}
		else {
			return inferables
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @operators.length == 1 {
			return @operators[0].inferWhenTrueTypes(inferables)
		}
		else {
			return inferables
		}
	} # }}}
	isComputed() => @computed
	isNullable() { # {{{
		for var operand in @operands {
			if operand.isNullable() {
				return true
			}
		}

		return false
	} # }}}
	isNullableComputed() { # {{{
		var mut nullable = true

		for var operand in @operands {
			if operand.isNullableComputed() {
				return true
			}
			else if !operand.isNullable() {
				nullable = false
			}
		}

		return nullable
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
	releaseReusable() { # {{{
		if @composite {
			@scope.releaseTempName(@reuseName)
		}

		for var operand in @operands {
			operand.releaseReusable()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @await {
			NotSupportedException.throw(this)
		}

		var test = this.isNullable() && !@tested
		if test {
			fragments.wrapNullable(this).code(' ? ')
		}

		if @junctive {
			if @junction == 'xor' {
				fragments.code($runtime.operator(this), '.xor(')

				@operators[0].toOperatorFragments(fragments, @reuseName, true, true, false, false)

				for var operator in @operators from 1 {
					fragments.code($comma)

					operator.toOperatorFragments(fragments, @reuseName, true, false, false, false)
				}

				fragments.code(')')
			}
			else {
				@operators[0].toOperatorFragments(fragments, @reuseName, true, true, false, false)

				for var operator in @operators from 1 {
					fragments.code(@junction)

					operator.toOperatorFragments(fragments, @reuseName, true, false, false, false)
				}
			}
		}
		else {
			@operators[0].toOperatorFragments(fragments, @reuseName, false, false, true, true)

			if @operators.length > 1 {
				for var operator in @operators from 1 til -1 {
					fragments.code(@junction)

					operator.toOperatorFragments(fragments, @reuseName, true, false, true, true)
				}

				fragments.code(@junction)

				@operators[@operators.length - 1].toOperatorFragments(fragments, @reuseName, true, false, false, false)
			}
		}

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
	type() => @scope.reference('Boolean')
}

abstract class ComparisonOperator {
	private {
		_left
		_node
		_right
	}
	constructor(@node, @left, @right)
	prepare()
	inferTypes(inferables) => @right.inferTypes(@left.inferTypes(inferables))
	inferWhenFalseTypes(inferables) => this.inferTypes(inferables)
	inferWhenTrueTypes(inferables) => this.inferTypes(inferables)
	isComputed() => true
}

class EqualityOperator extends ComparisonOperator {
	private {
		_enumLeft: Boolean		= false
		_enumRight: Boolean		= false
		_infinity: Boolean		= false
		_nanLeft: Boolean		= false
		_nanRight: Boolean		= false
	}
	prepare() { # {{{
		var leftType = @left.type()
		var rightType = @right.type()

		if leftType.isEnum() && @left is not NumericBinaryOperatorExpression {
			@enumLeft = true
		}
		else if @left is IdentifierLiteral {
			if @left.value() == 'NaN' {
				@nanLeft = true
			}
			else if @left.value() == 'Infinity' {
				@infinity = true
			}
		}
		else if @left is UnaryOperatorNegative && @left.argument() is IdentifierLiteral {
			@infinity = @left.argument().value() == 'Infinity'
		}

		if rightType.isNull() {
			unless leftType.isNullable() || @left.isLateInit() || @node._options.rules.ignoreMisfit {
				TypeException.throwInvalidComparison(@left, @right, @node)
			}

			@enumLeft = false
		}
		else {
			if leftType.isNull() {
				unless rightType.isNullable() || @right.isLateInit() || @node._options.rules.ignoreMisfit {
					TypeException.throwInvalidComparison(@left, @right, @node)
				}
			}
			else {
				if !leftType.isAssignableToVariable(rightType, false) && !rightType.isAssignableToVariable(leftType, false) {
					if leftType.isEnum() {
						unless leftType.isComparableWith(rightType) {
							TypeException.throwInvalidComparison(@left, @right, @node)
						}
					}
					else if rightType.isEnum() {
						unless rightType.isComparableWith(leftType) {
							TypeException.throwInvalidComparison(@left, @right, @node)
						}
					}
					else {
						TypeException.throwInvalidComparison(@left, @right, @node)
					}
				}

				if rightType.isEnum() && @right is not NumericBinaryOperatorExpression {
					@enumRight = true
				}
				else if @right is IdentifierLiteral {
					if @right.value() == 'NaN' {
						@nanRight = true
					}
					else if @right.value() == 'Infinity' {
						@infinity = true
					}
				}
				else if @right is UnaryOperatorNegative && @right.argument() is IdentifierLiteral {
					@infinity = @right.argument().value() == 'Infinity'
				}
			}
		}

		if @enumLeft && @enumRight {
			@enumLeft = @enumRight = false
		}
	} # }}}
	isComputed() => !@nanLeft && !@nanRight
	inferWhenFalseTypes(inferables) { # {{{
		if @left is IdentifierLiteral && @left.value() == 'null' && @right.isInferable() {
			inferables = @right.inferTypes(inferables)

			if @right.type().isNull() {
				if @right is IdentifierLiteral {
					inferables[@right.path()] = {
						isVariable: true
						type: @right.getDeclaredType().setNullable(false)
					}
				}
			}
			else {
				inferables[@right.path()] = {
					isVariable: @right is IdentifierLiteral
					type: @right.type().setNullable(false)
				}
			}
		}
		else if @right is IdentifierLiteral && @right.value() == 'null' && @left.isInferable() {
			inferables = @left.inferTypes(inferables)

			if @left.type().isNull() {
				if @left is IdentifierLiteral {
					inferables[@left.path()] = {
						isVariable: true
						type: @left.getDeclaredType().setNullable(false)
					}
				}
			}
			else {
				inferables[@left.path()] = {
					isVariable: @left is IdentifierLiteral
					type: @left.type().setNullable(false)
				}
			}
		}
		else {
			inferables = @right.inferTypes(@left.inferTypes(inferables))
		}

		return inferables
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		inferables = @right.inferTypes(@left.inferTypes(inferables))

		var leftType = @left.type()
		var rightType = @right.type()

		if @left.isInferable() {
			if @right.isInferable() {
				if rightType.isMorePreciseThan(leftType) {
					inferables[@left.path()] = {
						isVariable: @left is IdentifierLiteral
						type: rightType.setNullable(leftType)
					}
				}
				else if leftType.isMorePreciseThan(rightType) {
					inferables[@right.path()] = {
						isVariable: @right is IdentifierLiteral
						type: leftType.setNullable(rightType)
					}
				}
			}
			else if rightType.isAssignableToVariable(leftType, true) {
				inferables[@left.path()] = {
					isVariable: @left is IdentifierLiteral
					type: rightType
				}
			}
		}
		else if @right.isInferable() && leftType.isAssignableToVariable(rightType, true) {
			inferables[@right.path()] = {
				isVariable: @right is IdentifierLiteral
				type: leftType
			}
		}

		return inferables
	} # }}}
	toLeftFragments(fragments, reuseName?, reusable, assignable) { # {{{
		var mut suffix = null
		var mut wrap = true

		if @enumLeft {
			if @left.type().isNullable() {
				fragments.code($runtime.helper(@left), '.valueOf(')
				wrap = false
				suffix = ')'
			}
			else {
				suffix = '.value'
			}
		}
		else if @enumRight && @left.type().isAny() && !@left.type().isNull() {
			if @left.type().isNullable() {
				fragments.code($runtime.helper(@left), '.valueOf(')
				wrap = false
				suffix = ')'
			}
			else {
				suffix = '.valueOf()'
			}
		}

		if reusable && reuseName != null {
			if assignable {
				fragments.code('(', reuseName, $equals).compile(@left).code(')')
			}
			else {
				fragments.code(reuseName)
			}
		}
		else if wrap {
			fragments.wrap(@left)
		}
		else {
			fragments.compile(@left)
		}

		if suffix != null {
			fragments.code(suffix)
		}
	} # }}}
	toOperatorFragments(fragments, reuseName?, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @nanLeft {
			if rightReusable && reuseName != null  {
				fragments.code('Number.isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('Number.isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null  {
				fragments.code('Number.isNaN(', reuseName, ')')
			}
			else {
				fragments.code('Number.isNaN(').compile(@left).code(')')
			}
		}
		else if @infinity {
			fragments.code($runtime.operator(@node), '.eq(').compile(@left).code(', ').compile(@right).code(')')
		}
		else {
			this.toLeftFragments(fragments, reuseName, leftReusable, leftAssignable)

			fragments.code(' === ')

			this.toRightFragments(fragments, reuseName, rightReusable, rightAssignable)
		}
	} # }}}
	toRightFragments(fragments, reuseName?, reusable, assignable) { # {{{
		var mut suffix = null
		var mut wrap = true

		if @enumRight {
			suffix = '.value'
		}
		else if @enumLeft && @right.type().isAny() && !@right.type().isNull() {
			if @right.type().isNullable() {
				fragments.code($runtime.helper(@right), '.valueOf(')
				wrap = false
				suffix = ')'
			}
			else {
				suffix = '.valueOf()'
			}
		}

		if reusable && reuseName != null {
			if assignable {
				fragments.code('(', reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code(reuseName)
			}
		}
		else if wrap {
			fragments.wrap(@right)
		}
		else {
			fragments.compile(@right)
		}

		if suffix != null {
			fragments.code(suffix)
		}
	} # }}}
}

class InequalityOperator extends EqualityOperator {
	inferWhenFalseTypes(inferables) => super.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => super.inferWhenFalseTypes(inferables)
	toOperatorFragments(fragments, reuseName?, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @nanLeft {
			if rightReusable && reuseName != null  {
				fragments.code('!Number.isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('!Number.isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null  {
				fragments.code('!Number.isNaN(', reuseName, ')')
			}
			else {
				fragments.code('!Number.isNaN(').compile(@left).code(')')
			}
		}
		else if @infinity {
			fragments.code($runtime.operator(@node), '.neq(').compile(@left).code(', ').compile(@right).code(')')
		}
		else {
			this.toLeftFragments(fragments, reuseName, leftReusable, leftAssignable)

			fragments.code(' !== ')

			this.toRightFragments(fragments, reuseName, rightReusable, rightAssignable)
		}
	} # }}}
}

abstract class NumericComparisonOperator extends ComparisonOperator {
	private {
		_isNative: Boolean		= false
	}
	prepare() { # {{{
		super()

		if @left.type().isNumber() && @right.type().isNumber() {
			@isNative = true
		}
		else if @left.type().canBeNumber() {
			unless @right.type().canBeNumber() {
				TypeException.throwInvalidOperand(@right, this.operator(), @node)
			}
		}
		else {
			TypeException.throwInvalidOperand(@left, this.operator(), @node)
		}

		if @left.type().isNullable() || @right.type().isNullable() {
			@isNative = false
		}
	} # }}}
	isComputed() => @isNative
	abstract runtime(): String
	abstract symbol(): String
	toNativeFragments(fragments, reuseName?, leftReusable, rightReusable) { # {{{
		if leftReusable && reuseName != null  {
			fragments.code(reuseName)
		}
		else {
			fragments.wrap(@left)
		}

		fragments.code($space, this.symbol(), $space)

		if rightReusable && reuseName != null  {
			fragments.code('(', reuseName, $equals).compile(@right).code(')')
		}
		else {
			fragments.wrap(@right)
		}
	} # }}}
	toOperatorFragments(fragments, reuseName?, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @isNative {
			this.toNativeFragments(fragments, reuseName, leftReusable, rightReusable)
		}
		else {
			fragments.code($runtime.operator(@node), `.\(this.runtime())(`)

			if reuseName != null {
				if leftReusable {
					if leftAssignable {
						fragments.code(reuseName, $equals).compile(@left)
					}
					else {
						fragments.code(reuseName)
					}
				}
				else {
					fragments.compile(@left)
				}

				fragments.code($comma)

				if rightReusable {
					if rightAssignable {
						fragments.code(reuseName, $equals).compile(@right)
					}
					else {
						fragments.code(reuseName)
					}
				}
				else {
					fragments.compile(@right)
				}
			}
			else {
				fragments.compile(@left).code($comma).compile(@right)
			}

			fragments.code(')')
		}
	} # }}}
}

class GreaterThanOperator extends NumericComparisonOperator {
	operator() => Operator::GreaterThan
	runtime() => 'gt'
	symbol() => '>'
}

class GreaterThanOrEqualOperator extends NumericComparisonOperator {
	operator() => Operator::GreaterThanOrEqual
	runtime() => 'gte'
	symbol() => '>='
}

class LessThanOperator extends NumericComparisonOperator {
	operator() => Operator::LessThan
	runtime() => 'lt'
	symbol() => '<'
}

class LessThanOrEqualOperator extends NumericComparisonOperator {
	operator() => Operator::LessThanOrEqual
	runtime() => 'lte'
	symbol() => '<='
}
