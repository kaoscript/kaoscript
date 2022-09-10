class ArrayType extends Type {
	private {
		@length: Number					= 0
		@nullable: Boolean				= false
		@properties: Array<Type>		= []
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@spread: Boolean				= false
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ArrayType { # {{{
			var type = new ArrayType(scope)

			queue.push(() => {
				if ?data.properties {
					for var property in data.properties {
						type.addProperty(Type.import(property, metadata, references, alterations, queue, scope, node))
					}
				}

				if ?data.rest {
					type.setRestType(Type.import(data.rest, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	addProperty(type: Type) { # {{{
		@properties.push(type)
		@length += 1
	} # }}}
	clone() { # {{{
		var type = new ArrayType(@scope)

		type._length = @length
		type._nullable = @nullable
		type._properties = [...@properties]
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread

		return type
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
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
	compareToRef(value: DictionaryType, equivalences: String[][]? = null) { # {{{
		if @nullable != value.isNullable() {
			return @nullable ? 1 : -1
		}

		if @rest {
			if value.hasRest() {
				return $weightTOFs['Array'] - $weightTOFs['Dictionary']
			}
			else {
				return 1
			}
		}
		else if value.hasRest() {
			return -1
		}
		else {
			return $weightTOFs['Array'] - $weightTOFs['Dictionary']
		}
	} # }}}
	compareToRef(value: NullType, equivalences: String[][]? = null) => -1
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	compareToRef(value: UnionType, equivalences: String[][]? = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	discardSpread() { # {{{
		if @spread {
			if @rest {
				return @restType!?
			}
			else {
				return AnyType.NullableUnexplicit
			}
		}
		else {
			return this
		}
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @length == 0 && !@rest {
			return 'Array'
		}

		var export = {
			kind: TypeKind::Array
		}

		if @length > 0 {
			export.properties = [property.export(references, indexDelta, mode, module) for var property in @properties]
		}

		if @rest {
			export.rest = @restType.export(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	flagSpread() { # {{{
		return this if @spread

		var type = @clone()

		type._spread = true

		return type
	} # }}}
	getProperty(index: Number): Type? { # {{{
		if index >= @length {
			if @rest {
				return @restType
			}

			return null
		}
		else {
			return @properties[index]
		}
	} # }}}
	getProperty(name: String): Type { # {{{
		return @scope.reference('Array').getProperty(name)
	} # }}}
	getRestType(): @restType
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				str = `\(@restType.hashCode(fattenNull))[]`
			}
			else {
				str = `Array`
			}
		}
		else {
			str = '['

			for var property, index in @properties {
				if index > 0 {
					str += ', '
				}

				str += `\(property.hashCode(fattenNull))`
			}

			if @rest {
				if @length > 0 {
					str += ', '
				}

				str += `...\(@restType.hashCode(fattenNull))`
			}

			str += ']'
		}

		if @nullable {
			if fattenNull {
				str += '|Null'
			}
			else {
				str += '?'
			}
		}

		return str
	} # }}}
	hasProperties() => @length > 0
	hasRest() => @rest
	isArray() => true
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if this.isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value.isArray() {
			if this.isNullable() && !nullcast && !value.isNullable() {
				return false
			}

			if anycast && @length == 0 && !@rest {
				return true
			}

			return this.isSubsetOf(value, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass + MatchingMode::AutoCast)
		}
		else if value is UnionType {
			for var type in value.types() {
				if this.isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} # }}}
	isMorePreciseThan(value) => true
	isNullable() => @nullable
	isSealable() => true
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		return true if this == value
		return false unless @rest == value.hasRest()

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless @length == value.length()

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
					if var prop ?= @properties[index] {
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
					if var prop ?= @properties[index] {
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

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless @length == 0
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
	length() => @length
	parameter(index: Number = -1) { # {{{
		if @length > 0 || !@rest {
			return AnyType.NullableUnexplicit
		}
		else {
			return @restType
		}
	} # }}}
	properties() => @properties
	setNullable(nullable: Boolean) { # {{{
		if @nullable == nullable {
			return this
		}
		else {
			var type = @clone()

			type._nullable = nullable

			return type
		}
	} # }}}
	setRestType(@restType): this { # {{{
		@rest = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException()
	} # }}}
	toQuote() { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				str = `\(@restType.toQuote())[]`
			}
			else {
				str = `Array`
			}
		}
		else {
			str = '['

			for var property, index in @properties {
				if index > 0 {
					str += ', '
				}

				str += `\(property.toQuote())`
			}

			if @rest {
				if @length > 0 {
					str += ', '
				}

				str += `...\(@restType.toQuote())`
			}

			str += ']'
		}

		if @nullable {
			str += '?'
		}

		return str
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return this.export(references, indexDelta, mode, module)
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			fragments.code($runtime.type(node), '.isArray')
		}
		else {
			fragments.code(`value => `)

			@toTestFunctionFragments(fragments, node, Junction::NONE)
		}
	} # }}}
	override toTestFunctionFragments(fragments, node, junction) { # {{{
		if @nullable && junction == Junction::AND {
			fragments.code('(')
		}

		fragments.code($runtime.type(node), '.isArray(value')

		var literal = new Literal(false, node, node.scope(), 'value')

		if @rest {
			fragments.code($comma)

			@restType.toTestFunctionFragments(fragments, literal)
		}
		else if @length > 0 {
			fragments.code(', void 0')
		}

		if @length > 0 {
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

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(value)`)

			if junction == Junction::AND {
				fragments.code(')')
			}
		}
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
