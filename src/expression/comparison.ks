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
			BinaryOperatorKind::Equality => return new EqualityOperator(operand1, operand2)
			BinaryOperatorKind::GreaterThan => return new GreaterThanOperator(operand1, operand2)
			BinaryOperatorKind::GreaterThanOrEqual => return new GreaterThanOrEqualOperator(operand1, operand2)
			BinaryOperatorKind::Inequality => return new InequalityOperator(operand1, operand2)
			BinaryOperatorKind::LessThan => return new LessThanOperator(operand1, operand2)
			BinaryOperatorKind::LessThanOrEqual => return new LessThanOrEqualOperator(operand1, operand2)
		}
	} // }}}
	hasExceptions() => false
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
		_right
	}
	constructor(@left, @right)
	prepare()
	isComputed() => true
}

class EqualityOperator extends ComparisonOperator {
	private {
		_infinity: Boolean		= false
		_nanLeft: Boolean		= false
		_nanRight: Boolean		= false
	}
	prepare() { // {{{
		if @left is IdentifierLiteral {
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

		if @right is IdentifierLiteral {
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
	} // }}}
	isComputed() => !@nanLeft && !@nanRight
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
		if @nanLeft {
			if rightReusable && reuseName != null  {
				fragments.code('isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null  {
				fragments.code('isNaN(', reuseName, ')')
			}
			else {
				fragments.code('isNaN(').compile(@left).code(')')
			}
		}
		else {
			if leftReusable && reuseName != null  {
				fragments.code(reuseName)
			}
			else {
				fragments.wrap(@left)
			}

			if @infinity {
				fragments.code(' == ')
			}
			else {
				fragments.code(' === ')
			}

			if rightReusable && reuseName != null  {
				fragments.code('(', reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.wrap(@right)
			}
		}
	} // }}}
}

class InequalityOperator extends EqualityOperator {
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
		if @nanLeft {
			if rightReusable && reuseName != null  {
				fragments.code('!isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('!isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null  {
				fragments.code('!isNaN(', reuseName, ')')
			}
			else {
				fragments.code('!isNaN(').compile(@left).code(')')
			}
		}
		else {
			if leftReusable && reuseName != null  {
				fragments.code(reuseName)
			}
			else {
				fragments.wrap(@left)
			}

			if @infinity {
				fragments.code(' != ')
			}
			else {
				fragments.code(' !== ')
			}

			if rightReusable && reuseName != null  {
				fragments.code('(', reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.wrap(@right)
			}
		}
	} // }}}
}

class DirtyComparisonOperator extends ComparisonOperator {
	private {
		_operator: String
	}
	constructor(@left, @right, @operator) {
		super(left, right)
	}
	toOperatorFragments(fragments, reuseName?, leftReusable, rightReusable) { // {{{
		if leftReusable && reuseName != null  {
			fragments.code(reuseName)
		}
		else {
			fragments.wrap(@left)
		}

		fragments.code(' ', @operator, ' ')

		if rightReusable && reuseName != null  {
			fragments.code('(', reuseName, $equals).compile(@right).code(')')
		}
		else {
			fragments.wrap(@right)
		}
	} // }}}
}

class GreaterThanOperator extends DirtyComparisonOperator {
	constructor(@left, @right) { // {{{
		super(left, right, '>')
	} // }}}
}

class GreaterThanOrEqualOperator extends DirtyComparisonOperator {
	constructor(@left, @right) { // {{{
		super(left, right, '>=')
	} // }}}
}

class LessThanOperator extends DirtyComparisonOperator {
	constructor(@left, @right) { // {{{
		super(left, right, '<')
	} // }}}
}

class LessThanOrEqualOperator extends DirtyComparisonOperator {
	constructor(@left, @right) { // {{{
		super(left, right, '<=')
	} // }}}
}