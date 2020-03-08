class NeverType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) => 'Never'
	isNever() => true
	toFragments(fragments, node) { // {{{
		fragments.code('Never')
	} // }}}
	toQuote(): String => `Never`
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}