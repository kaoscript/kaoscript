class ArrayType extends Type {
	private late {
		@destructuring: Boolean			= false
		@fullTest: Boolean				= true
		@length: Number					= 0
		@nullable: Boolean				= false
		@min: Number?					= null
		@properties: Type[]				= []
		@reference: ReferenceType?		= null
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@specific: Boolean				= false
		@spread: Boolean				= false
		@testLength: Boolean			= true
		@testProperties: Boolean		= false
		@testRest: Boolean				= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ArrayType { # {{{
			var type = ArrayType.new(scope)

			if data.destructuring {
				type.flagDestructuring()
			}

			if data.nullable {
				type._nullable = true
			}

			queue.push(() => {
				var properties = []
				var mut restType = null

				if ?data.properties {
					for var property in data.properties {
						properties.push(Type.import(property, metadata, references, alterations, queue, scope, node))
					}
				}

				if ?data.rest {
					restType = Type.import(data.rest, metadata, references, alterations, queue, scope, node)
				}

				queue.push(() => {
					if ?data.properties {
						for var property in properties {
							type.addProperty(property)
						}
					}

					if ?data.rest {
						type.setRestType(restType)
					}

					type.flagComplete()
				})
			})

			return type
		} # }}}
	}
	addProperty(type: Type) { # {{{
		@properties.push(type)
		@length += 1
		@testProperties ||= !type.isAny() || !type.isNullable()
	} # }}}
	override applyGenerics(generics) { # {{{
		return this unless @isDeferrable()

		var result = @clone()

		for var property, index in result._properties {
			if property.isDeferrable() {
				result._properties[index] = property.applyGenerics(generics)
			}
		}

		if @rest && result._restType.isDeferrable() {
			result._restType = result._restType.applyGenerics(generics)
		}

		return result
	} # }}}
	override buildGenericMap(position, expressions, decompose, genericMap) { # {{{
		for var property in @properties when property.isDeferrable() {
			property.buildGenericMap(position, expressions, decompose, genericMap)
		}

		if @rest && @restType.isDeferrable() {
			@restType.buildGenericMap(position, expressions, value => decompose(value).parameter(), genericMap)
		}
	} # }}}
	override canBeRawCasted() { # {{{
		for var property in @properties {
			if property.canBeRawCasted() {
				return true
			}
		}

		return @rest && @restType.canBeRawCasted()
	} # }}}
	clone() { # {{{
		var type = ArrayType.new(@scope)

		type._destructuring = @destructuring
		type._length = @length
		type._nullable = @nullable
		type._properties = [...@properties]
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread
		type._testProperties = @testProperties
		type._testRest = @testRest

		return type
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
		if @rest {
			if !value.hasRest() {
				return 1
			}

			var rest = @restType.compareToRef(value.getRestType())

			if rest != 0 {
				return rest
			}
		}
		else if value.hasRest() {
			return -1
		}

		if @length < value.length() {
			return -1
		}
		else if @length > value.length() {
			return 1
		}

		return 0
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
	discardValue() { # {{{
		if @rest && @restType.isValue() && @length == 0 {
			var result = ArrayType.new(@scope)

			result.setRestType(@restType.discardValue())

			return result
		}

		return this
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @length == 0 && !@rest {
			return @nullable ? 'Array?' : 'Array'
		}

		return {
			kind: TypeKind.Array
			properties: [property.export(references, indexDelta, mode, module) for var property in @properties] if @length > 0
			rest: @restType.export(references, indexDelta, mode, module) if @rest
			destructuring: true if @destructuring
			mutable: true if @mutable
			nullable: true if @nullable
		}
	} # }}}
	override flagComplete() { # {{{
		@specific = !@rest && @length == 0

		return super()
	} # }}}
	flagDestructuring() { # {{{
		@destructuring = true
	} # }}}
	override flagIndirectlyReferenced() { # {{{
		for var type in @properties {
			type.flagIndirectlyReferenced()
		}

		if @rest {
			@restType.flagIndirectlyReferenced()
		}
	} # }}}
	override flagReferenced() { # {{{
		if @referenced {
			return this
		}
		else {
			@referenced = true
		}

		@flagIndirectlyReferenced()

		return this
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
	getProperty(name: String): Type? { # {{{
		return @scope.reference('Array').getProperty(name)
	} # }}}
	getRestType(): valueof @restType
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				str = `\(@restType.hashCode(fattenNull))[]`
			}
			else {
				str = `[]`
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
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}

		if value.isAlias() {
			return @isAssignableToVariable(value.discard(), anycast, nullcast, downcast, limited)
		}

		if value is UnionType {
			for var type in value.types() {
				if @isAssignableToVariable(type, anycast, nullcast, downcast, limited) {
					return true
				}
			}
		}

		if @isNullable() && !nullcast && !value.isNullable() {
			return false
		}

		if value is DeferredType {
			if value.isConstrainted() {
				return @isAssignableToVariable(value.constraint(), anycast, true, downcast)
			}

			return true
		}

		if value.isArray() {
			if @length == 0 && !@rest {
				return true
			}

			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.IgnoreDeferred

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			return @isSubsetOf(value, matchingMode)
		}

		return false
	} # }}}
	isBinding() => true
	isComplete() => true
	override isDeferrable() { # {{{
		return true if @rest && @restType.isDeferrable()

		for var property in @properties {
			return true if property.isDeferrable()
		}

		return false
	} # }}}
	isExhaustive() => !@rest || @scope.reference('Array').isExhaustive()
	override isExportable() => true
	override isExportable(module) => true
	assist isInstanceOf(value: AnyType, generics, subtypes) => false
	isIterable() => true
	isMorePreciseThan(value: AnyType) => true
	isMorePreciseThan(value: ArrayType) { # {{{
		return true if this == value

		if !@rest {
			if @length == 0 {
				return !(value.hasProperties() || value.hasRest())
			}

			if value.hasRest() {
				var rest = value.getRestType()

				for var property in @properties {
					return false unless property.isMorePreciseThan(rest)
				}

				return true
			}

			var properties = value.properties()

			return false unless @length <= #properties

			for var property, index in @properties {
				return false unless property.isMorePreciseThan(properties[index])
			}

			return true
		}

		if !@nullable && value.isNullable() {
			return @restType.equals(value.getRestType()) || @restType.isMorePreciseThan(value.getRestType())
		}
		else {
			return @restType.isMorePreciseThan(value.getRestType())
		}
	} # }}}
	isMorePreciseThan(value: ReferenceType) { # {{{
		if value.isAlias() {
			return @isMorePreciseThan(value.discardAlias())
		}

		return false unless value.isArray()

		return true unless value.hasParameters()
		return false unless @rest

		return @restType.isMorePreciseThan(value.parameter())
	} # }}}
	isMorePreciseThan(value: UnionType) { # {{{
		for var type in value.types() {
			if @equals(type) || @isMorePreciseThan(type) {
				return true
			}
		}

		return false
	} # }}}
	isNullable() => @nullable
	isSealable() => true
	override isSpecific() => @specific
	isSpread() => @spread
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			if value.isAny() && !value.isExplicit() && mode ~~ MatchingMode.Missing {
				return true
			}
			else {
				return false
			}
		}
		else {
			return value.isAny()
		}
	} # }}}
	assist isSubsetOf(value: ArrayType, generics, subtypes, mode) { # {{{
		return true if this == value

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless @rest == value.hasRest()
			return false unless @length == value.length()

			if mode ~~ MatchingMode.NonNullToNull {
				if @isNullable() && !value.isNullable() {
					return false
				}
			}
			else if @isNullable() != value.isNullable() {
				return false
			}

			for var type, index in value.properties() {
				return false unless @properties[index].isSubsetOf(type, mode)
			}

			if @rest {
				return @restType.isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @isNullable() && !value.isNullable() {
				return false
			}

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
				// for exact match
				// else if mode ~~ MatchingMode.Exact {
				// 	return false unless lastIndex + 1 == @length
				// }
			}
		}

		return true
	} # }}}
	assist isSubsetOf(value: FusionType, generics, subtypes, mode) { # {{{
		return false if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass

		for var type in value.types() {
			if !@isSubsetOf(type, mode) {
				return false
			}
		}

		return true
	} # }}}
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		return false unless value.isArray()

		if @isNullable() && !value.isNullable() {
			return false
		}

		if value.name() != 'Array' {
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
	assist isSubsetOf(value: UnionType, generics, subtypes, mode) { # {{{
		return false if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass

		if @isNullable() {
			return false unless value.isNullable()

			var notNull = @setNullable(false)

			for var type in value.types() {
				if !type.isNull() && notNull.isSubsetOf(type, mode) {
					return true
				}
			}
		}
		else {
			for var type in value.types() {
				if @isSubsetOf(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	isTestingProperties() => @testProperties
	length() => @length
	assist limitTo(value: ReferenceType) { # {{{
		if value.isArray() && @isNullable() && !value.isNullable() {
			return @setNullable(false)
		}

		return this
	} # }}}
	listMissingProperties(tuple: TupleType) { # {{{
		var fields = {}
		var functions = {}

		for var type, index in @properties {
			if var variable ?= tuple.getProperty(index) {
				unless variable.isSubsetOf(type, MatchingMode.Default) {
					fields[index] = type
				}
			}
			else {
				fields[index] = type
			}
		}

		return { fields, functions }
	} # }}}
	override makeMemberCallee(property, path, generics, node) { # {{{
		@reference ??= @reference(node.scope())

		return @reference.makeMemberCallee(property, path, generics, node)
	} # }}}
	override makeMemberCallee(property, path, reference, generics, node) { # {{{
		@reference ??= @reference(node.scope())

		return @reference.makeMemberCallee(property, path, generics, node)
	} # }}}
	matchContentOf(value: Type) { # {{{
		if value.isAny() || value.isArray() {
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
	matchDeferred(type: ArrayType, generics: Type{}) { # {{{
		var result = @clone()

		if @rest && @restType.isDeferrable() && type.hasRest() {
			result.setRestType(@restType.matchDeferred(type.getRestType(), generics).type)
		}

		if type.hasProperties() {
			var properties = type.properties()!?

			if @length != 0 {
				for var property, index in @properties {
					if property.isDeferrable() {
						result._properties[index] = property.matchDeferred(properties[index], generics).type
					}
				}
			}
			else if @rest && @restType.isDeferrable() {
				result.setRestType(@restType.matchDeferred(Type.union(@scope, ...properties), generics).type)
			}
		}

		return {
			type: result
			match: false
		}
	} # }}}
	matchDeferred(type: Type, generics: Type{}) { # {{{
		return {
			type: this
			match: false
		}
	} # }}}
	assist merge(value: ArrayType, generics, subtypes, ignoreUndefined, node) { # {{{
		var result = ArrayType.new(@scope)

		result.flagDestructuring() if @destructuring
		result.flagSpread() if @spread

		if @hasProperties() {
			if value.hasProperties() {
				for var type, index in @properties {
					result.addProperty(type.merge(value.getProperty(index), generics, subtypes, ignoreUndefined, node))
				}

				if @rest {
					if value.hasRest() {
						result.setRestType(@restType.merge(value.getRestType(), generics, subtypes, ignoreUndefined, node))
					}
					else {
						result.setRestType(@restType)
					}
				}
			}
			else if value.hasRest() {
				var restType = value.getRestType()

				for var type in @properties {
					result.addProperty(type.merge(restType, generics, subtypes, ignoreUndefined, node))
				}

				if @rest {
					result.setRestType(@restType.merge(restType, generics, subtypes, ignoreUndefined, node))
				}
			}
			else {
				return this
			}

			return result
		}
		else if @rest && value.hasRest() {
			result.setRestType(@restType.merge(value.getRestType(), generics, subtypes, ignoreUndefined, node))

			return result
		}
		else {
			return this
		}
	} # }}}
	assist merge(value: ReferenceType, generics, subtypes, ignoreUndefined, node) { # {{{
		unless value.isBroadArray() {
			TypeException.throwIncompatible(this, value, node)
		}

		if !value.isArray() {
			unless value.isAssignableToVariable(this, true, false, false) {
				TypeException.throwIncompatible(value, this, node)
			}

			return value
		}

		if value.hasParameters() {
			var result = ArrayType.new(@scope)

			result.flagDestructuring() if @destructuring
			result.flagSpread() if @spread

			if @hasProperties() {
				var restType = value.parameter()

				for var type in @properties {
					result.addProperty(restType.merge(type, generics, subtypes, ignoreUndefined, node))
				}

				if @rest {
					result.setRestType(@restType.merge(restType, generics, subtypes, ignoreUndefined, node))
				}
			}
			else {
				throw NotImplementedException.new()
			}

			return result
		}
		else if value.isAlias() {
			return @merge(value.discard(), generics, subtypes, ignoreUndefined, node)
		}
		else {
			return this
		}
	} # }}}
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
	setRestType(@restType): valueof this { # {{{
		@rest = true
		@testRest = !@restType.isAny() || !@restType.isNullable()
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new()
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
	toAssertFragments(value, testingType: Boolean, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).assertDexArray(`).compile(value)

		if @testRest || @testProperties || @testLength {
			@toSubtestFragments('value', false, testingType, @testLength, fragments, node)
		}

		fragments.code(')')
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, hasDeferred, casting, blind, generics, subtypes, fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			if @destructuring {
				fragments.code(`\($runtime.type(node)).isDXArray`)
			}
			else {
				fragments.code($runtime.type(node), '.isArray')
			}
		}
		else if @rest || @testProperties || @nullable {
			fragments.code(`\(varname) => `)

			if @length == 0 && !@destructuring && !@testProperties {
				fragments.code(`\($runtime.type(node)).isArray(\(varname)`)

				if @testRest && !node.isMisfit() {
					fragments.code($comma)

					@restType.toAwareTestFunctionFragments(varname, nullable, hasDeferred, casting, blind, generics, subtypes, fragments, node)
				}

				fragments.code(')')
			}
			else {
				fragments.code(`\($runtime.type(node)).isDexArray(\(varname)`)

				@toSubtestFragments(varname, casting, true, @testLength, fragments, node)

				fragments.code(')')
			}

			if @nullable {
				fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
			}
		}
		else {
			if @destructuring {
				fragments.code(`\($runtime.type(node)).isDXArray`)
			}
			else {
				fragments.code($runtime.type(node), '.isArray')
			}
		}
	} # }}}
	override toBlindTestFragments(funcname, varname, casting, generics, subtypes, junction, fragments, node) { # {{{
		@toBlindTestFragments(funcname, varname, casting, true, @testLength, generics, subtypes, junction, fragments, node)
	} # }}}
	toBlindTestFragments(funcname: String?, varname: String, casting: Boolean, testingType: Boolean, testingLength: Boolean, generics: Generic[]?, subtypes: AltType[]?, junction: Junction, fragments, node) { # {{{
		fragments.code('(') if @nullable && junction == .AND

		if testingType && @length == 0 && !@destructuring && !@testProperties {
			fragments.code(`\($runtime.type(node)).isArray(\(varname)`)

			if @testRest && !node.isMisfit() {
				fragments.code($comma)

				@restType.toBlindTestFunctionFragments(funcname, varname, casting, true, generics, fragments, node)
			}

			fragments.code(')')
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexArray(\(varname)`)

			@toSubtestFragments(varname, casting, testingType, testingLength, fragments, node)

			fragments.code(')')
		}

		if @nullable {
			fragments
				..code(` || \($runtime.type(node)).isNull(\(varname))`)
				..code(')') if junction == .AND
		}
	} # }}}
	override toBlindTestFunctionFragments(funcname, varname, casting, testingType, generics, fragments, node) { # {{{
		if @length == 0 && !@rest && !@nullable {
			if @destructuring {
				fragments.code(`\($runtime.type(node)).isDXArray`)
			}
			else {
				fragments.code($runtime.type(node), '.isArray')
			}
		}
		else if @rest || @testProperties || @nullable {
			fragments.code(`\(varname) => `)

			@toBlindTestFragments(funcname, varname, casting, testingType, @testLength, generics, null, Junction.NONE, fragments, node)
		}
		else {
			if @destructuring {
				fragments.code(`\($runtime.type(node)).isDXArray`)
			}
			else {
				fragments.code($runtime.type(node), '.isArray')
			}
		}
	} # }}}
	override toPositiveTestFragments(_, _, junction, fragments, node) { # {{{
		fragments.code('(') if @nullable && junction == Junction.AND

		if @length == 0 && !@destructuring && !@testProperties {
			fragments.code(`\($runtime.type(node)).isArray(`).compileReusable(node)

			if @testRest && !node.isMisfit() {
				fragments.code($comma)

				@restType.toAwareTestFunctionFragments('value', @nullable, false, false, false, null, null, fragments, node)
			}

			fragments.code(')')
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexArray(`).compileReusable(node)

			@toSubtestFragments('value', false, true, @testLength, fragments, node)

			fragments.code(')')
		}

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(`).compileReusable(node).code(`)`)

			fragments.code(')') if junction == Junction.AND
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
	unflagFullTest(@min) { # {{{
		@fullTest = false
		@testLength = @min > 0
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

	private {
		toSubtestFragments(varname: String, casting: Boolean, testingType: Boolean, testingLength: Boolean, fragments, node) { # {{{
			if testingType {
				fragments.code(', 1')
			}
			else {
				fragments.code(', 0')
			}

			if testingLength {
				fragments.code(`, \(@min ?? @length), 0`)
			}
			else {
				fragments.code(`, 0, 0`)
			}

			if @testRest || @testProperties {
				fragments.code($comma)

				var literal = Literal.new(false, node, node.scope(), 'value')

				if @testProperties {
					if @testRest {
						var mut onlyRest = @fullTest

						if onlyRest {
							for var type in @properties {
								if type != @restType {
									onlyRest = false
									break
								}
							}
						}

						@restType.toBlindTestFunctionFragments(null, varname, casting, true, null, fragments, literal)

						if !onlyRest {
							fragments.code(', [')

							var mut comma = false

							for var type in @properties {
								if comma {
									fragments.code($comma)
								}
								else {
									comma = true
								}

								type.toBlindTestFunctionFragments(null, varname, casting, true, null, fragments, literal)
							}

							fragments.code(']')
						}
					}
					else {
						fragments.code('0, [')

						var mut comma = false

						for var type in @properties {
							if comma {
								fragments.code($comma)
							}
							else {
								comma = true
							}

							type.toBlindTestFunctionFragments(null, varname, casting, true, null, fragments, literal)
						}

						fragments.code(']')
					}
				}
				else {
					@restType.toBlindTestFunctionFragments(null, varname, casting, true, null, fragments, literal)
				}
			}
		} # }}}
	}
}
