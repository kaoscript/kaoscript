class AnyType extends Type {
	equals(b?): Boolean => b is AnyType
	export(references, ignoreAlteration) => 'Any'
	flagAlien() { // {{{
		const type = new AnyType(null)

		type._alien = true

		return type
	} // }}}
	getProperty(name) => Type.Any
	hashCode() => 'Any'
	isAny() => true
	isInstanceOf(target: Type) => true
	isNullable() => false
	matchContentOf(b) => true
	matchSignatureOf(b, matchables) => b.isAny()
	parameter() => Type.Any
	flagRequired() => this
	toFragments(fragments, node) { // {{{
		fragments.code('Any')
	} // }}}
	toMetadata(references, ignoreAlteration) => -1
	toQuote(): String => `'Any'`
	toReference(references, ignoreAlteration) => 'Any'
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
}