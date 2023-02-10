class ObjectType extends Type {
	private {
		@empty: Boolean					= false
		@length: Number					= 0
		@liberal: Boolean				= false
		@nullable: Boolean				= false
		@properties: Object<Type>		= {}
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@spread: Boolean				= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ObjectType { # {{{
			var type = new ObjectType(scope)

			if data.system {
				type.flagSystem()
			}
			else if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				if ?data.properties {
					for var property, name of data.properties {
						type.addProperty(name, Type.import(property, metadata, references, alterations, queue, scope, node))
					}
				}

				if ?data.rest {
					type.setRestType(Type.import(data.rest, metadata, references, alterations, queue, scope, node))
				}
			})

			return type.flagComplete()
		} # }}}
	}
	addProperty(name: String, type: Type) { # {{{
		@properties[name] = type
		@length += 1
	} # }}}
	clone() { # {{{
		var type = new ObjectType(@scope)

		type._complete = @complete
		type._nullable = @nullable
		type._length = @length
		type._properties = {...@properties}
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread

		return type
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
		if @nullable != value.isNullable() {
			return @nullable ? 1 : -1
		}

		if @rest {
			if value.hasRest() {
				return $weightTOFs['Object'] - $weightTOFs['Array']
			}
			else {
				return 1
			}
		}
		else if value.hasRest() {
			return -1
		}
		else {
			return $weightTOFs['Object'] - $weightTOFs['Array']
		}
	} # }}}
	compareToRef(value: ObjectType, equivalences: String[][]? = null) { # {{{
		if this.isSubsetOf(value, MatchingMode.Similar) {
			if this.isSubsetOf(value, MatchingMode.Exact) {
				return 0
			}
			else {
				return -1
			}
		}

		return 1
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
		if !@system && !@sealed && @length == 0 && !@rest {
			return 'Object'
		}

		var export = {
			kind: TypeKind.Object
		}

		if @system {
			export.system = true
		}
		else if @sealed {
			export.sealed = true
		}

		if @length > 0 {
			export.properties = {}

			for var value, name of @properties {
				export.properties[name] = value.export(references, indexDelta, mode, module)
			}
		}

		if @rest {
			export.rest = @restType.export(references, indexDelta, mode, module)
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
	flagEmpty(): this { # {{{
		@empty = true
	} # }}}
	flagLiberal(): this { # {{{
		@liberal = true
	} # }}}
	flagSpread() { # {{{
		return this if @spread

		var type = @clone()

		type._spread = true

		return type
	} # }}}
	getProperty(name: String): Type? { # {{{
		if var type ?= @properties[name] {
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
				str = `Object`
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
	hasMutableAccess() => true
	hasProperty(name: String) => ?@properties[name]
	hasProperties() => @length > 0
	hasRest() => @rest
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value.isObject() {
			if @isNullable() && !nullcast && !value.isNullable() {
				return false
			}

			if @length == 0 && !@rest {
				return true
			}

			return this.isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast)
		}
		else if value is UnionType {
			for var type in value.types() {
				if @isAssignableToVariable(type, anycast, nullcast, downcast) {
					return true
				}
			}
		}

		return false
	} # }}}
	isInstanceOf(value: AnyType) => false
	isMorePreciseThan(value: AnyType) => true
	isMorePreciseThan(value: ObjectType) { # {{{
		return @restType.isMorePreciseThan(value.getRestType())
	} # }}}
	isMorePreciseThan(value: ReferenceType) { # {{{
		return false unless value.isObject()

		if value.isAlias() {
			var alias = value.discard()

			return alias.hasRest()
		}
		else {
			return true unless value.hasParameters()
			return false unless @rest

			return @restType.isMorePreciseThan(value.parameter())
		}
	} # }}}
	isNullable() => @nullable
	isObject() => true
	isExportable() => true
	isLiberal() => @liberal
	isSealable() => true
	isSubsetOf(value: DestructurableObjectType, mode: MatchingMode) { # {{{
		for var type, name of value.properties() {
			if var prop ?= @properties[name] {
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
	isSubsetOf(value: ObjectType, mode: MatchingMode) { # {{{
		return true if this == value || @empty

		var type = mode !~ MatchingMode.Reference
		if type {
			return false unless @rest == value.hasRest()
		}

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless @length == value.length()

			var properties = value.properties()

			return false unless Array.same(Object.keys(@properties), Object.keys(properties))

			for var type, name of properties {
				return false unless @properties[name].isSubsetOf(type, mode)
			}

			if @rest {
				return @restType.isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if type && @rest {
				return false unless value.hasRest()
				return false unless @restType.isSubsetOf(value.getRestType(), mode)

				for var type, name of value.properties() {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, mode)
					}
					else {
						return false unless type.isNullable() || @restType.isSubsetOf(type, mode)
					}
				}
			}
			else {
				for var type, name of value.properties() {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, mode)
					}
					else {
						return false unless type.isNullable()
					}
				}

				if value.hasRest() {
					var rest = value.getRestType()

					for var prop, name of @properties when !value.hasProperty(name) {
						return false unless prop.isSubsetOf(rest, mode)
					}
				}
				else if mode ~~ MatchingMode.Exact {
					return false unless value.length() == @length
				}
			}
		}

		return true
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return false unless value.isObject()

		if value.name() != 'Object' {
			return this.isSubsetOf(value.discard(), mode + MatchingMode.Reference)
		}

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
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
		if value.isAny() || value.isObject() {
			return true
		}

		if value is UnionType {
			for var type in value.types() {
				if @matchContentOf(type) {
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
				str = `Object`
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
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return @export(references, indexDelta, mode, module)
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			fragments.code($runtime.type(node), '.isObject')
		}
		else {
			fragments.code(`value => `)

			@toTestFunctionFragments(fragments, node, Junction.NONE)
		}
	} # }}}
	override toTestFunctionFragments(fragments, node, junction) { # {{{
		if @nullable && junction == Junction.AND {
			fragments.code('(')
		}

		fragments.code($runtime.type(node), '.isObject(value')

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

			if junction == Junction.AND {
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
	override unspecify() { # {{{
		var type = @scope.reference('Object')

		if @nullable {
			return type.setNullable(true)
		}
		else {
			return type
		}
	} # }}}
	walk(fn) { # {{{
		for var type, name of @properties {
			fn(name, type)
		}
	} # }}}
}
