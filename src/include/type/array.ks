class ArrayType extends Type {
	private {
		@properties: Array<Type>		= []
		@rest: Boolean					= false
		@restType: Type?				= null
	}
	addProperty(type: Type) { # {{{
		@properties.push(type)
	} # }}}
	clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	compareToRef(value: ArrayType, equivalences: Array<Array<String>> = null) { # {{{
		if @isSubsetOf(value, MatchingMode::Similar) {
			if @isSubsetOf(value, MatchingMode::Exact) {
				return 0
			}
			else {
				return -1
			}
		}

		return 1
	} # }}}
	compareToRef(value: NullType, equivalences: Array<Array<String>> = null) => -1
	compareToRef(value: ReferenceType, equivalences: Array<Array<String>> = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	compareToRef(value: UnionType, equivalences: Array<Array<String>> = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			kind: TypeKind::Array
		}

		if @sealed {
			export.sealed = @sealed
		}

		export.properties = [property.export(references, indexDelta, mode, module) for var property in @properties]

		return export
	} # }}}
	getProperty(index: Number): Type? { # {{{
		if index >= @properties.length {
			if @rest {
				return @restType
			}

			return null
		}
		else {
			return @properties[index]
		}
	} # }}}
	getRestType(): @restType
	hashCode() => this.toQuote()
	hasProperties() => @properties.length > 0
	hasRest() => @rest
	isArray() => true
	isMorePreciseThan(value) => true
	isNullable() => false
	isSealable() => true
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		return true if this == value
		return false unless @rest == value.hasRest()

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless @properties.length == value.length()

			for var type, index in value.properties() {
				return false unless @properties[index].isSubsetOf(type, mode)
			}

			if @rest {
				return @restType.isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @rest {
				return false unless value.hasRest()
				return false unless @restType.isSubsetOf(value.getRestType(), mode)

				for var type, index in value.properties() {
					if var prop = @properties[index] {
						return false unless prop.isSubsetOf(type, mode)
					}
					else {
						return false unless type.isNullable() || @restType.isSubsetOf(type, mode)
					}
				}
			}
			else {
				if value.hasRest() {
					return false unless value.getRestType().isNullable()
				}

				for var type, index in value.properties() {
					if var prop = @properties[index] {
						return false unless prop.isSubsetOf(type, mode)
					}
					else {
						return false unless type.isNullable()
					}
				}
			}
		}

		return true
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return false unless value.isArray()

		if mode ~~ MatchingMode::Exact {
			return false unless @properties.length == 0
			return false unless @rest == value.hasParameters()

			if @rest {
				return @restType.isSubsetOf(value.parameter(0), mode)
			}
		}
		else {
			return true if !value.hasParameters()

			var parameter = value.parameter(0)

			for var type in @properties {
				return false unless type.isSubsetOf(parameter, mode)
			}

			if @rest {
				return @restType.isSubsetOf(parameter, mode)
			}
		}

		return true
	} # }}}
	length() => @properties.length
	properties() => @properties
	setRestType(@restType): this { # {{{
		@rest = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	toQuote() { # {{{
		if @properties.length == 0 && !@rest {
			return 'Array'
		}

		var mut str = '['

		for var property, index in @properties {
			if index > 0 {
				str += ', '
			}

			str += `\(property.toQuote())`
		}

		if @rest {
			if @properties.length > 0 {
				str += ', '
			}

			str += `...\(@restType.toQuote())`
		}

		str += ']'

		return str
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @properties.length == 0 && !@rest {
			fragments.code($runtime.type(node), '.isArray')
		}
		else {
			fragments.code(`value => `)

			@toTestFunctionFragments(fragments, node, Junction::NONE)
		}
	} # }}}
	override toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code($runtime.type(node), '.isArray(value')

		var literal = new Literal(false, node, node.scope(), 'value')

		if @rest {
			fragments.code($comma)

			@restType.toTestFunctionFragments(fragments, literal)
		}
		else if @properties.length > 0 {
			fragments.code(', void 0')
		}

		if @properties.length > 0 {
			fragments.code(', [')

			for var type, index in @properties {
				if index > 0 {
					fragments.code($comma)
				}

				type.toTestFunctionFragments(fragments, literal)
			}

			fragments.code(']')
		}

		fragments.code(')')
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('array')

		for var property in @properties {
			property.toVariations(variations)
		}

		if @rest {
			@restType.toVariations(variations)
		}
	} # }}}
	walk(fn)
}
