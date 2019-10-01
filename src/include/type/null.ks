class NullType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode)
	getProperty(name) => Type.Any
	isInstanceOf(target: Type) => true
	isMorePreciseThan(type: Type) => type.isAny() || type.isNullable()
	isAny() => true
	isMatching(value: NullType, mode: MatchingMode) => true
	isMatching(value: Type, mode: MatchingMode) => false
	isNull() => true
	isNullable() => true
	matchContentOf(type: Type) => type.isAny() || type.isNullable()
	toQuote() => `Null`
	toFragments(fragments, node)
	toTestFragments(fragments, node)
}