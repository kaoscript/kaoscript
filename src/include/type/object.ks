class ObjectType extends Type {
	private {
		@builtFlags: Boolean			= false
		@computed: Boolean{}			= {}
		@destructuring: Boolean			= false
		@empty: Boolean					= false
		@key: Boolean					= false
		@keyType: Type
		@length: Number					= 0
		@liberal: Boolean				= false
		@nullable: Boolean				= false
		@properties: Type{}				= {}
		@rest: Boolean					= false
		@restType: Type					= AnyType.NullableUnexplicit
		@specific: Boolean				= false
		@spread: Boolean				= false
		@testCast: Boolean				= false
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

			if data.destructuring {
				type.flagDestructuring()
			}

			if data.nullable {
				type._nullable = true
			}

			if data.system {
				type.flagSystem()
			}
			else if data.sealed {
				type.flagSealed()
			}

			queue.push(() => {
				var properties = {}
				var mut restType = null
				var mut keyType = null

				if ?data.properties {
					for var property, name of data.properties {
						properties[name] = Type.import(property, metadata, references, alterations, queue, scope, node)
					}
				}

				if ?data.rest {
					restType = Type.import(data.rest, metadata, references, alterations, queue, scope, node)
				}

				if ?data.key {
					keyType = Type.import(data.key, metadata, references, alterations, queue, scope, node)
				}

				queue.push(() => {
					if ?data.properties {
						for var property, name of properties {
							type.addProperty(name, property)
						}
					}

					if ?data.rest {
						type.setRestType(restType)
					}

					if ?data.key {
						type.setKeyType(keyType)
					}

					type.flagComplete()
				})
			})

			return type
		} # }}}
	}
	constructor(@scope) { # {{{
		super(scope)

		@keyType = @scope.reference('String')
	} # }}}
	addProperty(name: String, computed: Boolean = false, type: Type) { # {{{
		@properties[name] = type
		@computed[name] = computed
		@length += 1

		if type is VariantType {
			@variant = true
			@variantName = name
			@variantType = type
		}
	} # }}}
	override applyGenerics(generics) { # {{{
		return this unless @isDeferrable()

		var result = @clone()

		for var property, name of result._properties {
			if property.isDeferrable() {
				result._properties[name] = property.applyGenerics(generics)
			}
		}

		if @rest && result._restType.isDeferrable() {
			result._restType = result._restType.applyGenerics(generics)
		}

		return result
	} # }}}
	override buildGenericMap(position, expressions, decompose, genericMap) { # {{{
		for var property of @properties when property.isDeferrable() {
			property.buildGenericMap(position, expressions, decompose, genericMap)
		}

		if @rest && @restType.isDeferrable() {
			@restType.buildGenericMap(position, expressions, value => decompose(value).parameter(), genericMap)
		}

		if ?@keyType {
			@keyType.buildGenericMap(position, expressions, (mut value) => {
				value = decompose(value)

				if value.hasKeyType() {
					return value.getKeyType()
				}
				else {
					return @scope.reference('String')
				}
			}, genericMap)
		}
	} # }}}
	override canBeDeferred() => @buildFlags() && @testGenerics
	override canBeRawCasted() => @buildFlags() && @testCast
	clone() { # {{{
		var type = ObjectType.new(@scope)

		type._complete = @complete
		type._destructuring = @destructuring
		type._nullable = @nullable
		type._length = @length
		type._liberal = @liberal
		type._properties = {...@properties}
		type._computed = {...@computed}
		type._rest = @rest
		type._restType = @restType
		type._spread = @spread
		type._testName = @testName
		type._variant = @variant
		type._variantName = @variantName
		type._variantType = @variantType

		return type
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
		if @nullable != value.isNullable() {
			return if @nullable set 1 else -1
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
			return if @nullable set 'Object?' else 'Object'
		}

		return {
			kind: TypeKind.Object
			key: @keyType.export(references, indexDelta, mode, module) if @key
			properties: { [name]: value.export(references, indexDelta, mode, module) for var value, name of @properties } if @length > 0
			rest: @restType.export(references, indexDelta, mode, module) if @rest
			destructuring: true if @destructuring
			nullable: true if @nullable
			sealed: true if @sealed && !@system
			system: true if @system
		}
	} # }}}
	override finalize(data, generics, node) { # {{{
		if @variant {
			var scope = node.scope()

			@variantType.flagComplete()

			for var { kind, type } in data.properties when kind == AstKind.PropertyType && type.kind == AstKind.VariantType {
				for var property in type.properties {
					if property.kind == AstKind.VariantField && ?property.type {
						var names = [name for var { name } in property.names]

						@variantType.addField(names, Type.fromAST(property.type, scope, true, generics, node))
					}
				}

				break
			}

			@variantType.buildAliases(node)

			@testGenerics ||= @variantType.canBeDeferred()
		}
	} # }}}
	flagAlien() { # {{{
		@alien = true

		for var property of @properties {
			property.flagAlien()
		}

		return this
	} # }}}
	override flagComplete() { # {{{
		@specific = !@rest && @length == 0

		return super()
	} # }}}
	flagDestructuring() { # {{{
		@destructuring = true
	} # }}}
	flagEmpty(): valueof this { # {{{
		@empty = true
	} # }}}
	override flagIndirectlyReferenced() { # {{{
		if @key {
			@keyType.flagIndirectlyReferenced()
		}

		for var type of @properties {
			type.flagIndirectlyReferenced()
		}

		if @rest {
			@restType.flagIndirectlyReferenced()
		}
	} # }}}
	flagLiberal(): valueof this { # {{{
		@liberal = true
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
	getInstanceVariable(name: String) { # {{{
		if var property ?= @getProperty(name) {
			return VirtualVariableType.new(@scope, property)
		}
		else {
			return null
		}
	} # }}}
	getKeyType(): valueof @keyType
	getProperty(name: String): Type? { # {{{
		if var type ?= @properties[name] {
			return type
		}

		if @rest {
			return @restType
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
				str = `{}`
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

		if @isNullable() && !nullcast && !value.isNullable() {
			return false
		}

		if value is DeferredType {
			if value.isConstrainted() {
				return @isAssignableToVariable(value.constraint(), anycast, true, downcast)
			}

			return true
		}

		if value.isVariant() && value is ReferenceType {
			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			var { type % object, generics, subtypes } = value.getGenericMapper()
			var variant: VariantType = object.getVariantType()

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
				if prop.isValue() {
					var propname = prop.value()

					if value.hasSubtypes() {
						var mut matched = false

						for var { name } in value.getSubtypes() {
							var names = variant.explodeVarnames({ name })

							if names.contains(propname) {
								matched = true

								break
							}
						}

						return false unless matched
					}

					if var field ?= variant.getField(propname) {
						Object.merge(newProperties, field.type.properties())
					}
				}
				else if prop.isView() {
					var view = prop.discard()
					var fields = []

					for var viewValue in view.values() {
						if var field ?= variant.getField(viewValue.name()) {
							fields.pushUniq(field)
						}
					}

					match #fields {
						0 {
							pass
						}
						1 {
							if variant.isValidField(fields[0], subtypes) {
								Object.merge(newProperties, fields[0].type.properties())
							}
							else {
								return false
							}
						}
						else {
							for var field in fields {
								if variant.isValidField(field, subtypes) {
									for var fieldType, fieldName of field.type.properties() {
										if var p ?= @properties[fieldName] {
											return false unless p.isSubsetOf(fieldType, generics, subtypes, matchingMode)
										}
										else {
											return false unless fieldType.isNullable(generics)
										}
									}
								}
								else {
									return false
								}
							}
						}
					}
				}
				else {
					return false
				}
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
			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.IgnoreDeferred

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
	isComplex() => @buildFlags() && (@destructuring || @testRest || @testProperties || @variant)
	override isDeferrable() { # {{{
		return true if @rest && @restType.isDeferrable()

		for var property of @properties {
			return true if property.isDeferrable()
		}

		return false
	} # }}}
	isDestructuring() => @destructuring
	isExhaustive() => !@rest || @scope.reference('Object').isExhaustive()
	isFinite() => !@rest
	assist isInstanceOf(value: AnyType, generics, subtypes) => false
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
			if @equals(type) || @isMorePreciseThan(type) {
				return true
			}
		}

		return false
	} # }}}
	isNullable() => @nullable
	isObject() => true
	override isExportable() => true
	override isExportable(module) => true
	isLiberal() => @liberal
	isMatching(value: Type, mode: MatchingMode) => false
	override isSpecific() => @specific
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
			return value.isAny()
		}
	} # }}}
	assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
		if ?#generics {
			var valname = value.name()

			for var { name, type } in generics {
				if name == valname {
					return @isSubsetOf(type, generics, [], mode)
				}
			}
		}

		return mode ~~ MatchingMode.IgnoreDeferred
	} # }}}
	assist isSubsetOf(value: FusionType, generics, subtypes, mode) { # {{{
		return false if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass

		for var type in value.types() {
			unless @isSubsetOf(type, mode) {
				return false
			}
		}

		return true
	} # }}}
	assist isSubsetOf(value: ObjectType, generics, subtypes, mode) { # {{{
		return true if this == value

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
								var propValue = prop.value()

								if var field ?= type.getField(propValue) {
									if type.isValidField(field, subtypes) {
										Object.merge(newProperties, field.type.properties())
									}
									else {
										return false
									}
								}
								else {
									unless type.hasSubtype(propValue) {
										return false
									}

									if ?#subtypes && !subtypes.some((subtype, ...) => subtype.name == propValue) {
										return false
									}
								}
							}
							else if prop.isView() {
								var view = prop.discard()
								var fields = []

								for var viewValue in view.values() {
									if var field ?= type.getField(viewValue.name()) {
										fields.pushUniq(field)
									}
								}

								match #fields {
									0 {
										pass
									}
									1 {
										if type.isValidField(fields[0], subtypes) {
											Object.merge(newProperties, fields[0].type.properties())
										}
										else {
											return false
										}
									}
									else {
										for var field in fields {
											if type.isValidField(field, subtypes) {
												for var fieldType, fieldName of field.type.properties() {
													if var p ?= @properties[fieldName] {
														return false unless p.isSubsetOf(fieldType, generics, subtypes, mode)
													}
													else {
														return false unless fieldType.isNullable(generics)
													}
												}
											}
											else {
												return false
											}
										}
									}
								}
							}
							else if type.isEmpty() {
								pass
							}
							else if mode ~~ MatchingMode.Exact {
								return false
							}
							else if prop.isAny() {
								pass
							}
							else if type.canBeBoolean() && prop.isBoolean() {
								pass
							}
							else {
								return false
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
			else if @variant && ?#subtypes {
				var newProperties = {}

				if subtypes.length == 1 {
					if var field ?= @variantType.getField(subtypes[0].name) {
						Object.merge(newProperties, field.type.properties())
					}
				}
				else {
					NotImplementedException.throw()
				}

				for var type, name of value.properties() {
					if var prop ?= @properties[name] ?? newProperties[name] {
						return false unless prop.isSubsetOf(type, generics, subtypes, mode)
					}
					else {
						return false unless type.isNullable()
					}
				}
			}
			else {
				for var type, name of value.properties() {
					if var prop ?= @properties[name] {
						return false unless prop.isSubsetOf(type, generics, subtypes, mode)
					}
					else {
						return false unless type.isNullable() || mode ~~ .TypeCasting
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

		if @isNullable() && !value.isNullable() {
			return false
		}

		if value.name() != 'Object' {
			if ?#generics || ?#subtypes {
				return @isSubsetOf(value.discard(), generics, subtypes, mode + MatchingMode.Reference)
			}
			else {
				var map = value.getGenericMapper()

				return @isSubsetOf(map.type, map.generics, map.subtypes, mode + MatchingMode.Reference)
			}
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
	override isTestable() => true
	isTestingProperties() => @buildFlags() && @testProperties
	isVariant() => @variant
	length(): valueof @length
	assist limitTo(value: ReferenceType) { # {{{
		if value.isObject() && @isNullable() && !value.isNullable() {
			return @setNullable(false)
		}

		return this
	} # }}}
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
	override makeMemberCallee(property % propName, path, generics, node) { # {{{
		if var property ?= @getProperty(propName) {
			return property.makeCallee(propName, generics, node)
		}
		else {
			return node.scope().reference('Object').makeMemberCallee(propName, path, generics, node)
		}
	} # }}}
	override makeMemberCallee(property % propName, path, reference, generics, node) { # {{{
		if var property ?= @getProperty(propName) {
			if property is FunctionType || property is OverloadedFunctionType {
				var assessment = property.assessment(propName, node)

				match var result = node.matchArguments(assessment) {
					is LenientCallMatchResult {
						node.addCallee(LenientFunctionCallee.new(node.data(), assessment, result, node))
					}
					is PreciseCallMatchResult with var { matches } {
						if matches.length == 1 {
							var match = matches[0]

							if match.function.isAlien() || match.function.index() == -1 {
								node.addCallee(LenientFunctionCallee.new(node.data(), assessment, [match.function], node))
							}
							else {
								node.addCallee(PreciseFunctionCallee.new(node.data(), assessment, matches, node))
							}
						}
						else {
							var functions = [match.function for var match in matches]

							node.addCallee(LenientFunctionCallee.new(node.data(), assessment, functions, node))
						}
					}
					else {
						return () => {
							if property.isExhaustive(node) {
								ReferenceException.throwNoMatchingFunction(propName, reference.name(), node.arguments(), node)
							}
							else {
								node.addCallee(DefaultCallee.new(node.data(), node.object(), reference, node))
							}
						}
					}
				}
			}
			else {
				throw NotImplementedException.new(node)
			}
		}
		else if @isExhaustive(node) {
			ReferenceException.throwNotDefinedProperty(propName, node)
		}
		else {
			node.prepareArguments()

			node.addCallee(DefaultCallee.new(node.data(), node.object(), reference, node))
		}

		return null
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
	matchDeferred(type: ObjectType, generics: Type{}) { # {{{
		var result = @clone()

		if @rest && @restType.isDeferrable() && type.hasRest() {
			result.setRestType(@restType.matchDeferred(type.getRestType(), generics).type)
		}

		if type.hasProperties() {
			var properties = type.properties()

			if @length != 0 {
				for var property, name of @properties {
					if property.isDeferrable() {
						result._properties[name] = property.matchDeferred(properties[name], generics).type
					}
				}
			}
			else if @rest && @restType.isDeferrable() {
				result.setRestType(@restType.matchDeferred(Type.union(@scope, ...Object.values(properties)!?), generics).type)
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
	assist merge(value: ObjectType, generics, subtypes, ignoreUndefined, node) { # {{{
		var result = ObjectType.new(@scope)

		result.flagDestructuring() if @destructuring
		result.flagSpread() if @spread

		if @hasProperties() {
			var newProperties = {}

			if value.isVariant() && ?#subtypes {
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
			var restType = if rest set value.getRestType() else @restType

			if @rest {
				result.setRestType(restType)
			}

			if value.hasProperties() {
				for var type, name of @properties {
					if var property ?= value.getProperty(name) ?? newProperties[name] {
						result.addProperty(name, @computed[name], type.merge(property, generics, subtypes, ignoreUndefined, node))
					}
					else if rest {
						result.addProperty(name, @computed[name], type.merge(restType, generics, subtypes, ignoreUndefined, node))
					}
					else if !ignoreUndefined {
						ReferenceException.throwUndefinedBindingVariable(name, node)
					}
				}
			}
			else if rest {
				for var type, name of @properties {
					result.addProperty(name, @computed[name], type.merge(restType, generics, subtypes, ignoreUndefined, node))
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
				for var type, name of @properties {
					var valueType = value.getProperty(name)
					var mergeType = valueType.merge(type, generics, subtypes, ignoreUndefined, node)

					result.addProperty(name, @computed[name], mergeType)
				}

				if @rest {
					var valueType = value.parameter()
					var mergeType = valueType.merge(@restType, generics, subtypes, ignoreUndefined, node)

					result.setRestType(mergeType)
				}
			}
			else {
				throw NotImplementedException.new()
			}

			return result
		}
		else if value.isAlias() {
			var map = value.getGenericMapper()

			return @merge(map.type, map.generics, map.subtypes, ignoreUndefined, node)
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
	override setProperty(name, type) { # {{{
		@properties[name] = type
	} # }}}
	setRestType(@restType): valueof this { # {{{
		@rest = true
	} # }}}
	setTestName(@testName)
	override tryCastingTo(value) { # {{{
		if @isNullable() && !value.isNullable() {
			return @setNullable(false).tryCastingTo(value)
		}

		if value.isMorePreciseThan(this) {
			return value
		}

		var root = value.discard()

		return this unless root.isObject()

		var result = ObjectType.new(@scope)

		if @hasProperties() {
			for var type, name of @properties {
				if var property ?= root.getProperty(name) {
					result.addProperty(name, type.tryCastingTo(property))
				}
				else {
					result.addProperty(name, type)
				}
			}
		}

		if @rest {
			result.setRestType(@restType.tryCastingTo(root.getRestType()))
		}

		return result
	} # }}}
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
		@buildFlags()

		fragments.code(`\($runtime.helper(node)).assertDexObject(`).compile(value)

		if @testRest || @testProperties {
			@toSubtestFragments(null, 'value', false, testingType, null, fragments, node)
		}

		fragments.code(')')
	} # }}}
	override toAwareTestFunctionFragments(varname, mut nullable, hasDeferred, casting, blind, generics, subtypes, fragments, node) { # {{{
		@buildFlags()

		nullable ||= @nullable

		if ?@testName {
			if nullable || ?#generics || (@variant && ?#subtypes) {
				fragments
					.code('(') if hasDeferred
					.code(`\(varname) => \(@testName).is(\(varname)`)

				if @testCast {
					if casting {
						fragments.code(`, \(if blind set 'cast' else 'true')`)
					}
					else {
						fragments.code(', 0')
					}
				}

				if ?#generics {
					fragments.code(`, [`)

					for var { type }, index in generics {
						fragments.code($comma) if index != 0

						type.toAwareTestFunctionFragments(varname, false, hasDeferred, casting, blind, null, null, fragments, node)
					}

					fragments.code(`]`)
				}
				else if @testGenerics {
					NotImplementedException.throw()
				}

				if @variant && ?#subtypes {
					@variantType.toFilterFragments(varname, subtypes, fragments)
				}

				fragments.code(`)`)

				if nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}

				fragments.code(')') if hasDeferred
			}
			else if casting && @testCast {
				fragments
					.code('(') if hasDeferred
					.code(`\(varname) => \(@testName).is(\(varname), \(if blind set 'cast' else 'true'))`)
					.code(')') if hasDeferred
			}
			else {
				fragments.code(`\(@testName).is`)
			}

			if @standardLibrary ~~ .Yes {
				node.module().flagLibSTDType()
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
			else if @testRest || @testProperties || nullable || @variant || @testCast {
				fragments.code('(') if hasDeferred

				if @testCast || @variant {
					fragments.code(`(\(varname)`)

					if @testCast {
						fragments.code(', cast')
					}
					if @variant {
						fragments.code(', filter')
					}

					fragments.code(`) => `)
				}
				else {
					fragments.code(`\(varname) => `)
				}

				@toBlindTestFragments(null, varname, @testCast, nullable, true, null, subtypes, Junction.NONE, fragments, node)

				fragments.code(')') if hasDeferred
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
	override toBlindSubtestFunctionFragments(funcname, varname, casting, propname, mut nullable, generics, fragments, node) { # {{{
		@buildFlags()

		nullable ||= @nullable

		if ?@testName {
			if @testCast || nullable || ?#generics {
				fragments.code(`\(varname) => \(@testName).is(\(varname)`)

				if @testCast {
					fragments.code(', cast')
				}

				if ?#generics {
					fragments.code(`, [`)

					for var { type }, index in generics {
						fragments.code($comma) if index != 0

						type.toAwareTestFunctionFragments(varname, false, false, ?propname, true, null, null, fragments, node)
					}

					fragments.code(`]`)
				}

				fragments.code(`)`)

				if nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}
			}
			else {
				fragments.code(`\(@testName).is`)
			}
		}
		else {
			if @testRest || @testProperties || @nullable || @testCast || @testGenerics || @variant || nullable {
				if @testCast || @testGenerics || @variant {
					fragments.code(`(\(varname)`)

					if @testCast {
						fragments.code(', cast')
					}
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

				@toSubtestFragments(funcname, varname, @testCast, true, generics, fragments, node)

				fragments.code(')')

				if nullable {
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
	override toBlindTestFragments(funcname, varname, casting, generics, subtypes, junction, fragments, node) { # {{{
		@toBlindTestFragments(funcname, varname, casting, @nullable, true, generics, subtypes, junction, fragments, node)
	} # }}}
	toBlindTestFragments(funcname: String?, varname: String, casting: Boolean, mut nullable: Boolean, testingType: Boolean, generics: Generic[]?, subtypes: AltType[]?, junction: Junction, fragments, node) { # {{{
		@buildFlags()

		nullable ||= @nullable

		fragments.code('(') if nullable && junction == .AND

		if ?@testName {
			if @testCast && (casting || (@variant && ?#subtypes)) {
				fragments.code(`\(@testName).is(\(varname)`)

				if @testCast && (casting || (@variant && ?#subtypes)) {
					if casting {
						fragments.code(', cast')
					}
					else {
						fragments.code(', 0')
					}
				}

				if @testGenerics {
					fragments.code(', []')
				}

				if @variant && ?#subtypes {
					@variantType.toFilterFragments(varname, subtypes, fragments)
				}

				fragments.code(`)`)
			}
			else {
				fragments.code(`\(@testName).is(\(varname))`)
			}
		}
		else if testingType && !@destructuring && !@testRest && !@testProperties {
			fragments.code(`\($runtime.type(node)).isObject(\(varname))`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexObject(\(varname)`)

			@toSubtestFragments(funcname, varname, casting, testingType, generics, fragments, node)

			fragments.code(')')
		}

		if nullable {
			fragments
				..code(` || \($runtime.type(node)).isNull(\(varname))`)
				..code(')') if junction == .AND
		}
	} # }}}
	override toBlindTestFunctionFragments(funcname, varname, casting, testingType, generics, fragments, node) { # {{{
		@buildFlags()

		if !?#@properties && !@rest && !@nullable && !@variant {
			if @destructuring {
				fragments.code($runtime.type(node), '.isDexObject')
			}
			else {
				fragments.code($runtime.type(node), '.isObject')
			}
		}
		else if @testRest || @testProperties || @nullable || @testCast || @testGenerics || @variant {
			if @testCast || @testGenerics || @variant {
				fragments.code(`(\(varname)`)

				if @testCast {
					fragments.code(', cast')
				}
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

			@toSubtestFragments(funcname, varname, @testCast, testingType, generics, fragments, node)

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
		@buildFlags()

		fragments.code('(') if @nullable && junction == .AND

		if ?@testName {
			fragments.code(`\(@testName).is(`).compileReusable(node)

			if @testCast {
				fragments.code(', 0')
			}

			if ?#parameters {
				fragments.code(`, [`)

				for var { type }, index in parameters {
					fragments.code($comma) if index > 0

					type.toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)
				}

				fragments.code(`]`)
			}

			if ?#subtypes {
				@variantType.toFilterFragments('value', subtypes, fragments)
			}

			fragments.code(')')
		}
		else if !@destructuring && !@testRest && !@testProperties {
			fragments.code(`\($runtime.type(node)).isObject(`).compileReusable(node).code(`)`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isDexObject(`).compileReusable(node)

			@toSubtestFragments(null, 'value', false, true, null, fragments, node)

			fragments.code(')')
		}

		if @nullable {
			fragments
				..code(` || \($runtime.type(node)).isNull(`).compile(node).code(`)`)
				..code(')') if junction == .AND
		}
	} # }}}
	toVariantTestFragments(name: String, parameters: AltType[], junction: Junction, fragments, node) { # {{{
		var main = @variantType.getMainName(name)

		fragments.code(`\(@testName).is\(main.capitalize())(`).compile(node).code(`, [`)

		for var { type }, pIndex in parameters {
			fragments.code($comma) if pIndex > 0

			type.toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)
		}

		fragments.code(`])`)
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
		buildFlags() { # {{{
			return true if @builtFlags

			@builtFlags = true

			for var property of @properties {
				@testProperties ||= !property.isAny() || !property.isNullable()
				@testGenerics ||= property.canBeDeferred()
				@testCast ||= property.canBeRawCasted()
			}

			if @rest {
				@testRest ||= !@restType.isAny() || !@restType.isNullable()
				@testGenerics ||= @restType.canBeDeferred()
				@testCast ||= @restType.canBeRawCasted()
			}

			return true
		} # }}}
		toSubtestFragments(funcname: String?, varname: String, casting: Boolean, testingType: Boolean, generics: Generic[]?, fragments, node) { # {{{
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
						@restType.toBlindSubtestFunctionFragments(funcname, varname, casting, null, false, generics, fragments, node)
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

							type.toBlindSubtestFunctionFragments(funcname, varname, casting, name, false, generics, fragments, node)
						}
						else {
							fragments.code(`\(name): `)

							type.toBlindSubtestFunctionFragments(funcname, varname, casting, `"\(name)"`, false, generics, fragments, node)
						}
					}

					fragments.code('}')
				}
				else {
					@restType.toBlindSubtestFunctionFragments(funcname, varname, casting, null, false, generics, fragments, node)
				}
			}
		} # }}}
	}
}
