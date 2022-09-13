class NeverType extends Type {
	constructor() { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Never'
	isComplete() => true
	isNever() => true
	toFragments(fragments, node) { # {{{
		fragments.code('Never')
	} # }}}
	toQuote(): String => `Never`
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotSupportedException(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('never')
	} # }}}
}
