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
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ArrayType { # {{{
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
	compareToRef(value: ObjectType, equivalences: String[][]? = null) { # {{{
		if @nullable != value.isNullable() {
			return @nullable ? 1 : -1
		}

		if @rest {
			if value.hasRest() {
				return $weightTOFs['Array'] - $weightTOFs['Object']
			}
			else {
				return 1
			}
		}
		else if value.hasRest() {
			return -1
		}
		else {
			return $weightTOFs['Array'] - $weightTOFs['Object']
		}
	} # }}}
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
			kind: TypeKind.Array
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
	hasMutableAccess() => true
	hasProperties() => @length > 0
	hasRest() => @rest
	isArray() => true
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value.isTuple() {
			return false
		}
		else if value.isArray() {
			if @isNullable() && !nullcast && !value.isNullable() {
				return false
			}

			if anycast && @length == 0 && !@rest {
				return true
			}

			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			return this.isSubsetOf(value, matchingMode)
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
	isComplete() => true
	isExhaustive() => @rest ? false : @length > 0 || @scope.reference('Array').isExhaustive()
	isExportable() => true
	isInstanceOf(value: AnyType) => false
	isIterable() => true
	isMorePreciseThan(value: AnyType) => true
	isMorePreciseThan(value: ArrayType) { # {{{
		return @restType.isMorePreciseThan(value.getRestType())
	} # }}}
	isMorePreciseThan(value: ReferenceType) { # {{{
		return false unless value.isArray()

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
	isSealable() => true
	isSpread() => @spread
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		return true if this == value

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless @rest == value.hasRest()
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
				var mut lastIndex = -1

				for var type, index in value.properties() {
					if var prop ?= @properties[index] {
						lastIndex = index

						return false unless prop.isSubsetOf(type, mode)
					}
					else {
						return false unless type.isNullable()
					}
				}

				if value.hasRest() {
					var rest = value.getRestType()

					for var prop in @properties from lastIndex + 1 {
						return false unless prop.isSubsetOf(rest, mode)
					}
				}
				else if mode ~~ MatchingMode.Exact {
					return false unless lastIndex + 1 == @length
				}
			}
		}

		return true
	} # }}}
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		return false unless value.isArray()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless @length == 0
			return false unless @rest == value.hasParameters()

			if @rest {
				return @restType.isSubsetOf(value.parameter(0), mode)
			}
		}
		else {
			return true unless value.hasParameters()

			var parameter = value.parameter(0)

			return true unless parameter.isExplicit()

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
		if @length > 0 {
			if @rest {
				return Type.union(@scope, ...@properties, @restType)
			}
			else {
				return Type.union(@scope, ...@properties)
			}
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
		return @export(references, indexDelta, mode, module)
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

			@toTestFunctionFragments(fragments, node, Junction.NONE)
		}
	} # }}}
	override toTestFunctionFragments(fragments, node, junction) { # {{{
		if @nullable && junction == Junction.AND {
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

			if junction == Junction.AND {
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
	override unspecify() { # {{{
		var type = @scope.reference('Array')

		if @nullable {
			return type.setNullable(true)
		}
		else {
			return type
		}
	} # }}}
	walk(fn)
}
