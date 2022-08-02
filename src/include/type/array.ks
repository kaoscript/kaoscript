class ArrayType extends Type {
	private {
		_elements: Array			= []
	}
	addElement(type: Type) { # {{{
		@elements.push(type)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			kind: TypeKind::Array
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.elements = [element.export(references, indexDelta, mode, module) for var element in @elements]

		return export
	} # }}}
	getElement(index: Number): Type => index >= @elements.length ? AnyType.NullableUnexplicit : @elements[index]
	isArray() => true
	isMorePreciseThan(value) => true
	isNullable() => false
	isSealable() => true
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		if this.length() != value.length() {
			return false
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		for var element, index in value._elements {
			unless @elements[index].isSubsetOf(element, mode) {
				return false
			}
		}

		return true
	} # }}}
	length() => @elements.length
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @elements.length == 0 {
			fragments.code($runtime.type(node), '.isArray')
		}
		else {
			fragments.code(`value => `, $runtime.type(node), '.isArray(value)')

			for var value, index in @elements {
				fragments.code(' && ')

				value.toPositiveTestFragments(fragments, new Literal(false, node, node.scope(), `value[\(index)]`))
			}
		}
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('array')

		for var element in @elements {
			element.toVariations(variations)
		}
	} # }}}
	walk(fn)
}
