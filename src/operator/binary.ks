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
		@right.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	hasExceptions() => false
	isAwait() => @await
	isAwaiting() => @left.isAwaiting() || @right.isAwaiting()
	isComputed() => true
	isNullable() => @left.isNullable() || @right.isNullable()
	isNullableComputed() => (@left.isNullable() && @right.isNullable()) || @left.isNullableComputed() || @right.isNullableComputed()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(false)
		@right.acquireReusable(false)
	} // }}}
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

class BinaryOperatorAddition extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('+', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type(): Type { // {{{
		if @left.type().isNumber() || @left.type().isString() {
			return @left.type()
		}
		else {
			return new UnionType(@scope, [@scope.reference('Number'), @scope.reference('String')], false)
		}
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope, ScopeType::Operation)
	} // }}}
	prepare() { // {{{
		@left.prepare()

		for const data, name of @left.inferTypes() when !data.type.isAny() {
			@scope.updateInferable(name, data, this)
		}

		@right.prepare()

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
	inferContraryTypes() { // {{{
		const inferables = {}

		const rightTypes = @right.inferContraryTypes()

		for const :name of @left.inferContraryTypes() when rightTypes[name]? {
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

class BinaryOperatorBitwiseAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('&', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseLeftShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('<<', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('|', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseRightShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('>>', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseXor extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('^', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorDivision extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('/', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorImply extends BinaryOperatorExpression {
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

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('%', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('*', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	private {
		_type: Type
	}
	prepare() { // {{{
		super.prepare()

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
	inferContraryTypes() { // {{{
		const inferables = {}

		const right = @right.inferTypes()

		for const data, name of @left.inferContraryTypes() {
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

class BinaryOperatorQuotient extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.code('Number.parseInt(')
			.wrap(@left)
			.code($space)
			.code('/', @data.operator)
			.code($space)
			.wrap(@right)
			.code(')')
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorSubtraction extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space, '-', @data.operator, $space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
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

		if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
			if const variable = @scope.getVariable(@data.right.typeName.name) {
				const type = variable.getRealType()

				unless type.isClass() {
					TypeException.throwNotClass(variable.name(), this)
				}

				if @left.type().isNull() {
					TypeException.throwNullTypeChecking(type, this)
				}
				else if !@left.type().isAny() && !type.matchContentOf(@left.type()) {
					TypeException.throwInvalidTypeChecking(@left.type(), type, this)
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
	inferContraryTypes() { // {{{
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

		if @data.right.kind == NodeKind::TypeReference && @data.right.typeName?.kind == NodeKind::Identifier {
			if variable ?= @scope.getVariable(@data.right.typeName.name) {
				type = variable.getRealType()

				unless type.isClass() {
					TypeException.throwNotClass(variable.name(), this)
				}

				if @left.type().isNull() {
					TypeException.throwNullTypeChecking(type, this)
				}
				else if !@left.type().isAny() && (!type.matchContentOf(@left.type()) || type.matchClassName(@left.type())) {
					TypeException.throwUnnecessaryTypeChecking(type, this)
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
	inferContraryTypes() { // {{{
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