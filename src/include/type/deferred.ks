class DeferredType extends Type {
	private {
		@name: String
	}
	constructor(@name, @scope) { # {{{
		super(scope)
	} # }}}
	override canBeDeferred() => true
	override clone() => this
	override export(references, indexDelta, mode, module) { # {{{
		NotImplementedException.throw()
	} # }}}
	override hashCode() => `<\(@name)>`
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		NotImplementedException.throw()
	} # }}}
	name() => @name
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, mapper, subtypes, fragments, node) { # {{{
	} # }}}
	override toBlindSubtestFunctionFragments(varname, _, generics, fragments, node) { # {{{
		var index = generics.indexOf(@name)

		unless ?index {
			NotImplementedException.throw()
		}

		fragments.code(`mapper[\(index)]`)
	} # }}}
	override toQuote() => `<\(@name)>`
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
