class SubstituteCallee extends Callee {
	private {
		@substitute: Substitude
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
	override hashCode() => null
	substitute(): @substitute
	toFragments(fragments, mode, node) { # {{{
		@substitute.toFragments(fragments, mode)
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	translate()
	type() => @type

	proxy @substitute {
		isInitializingInstanceVariable
		isSkippable
	}
}
