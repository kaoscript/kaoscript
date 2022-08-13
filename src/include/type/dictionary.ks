class DictionaryType extends Type {
	private {
		@nullable: Boolean				= false
		@length: Number					= 0
		@properties: Dictionary<Type>	= {}
		@rest: Boolean					= false
		@restType: Type?				= null
		@spread: Boolean				= false
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): DictionaryType { # {{{
			var type = new DictionaryType(scope)

			if data.systemic {
				type.flagSystemic()
			}
			else if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				for var property, name of data.properties {
					type.addProperty(name, Type.import(property, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	addProperty(name: String, type: Type) { # {{{
		@properties[name] = type
		++@length
	} # }}}
	clone() { # {{{
		var type = new DictionaryType(@scope)

		type._nullable = @nullable
		type._length = @length
		type._properties = {...@properties}
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread

		return type
	} # }}}
	compareToRef(value: DictionaryType, equivalences: String[][] = null) { # {{{
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
	compareToRef(value: NullType, equivalences: String[][] = null) => -1
	compareToRef(value: ReferenceType, equivalences: String[][] = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	compareToRef(value: UnionType, equivalences: String[][] = null) { # {{{
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
		var export = {
			kind: TypeKind::Dictionary
		}

		if @systemic {
			export.systemic = true
		}
		else if @sealed {
			export.sealed = true
		}

		export.properties = {}

		for var value, name of @properties {
			export.properties[name] = value.export(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	flagAlien() { # {{{
		@alien = true

		for var property of @properties {
			property.flagAlien()
		}

		return this
	} # }}}
	flagSpread() { # {{{
		return this if @spread
		
		var type = @clone()

		type._spread = true

		return type
	} # }}}
	getProperty(name: String): Type? { # {{{
		if var type = @properties[name] {
			return type
		}

		if @rest {
			return @restType
		}

		if @length == 0 {
			return AnyType.NullableUnexplicit
		}

		return null
	} # }}}
	getRestType(): @restType
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				str = `\(@restType.hashCode(fattenNull)){}`
			}
			else {
				str = `Dictionary`
			}
		}
		else {
			str = '{'

			var mut nc = false

			for var property, name of @properties {
				if nc {
					str += ', '
				}
				else {
					nc = true
				}

				str += `\(name): \(property.hashCode(fattenNull))`
			}

			if @rest {
				if nc {
					str += ', '
				}

				str += `...\(@restType.hashCode(fattenNull))`
			}

			str += '}'
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
		else if value.isObject() {
			if this.isNullable() && !nullcast && !value.isNullable() {
				return false
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
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return true
		}

		return false
	} # }}}
	isNullable() => @nullable
	isDictionary() => true
	isExportable() => true
	isSealable() => true
	isSubsetOf(value: DestructurableObjectType, mode: MatchingMode) { # {{{
		for var type, name of value.properties() {
			if var prop = @properties[name] {
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
	isSubsetOf(value: DictionaryType, mode: MatchingMode) { # {{{
		return true if this == value
		return false unless @rest == value.hasRest()

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless @length == value.length()

			var properties = value.properties()

			return false unless Array.same(Dictionary.keys(@properties), Dictionary.keys(properties))

			for var type, name of properties {
				return false unless @properties[name].isSubsetOf(type, mode)
			}

			if @rest {
				return @restType.isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @rest {
				return false unless value.hasRest()
				return false unless @restType.isSubsetOf(value.getRestType(), mode)

				for var type, name of value.properties() {
					if var prop = @properties[name] {
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

				for var type, name of value.properties() {
					if var prop = @properties[name] {
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
		return false unless value.isDictionary()

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

			for var type of @properties {
				return false unless type.isSubsetOf(parameter, mode)
			}

			if @rest {
				return @restType.isSubsetOf(parameter, mode)
			}
		}

		return true
	} # }}}
	isMatching(value: Type, mode: MatchingMode) => false
	length(): @length
	matchContentOf(value: Type) { # {{{
		if value.isAny() || value.isDictionary() {
			return true
		}

		if value is UnionType {
			for var type in value.types() {
				if this.matchContentOf(type) {
					return true
				}
			}
		}

		return false
	} # }}}
	parameter(index: Number = -1) { # {{{
		if @length > 0 || !@rest {
			return AnyType.NullableUnexplicit
		}
		else {
			return @restType
		}
	} # }}}
	properties() => @properties
	setExhaustive(@exhaustive) { # {{{
		for var property of @properties {
			property.setExhaustive(exhaustive)
		}

		return this
	} # }}}
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
				str = `\(@restType.toQuote()){}`
			}
			else {
				str = `Dictionary`
			}
		}
		else {
			str = '{'

			var mut nc = false

			for var property, name of @properties {
				if nc {
					str += ', '
				}
				else {
					nc = true
				}

				str += `\(name): \(property.toQuote())`
			}

			if @rest {
				if nc {
					str += ', '
				}

				str += `...\(@restType.toQuote())`
			}

			str += '}'
		}

		if @nullable {
			str += '?'
		}

		return str
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			fragments.code($runtime.type(node), '.isDictionary')
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

		fragments.code($runtime.type(node), '.isDictionary(value')

		var literal = new Literal(false, node, node.scope(), 'value')

		if @rest {
			fragments.code($comma)

			@restType.toTestFunctionFragments(fragments, literal)
		}
		else if @length > 0 {
			fragments.code(', void 0')
		}

		if @length > 0 {
			fragments.code(', {')

			var mut nc = false

			for var type, name of @properties {
				if nc {
					fragments.code($comma)
				}
				else {
					nc = true
				}

				fragments.code(`\(name): `)

				type.toTestFunctionFragments(fragments, literal)
			}

			fragments.code('}')
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
		variations.push('dict')

		for var type, name of @properties {
			variations.push(name)

			type.toVariations(variations)
		}

		if @rest {
			@restType.toVariations(variations)
		}
	} # }}}
	walk(fn) { # {{{
		for var type, name of @properties {
			fn(name, type)
		}
	} # }}}
}
