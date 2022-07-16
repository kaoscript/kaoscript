class DefaultCallee extends Callee {
	private {
		@arguments: Array<Number>?
		@expression: Expression?
		@flatten: Boolean
		@methods: Array<FunctionType>?
		@node: CallExpression
		@object: Expression?
		@scope: ScopeKind
		@type: Type
	}
	private static {
		toArgumentFragments(argument?, fragments, mode) { // {{{
			if ?argument {
				argument.toArgumentFragments(fragments, mode)
			}
			else {
				fragments.code('void 0')
			}
		} // }}}
	}

	constructor(@data, @object, _type: Type | Array<Type> | Null, @arguments = null, @node) { // {{{
		super(data)

		if object == null {
			@expression = $compile.expression(data.callee, node)
		}
		else {
			@expression = new MemberExpression(data.callee, node, node.scope(), object)
		}

		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		// FIX type ??= @expression.type()
		const type = _type ?? @expression.type()

		if type is Array {
			const types = []

			for const tt in type {
				this.validate(tt, node)

				types.pushUniq(tt.getReturnType())
			}

			@type = Type.union(node.scope(), ...types)
		}
		else if type.isClass() {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			this.validate(type, node)

			@type = type.getReturnType()
		}
		else if type.isStruct() || type.isTuple() {
			@type = node.scope().reference(type)
		}
		else {
			@type = AnyType.NullableUnexplicit
		}
	} // }}}
	constructor(@data, @object, @methods, @type, @arguments = null, @node) { // {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), object)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		for method in methods {
			this.validate(method, node)
		}

		if @type.isClass() {
			TypeException.throwConstructorWithoutNew(@type.name(), node)
		}
	} // }}}
	constructor(@data, @expression, @node) { // {{{
		super(data)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		const type = @expression.type()

		if type is Array {
			const types = []

			for const tt in type {
				this.validate(tt, node)

				types.pushUniq(tt.getReturnType())
			}

			@type = Type.union(node.scope(), ...types)
		}
		else if type.isClass() {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			this.validate(type, node)

			@type = type.getReturnType()
		}
		else if type.isStruct() || type.isTuple() {
			@type = node.scope().reference(type)
		}
		else {
			@type = AnyType.NullableUnexplicit
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@expression.acquireReusable(@nullable || (@flatten && @scope == ScopeKind::This))
	} // }}}
	override hashCode() => `default`
	isInitializingInstanceVariable(name: String): Boolean { // {{{
		if @methods? {
			for const method in @methods {
				if !method.isInitializingInstanceVariable(name) {
					return false
				}
			}

			return true
		}
		else {
			return false
		}
	} // }}}
	mergeWith(that: Callee) { // {{{
		@type = Type.union(@node.scope(), @type, that.type())
	} // }}}
	releaseReusable() { // {{{
		@expression.releaseReusable()
	} // }}}
	toFragments(fragments, mode, node) { // {{{
		const arguments = @prepareArguments(node)

		if @flatten {
			if @scope == ScopeKind::Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node._callScope, mode)
			}
			else if @scope == ScopeKind::Null || @expression is not MemberExpression {
				fragments
					.compileReusable(@expression)
					.code('.apply(null')
			}
			else {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(@expression.caller(), mode)
			}

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), arguments)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments.wrap(@expression, mode).code('.call(').compile(node._callScope, mode)

					for const argument in arguments {
						fragments.code($comma)

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
				ScopeKind::Null => {
					fragments.wrap(@expression, mode).code('.call(null')

					for const argument in arguments {
						fragments.code($comma)

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
				ScopeKind::This => {
					fragments.wrap(@expression, mode).code('(')

					for const argument, index in arguments {
						fragments.code($comma) if index != 0

						DefaultCallee.toArgumentFragments(argument, fragments, mode)
					}
				}
			}
		}
	} // }}}
	toCurryFragments(fragments, mode, node) { // {{{
		node.module().flag('Helper')

		const arguments = @prepareArguments(node)

		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', null')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code($comma)
						.compile(@expression.caller())
				}
			}

			for argument in arguments {
				fragments.code($comma)

				DefaultCallee.toArgumentFragments(argument, fragments, mode)
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', null')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			for argument in arguments {
				fragments.code($comma)

				DefaultCallee.toArgumentFragments(argument, fragments, mode)
			}
		}
	} // }}}
	toNullableFragments(fragments, node) { // {{{
		if @nullable {
			if @expression.isNullable() {
				fragments
					.compileNullable(@expression)
					.code(' && ')
			}

			fragments
				.code($runtime.type(node) + '.isFunction(')
				.compileReusable(@expression)
				.code(')')
		}
		else if @expression.isNullable() {
			fragments.compileNullable(@expression)
		}
		else {
			fragments
				.code($runtime.type(node) + '.isValue(')
				.compileReusable(@expression)
				.code(')')
		}
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		fragments
			.code($runtime.type(node) + '.isValue(')
			.compileReusable(@object)
			.code(')')
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	type() => @type
	type(@type) => this

	private {
		prepareArguments(node) { // {{{
			if @arguments? {
				return [node._arguments[index] for const index in @arguments]
			}
			else {
				return node._arguments
			}
		} // }}}
	}
}
