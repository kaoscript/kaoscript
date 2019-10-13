class BinaryOperatorExpression extends Expression {
	private {
		_await: Boolean		= false
		_left
		_right
		_tested: Boolean	= false
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@right = $compile.expression(@data.right, this)
		@right.analyse()

		@await = @left.isAwait() || @right.isAwait()
	} // }}}
	prepare() { // {{{
		@left.prepare()

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
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
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(false)
		@right.acquireReusable(false)
	} // }}}
	hasExceptions() => false
	isAwait() => @await
	isAwaiting() => @left.isAwaiting() || @right.isAwaiting()
	isComputed() => true
	isNullable() => @left.isNullable() || @right.isNullable()
	isNullableComputed() => (@left.isNullable() && @right.isNullable()) || @left.isNullableComputed() || @right.isNullableComputed()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	releaseReusable() { // {{{
		@left.releaseReusable()
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @await {
			if @left.isAwaiting() {
				return @left.toFragments(fragments, mode)
			}
			else if @right.isAwaiting() {
				return @right.toFragments(fragments, mode)
			}
			else {
				this.toOperatorFragments(fragments)
			}
		}
		else if this.isNullable() && !@tested {
			fragments
				.wrapNullable(this)
				.code(' ? ')

			this.toOperatorFragments(fragments)

			fragments.code(' : false')
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			if @left.isNullable() {
				fragments.compileNullable(@left)

				if @right.isNullable() {
					fragments.code(' && ').compileNullable(@right)
				}
			}
			else {
				fragments.compileNullable(@right)
			}

			@tested = true
		}
	} // }}}
}

abstract class NumericBinaryOperatorExpression extends BinaryOperatorExpression {
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
		fragments.wrap(@left).code($space).code(this.symbol(), @data.operator).code($space).wrap(@right)
	} // }}}
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == this.operator() && type == OperandType::Number {
			fragments.compile(@left).code($comma).compile(@right)
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
			fragments
				.code($runtime.operator(this), `.\(this.runtime())(`)
				.compile(@left)
				.code($comma)
				.compile(@right)
				.code(')')
		}
	} // }}}
	toQuote() => `\(@left.toQuote()) \(this.symbol()) \(@right.toQuote())`
	type() => @type
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
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
	} // }}}
	isComputed() => @isNative
	toOperandFragments(fragments, operator, type) { // {{{
		if operator == Operator::Addition && ((@isNumber && type == OperandType::Number) || (@isString && type == OperandType::String)) {
			fragments.compile(@left).code($comma).compile(@right)
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toOperatorFragments(fragments) { // {{{
		if @isNative {
			fragments
				.wrap(@left)
				.code($space)
				.code('+', @data.operator)
				.code($space)
				.wrap(@right)
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

			fragments.compile(@left).code($comma).compile(@right).code(')')
		}
	} // }}}
	toQuote() => `\(@left.toQuote()) + \(@right.toQuote())`
	type() => @type
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope, ScopeType::Operation)
	} // }}}
	prepare() { // {{{
		@left.prepare()

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		unless @left.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@left, Operator::And, this)
		}

		for const data, name of @left.inferTypes() {
			@scope.updateInferable(name, data, this)
		}

		@right.prepare()

		if @right.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}

		unless @right.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@right, Operator::And, this)
		}

		this.statement().assignTempVariables(@scope)
	} // }}}
	inferTypes() { // {{{
		const inferables = {}

		for const data, name of @left.inferTypes() {
			inferables[name] = data
		}
		for const data, name of @right.inferTypes() {
			inferables[name] = data
		}

		return inferables
	} // }}}
	inferContraryTypes(isExit) { // {{{
		const inferables = {}

		const rightTypes = @right.inferContraryTypes(false)

		for const :name of @left.inferContraryTypes(false) when rightTypes[name]? {
			inferables[name] = rightTypes[name]
		}

		return inferables
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@left)
			.code($space)
			.code('&&', @data.operator)
			.code($space)
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorBitwiseAnd extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseAnd
	runtime() => 'bitwiseAnd'
	symbol() => '&'
}

class BinaryOperatorBitwiseLeftShift extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseLeftShift
	runtime() => 'bitwiseLeftShift'
	symbol() => '<<'
}

class BinaryOperatorBitwiseOr extends NumericBinaryOperatorExpression {
	isAcceptingEnum() => true
	operator() => Operator::BitwiseOr
	runtime() => 'bitwiseOr'
	symbol() => '|'
}

