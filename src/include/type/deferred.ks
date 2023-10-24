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
	override isNullable(generics: AltType[]?) { # {{{
		return true unless #generics

		for var { name, type } in generics {
			if name == @name {
				return type.isNullable()
			}
		}

		return true
	} # }}}
	name() => @name
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, generics, subtypes, fragments, node) { # {{{
	} # }}}
	override toBlindSubtestFunctionFragments(varname, _, generics, fragments, node) { # {{{
		if var index ?= generics.indexOf(@name) {
			fragments.code(`mapper[\(index)]`)
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	override toQuote() => `<\(@name)>`
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
