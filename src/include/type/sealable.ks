class SealableType extends Type {
	private {
		_type: Type
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new SealableType(scope, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node))

			if data.sealed {
				type.flagSealed()
			}

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		if @systemic {
			return {
				kind: TypeKind::Sealable
				systemic: true
				type: @type.toReference(references, mode)
			}
		}
		else {
			return {
				kind: TypeKind::Sealable
				sealed: this.isSealed()
				type: @type.toReference(references, mode)
			}
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		@type.flagExported(explicitly)

		return this
	} // }}}
	flagReferenced() { // {{{
		@type.flagReferenced()

		return this
	} // }}}
	isMatching(value: SealableType, mode: MatchingMode) => @type.isMatching(value.type(), mode)
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Similar {
			return @type.isMatching(value, mode)
		}
		else {
			return false
		}
	} // }}}
	isSealable() => true
	isSealed() => @sealed || @type.isSealed()
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote(...args) => @type.toQuote(...args)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	type() => @type
}