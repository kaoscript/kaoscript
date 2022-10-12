class EnumCreateCallee extends Callee {
	private {
		@argument
		@bitmask: Boolean
		@enum: NamedType<EnumType>
		@expression
		@node: CallExpression
		@type: Type
		@useFrom: Boolean
	}
	constructor(@data, @enum, @argument, @node) { # {{{
		super(data)

		@expression = $compile.expression(data.callee, node)
		@expression.analyse()
		@expression.prepare(AnyType.NullableUnexplicit)

		@bitmask = enum.type().kind() == EnumTypeKind::Bit
		@type = node.scope().reference(enum)

		if !@bitmask || !argument.type().isAssignableToVariable(enum.type().type(), false, false, false) {
			@type = @type.setNullable(true)
			@useFrom = true
		}
		else {
			@useFrom = false
		}
	} # }}}
	override {
		hashCode() => null
		toFragments(fragments, mode, node) { # {{{
			if @useFrom {
				fragments.wrap(@expression, mode).code('.__ks_from(').compile(@argument)
			}
			else {
				fragments.wrap(@expression, mode).code('(').compile(@argument)
			}
		} # }}}
		toNullableFragments(fragments, node) { # {{{
		} # }}}
		translate() { # {{{
			@expression.translate()
		} # }}}
		type() => @type
	}
}
