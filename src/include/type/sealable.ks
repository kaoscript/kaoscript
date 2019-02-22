class SealableType extends Type {
	private {
		_type: Type
	}
	static {
		fromMetadata(data, references: Array, alterations, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new SealableType(scope, Type.fromMetadata(data.type, references, alterations, scope, node))

			if data.sealed {
				type.flagSealed()
			}

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	equals(b?) { // {{{
		if b is SealableType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	} // }}}
	export(references, ignoreAlteration) => { // {{{
		kind: TypeKind::Sealable
		sealed: this.isSealed()
		type: @type.toReference(references, ignoreAlteration)
	} // }}}
	flagExported() { // {{{
		@type.flagExported()

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