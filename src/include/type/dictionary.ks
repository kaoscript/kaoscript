class DictionaryType extends Type {
	private {
		_properties: Dictionary			= {}
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): DictionaryType { # {{{
			const type = new DictionaryType(scope)

			if data.systemic {
				type.flagSystemic()
			}
			else if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				for const property, name of data.properties {
					type.addProperty(name, Type.import(property, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	addProperty(name: String, type: Type) { # {{{
		@properties[name] = type
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
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
			export.properties[name] = value.export(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	flagAlien() { # {{{
		@alien = true

		for const property of @properties {
			property.flagAlien()
		}

		return this
	} # }}}
	getProperty(name: String): Type? => @properties[name]
	hashCode() => this.toQuote()
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if this.isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value.isDictionary() {
			if this.isNullable() && !nullcast && !value.isNullable() {
				return false
			}

			return this.isSubsetOf(value, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass + MatchingMode::AutoCast)
		}
		else if value is UnionType {
			for const type in value.types() {
				if this.isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} # }}}
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return true
		}

		return false
	} # }}}
	isNullable() => false
	isDictionary() => true
	isExhaustive() => false
	isExportable() => true
	isSealable() => true
	isSubsetOf(value: DictionaryType, mode: MatchingMode) { # {{{
		if this == value {
			return true
		}

		if this.isSealed() != value.isSealed() {
			return false
		}

		for const type, name of value.properties() {
			if const prop = @properties[name] {
				if !prop.isSubsetOf(type, mode) {
					return false
				}
			}
			else if !type.isNullable() {
				return false
			}
		}

		return true
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return false unless value.isDictionary()

		if value.hasParameters() {
			const parameter = value.parameter(0)

			for const type, name of @properties {
				if !type.isSubsetOf(parameter, mode) {
					return false
				}
			}
		}

		return true
	} # }}}
	isMatching(value: Type, mode: MatchingMode) => false
	matchContentOf(value: Type) { # {{{
		if value.isAny() || value.isDictionary() {
			return true
		}

		if value is UnionType {
			for const type in value.types() {
				if this.matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} # }}}
	parameter() => AnyType.NullableUnexplicit
	properties() => @properties
	setExhaustive(@exhaustive) { # {{{
		for const property of @properties {
			property.setExhaustive(exhaustive)
		}

		return this
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	toQuote() { # {{{
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
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::AND

		fragments.code('!', $runtime.type(node), '.isDictionary(').compile(node).code(')')

		for const value, name of @properties {
			fragments.code(' || ')

			value.toNegativeTestFragments(fragments, new Literal(false, node, node.scope(), `\(node.path()).\(name)`))
		}

		fragments.code(')') if junction == Junction::AND
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::OR

		fragments.code($runtime.type(node), '.isDictionary(').compile(node).code(')')

		for const value, name of @properties {
			fragments.code(' && ')

			value.toPositiveTestFragments(fragments, new Literal(false, node, node.scope(), `\(node.path()).\(name)`))
		}

		fragments.code(')') if junction == Junction::OR
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if Dictionary.isEmpty(@properties) {
			fragments.code($runtime.type(node), '.isDictionary')
		}
		else {
			fragments.code(`value => `, $runtime.type(node), '.isDictionary(value)')

			for const value, name of @properties {
				fragments.code(' && ')

				value.toPositiveTestFragments(fragments, new Literal(false, node, node.scope(), `value.\(name)`), Junction::AND)
			}
		}
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('dict')

		for const type, name of @properties {
			variations.push(name)

			type.toVariations(variations)
		}
	} # }}}
	walk(fn) { # {{{
		for const type, name of @properties {
			fn(name, type)
		}
	} # }}}
}
