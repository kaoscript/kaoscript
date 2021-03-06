class NullType extends Type {
	static {
		Explicit = new NullType(true)
		Unexplicit = new NullType(false)
	}
	private {
		_explicit: Boolean	= false
	}
	constructor() { // {{{
		super(null)
	} // }}}
	constructor(@explicit) { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode)
	getProperty(name) => AnyType.NullableUnexplicit
	isAssignableToVariable(value, anycast, nullcast, downcast) => nullcast || value.isNullable()
	isExplicit() => @explicit
	isExportable() => true
	isInstanceOf(target: Type) => true
	isMorePreciseThan(type: Type) => type.isAny() || type.isNullable()
	isMatching(value: NullType, mode: MatchingMode) => true
	isMatching(value: Type, mode: MatchingMode) => false
	isNull() => true
	isNullable() => true
	matchContentOf(type: Type) => type.isNullable()
	setNullable(nullable: Boolean) { // {{{
		if nullable {
			return this
		}
		else {
			return AnyType.Unexplicit
		}
	} // }}}
	toFragments(fragments, node)
	toQuote() => 'Null'
	toReference(references, mode) => 'Null'
	override toPositiveTestFragments(fragments, node, junction)
}