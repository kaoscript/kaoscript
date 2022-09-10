class PreciseMethodCallee extends Callee {
	private {
		@alien: Boolean
		@arguments: Array<CallMatchArgument>
		@expression
		@flatten: Boolean
		@function: FunctionType
		@functions: Array<FunctionType>
		@index: Number
		@instance: Boolean
		@node: CallExpression
		@object
		@property: String
		@proxy: Boolean
		@reference: ReferenceType
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @object, @property, match: CallMatch, @reference, @node) { # {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), object)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@validate(match.function, node)

		@function = match.function
		@functions = [@function]
		@index = match.function.index()
		@alien = match.function.isAlien()
		@instance = match.function.isInstance()
		@proxy = match.function.isProxy()
		@arguments = match.arguments
		@type = match.function.getReturnType()
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@flatten && @scope == ScopeKind::This)
	} # }}}
	functions() => @functions
	override hashCode() { # {{{
		return `method:\(@property):\(@index):\(@alien):\(@instance):\(@arguments)`
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var function in @functions {
			if function.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
		@functions.push(...that.functions())
	} # }}}
	releaseReusable() { # {{{
		@expression.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					fragments.compileReusable(@object)

					if @alien {
						fragments.code(`.\(@property).call(`)
					}
					else if @instance {
						fragments.code(`.__ks_func_\(@property)_\(@index).call(`)
					}
					else {
						fragments.code(`.__ks_sttc_\(@property)_\(@index).call(`)
					}

					fragments.compile(@object, mode)

					Router.toArgumentsFragments(@arguments, node._arguments, @function, true, fragments, mode)
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					fragments.wrap(@object)

					if @alien {
						fragments.code(`.\(@property)(`)
					}
					else if @instance {
						if @proxy {
							fragments.code(`\(@function.getProxyPath()).__ks_func_\(@function.getProxyName())_\(@index)(`)
						}
						else {
							fragments.code(`.__ks_func_\(@property)_\(@index)(`)
						}
					}
					else {
						fragments.code(`.__ks_sttc_\(@property)_\(@index)(`)
					}

					Router.toArgumentsFragments(@arguments, node._arguments, @function, false, fragments, mode)
				}
			}
		}
	} # }}}
	toCurryFragments(fragments, mode, node) { # {{{
		node.module().flag('Helper')

		if @flatten {
			throw new NotImplementedException(this)
		}
		else {
			fragments.code($runtime.helper(node), '.vcurry(')

			if @alien {
				fragments.compile(@object).code(`.\(@property)`).code($comma)
			}
			else if @instance {
				fragments.compile(@object).code(`.__ks_func_\(@property)_\(@index)`).code($comma)
			}
			else {
				fragments.compile(@object).code(`.__ks_sttc_\(@property)_\(@index)`).code($comma)
			}

			switch @scope {
				ScopeKind::Argument => {
					fragments.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments.code('null')
				}
				ScopeKind::This => {
					fragments.compile(@object.caller())
				}
			}

			Router.toArgumentsFragments(@arguments, node._arguments, @function, true, fragments, mode)
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
	toPositiveTestFragments(fragments, node) { # {{{
		@reference.toPositiveTestFragments(fragments, @object)
	} # }}}
	translate() { # {{{
		@object.translate()
		@expression.translate()
	} # }}}
	type() => @type
}
