class NeverType extends Type {
	constructor() { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Never'
	hashCode() => `Never`
	isComplete() => true
	isNever() => true
	toFragments(fragments, node) { # {{{
		fragments.code('Never')
	} # }}}
	toQuote(): String => `Never`
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw NotSupportedException.new(node)
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Never'
	override toVariations(variations) { # {{{
		variations.push('never')
	} # }}}
}
