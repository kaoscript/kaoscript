class SubstituteCallee extends Callee {
	private {
		@substitute
		@type: Type
	}
	constructor(@data, @substitute, node) { # {{{
		super(data)

		@nullableProperty = substitute.isNullable()

		@type = @substitute.type()
	} # }}}
	constructor(@data, @substitute, @type, node) { # {{{
		super(data)

		@nullableProperty = substitute.isNullable()
	} # }}}
	isInitializingInstanceVariable(name: String): Boolean => @substitute.isInitializingInstanceVariable(name)
	isSkippable() => @substitute.isSkippable()
	override hashCode() => null
	substitute(): @substitute
	toFragments(fragments, mode, node) { # {{{
		@substitute.toFragments(fragments, mode)
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	translate()
	type() => @type

	// TODO
	// proxy @substitute {
	// 	isInitializingInstanceVariable
	// 	isSkippable
	// 	toFragments
	// }
}
