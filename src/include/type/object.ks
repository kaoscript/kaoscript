class ObjectType extends Type {
	private {
		@computed: Boolean{}			 = {}
		@destructuring: Boolean			= false
		@empty: Boolean					= false
		@length: Number					= 0
		@liberal: Boolean				= false
		@nullable: Boolean				= false
		@properties: Type{}				= {}
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@spread: Boolean				= false
		@testProperties: Boolean		= false
		@testRest: Boolean				= false
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

			if data.destructuring {
				type.flagDestructuring()
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
	addProperty(name: String, computed: Boolean = false, type: Type) { # {{{
		@properties[name] = type
		@computed[name] = computed
		@length += 1
		@testProperties ||= !type.isAny() || !type.isNullable()
	} # }}}
	clone() { # {{{
		var type = new ObjectType(@scope)

		type._complete = @complete
		type._destructuring = @destructuring
		type._nullable = @nullable
		type._length = @length
		type._properties = {...@properties}
		type._computed = {...@computed}
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread
		type._testProperties = @testProperties
		type._testRest = @testRest

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
		if @destructuring {
			export.destructuring = true
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
	flagDestructuring() { # {{{
		@destructuring = true
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
	isBinding() => true
	isDestructuring() => @destructuring
	isExhaustive() => @rest ? false : @length > 0 || @scope.reference('Object').isExhaustive()
	isInstanceOf(value: AnyType) => false
	isMorePreciseThan(value: AnyType) => true
	isMorePreciseThan(value: ObjectType) { # {{{
		if value.hasProperties() {
			if @hasProperties() {
				for var type, name of @properties {
					if !value.hasProperty(name) {
						return false
					}
				}

				if @length > value.length() {
					return false
				}
			}
			else {
				return false
			}
		}

		if @rest && value.hasRest() {
			return @restType.isMorePreciseThan(value.getRestType())
		}

		return true
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
	isMatching(value: Type, mode: MatchingMode) => false
	isSealable() => true
	isSubsetOf(value: ObjectType, mode: MatchingMode) { # {{{
		return true if this == value || @empty

		var type = mode !~ MatchingMode.Reference
		if type {
			return false unless @rest == value.hasRest()
		}

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless @length == value.length()

			if mode ~~ MatchingMode.NonNullToNull {
				if @isNullable() && !value.isNullable() {
					return false
				}
			}
			else if @isNullable() != value.isNullable() {
				return false
			}

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
			if @isNullable() && !value.isNullable() {
				return false
			}

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
				// for exact match
				// else if mode ~~ MatchingMode.Exact {
				// 	return false unless value.length() == @length
				// }
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
	isTestingProperties() => @testProperties
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
	merge(value: ObjectType, node): Type { # {{{
		var result = new ObjectType(@scope)

		result.flagDestructuring() if @destructuring
		result.flagSpread() if @spread

		if @hasProperties() {
			if value.hasProperties() {
				for var type, name of @properties {
					result.addProperty(name, @computed[name], type.merge(value.getProperty(name), node))
				}

				if @rest {
					if value.hasRest() {
						result.setRestType(@restType.merge(value.getRestType(), node))
					}
					else {
						result.setRestType(@restType)
					}
				}
			}
			else if value.hasRest() {
				var restType = value.getRestType()

				for var type, name of @properties {
					result.addProperty(name, @computed[name], type.merge(restType, node))
				}

				if @rest {
					result.setRestType(@restType.merge(restType, node))
				}
			}
			else {
				return this
			}
		}
		else {
			throw new NotImplementedException()
		}

		return result
	} # }}}
	merge(value: ReferenceType, node): Type { # {{{
		unless value.isBroadObject() {
			TypeException.throwIncompatible(value, this, node)
		}

		if !value.isObject() {
			unless value.isAssignableToVariable(this, true, false, false) {
				TypeException.throwIncompatible(value, this, node)
			}

			return value
		}

		if value.hasParameters() {
			var result = new ObjectType(@scope)

			result.flagDestructuring() if @destructuring
			result.flagSpread() if @spread

			if @hasProperties() {
				var restType = value.parameter()

				for var type, name of @properties {
					result.addProperty(name, @computed[name], restType.merge(type, node))
				}

				if @rest {
					result.setRestType(@restType.merge(restType, node))
				}
			}
			else {
				throw new NotImplementedException()
			}

			return result
		}
		else if value.isAlias() {
			return @merge(value.discard(), node)
		}
		else {
			return this
		}
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
		@testRest = !@restType.isAny() || !@restType.isNullable()
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

				if @computed[name] {
					str += `[\(name)]: \(property.toQuote())`
				}
				else {
					str += `\(name): \(property.toQuote())`
				}
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
	toAssertFragments(value, testingType: Boolean, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).assertDexObject(`).compile(value)

		if @testRest || @testProperties {
			@toSubtestFragments(testingType, fragments, node)
		}

		fragments.code(')')
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException()
	} # }}}
	toSubtestFragments(testingType: Boolean, fragments, node) { # {{{
		if testingType {
			if @destructuring {
				fragments.code(', 1')
			}
			else {
				fragments.code(', 2')
			}
		}
		else {
			fragments.code(', 0')
		}

		if @testRest || @testProperties {
			fragments.code($comma)

			var literal = new Literal(false, node, node.scope(), 'value')

			if @testProperties {
				if @testRest {
					@restType.toTestFunctionFragments(fragments, literal)
				}
				else {
					fragments.code('0')
				}

				fragments.code(', {')

				var mut comma = false

				for var type, name of @properties {
					if comma {
						fragments.code($comma)
					}
					else {
						comma = true
					}

					if @computed[name] {
						fragments.code(`[\(name)]: `)
					}
					else {
						fragments.code(`\(name): `)
					}

					type.toTestFunctionFragments(fragments, literal)
				}

				fragments.code('}')
			}
			else {
				@restType.toTestFunctionFragments(fragments, literal)
			}
		}
	} # }}}
	toTestFragments(name: String, testingType: Boolean, fragments, node) { # {{{
		if testingType && !@destructuring && !@testRest && !@testProperties {
			fragments.code(`\($runtime.type(node)).isObject(\(name))`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexObject(\(name)`)

			@toSubtestFragments(testingType, fragments, node)

			fragments.code(')')
		}
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			if !@destructuring {
				fragments.code($runtime.type(node), '.isObject')
			}
		}
		else if @testRest || @testProperties || @nullable {
			fragments.code(`value => `)

			@toTestFunctionFragments(fragments, node, Junction.NONE)
		}
		else {
			if @destructuring {
				fragments.code($runtime.type(node), '.isDexObject')
			}
			else {
				fragments.code($runtime.type(node), '.isObject')
			}
		}
	} # }}}
	override toTestFunctionFragments(fragments, node, junction) { # {{{
		if @nullable {
			fragments.code('(') if junction == Junction.AND

			@toTestFragments('value', true, fragments, node)

			fragments.code(` || \($runtime.type(node)).isNull(value)`)

			fragments.code(')') if junction == Junction.AND
		}
		else {
			@toTestFragments('value', true, fragments, node)
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
