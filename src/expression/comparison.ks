class ComparisonExpression extends Expression {
	private {
		_await: Boolean		= false
		_composite: Boolean	= false
		_computed: Boolean	= true
		_operands			= []
		_operators			= []
		_reuseName: String?	= null
		_tested: Boolean	= false
	}
	analyse() { // {{{
		let operand1, operand2, operator

		operand1 = $compile.expression(@data.values[0], this)
		operand1.analyse()

		@operands.push(operand1)
		@await = @await || operand1.isAwait()

		for const i from 1 til @data.values.length by 2 {
			operand2 = $compile.expression(@data.values[i + 1], this)
			operand2.analyse()

			@operands.push(operand2)
			@await = @await || operand2.isAwait()

			operator = this.getOperator(@data.values[i], operand1, operand2)

			@operators.push(operator)

			operand1 = operand2
		}
	} // }}}
	prepare() { // {{{
		for const operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}
		}

		for const operator in @operators {
			operator.prepare()
		}

		if @operators.length == 1 {
			@computed = @operators[0].isComputed()
		}
	} // }}}
	translate() { // {{{
		for const operand in @operands {
			operand.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @operators.length > 1 {
			for const operand in @operands from 1 til -1 until @composite {
				@composite = operand.isComposite()
			}

			if @composite {
				@reuseName = @scope.acquireTempName()
			}
		}

		for const operand in @operands {
			operand.acquireReusable(acquire)
		}
	} // }}}
	private getOperator(data, operand1, operand2) { // {{{
		switch data.kind {
			BinaryOperatorKind::Equality => return new EqualityOperator(this, operand1, operand2)
			BinaryOperatorKind::GreaterThan => return new GreaterThanOperator(this, operand1, operand2)
			BinaryOperatorKind::GreaterThanOrEqual => return new GreaterThanOrEqualOperator(this, operand1, operand2)
			BinaryOperatorKind::Inequality => return new InequalityOperator(this, operand1, operand2)
			BinaryOperatorKind::LessThan => return new LessThanOperator(this, operand1, operand2)
			BinaryOperatorKind::LessThanOrEqual => return new LessThanOrEqualOperator(this, operand1, operand2)
		}
	} // }}}
	hasExceptions() => false
	inferTypes(inferables) { // {{{
		if @operators.length == 1 {
			return @operators[0].inferTypes(inferables)
		}
		else {
			return inferables
		}
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
		if @operators.length == 1 {
			return @operators[0].inferWhenFalseTypes(inferables)
		}
		else {
			return inferables
		}
	} // }}}
	inferWhenTrueTypes(inferables) { // {{{
		if @operators.length == 1 {
			return @operators[0].inferWhenTrueTypes(inferables)
		}
		else {
			return inferables
		}
	} // }}}
	isComputed() => @computed
	isNullable() { // {{{
		for const operand in @operands {
			if operand.isNullable() {
				return true
			}
		}

		return false
	} // }}}
	isNullableComputed() { // {{{
		let nullable = true

		for const operand in @operands {
			if operand.isNullableComputed() {
				return true
			}
			else if !operand.isNullable() {
				nullable = false
			}
		}

		return nullable
	} // }}}
	isUsingVariable(name) { // {{{
		for const operand in @operands {
			if operand.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	releaseReusable() { // {{{
		if @composite {
			@scope.releaseTempName(@reuseName)
		}

		for const operand in @operands {
			operand.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		const test = this.isNullable() && !@tested
		if test {
			fragments.wrapNullable(this).code(' ? ')
		}

		@operators[0].toOperatorFragments(fragments, @reuseName, false, true)

		if @operators.length > 1 {
			for const operator in @operators from 1 til -1 {
				fragments.code(' && ')

				operator.toOperatorFragments(fragments, @reuseName, true, true)
			}

			fragments.code(' && ')

			@operators[@operators.length - 1].toOperatorFragments(fragments, @reuseName, true, false)
		}

		if test {
			fragments.code(' : false')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			let nf = false
			for const operand in @operands {
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
	} // }}}
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
	prepare() { // {{{
		if @left.type().isEnum() && @left is not NumericBinaryOperatorExpression {
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

		if @right.type().isEnum() && @right is not NumericBinaryOperatorExpression {
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

		if @enumLeft && @enumRight {
			@enumLeft = @enumRight = false
		}
	} // }}}
	isComputed() => !@nanLeft && !@nanRight
	inferTypes(inferables) { // {{{
		if @left is IdentifierLiteral && @left.value() == 'null' {
			inferables = @right.inferTypes(inferables)
		}
		else if @right is IdentifierLiteral && @right.value() == 'null' {
			inferables = @left.inferTypes(inferables)
		}
		else {
			inferables = @right.inferTypes(@left.inferTypes(inferables))
		}

		return inferables
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
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
	} // }}}
	toLeftFragments(fragments, leftReusable, reuseName?) { // {{{
		let suffix = null
		let wrap = true

		if @enumLeft {
			suffix = '.value'
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

		if leftReusable && reuseName != null  {
			fragments.code(reuseName)
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
	} // }}}
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
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
			this.toLeftFragments(fragments, leftReusable, reuseName)

			fragments.code(' === ')

			this.toRightFragments(fragments, rightReusable, reuseName)
		}
	} // }}}
	toRightFragments(fragments, rightReusable, reuseName?) { // {{{
		let suffix = null
		let wrap = true

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

		if rightReusable && reuseName != null  {
			fragments.code('(', reuseName, $equals).compile(@right).code(')')
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
	} // }}}
}

class InequalityOperator extends EqualityOperator {
	inferWhenFalseTypes(inferables) => super.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => super.inferWhenFalseTypes(inferables)
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
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
			this.toLeftFragments(fragments, leftReusable, reuseName)

			fragments.code(' !== ')

			this.toRightFragments(fragments, rightReusable, reuseName)
		}
	} // }}}
}

abstract class NumericComparisonOperator extends ComparisonOperator {
	private {
		_isNative: Boolean		= false
	}
	prepare() { // {{{
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
	} // }}}
	isComputed() => @isNative
	abstract runtime(): String
	abstract symbol(): String
	toNativeFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
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
	} // }}}
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
		if @isNative {
			this.toNativeFragments(fragments, reuseName, leftReusable, rightReusable)
		}
		else {
			fragments.code($runtime.operator(@node), `.\(this.runtime())(`)

			if leftReusable && reuseName != null  {
				fragments.code(reuseName)
			}
			else {
				fragments.wrap(@left)
			}

			fragments.code($comma)

			if rightReusable && reuseName != null  {
				fragments.code(reuseName, $equals).compile(@right)
			}
			else {
				fragments.wrap(@right)
			}

			fragments.code(')')
		}
	} // }}}
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