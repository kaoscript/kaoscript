class ArrayType extends Type {
	private {
		_elements: Array			= []
	}
	addElement(type: Type) { // {{{
		@elements.push(type)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		const export = {
			kind: TypeKind::Array
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.elements = [element.export(references, ignoreAlteration) for const element in @elements]

		return export
	} // }}}
	getElement(index: Number): Type => index >= @elements.length ? Type.Any : @elements[index]
	isArray() => true
	isNullable() => false
	isSealable() => true
	length() => @elements.length
	matchSignatureOf(value, matchables) { // {{{
		if value is not ArrayType || this.length() != value.length() {
			return false
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		for const element, index in value._elements {
			unless @elements[index].matchSignatureOf(element, matchables) {
				return false
			}
		}

		return true
	} // }}}
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn)
}