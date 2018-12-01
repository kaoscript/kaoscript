class AnyType extends Type {
	equals(b?): Boolean => b is AnyType
	export(references) => 'Any'
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
	matchSignatureOf(b) => b.isAny()
	parameter() => Type.Any
	flagRequired() => this
	toFragments(fragments, node) { // {{{
		fragments.code('Any')
	} // }}}
	toMetadata(references) => -1
	toQuote(): String => `'Any'`
	toReference(references) => 'Any'
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
}