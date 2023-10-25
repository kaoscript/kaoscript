class ObjectType extends Type {
	private {
		@computed: Boolean{}			 = {}
		@destructuring: Boolean			= false
		@empty: Boolean					= false
		@key: Boolean					= false
		@keyType: Type?					= null
		@length: Number					= 0
		@liberal: Boolean				= false
		@nullable: Boolean				= false
		@properties: Type{}				= {}
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@spread: Boolean				= false
		@testGenerics: Boolean			= false
		// TODO move to alias
		@testName: String?
		@testProperties: Boolean		= false
		@testRest: Boolean				= false
		@variant: Boolean				= false
		@variantName: String?
		@variantType: VariantType?
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ObjectType { # {{{
			var type = ObjectType.new(scope)

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

				if ?data.key {
					type.setKeyType(Type.import(data.rest, metadata, references, alterations, queue, scope, node))
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
		@testGenerics ||= type.canBeDeferred()

		if type is VariantType {
			@variant = true
			@variantName = name
			@variantType = type
		}
	} # }}}
	override canBeDeferred() => @testGenerics
	clone() { # {{{
		var type = ObjectType.new(@scope)

		type._complete = @complete
		type._destructuring = @destructuring
		type._nullable = @nullable
		type._length = @length
		type._properties = {...@properties}
		type._computed = {...@computed}
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread
		type._testName = @testName
		type._testProperties = @testProperties
		type._testRest = @testRest
		type._variant = @variant
		type._variantName = @variantName
		type._variantType = @variantType

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

		if @key {
			export.key = @keyType.export(references, indexDelta, mode, module)
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
	flagEmpty(): valueof this { # {{{
		@empty = true
	} # }}}
	flagLiberal(): valueof this { # {{{
		@liberal = true
	} # }}}
	flagSpread() { # {{{
		return this if @spread

		var type = @clone()

		type._spread = true

		return type
	} # }}}
	getKeyType(): valueof @keyType
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
	getRestType(): valueof @restType
	getTestName(): valueof @testName
	getVariantName() => @variantName
	getVariantType() => @variantType
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				if @key {
					str = `Object<\(@restType.hashCode(fattenNull)), \(@keyType.hashCode(fattenNull))>`
				}
				else {
					str = `\(@restType.hashCode(fattenNull)){}`
				}
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
	hasKeyType() => @key
	hasMutableAccess() => true
	hasProperty(name: String) => ?@properties[name]
	hasProperties() => @length > 0
	hasRest() => @rest
	hasTest() => ?@testName
	override isAssignableToVariable(mut value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value.isUnion() {
			for var type in value.discard().types() {
				if @isAssignableToVariable(type, anycast, nullcast, downcast, limited) {
					return true
				}
			}

			return false
		}

		if value.isVariant() && value is ReferenceType && value.hasSubtypes() {
			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			var { type % object, generics, subtypes } = value.getGenericMapper()
			var variant = object.getVariantType()

			for var type, name of object.properties() {
				if var prop ?= @properties[name] {
					return false unless prop.isSubsetOf(type, generics, subtypes, matchingMode)
				}
				else {
					return false unless type.isNullable()
				}
			}

			var newProperties = {}

			if var prop ?= @properties[object.getVariantName()] {
				var mut matched = false
				var propname = prop.value()

				for var { name, type } of value.getSubtypes() {
					if variant.getField(propname) == variant.getField(name) {
						Object.merge(newProperties, variant.getField(propname).type.properties())

						matched = true
					}
				}

				return false unless matched
			}
			else {
				return false
			}

			for var type, name of newProperties {
				if var prop ?= @properties[name] {
					return false unless prop.isSubsetOf(type, generics, subtypes, matchingMode)
				}
				else {
					return false unless type.isNullable(generics)
				}
			}

			return true
		}

		if value.isObject() {
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

			if value.isAlias() {
				var { type, generics, subtypes } = value.getGenericMapper()

				return @isSubsetOf(type, generics, subtypes, matchingMode)
			}
			else {
				return @isSubsetOf(value, null, null, matchingMode)
			}
		}

		return false
	} # }}}
	isBinding() => true
	isComplex() => @destructuring || @testRest || @testProperties
	isDestructuring() => @destructuring
	isExhaustive() => @rest ? false : @length > 0 || @scope.reference('Object').isExhaustive()
	isInstanceOf(value: AnyType) => false
	isMorePreciseThan(value: AnyType) => true
	isMorePreciseThan(value: ObjectType) { # {{{
		return true if this == value

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
		if value.isAlias() {
			return @isMorePreciseThan(value.discardAlias())
		}

		return false unless value.isObject()

		return true unless value.hasParameters()
		return false unless @rest

		return @restType.isMorePreciseThan(value.parameter())
	} # }}}
	isMorePreciseThan(value: UnionType) { # {{{
		for var type in value.types() {
			if @isMorePreciseThan(type) {
				return true
			}
		}

		return false
	} # }}}
	isNullable() => @nullable
	isObject() => true
	isExportable() => true
	isLiberal() => @liberal
	isMatching(value: Type, mode: MatchingMode) => false
	isSealable() => true
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
			if value is UnionType {
				for var type in value.types() {
					if this.isSubsetOf(type, mode) {
						return true
					}
				}

				return false
			}
			else {
				return value.isAny()
			}
		}
	} # }}}
	assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
		if #generics {
			var valname = value.name()

			for var { name, type } in generics {
				if name == valname {
					return @isSubsetOf(type, generics, subtypes, mode)
				}
			}
		}

		return true
	} # }}}
	assist isSubsetOf(value: ObjectType, generics, subtypes, mode) { # {{{
		return true if this == value || @empty

		var reference = mode !~ MatchingMode.Reference

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			if reference {
				return false unless @rest == value.hasRest()
			}

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

			if @rest {
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
			else if value.isVariant() {
				var newProperties = {}

				for var type, name of value.properties() {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, generics, subtypes, mode)

						if type is VariantType {
							if type == prop {
								pass
							}
							else if prop is ValueType {
								var value = prop.value()

								if var field ?= type.getField(value) {
									if type.isValidField(field, subtypes) {
										Object.merge(newProperties, field.type.properties())
									}
									else {
										return false
									}
								}
								else if !type.hasSubtype(value) {
									NotImplementedException.throw()
								}
							}
							else {
								NotImplementedException.throw()
							}
						}
					}
					else {
						return false unless type.isNullable()
					}
				}

				for var type, name of newProperties {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, generics, subtypes, mode)
					}
					else {
						return false unless type.isNullable(generics)
					}
				}
			}
			else {
				for var type, name of value.properties() {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, generics, subtypes, mode)
					}
					else {
						return false unless type.isNullable()
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
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		return false unless value.isObject()

		if value.name() != 'Object' {
			var { type, generics, subtypes } = value.getGenericMapper()

			return @isSubsetOf(type, generics, subtypes, mode + MatchingMode.Reference)
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
	isVariant() => @variant
	length(): valueof @length
	listFunctions(name: String): Array { # {{{
		var result = []

		if var property ?= @properties[name] {
			if property is FunctionType {
				result.push(property)
			}
		}

		return result
	} # }}}
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		if var property ?= @properties[name] {
			if property is FunctionType {
				if property.isSubsetOf(type, mode) {
					result.push(property)
				}
			}
		}

		return result
	} # }}}
	listMissingProperties(class: ClassType) { # {{{
		var fields = {}
		var functions = {}

		for var type, name of @properties {
			match type {
				is FunctionType {
					unless class.hasMatchingInstanceMethod(name, type, MatchingMode.FunctionSignature) {
						functions[name] = type
					}
				}
				else {
					if var variable ?= class.getInstanceVariable(name) {
						unless variable.isSubsetOf(type, MatchingMode.Default) {
							fields[name] = type
						}
					}
					else {
						fields[name] = type
					}
				}
			}
		}

		return { fields, functions }
	} # }}}
	listMissingProperties(struct: StructType) { # {{{
		var fields = {}
		var functions = {}

		for var type, name of @properties {
			if var variable ?= struct.getProperty(name) {
				unless variable.isSubsetOf(type, MatchingMode.Default) {
					fields[name] = type
				}
			}
			else {
				fields[name] = type
			}
		}

		return { fields, functions }
	} # }}}
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
	assist merge(value: ObjectType, generics, subtypes, node) { # {{{
		var result = ObjectType.new(@scope)

		result.flagDestructuring() if @destructuring
		result.flagSpread() if @spread

		if @hasProperties() {
			var newProperties = {}

			if value.isVariant() && #subtypes {
				for var type, name of value.properties() when type is VariantType {
					if subtypes.length == 1 {
						if var field ?= type.getField(subtypes[0].name) {
							Object.merge(newProperties, field.type.properties())
						}
					}
					else {
						NotImplementedException.throw()
					}
				}
			}

			var rest = value.hasRest()
			var restType = rest ? value.getRestType() : @restType

			if @rest {
				result.setRestType(restType)
			}

			if value.hasProperties() {
				for var type, name of @properties {
					if var property ?= value.getProperty(name) ?? newProperties[name] {
						result.addProperty(name, @computed[name], type.merge(property, generics, subtypes, node))
					}
					else if rest {
						result.addProperty(name, @computed[name], type.merge(restType, generics, subtypes, node))
					}
					else {
						ReferenceException.throwUndefinedBindingVariable(name, node)
					}
				}
			}
			else if rest {
				for var type, name of @properties {
					result.addProperty(name, @computed[name], type.merge(restType, generics, subtypes, node))
				}
			}
			else {
				return this
			}
		}
		else {
			throw NotImplementedException.new()
		}

		return result
	} # }}}
	assist merge(value: ReferenceType, generics, subtypes, node) { # {{{
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
			var result = ObjectType.new(@scope)

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
				throw NotImplementedException.new()
			}

			return result
		}
		else if value.isAlias() {
			var { type, generics, subtypes } = value.getGenericMapper()

			return @merge(type, generics, subtypes, node)
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
	setDeferrable(deferrable) { # {{{
		@testGenerics ||= deferrable
	} # }}}
	setExhaustive(@exhaustive) { # {{{
		for var property of @properties {
			property.setExhaustive(exhaustive)
		}

		return this
	} # }}}
	setKeyType(@keyType) { # {{{
		@key = true
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
	setRestType(@restType): valueof this { # {{{
		@rest = true
		@testRest = !@restType.isAny() || !@restType.isNullable()
	} # }}}
	setTestName(@testName)
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new()
	} # }}}
	toQuote() { # {{{
		var mut str = ''

		if @length == 0 {
			if @rest {
				if @key {
					str = `Object<\(@restType.toQuote()), \(@keyType.toQuote())>`
				}
				else {
					str = `\(@restType.toQuote()){}`
				}
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
			@toSubtestFragments('value', testingType, null, fragments, node)
		}

		fragments.code(')')
	} # }}}
	override toAwareTestFunctionFragments(varname, mut nullable, generics, subtypes, fragments, node) { # {{{
		nullable ||= @nullable

		if ?@testName {
			if nullable || #generics || (@variant && #subtypes) {
				fragments.code(`\(varname) => \(@testName)(\(varname)`)

				if #generics {
					fragments.code(`, [`)

					for var { type }, index in generics {
						fragments.code($comma) if index != 0

						type.toAwareTestFunctionFragments(varname, false, null, null, fragments, node)
					}

					fragments.code(`]`)
				}

				if @variant && #subtypes {
					fragments.code(`, \(varname) => `)

					if @variantType.canBeBoolean() {
						for var { name, type }, index in subtypes {
							fragments
								..code(' || ') if index > 0
								..code('!') if @variantType.isFalseValue(name)
								..code(varname)
						}
					}
					else {
						for var { name, type }, index in subtypes {
							fragments
								..code(' || ') if index > 0
								..code(`\(varname) === `).compile(type).code(`.\(name)`)
						}
					}
				}

				fragments.code(`)`)

				if nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}
			}
			else {
				fragments.code(@testName)
			}
		}
		else {
			if @length == 0 && !@rest && !nullable && !@variant {
				if @destructuring {
					fragments.code($runtime.type(node), '.isDexObject')
				}
				else {
					fragments.code($runtime.type(node), '.isObject')
				}
			}
			else if @testRest || @testProperties || nullable || @variant {
				if @variant {
					fragments.code(`(\(varname), filter) => `)
				}
				else {
					fragments.code(`\(varname) => `)
				}

				@toBlindTestFragments(varname, nullable, true, null, Junction.NONE, fragments, node)
			}
			else {
				if @destructuring {
					fragments.code($runtime.type(node), '.isDexObject')
				}
				else {
					fragments.code($runtime.type(node), '.isObject')
				}
			}
		}
	} # }}}
	override toBlindSubtestFunctionFragments(varname, nullable, generics, fragments, node) { # {{{
		if ?@testName {
			if nullable || @nullable {
				fragments.code(`\(varname) => \(@testName)(\(varname)) || \($runtime.type(node)).isNull(\(varname))`)
			}
			else {
				fragments.code(@testName)
			}
		}
		else {
			if @testRest || @testProperties || @nullable || @testGenerics || @variant || nullable {
				if @testGenerics || @variant {
					fragments.code(`(\(varname)`)

					if @testGenerics {
						fragments.code(', mapper')
					}
					if @variant {
						fragments.code(', filter')
					}

					fragments.code(`) => `)
				}
				else {
					fragments.code(`\(varname) => `)
				}

				fragments.code(`\($runtime.type(node)).isDexObject(\(varname)`)

				@toSubtestFragments(varname, true, generics, fragments, node)

				fragments.code(')')

				if @nullable || nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}
			}
			else {
				if @destructuring {
					fragments.code($runtime.type(node), '.isDexObject')
				}
				else {
					fragments.code($runtime.type(node), '.isObject')
				}
			}
		}
	} # }}}
	override toBlindTestFragments(varname, generics, junction, fragments, node) { # {{{
		@toBlindTestFragments(varname, @nullable, true, generics, junction, fragments, node)
	} # }}}
	toBlindTestFragments(varname: String, mut nullable: Boolean, testingType: Boolean, generics: String[]?, junction: Junction, fragments, node) { # {{{
		nullable ||= @nullable

		fragments.code('(') if nullable && junction == .AND

		if ?@testName {
			fragments.code(`\(@testName)(\(varname))`)
		}
		else if testingType && !@destructuring && !@testRest && !@testProperties {
			fragments.code(`\($runtime.type(node)).isObject(\(varname))`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexObject(\(varname)`)

			@toSubtestFragments(varname, testingType, generics, fragments, node)

			fragments.code(')')
		}

		if nullable {
			fragments
				..code(` || \($runtime.type(node)).isNull(\(varname))`)
				..code(')') if junction == .AND
		}
	} # }}}
	override toBlindTestFunctionFragments(varname, generics, fragments, node) { # {{{
		if !#@properties && !@rest && !@nullable && !@variant {
			if @destructuring {
				fragments.code($runtime.type(node), '.isDexObject')
			}
			else {
				fragments.code($runtime.type(node), '.isObject')
			}
		}
		else if @testRest || @testProperties || @nullable || @testGenerics || @variant {
			if @testGenerics || @variant {
				fragments.code(`(\(varname)`)

				if @testGenerics {
					fragments.code(', mapper')
				}
				if @variant {
					fragments.code(', filter')
				}

				fragments.code(`) => `)
			}
			else {
				fragments.code(`\(varname) => `)
			}

			fragments.code(`\($runtime.type(node)).isDexObject(\(varname)`)

			@toSubtestFragments(varname, true, generics, fragments, node)

			fragments.code(')')

			if @nullable {
				fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
			}
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
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if @nullable && junction == .AND

		if ?@testName {
			if #subtypes {
				fragments.code(`\(@testName)(`).compile(node).code(`, value => `)

				for var { name, type }, index in subtypes {
					fragments
						..code(' || ') if index > 0
						..code('value === ').compile(type).code(`.\(name)`)
				}

				fragments.code(')')
			}
			else {
				fragments.code(`\(@testName)(`).compile(node).code(`)`)
			}
		}
		else if !@destructuring && !@testRest && !@testProperties {
			fragments.code(`\($runtime.type(node)).isObject(`).compile(node).code(`)`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexObject(`).compile(node)

			@toSubtestFragments('value', true, null, fragments, node)

			fragments.code(')')
		}

		if @nullable {
			fragments
				..code(` || \($runtime.type(node)).isNull(`).compile(node).code(`)`)
				..code(')') if junction == .AND
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
	unflagLiberal() { # {{{
		@liberal = false
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

	private {
		toSubtestFragments(varname: String, testingType: Boolean, generics: String[]?, fragments, node) { # {{{
			if testingType {
				fragments.code(', 1')
			}
			else {
				fragments.code(', 0')
			}

			if @testRest || @testProperties {
				fragments.code($comma)

				if @testProperties {
					if @testRest {
						@restType.toBlindSubtestFunctionFragments(varname, false, generics, fragments, node)
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

						type.toBlindSubtestFunctionFragments(varname, false, generics, fragments, node)
					}

					fragments.code('}')
				}
				else {
					@restType.toBlindSubtestFunctionFragments(varname, false, generics, fragments, node)
				}
			}
		} # }}}
	}
}
