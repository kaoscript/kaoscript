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
	override isExportable() => true
	override isExportable(module) => true
	assist isSubsetOf(value: VoidType, generics, subtypes, mode) => true
	isVoid() => true
	toFragments(fragments, node) { # {{{
		fragments.code('Void')
	} # }}}
	toQuote(): String => `Void`
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Void'
	override toVariations(variations) { # {{{
		variations.push('void')
	} # }}}
}
