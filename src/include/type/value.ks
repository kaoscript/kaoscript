class ValueType extends Type {
	private {
		@path: String
		@type: Type
		@value?
	}
	constructor(@value, @type, @path, @scope) { # {{{
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
	isSubsetOf(value: VariantType, mode: MatchingMode) { # {{{
		return @type == value.getMaster()
	} # }}}
	override isValue() => true
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
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
		isBoolean
		isComparableWith
		isEnum
		isMorePreciseThan
		isNull
		isNullable
		isNumber
		isString
		isUnion
	}
}
