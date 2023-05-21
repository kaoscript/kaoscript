class VoidType extends Type {
	constructor() { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
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
		throw NotSupportedException.new(node)
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Void'
	override toVariations(variations) { # {{{
		variations.push('void')
	} # }}}
}
