class SealedType extends Type {
	private {
		_type: ReferenceType
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	equals(b?) {
		if b is SealedType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	}
	export(references, ignoreAlteration) => { // {{{
		sealed: true
		type: @type.toReference(references, ignoreAlteration)
	} // }}}
	isSealed() => true
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
}