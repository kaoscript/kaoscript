enum JunctionKind {
	And
	Or
	Xor
}

class ComparisonExpression extends Expression {
	private {
		@await: Boolean				= false
		@composite: Boolean			= false
		@computed: Boolean			= true
		@junction: JunctionKind		= JunctionKind.Xor
		@junctive: Boolean			= false
		@operands: Expression[]		= []
		@operators					= []
		@reuseName: String?			= null
		@tested: Boolean			= false
	}
	analyse() { # {{{
		if @data.values.length == 3 {
			var operand1 = @addOperand(@data.values[0])
			var value = @data.values[2]

			if value.kind == NodeKind.JunctionExpression {
				@junctive = true

				for var operand in value.operands {
					@addOperator(@data.values[1], operand1, @addOperand(operand))
				}

				if value.operator.kind == BinaryOperatorKind.JunctionAnd {
					@junction = JunctionKind.And
				}
				else if value.operator.kind == BinaryOperatorKind.JunctionOr {
					@junction = JunctionKind.Or
				}
			}
			else {
				@addOperator(@data.values[1], operand1, @addOperand(@data.values[2]))
			}
		}
		else {
			var mut operand1 = @addOperand(@data.values[0])

			for var i from 1 to~ @data.values.length step 2 {
				var operand2 = @addOperand(@data.values[i + 1])

				@addOperator(@data.values[i], operand1, operand2)

				operand1 = operand2
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if !target.isVoid() && !target.canBeBoolean() {
			TypeException.throwUnexpectedExpression(this, target, this)
		}

		for var operand in @operands {
			operand.prepare(AnyType.NullableUnexplicit)

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
				for var operand in @operands from 1 to~ -1 until @composite {
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
		var operator = @getOperator(data, operand1, operand2)

		@operators.push(operator)
	} # }}}
	private getOperator(data, operand1, operand2) { # {{{
		match data.kind {
			BinaryOperatorKind.Equality => return EqualityOperator.new(this, operand1, operand2)
			BinaryOperatorKind.GreaterThan => return GreaterThanOperator.new(this, operand1, operand2)
			BinaryOperatorKind.GreaterThanOrEqual => return GreaterThanOrEqualOperator.new(this, operand1, operand2)
			BinaryOperatorKind.Inequality => return InequalityOperator.new(this, operand1, operand2)
			BinaryOperatorKind.LessThan => return LessThanOperator.new(this, operand1, operand2)
			BinaryOperatorKind.LessThanOrEqual => return LessThanOrEqualOperator.new(this, operand1, operand2)
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
			var shares = {}

			for var { isVariable, type }, name of @operators[0].inferWhenFalseTypes({}) {
				shares[name] = {
					isVariable,
					types: [type]
				}
			}

			for var operator in @operators from 1 {
				var newInfers = operator.inferWhenFalseTypes({})

				for var share, name of shares {
					if var { type } ?= newInfers[name] {
						share.types.push(type)
					}
					else if @junction == JunctionKind.And {
						Object.delete(shares, name)
					}
				}

				return inferables unless ?#shares
			}

			for var { isVariable, types }, name of shares {
				inferables[name] = {
					isVariable
					type: Type.union(@scope, ...types)
				}
			}

			return inferables
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @operators.length == 1 {
			return @operators[0].inferWhenTrueTypes(inferables)
		}
		else {
			var shares = {}

			for var { isVariable, type }, name of @operators[0].inferWhenTrueTypes({}) {
				shares[name] = {
					isVariable,
					types: [type]
				}
			}

			for var operator in @operators from 1 {
				var newInfers = operator.inferWhenTrueTypes({})

				for var share, name of shares {
					if var { type } ?= newInfers[name] {
						share.types.push(type)
					}
					else if @junction == JunctionKind.And {
						Object.delete(shares, name)
					}
				}

				return inferables unless ?#shares
			}

			for var { isVariable, types }, name of shares {
				inferables[name] = {
					isVariable
					type: Type.union(@scope, ...types)
				}
			}

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
	listAssignments(array: Array) { # {{{
		for var operand in @operands {
			operand.listAssignments(array)
		}

		return array
	} # }}}
	operands() => @operands
	releaseReusable() { # {{{
		if @composite {
			@scope.releaseTempName(@reuseName)
		}

		for var operand in @operands {
			operand.releaseReusable()
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if (@junctive || @operators.length > 1) && junction == Junction.AND {
			fragments.code('(').compile(this, mode).code(')')
		}
		else {
			fragments.compile(this, mode)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @await {
			NotSupportedException.throw(this)
		}

		var test = @isNullable() && !@tested
		if test {
			fragments.wrapNullable(this).code(' ? ')
		}

		if @junctive {
			if @junction == JunctionKind.Xor {
				fragments.code($runtime.operator(this), '.xor(')

				@operators[0].toOperatorFragments(fragments, @reuseName, true, true, true, false, false)

				for var operator in @operators from 1 {
					fragments.code($comma)

					operator.toOperatorFragments(fragments, @reuseName, false, true, false, false, false)
				}

				fragments.code(')')
			}
			else {
				var junction = @junction == JunctionKind.And ? ' && ' : ' || '

				@operators[0].toOperatorFragments(fragments, @reuseName, true, true, true, false, false)

				for var operator in @operators from 1 {
					fragments.code(junction)

					operator.toOperatorFragments(fragments, @reuseName, false, true, false, false, false)
				}
			}
		}
		else {
			@operators[0].toOperatorFragments(fragments, @reuseName, true, false, false, true, true)

			if @operators.length > 1 {
				for var operator in @operators from 1 to~ -1 {
					fragments.code(' && ')

					operator.toOperatorFragments(fragments, @reuseName, true, true, false, true, true)
				}

				fragments.code(' && ')

				@operators[@operators.length - 1].toOperatorFragments(fragments, @reuseName, true, true, false, false, false)
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
	toQuote() { # {{{
		var mut fragments = ''

		if @operands[0].isComputed() {
			fragments += `(\(@operands[0].toQuote()))`
		}
		else {
			fragments += @operands[0].toQuote()
		}

		for var i from 0 to~ @operators.length {
			fragments += ` \(@operators[i].native()) `

			if @operands[i + 1].isComputed() {
				fragments += `(\(@operands[i + 1].toQuote()))`
			}
			else {
				fragments += @operands[i + 1].toQuote()
			}
		}

		return fragments
	} # }}}
	type() => @scope.reference('Boolean')
}

abstract class ComparisonOperator {
	private {
		@left
		@node
		@right
	}
	abstract {
		symbol(): String
	}
	constructor(@node, @left, @right)
	prepare()
	inferTypes(inferables) => @right.inferTypes(@left.inferTypes(inferables))
	inferWhenFalseTypes(inferables) => @inferTypes(inferables)
	inferWhenTrueTypes(inferables) => @inferTypes(inferables)
	isComputed() => true
	native() => @symbol()
}

class EqualityOperator extends ComparisonOperator {
	private {
		@infinity: Boolean		= false
		@nanLeft: Boolean		= false
		@nanRight: Boolean		= false
	}
	override prepare() { # {{{
		var leftType = @left.type().discardValue()
		var rightType = @right.type().discardValue()

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

		if rightType.isNull() {
			unless leftType.isNullable() || @left.isLateInit() || @node.isMisfit() {
				TypeException.throwInvalidComparison(@left, @right, @node)
			}
		}
		else {
			if leftType.isNull() {
				unless rightType.isNullable() || @right.isLateInit() || @node.isMisfit() {
					TypeException.throwInvalidComparison(@left, @right, @node)
				}
			}
			else if !leftType.isAssignableToVariable(rightType, false) && !rightType.isAssignableToVariable(leftType, false) {
				TypeException.throwInvalidComparison(@left, @right, @node)
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
	} # }}}
	isComputed() => !@nanLeft && !@nanRight
	inferWhenFalseTypes(mut inferables) { # {{{
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
					isVariable: @right.isVariable()
					type: @right.type().discardValue().setNullable(false)
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
					isVariable: @left.isVariable()
					type: @left.type().discardValue().setNullable(false)
				}
			}
		}
		else {
			inferables = @right.inferTypes(@left.inferTypes(inferables))
		}

		return inferables
	} # }}}
	inferWhenTrueTypes(mut inferables) { # {{{
		inferables = @right.inferTypes(@left.inferTypes(inferables))

		var leftType = @left.type()
		var rightType = @right.type()

		if @left.isInferable() {
			if @right.isInferable() {
				if rightType.isMorePreciseThan(leftType) {
					inferables[@left.path()] = {
						isVariable: @left.isVariable()
						type: rightType.setNullable(leftType)
					}
				}
				else if leftType.isMorePreciseThan(rightType) {
					inferables[@right.path()] = {
						isVariable: @right.isVariable()
						type: leftType.setNullable(rightType)
					}
				}
			}
			else if rightType.isAssignableToVariable(leftType, true) {
				inferables[@left.path()] = {
					isVariable: @left.isVariable()
					type: rightType
				}
			}

			if leftType.isEnum() && rightType.isEnum() {
				if @left is MemberExpression && @left.caller().type().isVariant() && @right is MemberExpression | UnaryOperatorImplicit {
					var caller = @left.caller()
					var type = ReferenceType.new(@node.scope(), caller.type().name(), null, null, [{ name: @right.property(), type: rightType }])

					inferables[caller.path()] = {
						isVariable: caller is IdentifierLiteral
						type
					}
				}
			}
		}
		else if @right.isInferable() && leftType.isAssignableToVariable(rightType, true) {
			inferables[@right.path()] = {
				isVariable: @right.isVariable()
				type: leftType
			}
		}

		return inferables
	} # }}}
	symbol() => '=='
	toLeftFragments(fragments, reuseName?, castReusable, reusable, assignable) { # {{{
		var mut prefix = ''
		var mut suffix = ''
		var mut wrap = true

		if reusable && ?reuseName {
			if assignable {
				fragments.code('(', reuseName, $equals).code(prefix).compile(@left).code(suffix).code(')')
			}
			else {
				fragments.code(prefix).code(reuseName).code(suffix)
			}
		}
		else if wrap {
			fragments.code(prefix).wrap(@left).code(suffix)
		}
		else {
			fragments.code(prefix).compile(@left).code(suffix)
		}
	} # }}}
	toOperatorFragments(fragments, reuseName?, castReusable, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @nanLeft {
			if rightReusable && reuseName != null {
				fragments.code('Number.isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('Number.isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null {
				fragments.code('Number.isNaN(', reuseName, ')')
			}
			else {
				fragments.code('Number.isNaN(').compile(@left).code(')')
			}
		}
		else if @infinity {
			fragments.code($runtime.operator(@node), '.eq(').compile(@left).code(', ').compile(@right).code(')')
		}
		else if @left.isDerivative() {
			var type = @left.type().discardValue()

			fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(@left.property()))(`)

			@toRightFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(')')
		}
		else if @right.isDerivative() {
			var type = @right.type().discardValue()

			fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(@right.property()))(`)

			@toLeftFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(')')
		}
		else {
			@toLeftFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(' === ')

			@toRightFragments(fragments, reuseName, castReusable, rightReusable, rightAssignable)
		}
	} # }}}
	toRightFragments(fragments, reuseName?, castReusable, reusable, assignable) { # {{{
		var mut prefix = ''
		var mut suffix = ''
		var mut wrap = true

		if reusable && ?reuseName {
			if assignable {
				fragments.code('(', reuseName, $equals).code(prefix).compile(@right).code(suffix).code(')')
			}
			else {
				fragments.code(prefix).code(reuseName).code(suffix)
			}
		}
		else if wrap {
			fragments.code(prefix).wrap(@right).code(suffix)
		}
		else {
			fragments.code(prefix).compile(@right).code(suffix)
		}
	} # }}}
}

class InequalityOperator extends EqualityOperator {
	inferWhenFalseTypes(inferables) => super.inferWhenTrueTypes(inferables)
	inferWhenTrueTypes(inferables) => super.inferWhenFalseTypes(inferables)
	symbol() => '!='
	toOperatorFragments(fragments, reuseName?, castReusable, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @nanLeft {
			if rightReusable && reuseName != null {
				fragments.code('!Number.isNaN(').code(reuseName, $equals).compile(@right).code(')')
			}
			else {
				fragments.code('!Number.isNaN(').compile(@right).code(')')
			}
		}
		else if @nanRight {
			if leftReusable && reuseName != null {
				fragments.code('!Number.isNaN(', reuseName, ')')
			}
			else {
				fragments.code('!Number.isNaN(').compile(@left).code(')')
			}
		}
		else if @infinity {
			fragments.code($runtime.operator(@node), '.neq(').compile(@left).code(', ').compile(@right).code(')')
		}
		else if @left.isDerivative() {
			var type = @left.type().discardValue()

			fragments.code('!').compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(@left.property()))(`)

			@toRightFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(')')
		}
		else if @right.isDerivative() {
			var type = @right.type().discardValue()

			fragments.code('!').compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(@right.property()))(`)

			@toLeftFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(')')
		}
		else {
			@toLeftFragments(fragments, reuseName, castReusable, leftReusable, leftAssignable)

			fragments.code(' !== ')

			@toRightFragments(fragments, reuseName, castReusable, rightReusable, rightAssignable)
		}
	} # }}}
}

abstract class NumericComparisonOperator extends ComparisonOperator {
	private {
		@isNative: Boolean		= false
	}
	abstract {
		runtime(): String
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
	toNativeFragments(fragments, reuseName?, leftReusable, rightReusable) { # {{{
		if leftReusable && reuseName != null {
			fragments.code(reuseName)
		}
		else {
			fragments.wrap(@left)
		}

		fragments.code($space, @native(), $space)

		if rightReusable && reuseName != null {
			fragments.code('(', reuseName, $equals).compile(@right).code(')')
		}
		else {
			fragments.wrap(@right)
		}
	} # }}}
	toOperatorFragments(fragments, reuseName?, castReusable, leftReusable, leftAssignable, rightReusable, rightAssignable) { # {{{
		if @isNative {
			@toNativeFragments(fragments, reuseName, leftReusable, rightReusable)
		}
		else {
			fragments.code($runtime.operator(@node), `.\(@runtime())(`)

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
	operator() => Operator.GreaterThan
	runtime() => 'gt'
	symbol() => '>'
}

class GreaterThanOrEqualOperator extends NumericComparisonOperator {
	operator() => Operator.GreaterThanOrEqual
	runtime() => 'gte'
	symbol() => '>='
}

class LessThanOperator extends NumericComparisonOperator {
	operator() => Operator.LessThan
	runtime() => 'lt'
	symbol() => '<'
}

class LessThanOrEqualOperator extends NumericComparisonOperator {
	operator() => Operator.LessThanOrEqual
	runtime() => 'lte'
	symbol() => '<='
}
