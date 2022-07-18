class SealableType extends Type {
	private {
		_type: Type
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			const type = new SealableType(scope, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node))

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
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @systemic {
			return {
				kind: TypeKind::Sealable
				systemic: true
				type: @type.toReference(references, indexDelta, mode, module)
			}
		}
		else {
			return {
				kind: TypeKind::Sealable
				sealed: this.isSealed()
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
	isSealable() => true
	isSealed() => @sealed || @type.isSealed()
	isSubsetOf(value: SealableType, mode: MatchingMode) => @type.isSubsetOf(value.type(), mode)
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Similar {
			return @type.isSubsetOf(value, mode)
		}
		else {
			return false
		}
	} # }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	// TODO add alias
	// toQuote(...args) => @type.toQuote(...args)
	toQuote() => @type.toQuote()
	toQuote(double) => @type.toQuote(double)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { # {{{
		variations.push('sealable')

		@type.toVariations(variations)
	} # }}}
	type() => @type
}
