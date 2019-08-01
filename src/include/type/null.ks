class NullType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	equals(b?): Boolean => b is NullType
	export(references, mode)
	getProperty(name) => Type.Any
	isInstanceOf(target: Type) => true
	isMorePreciseThan(type: Type) => type.isAny() || type.isNullable()
	isAny() => true
	isNull() => true
	isNullable() => true
	matchContentOf(type: Type) => type.isAny() || type.isNullable()
	toQuote() => `null`
	toFragments(fragments, node)
	toTestFragments(fragments, node)
}