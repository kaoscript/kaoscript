class NullType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	equals(b?): Boolean => b is NullType
	export(references, ignoreAlteration)
	getProperty(name) => Type.Any
	isInstanceOf(target: Type) => true
	isMorePreciseThan(type: Type) => type.isAny() || type.isNullable()
	isAny() => true
	isNull() => true
	toQuote()
	toFragments(fragments, node)
	toTestFragments(fragments, node)
}