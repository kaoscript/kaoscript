class BitmaskCreateCallee extends Callee {
	private {
		@argument
		@bitmask: NamedType<BitmaskType>
		@expression
		@node: CallExpression
		@type: Type
	}
	constructor(@data, @bitmask, @argument, @node) { # {{{
		super(data)

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@type = node.scope().reference(bitmask)

		if !argument.type().isAssignableToVariable(bitmask.type().type(), false, false, false) {
			@type = @type.setNullable(true)
		}
	} # }}}
	override {
		hashCode() => null
		toFragments(fragments, mode, node) { # {{{
			fragments.wrap(@expression, mode).code('(').compile(@argument)
		} # }}}
		toNullableFragments(fragments, node) { # {{{
		} # }}}
		translate() { # {{{
			@expression.translate()
		} # }}}
		type() => @type
	}
}
