class InvertedPreciseMethodCallee extends Callee {
	private {
		_arguments: Array<CallMatchArgument>
		_expression: MemberExpression
		_function: FunctionType
		_name: NamedType
		_property: String
		_scope: ScopeKind
		_type: Type
	}
	constructor(@data, @name, @property, match: CallMatch, node) { # {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), node._object)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@function = match.function
		@arguments = match.arguments

		this.validate(@function, node)

		@type = @function.getReturnType()
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		return @function.isInitializingInstanceVariable(name)
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		switch @scope {
			ScopeKind::Argument => {
				throw new NotImplementedException(node)
			}
			ScopeKind::Null => {
				throw new NotImplementedException(node)
			}
			ScopeKind::This => {
				fragments.code(`\(@name.name())`)

				if @function.isInstance() {
					fragments.code(`.__ks_func_\(@property)_\(@function.index())(`)
				}
				else {
					fragments.code(`.__ks_sttc_\(@property)_\(@function.index())(`)
				}

				fragments.wrap(@expression._object, mode)

				Router.toArgumentsFragments(@arguments, node._arguments, @function, true, fragments, mode)
			}
		}
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
