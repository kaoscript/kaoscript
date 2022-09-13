class VoidType extends Type {
	constructor() { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Void'
	hashCode() => `Void`
	isComplete() => true
	isExportable() => true
	isSubsetOf(value: VoidType, mode: MatchingMode) => true
	isVoid() => true
	toFragments(fragments, node) { # {{{
		fragments.code('Void')
	} # }}}
	toQuote(): String => `Void`
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotSupportedException(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('void')
	} # }}}
}
