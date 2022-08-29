class TupleCallee extends Callee {
	private {
		@arguments: Array<CallMatchArgument>
		@expression
		@flatten: Boolean
		@function: FunctionType
		@node: CallExpression
		@scope: ScopeKind
		@type: Type
	}
	constructor(@data, match: CallMatch, @node) { # {{{
		super(data)

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@function = match.function
		@arguments = match.arguments

		this.validate(@function, node)

		@type = @function.getReturnType()
	} # }}}
	override hashCode() { # {{{
		return `tuple:\(@arguments)`
	} # }}}
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		fragments.wrap(@expression, mode).code(`.__ks_new`).code('(')

		Router.toArgumentsFragments(@arguments, node._arguments, @function, false, fragments, mode)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	type() => @type
}
