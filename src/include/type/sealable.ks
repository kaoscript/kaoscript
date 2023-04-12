class SealableType extends Type {
	private {
		@type: Type
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			var type = SealableType.new(scope, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node))

			if data.sealed {
				type.flagSealed()
			}

			return type
		} # }}}
	}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @system {
			return {
				kind: TypeKind.Sealable
				system: true
				type: @type.toReference(references, indexDelta, mode, module)
			}
		}
		else {
			return {
				kind: TypeKind.Sealable
				sealed: @isSealed()
				type: @type.toReference(references, indexDelta, mode, module)
			}
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@type.flagExported(explicitly)

		return this
	} # }}}
	flagReferenced() { # {{{
		@type.flagReferenced()

		return this
	} # }}}
	isComplete() => true
	isSealable() => true
	isSealed() => @sealed || @type.isSealed()
	isSubsetOf(value: SealableType, mode: MatchingMode) => @type.isSubsetOf(value.type(), mode)
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode.Similar {
			return @type.isSubsetOf(value, mode)
		}
		else {
			return false
		}
	} # }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { # {{{
		variations.push('sealable')

		@type.toVariations(variations)
	} # }}}
	type() => @type

	proxy {
		toQuote = @type.toQuote
	}
}
