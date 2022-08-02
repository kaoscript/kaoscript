class EnumMethodCallee extends Callee {
	private {
		_enum: NamedType<EnumType>
		_expression
		_flatten: Boolean
		_methodName: String
		_methods: Array<FunctionType>?
		_scope: ScopeKind
		_type: Type
	}
	constructor(@data, @enum, @methodName, @methods, node) { # {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), node._object)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		if ?@methods {
			var union = new UnionType(node.scope())

			for var method in @methods {
				union.addType(method.getReturnType())
			}

			@type = union.type()
		}
		else {
			@type = @expression.type()
		}

		for method in methods {
			this.validate(method, node)
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression.acquireReusable(@nullable || (@flatten && @scope == ScopeKind::This))
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		if @methods? {
			for var method in @methods {
				if !method.isInitializingInstanceVariable(name) {
					return false
				}
			}

			return true
		}
		else {
			return false
		}
	} # }}}
	releaseReusable() { # {{{
		@expression.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			NotImplementedException.throw(node)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					NotImplementedException.throw(node)
				}
				ScopeKind::Null => {
					NotImplementedException.throw(node)
				}
				ScopeKind::This => {
					fragments.code(`\(@enum.name()).\(@methodName)(`)

					fragments.wrap(@expression._object, mode)

					for var argument, index in node._arguments {
						fragments.code($comma)

						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		NotImplementedException.throw(node)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
