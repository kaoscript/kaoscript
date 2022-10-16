class LenientFunctionCallee extends Callee {
	private {
		@expression
		@flatten: Boolean
		@function: FunctionType
		@functions: FunctionType[]
		@hash: String
		@labelable: Boolean
		@labels: Number{}?
		@node: CallExpression
		@positions: Number[]
		@scope: ScopeKind
		@type: Type
	}
	// TODO!
	// constructor(@data, assessment, result: LenientCallMatchResult, @node) { # {{{
	// 	this(data, assessment, result.possibilities, result.positions, result.labels, node)
	// } # }}}
	constructor(@data, assessment: Router.Assessment, result: LenientCallMatchResult, @node) { # {{{
		super(data)

		// TODO
		// { @labelable } = assessment
		@labelable = assessment.labelable
		// TODO
		// { possibilities: @functions, @positions, @labels } = result
		@functions = result.possibilities
		@positions = result.positions
		@labels = result.labels

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind
		@function = @functions[0]

		var types = []

		for var function in @functions {
			@validate(function, node)

			types.pushUniq(function.getReturnType())
		}

		@type = Type.union(node.scope(), ...types)

		@hash = 'lenient'
		@hash += `:\(@functions.map((function, ...) => function.index()).join(','))`
		@hash += `:\(@positions.join(','))`
		@hash += `:\(Dictionary.map(@labels, ([label, index], ...) => `\(label)=\(index)`).join(','))`
	} # }}}
	constructor(@data, assessment: Router.Assessment, @functions, @positions = [], @labels = null, @node) { # {{{
		super(data)

		// TODO
		// { @labelable } = assessment
		@labelable = assessment.labelable

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind
		@function = @functions[0]

		var types = []

		for var function in @functions {
			@validate(function, node)

			types.pushUniq(function.getReturnType())
		}

		@type = Type.union(node.scope(), ...types)

		@hash = 'lenient'
		@hash += `:\(@functions.map((function, ...) => function.index()).join(','))`
		if ?@positions {
			@hash += `:\(@positions.join(','))`
		}
		if ?@labels {
			@hash += `:\(Dictionary.map(@labels, ([label, index], ...) => `\(label)=\(index)`).join(','))`
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@flatten)
	} # }}}
	functions() => @functions
	override hashCode() => @hash
	isInitializingInstanceVariable(name: String): Boolean => false
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
		@functions.push(...that.functions())
	} # }}}
	releaseReusable() { # {{{
		@expression.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			if @scope == ScopeKind::Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node.getCallScope(), mode)
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

			Router.Argument.toFlatFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments.wrap(@expression, mode).code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
				}
				ScopeKind::Null => {
					fragments.wrap(@expression, mode).code('.call(null')

					Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
				}
				ScopeKind::This => {
					fragments.wrap(@expression, mode).code('(')

					Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, false, fragments, mode)
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
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
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
