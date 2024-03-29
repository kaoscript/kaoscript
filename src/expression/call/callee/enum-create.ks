class EnumCreateCallee extends Callee {
	private {
		@argument
		@enum: NamedType<EnumType>
		@expression
		@node: CallExpression
		@type: Type
	}
	constructor(@data, @enum, @argument, @node) { # {{{
		super(data)

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@type = node.scope().reference(enum).setNullable(true)
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
