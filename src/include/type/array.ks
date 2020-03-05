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
	export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Array
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.elements = [element.export(references, mode) for const element in @elements]

		return export
	} // }}}
	getElement(index: Number): Type => index >= @elements.length ? AnyType.NullableUnexplicit : @elements[index]
	isArray() => true
	isMatching(value: ArrayType, mode: MatchingMode) { // {{{
		if this.length() != value.length() {
			return false
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		for const element, index in value._elements {
			unless @elements[index].isMatching(element, mode) {
				return false
			}
		}

		return true
	} // }}}
	isNullable() => false
	isSealable() => true
	length() => @elements.length
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn)
}