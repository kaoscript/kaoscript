class DictionaryType extends Type {
	private {
		_properties: Dictionary			= {}
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new DictionaryType(scope)

			if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				for const property, name of data.properties {
					if property.parameters? {
						type.addProperty(name, FunctionType.fromMetadata(property, metadata, references, alterations, queue, scope, node))
					}
					else {
						type.addProperty(name, Type.fromMetadata(property, metadata, references, alterations, queue, scope, node))
					}
				}
			})

			return type
		} // }}}
	}
	addProperty(name: String, type: Type) { // {{{
		@properties[name] = type
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		const export = {
			kind: TypeKind::Dictionary
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.properties = {}

		for const value, name of @properties {
			export.properties[name] = value.export(references, mode)
		}

		return export
	} // }}}
	getProperty(name: String): Type => @properties[name] ?? AnyType.NullableUnexplicit
	isMatching(value: DictionaryType, mode: MatchingMode) { // {{{
		if this == value {
			return true
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		let nf
		for const property of value._properties {
			nf = true

			for const prop of @properties while nf {
				if prop.isMatching(property, mode) {
					nf = false
				}
			}

			if nf {
				return false
			}
		}

		return true
	} // }}}
	isMatching(value: Type, mode: MatchingMode) => false
	isNullable() => false
	isDictionary() => true
	isSealable() => true
	parameter() => AnyType.NullableUnexplicit
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	walk(fn) { // {{{
		for const type, name of @properties {
			fn(name, type)
		}
	} // }}}
}