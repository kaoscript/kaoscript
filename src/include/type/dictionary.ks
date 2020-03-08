class DictionaryType extends Type {
	private {
		_properties: Dictionary			= {}
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new DictionaryType(scope)

			if data.systemic {
				type.flagSystemic()
			}
			else if data.sealed {
				type.flagSealed()
			}

			for const property, name of data.properties {
				type.addProperty(name, Type.fromMetadata(property, metadata, references, alterations, queue, scope, node))
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new DictionaryType(scope)

			if data.systemic {
				type.flagSystemic()
			}
			else if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				for const property, name of data.properties {
					type.addProperty(name, Type.fromMetadata(property, metadata, references, alterations, queue, scope, node))
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

		if @systemic {
			export.systemic = true
		}
		else if @sealed {
			export.sealed = true
		}

		export.properties = {}

		for const value, name of @properties {
			export.properties[name] = value.export(references, mode)
		}

		return export
	} // }}}
	getProperty(name: String): Type? => @properties[name]
	isAssignableToVariable(value, anycast, nullcast, downcast) { // {{{
		if value.isAny() || value.isDictionary() {
			if this.isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value is UnionType {
			for const type in value.types() {
				if this.isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} // }}}
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
	isMorePreciseThan(type: Type) { // {{{
		if type.isAny() {
			return true
		}

		return false
	} // }}}
	isNullable() => false
	isDictionary() => true
	isExhaustive() => false
	isExportable() => true
	isSealable() => true
	matchContentOf(type: Type) { // {{{
		if type.isAny() || type.isDictionary() {
			return true
		}

		if type is UnionType {
			for const type in type.types() {
				if this.matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} // }}}
	parameter() => AnyType.NullableUnexplicit
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toQuote() { // {{{
		auto str = '{'

		let first = true
		for const property, name of @properties {
			if first {
				first = false
			}
			else {
				str += ', '
			}

			str += `\(name): \(property.toQuote())`
		}

		if first {
			return 'Dictionary'
		}
		else {
			return str + '}'
		}
	} // }}}
	override toNegativeTestFragments(fragments, node, junction) { // {{{
		fragments.code('(') if junction == Junction::AND

		fragments.code('!', $runtime.type(node), '.isDictionary(').compile(node).code(')')

		for const value, name of @properties {
			fragments.code(' || ')

			value.toNegativeTestFragments(fragments, new Literal(false, node, node.scope(), `\(node.path()).\(name)`))
		}

		fragments.code(')') if junction == Junction::AND
	} // }}}
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		fragments.code('(') if junction == Junction::OR

		fragments.code($runtime.type(node), '.isDictionary(').compile(node).code(')')

		for const value, name of @properties {
			fragments.code(' && ')

			value.toPositiveTestFragments(fragments, new Literal(false, node, node.scope(), `\(node.path()).\(name)`))
		}

		fragments.code(')') if junction == Junction::OR
	} // }}}
	walk(fn) { // {{{
		for const type, name of @properties {
			fn(name, type)
		}
	} // }}}
}