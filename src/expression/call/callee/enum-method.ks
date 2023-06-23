class EnumMethodCallee extends Callee {
	private {
		@enum: NamedType<EnumType>
		@expression?
		@flatten: Boolean
		@instance: Boolean
		@methodName: String
		@methods: Array<FunctionType>?
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, @enum, @methodName, @methods, node) { # {{{
		super(data)

		@flatten = node._flatten
		@scope = data.scope.kind

		if #methods {
			var union = UnionType.new(node.scope())

			for var method in methods {
				@validate(method, node)

				union.addType(method.getReturnType())
			}

			@type = union.type()
		}
		else {
			@type = @expression.type()
		}

		@instance = @methods[0].isInstance()

		if @instance {
			@expression = MemberExpression.new(data.callee, node, node.scope(), node._object)
			@expression.analyse()
			@expression.prepare(AnyType.NullableUnexplicit)

			@nullableProperty = @expression.isNullable()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@expression?.acquireReusable(@nullable || (@flatten && @scope == ScopeKind.This))
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		if ?@methods {
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
		@expression?.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			NotImplementedException.throw(node)
		}
		else {
			match @scope {
				ScopeKind.Argument {
					NotImplementedException.throw(node)
				}
				ScopeKind.This {
					fragments.code(`\(@enum.name()).\(@methodName)(`)

					if @instance {
						fragments.wrap(@expression._object, mode)

						for var argument, index in node.arguments() {
							fragments.code($comma)

							argument.toArgumentFragments(fragments, mode)
						}
					}
					else {
						for var argument, index in node.arguments() {
							fragments.code($comma) if index != 0

							argument.toArgumentFragments(fragments, mode)
						}
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		NotImplementedException.throw(node)
	} # }}}
	translate() { # {{{
		@expression?.translate()
	} # }}}
	type() => @type
}
