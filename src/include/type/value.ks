class ValueType extends Type {
	private {
		@path: String
		@type: Type
		@value?
	}
	constructor(@value = null, @type, @path, @scope) { # {{{
		super(scope)
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	override discardValue() => @type
	assist equals(value: Type) { # {{{
		return false
	} # }}}
	assist equals(value: ValueType) { # {{{
		return true if this == value
		return @path == value.path() && @value == value.value() && @type.equals(value.type())
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		NotImplementedException.throw()
	} # }}}
	override hashCode() => `=\(@path)`
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isView() {
			var root = value.discard()

			if root.master() == @type.discard() {
				return root.hasValue(@value)
			}
		}

		return @type.isAssignableToVariable(value, anycast, nullcast, downcast, limited)
	} # }}}
	override isMorePreciseThan(value) { # {{{
		return @type.isSubsetOf(value, MatchingMode.Exact + MatchingMode.Subclass)
	} # }}}
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		return @type.isSubsetOf(value, generics, subtypes, mode)
	} # }}}
	assist isSubsetOf(value: VariantType, generics, subtypes, mode) { # {{{
		return @type.equals(value.getMaster())
	} # }}}
	override isValue() => true
	path() => @path
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toQuote() => @path
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
	override type() => @type
	value() => @value

	proxy @type {
		canBeBoolean
		canBeEnum
		canBeNumber
		canBeString
		discard
		isAny
		isBitmask
		isBoolean
		isComparableWith
		isEnum
		isExplicit
		// TODO!
		// isMorePreciseThan
		isNull
		isNullable
		isNumber
		isString
		isUnion
		toTypeQuote
	}
}
