class VoidType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	equals(b?): Boolean => b is VoidType
	export(references, ignoreAlteration) => 'Void'
	isVoid() => true
	toFragments(fragments, node) { // {{{
		fragments.code('Void')
	} // }}}
	toQuote(): String => `'Void'`
	toTestFragments(fragments, node) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}