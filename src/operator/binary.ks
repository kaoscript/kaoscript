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
			return new UnionType(@scope, [@scope.reference('Number'), @scope.reference('String')])
		}
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope, ScopeType::Operation)
	} // }}}
	prepare() { // {{{
		@left.prepare()

		const variables = @left.reduceTypes()

		for const type, name of variables when !type.isAny() {
			@scope.replaceVariable(name, type, this)
		}

		@right.prepare()

		this.statement().assignTempVariables(@scope)
	} // }}}
	reduceTypes() { // {{{
		const variables = {}

		for const type, name of @left.reduceTypes() {
			variables[name] = type
		}
		for const type, name of @right.reduceTypes() {
			variables[name] = type
		}

		return variables
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
	reduceTypes() { // {{{
		const variables = {}

		const right = @right.reduceTypes()

		let rtype
		for const type, name of @left.reduceTypes() {
			if (rtype ?= right[name]) && !type.isAny() && !rtype.isAny() {
				if type.equals(rtype) {
					variables[name] = type
				}
				else {
					variables[name] = Type.union(@scope, type, rtype)
				}
			}
		}

		return variables
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

		if @left.type().equals(@right.type()) {
			@type = @left.type()
		}
		else {
			@type = new UnionType(@scope, [@left.type(), @right.type()])
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
	reduceTypes() { // {{{
		const variables = {}

		const right = @right.reduceTypes()

		let rtype
		for const type, name of @left.reduceTypes() {
			if (rtype ?= right[name]) && !type.isAny() && !rtype.isAny() {
				if type.equals(rtype) {
					variables[name] = type
				}
				else {
					variables[name] = Type.union(@scope, type, rtype)
				}
			}
		}

		return variables
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
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left)
	} // }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private {
		_left
		_type: Type
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

				if type.isClass() {
					if (!@left.type().isAny() && !type.matchContentOf(@left.type())) || @left.type().isNull() {
						TypeException.throwInvalidTypeChecking(this)
					}
				}
				else if !type.isAny() {
					TypeException.throwNotClass(variable.name(), this)
				}

				@type = Type.fromAST(@data.right, this)
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
	reduceTypes() { // {{{
		const variables = {}

		if @left is IdentifierLiteral {
			variables[@left.value()] = @type
		}

		return variables
	} // }}}
	toFragments(fragments, mode) { // {{{
		@type.toTestFragments(fragments, @left)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorTypeInequality extends Expression {
	private {
		_left
		_type: Type
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

				if type.isClass() {
					if !@left.type().isAny() && (!type.matchContentOf(@left.type()) || type.matchClassName(@left.type())) {
						TypeException.throwInvalidTypeChecking(this)
					}
				}
				else if !type.isAny() {
					TypeException.throwNotClass(variable.name(), this)
				}

				@type = Type.fromAST(@data.right, this)
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
	toFragments(fragments, mode) { // {{{
		if @data.right.kind == NodeKind::TypeReference {
			fragments.code('!')

			@type.toTestFragments(fragments, @left)
		}
		else if @data.right.types? {
			fragments.code('!(')

			@type.toTestFragments(fragments, @left)

			fragments.code(')')
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorXor extends BinaryOperatorExpression {
	reduceTypes() { // {{{
		const variables = {}

		const right = @right.reduceTypes()

		let rtype
		for const type, name of @left.reduceTypes() {
			if (rtype ?= right[name]) && !type.isAny() && !rtype.isAny() {
				if type.equals(rtype) {
					variables[name] = type
				}
				else {
					variables[name] = Type.union(@scope, type, rtype)
				}
			}
		}

		return variables
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