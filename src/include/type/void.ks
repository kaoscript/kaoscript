class VoidType extends Type {
	constructor() { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) => 'Void'
	isMatching(value: VoidType, mode: MatchingMode) => true
	isVoid() => true
	toFragments(fragments, node) { // {{{
		fragments.code('Void')
	} // }}}
	toQuote(): String => `Void`
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}