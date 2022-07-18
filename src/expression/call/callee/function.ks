class FunctionCallee extends Callee {
	private {
		@arguments: Array<CallMatchArgument>
		@expression
		@flatten: Boolean
		@functions: Array<FunctionType>
		@node: CallExpression
		@index: Number
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, match: CallMatch, @node) { # {{{
		super(data)

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		this.validate(match.function, node)

		@functions = [match.function]
		@index = match.function.getCallIndex()
		@arguments = match.arguments
		@type = match.function.getReturnType()
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@flatten)
	} # }}}
	override hashCode() { # {{{
		return `function:\(@index):\(@arguments)`
	} # }}}
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

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node._arguments)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('.call(').compile(node._callScope, mode)

					Router.toArgumentsFragments(@arguments, node._arguments, @functions[0], true, fragments, mode)
				}
				ScopeKind::Null => {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('.call(null')

					Router.toArgumentsFragments(@arguments, node._arguments, @functions[0], true, fragments, mode)
				}
				ScopeKind::This => {
					fragments.wrap(@expression, mode).code(`.__ks_\(@index)`).code('(')

					Router.toArgumentsFragments(@arguments, node._arguments, @functions[0], false, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		node.module().flag('Helper')

		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code($comma)
						.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', null')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node._arguments)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code($comma)
						.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', null')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(`.__ks_\(@index)`)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			Router.toArgumentsFragments(@arguments, node._arguments, @functions[0], true, fragments, mode)
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