class BinaryOperatorBitwiseRightShift extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseRightShift
	runtime() => 'bitwiseRightShift'
	symbol() => '>>'
}

class BinaryOperatorBitwiseXor extends NumericBinaryOperatorExpression {
	operator() => Operator::BitwiseXor
	runtime() => 'bitwiseXor'
	symbol() => '^'
}

class BinaryOperatorDivision extends NumericBinaryOperatorExpression {
	operator() => Operator::Division
	runtime() => 'division'
	symbol() => '/'
}

class BinaryOperatorImply extends BinaryOperatorExpression {
	prepare() { // {{{
		super()

		unless @left.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@left, Operator::Imply, this)
		}

		unless @right.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@right, Operator::Imply, this)
		}
	} // }}}
	inferTypes() { // {{{
		const inferables = {}

		const right = @right.inferTypes()

		let rtype
		for const data, name of @left.inferTypes() {
			if (rtype ?= right[name].type) && !data.type.isAny() && !rtype.isAny() {
				inferables[name] = data

				if !data.type.equals(rtype) {
					inferables[name].type = Type.union(@scope, data.type, rtype)
				}
			}
		}

		return inferables
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.code('!')
			.wrapBoolean(@left)
			.code(' || ')
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorModulo extends NumericBinaryOperatorExpression {
	operator() => Operator::Modulo
	runtime() => 'modulo'
	symbol() => '%'
}

class BinaryOperatorMultiplication extends NumericBinaryOperatorExpression {
	operator() => Operator::Multiplication
	runtime() => 'multiplication'
	symbol() => '*'
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	private {
		_type: Type
	}
	prepare() { // {{{
		super()

		@left.acquireReusable(true)
		@left.releaseReusable()

		const leftType = @left.type().setNullable(false)

		if leftType.equals(@right.type()) {
			@type = leftType
		}
		else {
			@type = new UnionType(@scope, [leftType, @right.type()])
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		@left.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code(')')
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code(' : ')
			.compile(@right)
	} // }}}}
	type() => @type
}

class BinaryOperatorOr extends BinaryOperatorExpression {
	prepare() { // {{{
		super()

		unless @left.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@left, Operator::Or, this)
		}

		unless @right.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@right, Operator::Or, this)
		}
	} // }}}
	inferTypes() { // {{{
		const inferables = {}

		const right = @right.inferTypes()

		for const data, name of @left.inferTypes() {
			if right[name]? {
				const rtype = right[name].type

				if !data.type.isAny() && !rtype.isAny() {
					inferables[name] = data

					if !data.type.equals(rtype) {
						inferables[name].type = Type.union(@scope, data.type, rtype)
					}
				}
			}
			else {
				inferables[name] = data
			}
		}

		return inferables
	} // }}}
	inferContraryTypes(isExit) { // {{{
		if isExit {
			const inferables = @left.inferContraryTypes(false)

			for const data, name of @right.inferContraryTypes(false) {
				if inferables[name]? {
					const itype = inferables[name].type

					if !data.type.isAny() && !itype.isAny() {
						inferables[name] = {
							isVariable: data.isVariable
							type: data.type.reduce(itype)
						}
					}
				}
				else {
					inferables[name] = data
				}
			}

			return inferables
		}
		else {
			const inferables = {}

			const right = @right.inferTypes()

			for const data, name of @left.inferContraryTypes(false) {
				if right[name]? {
					const rtype = right[name].type

					if !data.type.isAny() && !rtype.isAny() {
						inferables[name] = {
							isVariable: data.isVariable
							type: data.type.reduce(rtype)
						}
					}
				}
				else {
					inferables[name] = data
				}
			}

			return inferables
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@left)
			.code($space)
			.code('||', @data.operator)
			.code($space)
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorQuotient extends NumericBinaryOperatorExpression {
	operator() => Operator::Quotient
	runtime() => 'quotient'
	symbol() => '/.'
	toNativeFragments(fragments) { // {{{
		fragments.code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} // }}}
}

class BinaryOperatorSubtraction extends NumericBinaryOperatorExpression {
	operator() => Operator::Subtraction
	runtime() => 'subtraction'
	symbol() => '-'
}

class BinaryOperatorTypeCasting extends Expression {
	private {
		_left
		_type: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()

		@type = Type.fromAST(@data.right, this)
	} // }}}
	prepare() { // {{{
		@left.prepare()

		const type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if !(type is ReferenceType || type is UnionType || type.isAny()) {
			TypeException.throwInvalidCasting(this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	hasExceptions() => false
	isComputed() => false
	isNullable() => @left.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name)
	name() => @left is IdentifierLiteral ? @left.name() : null
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left)
	} // }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private {
		_falseType: Type
		_left
		_trueType: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
	} // }}}
	prepare() { // {{{
		@left.prepare()

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
			if const variable = @scope.getVariable(@data.right.typeName.name) {
				const type = variable.getRealType()

				if @left.type().isNull() {
					TypeException.throwNullTypeChecking(type, this)
				}

				if type is NamedType && type.name() == 'Namespace' {
					if !@left.type().isAny() && !@left.type().isNamespace() {
						TypeException.throwInvalidTypeChecking(@left.type(), type, this)
					}
				}
				else if type is NamedType && type.name() == 'Enum' {
					if !@left.type().isAny() && !@left.type().isEnum() {
						TypeException.throwInvalidTypeChecking(@left.type(), type, this)
					}
				}
				else if type.isClass() || type.isEnum() || type.isUnion() || type.isExclusion() {
					if !@left.type().isAny() && !type.matchContentOf(@left.type()) {
						TypeException.throwInvalidTypeChecking(@left.type(), type, this)
					}
				}
				else {
					TypeException.throwNotClass(variable.name(), this)
				}

				@trueType = type.reference()

				if @left.isInferable() {
					@falseType = @left.type().reduce(type)
				}
			}
			else {
				ReferenceException.throwNotDefined(@data.right.typeName.name, this)
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	hasExceptions() => false
	inferTypes() { // {{{
		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @trueType
			}
		}

		return inferables
	} // }}}
	inferContraryTypes(isExit) { // {{{
		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @falseType
			}
		}

		return inferables
	} // }}}
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @left.isUsingVariable(name)
	toFragments(fragments, mode) { // {{{
		@trueType.toTestFragments(fragments, @left)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorTypeInequality extends Expression {
	private {
		_falseType: Type
		_left
		_trueType: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
	} // }}}
	prepare() { // {{{
		@left.prepare()

		if @left.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
			if variable ?= @scope.getVariable(@data.right.typeName.name) {
				type = variable.getRealType()

				if @left.type().isNull() {
					TypeException.throwNullTypeChecking(type, this)
				}

				if type is NamedType && type.name() == 'Namespace' {
					if !@left.type().isAny() && !@left.type().isNamespace() {
						TypeException.throwUnnecessaryTypeChecking(type, this)
					}
				}
				else if type is NamedType && type.name() == 'Enum' {
					if !@left.type().isAny() && !@left.type().isEnum() {
						TypeException.throwUnnecessaryTypeChecking(type, this)
					}
				}
				else if type.isEnum() || type.isUnion() || type.isExclusion() {
					if !@left.type().isAny() && !type.matchContentOf(@left.type()) {
						TypeException.throwUnnecessaryTypeChecking(@left.type(), this)
					}
				}
				else if type.isClass() {
					if !@left.type().isAny() && (!type.matchContentOf(@left.type()) || type.matchClassName(@left.type())) {
						TypeException.throwUnnecessaryTypeChecking(@left.type(), this)
					}
				}
				else {
					TypeException.throwNotClass(variable.name(), this)
				}

				@falseType = type.reference()

				if @left.isInferable() {
					@trueType = @left.type().reduce(type)
				}
			}
			else {
				ReferenceException.throwNotDefined(@data.right.typeName.name, this)
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	hasExceptions() => false
	isComputed() => false
	isNullable() => false
	isUsingVariable(name) => @left.isUsingVariable(name)
	inferTypes() { // {{{
		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @trueType
			}
		}

		return inferables
	} // }}}
	inferContraryTypes(isExit) { // {{{
		const inferables = {}

		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left is IdentifierLiteral
				type: @falseType
			}
		}

		return inferables
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('!')

		@falseType.toTestFragments(fragments, @left)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorXor extends BinaryOperatorExpression {
	prepare() { // {{{
		super()

		unless @left.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@left, Operator::Xor, this)
		}

		unless @right.type().canBeBoolean() {
			TypeException.throwInvalidOperand(@right, Operator::Xor, this)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@left)
			.code($space)
			.code('!==', @data.operator)
			.code($space)
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}