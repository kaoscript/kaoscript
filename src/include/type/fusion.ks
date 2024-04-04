class FusionType extends Type {
	private {
		@builtFlags: Boolean		= false
		@cast: Boolean				= false
		@generics: Boolean			= false
		@nullable: Boolean			= false
		// TODO move to alias
		@testName: String?
		@types: Type[]				= []
		@variant: Boolean			= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): FusionType { # {{{
			var fusion = FusionType.new(scope)

			queue.push(() => {
				var types = []

				for var type in data.types {
					types.push(Type.import(type, metadata, references, alterations, queue, scope, node))
				}

				var finalize = () => {
					var mut complete = true

					for var type in types {
						if !type.isComplete() {
							complete = false

							break
						}
					}

					if complete {
						for var type in types {
							fusion.addType(type)
						}
					}
					else {
						queue.push(finalize)
					}
				}

				finalize()
			})

			return fusion
		} # }}}
	}
	constructor(@scope) { # {{{
		super(scope)
	} # }}}
	constructor(@scope, types: typeof @types) { # {{{
		super(scope)

		for var type in types {
			@addType(type)
		}
	} # }}}
	addType(type: Type) { # {{{
		@nullable ||= type.isNullable()
		@variant ||= type.isVariant()

		@types.push(type.setNullable(false))
	} # }}}
	canBeDeferred() => @buildFlags() && @generics
	override canBeRawCasted() => @buildFlags() && @cast
	clone(): FusionType { # {{{
		var result = FusionType.new(@scope)

		result._nullable = @nullable
		result._testName = @testName
		result._types = [...@types]
		result._variant = @variant

		return result
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Fusion
			types: [type.toReference(references, indexDelta, mode, module) for var type in @types]
		}
	} # }}}
	override finalize(data, generics, node) { # {{{
		for var data, index in data.types {
			@types[index].finalize(data, generics, node)
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for var type in @types {
			type.flagExported(explicitly).flagReferenced()
		}

		return this
	} # }}}
	override flagIndirectlyReferenced()
	getKeyType() { # {{{
		for var type in @types {
			var root = type.discard()

			if root is ObjectType && root.hasKeyType() {
				return root.getKeyType()
			}
		}

		return null
	} # }}}
	getProperty(index: Number): Type? { # {{{
		for var type in @types {
			if var property ?= type.getProperty(index) {
				return property
			}
		}

		return null
	} # }}}
	getProperty(name: String): Type? { # {{{
		var mut undecided = false

		for var type in @types {
			if var property ?= type.getProperty(name) {
				if property == Type.Undecided {
					undecided = true
				}
				else {
					return property
				}
			}
		}

		if undecided {
			return AnyType.NullableUnexplicit
		}

		return null
	} # }}}
	getRestType(): Type? { # {{{
		for var type in @types {
			var root = type.discard()

			if root is ObjectType {
				if var property ?= root.getRestType() {
					return property
				}
			}
		}

		return null
	} # }}}
	getTestName(): valueof @testName
	getVariantName() { # {{{
		for var type in @types {
			if type.isVariant() {
				return type.getVariantName()
			}
		}

		return null
	} # }}}
	getVariantType() { # {{{
		for var type in @types {
			if type.isVariant() {
				return type.getVariantType()
			}
		}

		return null
	} # }}}
	hashCode(fattenNull: Boolean = false): String { # {{{
		var hash = [type.hashCode(fattenNull) for var type in @types].join('&')

		if @nullable {
			return `\(hash)?`
		}
		else {
			return hash
		}
	} # }}}
	hasKeyType() { # {{{
		for var type in @types {
			var root = type.discard()

			if root is ObjectType && root.hasKeyType() {
				return true
			}
		}

		return false
	} # }}}
	hasTest() => ?@testName
	isArray() { # {{{
		for var type in @types {
			if type.isArray() {
				return true
			}
		}

		return false
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}

		if @isNullable() && !nullcast && !value.isNullable() {
			return false
		}

		return @isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass)
	} # }}}
	isComplete() => true
	isComplex() => true
	override isExportable() => true
	override isExportable(module) => true
	isFusion() => true
	isNullable() => @nullable
	isObject() { # {{{
		for var type in @types {
			if type.isObject() {
				return true
			}
		}

		return false
	} # }}}
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		for var type in @types {
			if type.isSubsetOf(value, generics, subtypes, mode) {
				return true
			}
		}

		return false
	} # }}}
	assist isSubsetOf(value: FusionType, generics, subtypes, mode) { # {{{
		if @types.length != value._types.length {
			return false
		}

		var mut match = 0
		for var aType in @types {
			for var bType in value._types {
				if aType.isSubsetOf(bType, generics, subtypes, mode) {
					match += 1
					break
				}
			}
		}

		return match == @types.length
	} # }}}
	override isVariant() => @variant
	listFunctions(name: String): Array { # {{{
		var result = []

		for var type in @types {
			result.push(...type.listFunctions(name)!?)
		}

		return result
	} # }}}
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		for var subtype in @types {
			result.push(...subtype.listFunctions(name, type, mode)!?)
		}

		return result
	} # }}}
	listMissingProperties(class: ClassType | StructType | TupleType) { # {{{
		var mut fields = {}
		var mut functions = {}

		for var subtype in @types {
			var missing = subtype.listMissingProperties(class)

			fields = { ...missing.fields!?, ...fields }
			functions = { ...missing.functions!?, ...functions }
		}

		return { fields, functions }
	} # }}}
	parameter() { # {{{
		for var type in @types when type.isArray() {
			return type.parameter()
		}

		return AnyType.NullableUnexplicit
	} # }}}
	properties() { # {{{
		var mut properties = {}

		for var type in @types when type.isObject() {
			var object = type.discard()

			if object is ObjectType {
				properties = { ...properties, ...object.properties()!? }
			}
		}

		return properties
	} # }}}
	setNullable(nullable: Boolean): FusionType { # {{{
		return this if nullable == @nullable

		var result = @clone()

		result._nullable = nullable

		return result
	} # }}}
	setTestName(@testName)
	override toAwareTestFunctionFragments(varname, mut nullable, hasDeferred, casting, blind, generics, subtypes, fragments, node) { # {{{
		@buildFlags()

		nullable ||= @nullable

		if ?@testName {
			if nullable || ?#generics || (@variant && ?#subtypes) {
				fragments.code(`\(varname) => \(@testName)(\(varname)`)

				if @cast && (casting || ?#generics || (@variant && ?#subtypes)) {
					if casting {
						fragments.code(', cast')
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

				if @variant && ?#subtypes {
					var variantType = @getVariantType()

					variantType.toFilterFragments(varname, subtypes, fragments)
				}

				fragments.code(`)`)

				if nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}
			}
			else if casting && @cast {
				fragments.code(`\(varname) => \(@testName)(\(varname), \(blind ? 'cast' : 'true'))`)
			}
			else {
				fragments.code(@testName)
			}

			if @standardLibrary ~~ .Yes {
				node.module().flagLibSTDType()
			}
		}
		else {
			super(varname, nullable, hasDeferred, casting, blind, generics, subtypes, fragments, node)
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, casting, propname, mut nullable, generics, fragments, node) { # {{{
		@buildFlags()

		nullable ||= @nullable

		if ?@testName {
			if casting && @cast {
				fragments.code(`\(varname) => \(@testName)(\(varname), cast)`)

				if nullable {
					fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)
				}
			}
			else if nullable {
				fragments.code(`\(varname) => \(@testName)(\(varname)) || \($runtime.type(node)).isNull(\(varname))`)
			}
			else {
				fragments.code(@testName)
			}
		}
		else {
			@toBlindTestFunctionFragments(funcname, varname, casting, true, generics, fragments, node)
		}
	} # }}}
	override toBlindTestFragments(funcname, varname, casting, generics, subtypes, junction, fragments, node) { # {{{
		@buildFlags()

		if ?@testName {
			fragments.code(`\(@testName)(\(varname)`)

			if @cast && (casting || (@variant && ?#subtypes)) {
				if casting {
					fragments.code(', cast')
				}
				else {
					fragments.code(', 0')
				}
			}

			if @variant && ?#subtypes {
				var variantType = @getVariantType()

				variantType.toFilterFragments(varname, subtypes, fragments)
			}

			fragments.code(')')
		}
		else {
			fragments.code('(') if junction == Junction.OR

			for var type, index in @types {
				fragments.code(' && ') if index != 0

				type.toBlindTestFragments(funcname, varname, casting, generics, subtypes, Junction.AND, fragments, node)
			}

			fragments.code(')') if junction == Junction.OR
		}
	} # }}}
	override toBlindTestFunctionFragments(funcname, varname, casting, testingType, generics, fragments, node) { # {{{
		@buildFlags()

		if @cast || @generics || @variant {
			fragments.code(`(\(varname)`)

			if @cast {
				fragments.code(', cast')
			}
			if @generics {
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

		for var type, index in @types {
			fragments.code(' && ') if index != 0

			type.toBlindTestFragments(funcname, varname, @cast, generics, null, Junction.AND, fragments, node)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toNegativeTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .OR

		for var type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toNegativeTestFragments(parameters, subtypes, Junction.AND, fragments, node)
		}

		fragments.code(')') if junction == .OR
	} # }}}
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		@buildFlags()

		if ?@testName {
			fragments.code(`\(@testName)(`).compile(node)

			if @cast && (?#parameters || ?#subtypes) {
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
				if subtypes.length == 1 {
					var { name, type } = subtypes[0]
					var value = type.discard().getValue(name)

					if value.isAlias() {
						if value.isDerivative() {
							fragments.code(', ').compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))`)
						}
						else {
							fragments.code(`, value => value === `).compile(type).code(`.\(value.original())`)
						}
					}
					else {
						fragments.code(`, value => value === `).compile(type).code(`.\(name)`)
					}
				}
				else {
					fragments.code(`, value => `)

					for var { name, type }, index in subtypes {
						fragments.code(' || ') if index > 0

						var value = type.discard().getValue(name)

						if value.isAlias() {
							if value.isDerivative() {
								fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))(value)`)
							}
							else {
								fragments.code(`value === `).compile(type).code(`.\(value.original())`)
							}
						}
						else {
							fragments.code(`value === `).compile(type).code(`.\(name)`)
						}
					}
				}
			}

			fragments.code(')')
		}
		else {
			fragments.code('(') if junction == .OR

			for var type, i in @types {
				if i != 0 {
					fragments.code(' && ')
				}

				type.toPositiveTestFragments(parameters, subtypes, Junction.AND, fragments, node)
			}

			fragments.code(')') if junction == .OR
		}
	} # }}}
	toQuote() => @hashCode()
	override toVariations(variations) { # {{{
		variations.push('fusion', @nullable)

		for var type in @types {
			type.toVariations(variations)
		}
	} # }}}
	type() { # {{{
		if @types.length == 1 {
			var type = @types[0]

			if @nullable == type.isNullable() {
				return type
			}
			else {
				return type.setNullable(@nullable)
			}
		}
		else {
			return this
		}
	} # }}}
	types() => @types

	private {
		buildFlags() { # {{{
			return true if @builtFlags

			@builtFlags = true

			for var type in @types {
				@generics ||= type.canBeDeferred()
				@cast ||= type.canBeRawCasted()
			}

			return true
		} # }}}
	}
}
