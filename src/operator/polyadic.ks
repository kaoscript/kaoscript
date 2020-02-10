class PolyadicOperatorExpression extends Expression {
	private {
		_operands			= []
		_tested: Boolean	= false
	}
	analyse() { // {{{
		for const data in @data.operands {
			operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} // }}}
	prepare() { // {{{
		for const operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}
		}
	} // }}}
	translate() { // {{{
		for const operand in @operands {
			operand.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		for const operand in @operands {
			operand.acquireReusable(false)
			operand.releaseReusable()
		}
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	hasExceptions() => false
	isComputed() => true
	isNullable() { // {{{
		for operand in @operands {
			if operand.isNullable() {
				return true
			}
		}

		return false
	} // }}}
	isUsingVariable(name) { // {{{
		for const operand in @operands {
			if operand.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	listAssignments(array) { // {{{
		for const operand in @operands {
			operand.listAssignments(array)
		}

		return array
	} // }}}
	toFragments(fragments, mode) { // {{{
		const test = this.isNullable() && !@tested
		if test {
			fragments
				.compileNullable(this)
				.code(' ? ')
		}

		this.toOperatorFragments(fragments)

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
}

abstract class NumericPolyadicOperatorExpression extends PolyadicOperatorExpression {
	private lateinit {
		_isEnum: Boolean		= false
		_isNative: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		if this.isAcceptingEnum() && @operands[0].type().isEnum() {
			const name = @operands[0].type().name()

			@isEnum = true

			for const operand in @operands from 1 {
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
			let nullable = false

			@isNative = true

			for const operand in @operands {
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
	} // }}}
	translate() { // {{{
		super()

		if @isEnum {
			const type = @parent.type()

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
	} // }}}
	isAcceptingEnum() => false
	isComputed() => @isNative
	abstract operator(): Operator
	abstract runtime(): String
	abstract symbol(): String
	toNativeFragments(fragments) { // {{{
		for const operand, index in @operands {
			if index != 0 {
				fragments.code($space).code(this.symbol(), @data.operator).code($space)
			}

			fragments.wrap(operand)
		}
	} // }}}
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == this.operator() && type == OperandType::Number {
			for const operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toOperatorFragments(fragments) { // {{{
		if @isEnum {
			fragments.code(@type.name(), '(')

			this.toNativeFragments(fragments)

			fragments.code(')')
		}
		else if @isNative {
			this.toNativeFragments(fragments)
		}
		else {
			fragments.code($runtime.operator(this), `.\(this.runtime())(`)

			for const operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} // }}}
	toQuote() { // {{{
		let fragments = ''

		for const operand, index in @operands {
			if index != 0 {
				fragments += ` \(this.symbol()) `
			}

			fragments += operand.toQuote()
		}

		return fragments
	} // }}}
	type() => @type
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	private lateinit {
		_isNative: Boolean		= false
		_isNumber: Boolean		= false
		_isString: Boolean		= false
		_type: Type
	}
	prepare() { // {{{
		super()

		let nullable = false

		@isNative = true

		for const operand in @operands {
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

			let notNumber = null

			for const operand in @operands while @isNative || @isNumber {
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
			const numberType = nullable ? @scope.reference('Number').setNullable(true) : @scope.reference('Number')

			@type = new UnionType(@scope, [numberType, @scope.reference('String')], false)
		}
	} // }}}
	isComputed() => @isNative
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == Operator::Addition && ((@isNumber && type == OperandType::Number) || (@isString && type == OperandType::String)) {
			for const operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toOperatorFragments(fragments) { // {{{
		if @isNative {
			for const operand, index in @operands {
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

			for const operand, index in @operands {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(operand)
			}

			fragments.code(')')
		}
	} // }}}
	toQuote() { // {{{
		let fragments = ''

		for const operand, index in @operands {
			if index != 0 {
				fragments += ' + '
			}

			fragments += operand.toQuote()
		}

		return fragments
	} // }}}
	type() => @type
}

class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	prepare() { // {{{
		for operand in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeBoolean() {
				TypeException.throwInvalidOperand(operand, Operator::And, this)
			}

			for const data, name of operand.inferWhenTrueTypes({}) {
				@scope.updateInferable(name, data, this)
			}
		}
	} // }}}
	inferTypes(inferables) { // {{{
		for const data, name of @operands[0].inferTypes({}) {
			if inferables[name]? {
				if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
					inferables[name] = data
				}
				else {
					inferables[name] = {
						isVariable: data.isVariable
						type: Type.union(@scope, inferables[name].type, data.type)
					}
				}
			}
			else {
				inferables[name] = data
			}
		}

		return inferables
	} // }}}
	inferWhenTrueTypes(inferables) { // {{{
		for const operand in @operands {
			for const data, name of operand.inferWhenTrueTypes({}) {
				if inferables[name]? {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
				else {
					inferables[name] = data
				}
			}
		}

		return inferables
	} // }}}
	toFragments(fragments, mode) { // {{{
		let nf = false

		for const operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('&&', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}

			fragments.wrapBoolean(operand)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorBitwiseAnd extends NumericPolyadicOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&'
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

class PolyadicOperatorImply extends PolyadicOperatorExpression {
	toFragments(fragments, mode) { // {{{
		const l = @operands.length - 2
		fragments.code('!('.repeat(l))

		fragments.code('!').wrapBoolean(@operands[0])

		for const operand in @operands from 1 til -1 {
			fragments.code(' || ').wrapBoolean(operand).code(')')
		}

		fragments.code(' || ').wrapBoolean(@operands[@operands.length - 1])
	} // }}}
	type() => @scope.reference('Boolean')
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
	private lateinit {
		_type: Type
	}
	analyse() { // {{{
		@operands = []
		for operand in @data.operands {
			@operands.push(operand = $compile.expression(operand, this))

			operand.analyse()
		}
	} // }}}
	prepare() { // {{{
		const types = []
		const last = @operands.length - 1

		let operandType, type, ne
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
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Type')

		let l = @operands.length - 1

		let operand
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
	} // }}}
	type() => @type
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	prepare() { // {{{
		const lastIndex = @operands.length - 1
		const originals = {}

		for const operand, index in @operands {
			operand.prepare()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			unless operand.type().canBeBoolean() {
				TypeException.throwInvalidOperand(operand, Operator::And, this)
			}

			if index < lastIndex {
				for const data, name of operand.inferWhenFalseTypes({}) {
					if data.isVariable && !?originals[name] {
						originals[name] = {
							isVariable: true
							type: @scope.getVariable(name).getRealType()
						}
					}

					@scope.updateInferable(name, data, this)
				}
			}
		}

		for const data, name of originals {
			@scope.updateInferable(name, data, this)
		}
	} // }}}
	inferTypes(inferables) { // {{{
		for const data, name of @operands[0].inferTypes({}) {
			if inferables[name]? {
				if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
					inferables[name] = data
				}
				else {
					inferables[name] = {
						isVariable: data.isVariable
						type: Type.union(@scope, inferables[name].type, data.type)
					}
				}
			}
			else {
				inferables[name] = data
			}
		}

		for const operand in @operands from 1 {
			for const data, name of operand.inferTypes({}) {
				if inferables[name]? {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
			}
		}

		return inferables
	} // }}}
	inferWhenFalseTypes(inferables) { // {{{
		const operandTypes = [null]
		for const operand in @operands from 1 {
			operandTypes.push(operand.inferWhenTrueTypes({}))
		}

		for const operand in @operands {
			for const data, name of operand.inferWhenFalseTypes({}) {
				let type = data.type

				for const index from 1 til @operands.length {
					const types = operandTypes[index]

					if types[name]? {
						type = type.reduce(types[name].type)
					}
					else {
						break
					}
				}

				inferables[name] = {
					isVariable: data.isVariable
					type
				}
			}
		}

		return inferables
	} // }}}
	inferWhenTrueTypes(inferables) { // {{{
		const typings = {}

		for const data, name of @operands[0].inferWhenTrueTypes({}) {
			inferables[name] = data

			if data.isTyping {
				typings[name] = true
			}
		}

		for const operand, index in @operands from 1 {
			const types = operand.inferWhenTrueTypes({})

			for const _, name of typings {
				if !?types[name] {
					delete inferables[name]
				}
			}

			for const data, name of types {
				if inferables[name]? {
					if data.type.equals(inferables[name].type) || data.type.isMorePreciseThan(inferables[name].type) {
						inferables[name] = data
					}
					else {
						inferables[name] = {
							isVariable: data.isVariable
							type: Type.union(@scope, inferables[name].type, data.type)
						}
					}
				}
			}
		}

		return inferables
	} // }}}
	toFragments(fragments, mode) { // {{{
		let nf = false

		for const operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('||', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}

			fragments.wrapBoolean(operand)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorQuotient extends NumericPolyadicOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.'
	toNativeFragments(fragments) { // {{{
		const l = @operands.length - 1
		fragments.code('Number.parseInt('.repeat(l))

		fragments.wrap(@operands[0])

		for const operand in @operands from 1 {
			fragments.code(' / ').wrap(operand).code(')')
		}
	} // }}}
}

class PolyadicOperatorSubtraction extends NumericPolyadicOperatorExpression {
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
}

class PolyadicOperatorXor extends PolyadicOperatorExpression {
	toFragments(fragments, mode) { // {{{
		const l = @operands.length - 2
		fragments.code('('.repeat(l))

		fragments.wrapBoolean(@operands[0])

		for const operand in @operands from 1 til -1 {
			fragments.code(' !== ').wrapBoolean(operand).code(')')
		}

		fragments.code(' !== ').wrapBoolean(@operands[@operands.length - 1])
	} // }}}
	type() => @scope.reference('Boolean')
}