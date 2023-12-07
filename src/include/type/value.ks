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
	override export(references, indexDelta, mode, module) { # {{{
		NotImplementedException.throw()
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		NotImplementedException.throw()
	} # }}}
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		return @type.isSubsetOf(value, generics, subtypes, mode)
	} # }}}
	assist isSubsetOf(value: VariantType, generics, subtypes, mode) { # {{{
		return @type == value.getMaster()
	} # }}}
	override isValue() => true
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
		isAssignableToVariable
		isBitmask
		isBoolean
		isComparableWith
		isEnum
		isExplicit
		isMorePreciseThan
		isNull
		isNullable
		isNumber
		isString
		isUnion
		toTypeQuote
	}
}
