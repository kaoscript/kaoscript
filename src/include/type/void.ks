class VoidType extends Type {
	equals(b?): Boolean => b is VoidType
	export(references, ignoreAlteration) => 'Void'
	toFragments(fragments, node) { // {{{
		fragments.code('Void')
	} // }}}
	toQuote(): String => `'Void'`
	toTestFragments(fragments, node) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}