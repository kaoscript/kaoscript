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
	equals(b?) { // {{{
		if b is SealableType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	} // }}}
	export(references, mode) => { // {{{
		kind: TypeKind::Sealable
		sealed: this.isSealed()
		type: @type.toReference(references, mode)
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		@type.flagExported(explicitly)

		return this
	} // }}}
	flagReferenced() { // {{{
		@type.flagReferenced()

		return this
	} // }}}
	isSealable() => true
	isSealed() => @sealed || @type.isSealed()
	matchSignatureOf(that, matchables) { // {{{
		if that is SealableType {
			return @type.matchSignatureOf(that.type(), matchables)
		}
		else {
			return @type.matchSignatureOf(that, matchables)
		}
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
}