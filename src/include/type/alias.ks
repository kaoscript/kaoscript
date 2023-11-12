class AliasType extends Type {
	private late {
		@generics: Generic[]		= []
		@type: Type
		@testIndex: Number?			= null
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): AliasType { # {{{
			var type = AliasType.new(scope)

			if ?data.testIndex {
				type.setTestIndex(data.testIndex)
			}

			if ?data.generics {
				type._generics = data.generics
			}

			queue.push(() => {
				type
					..type(Type.import(data.of, metadata, references, alterations, queue, scope, node))
					..flagComplete()
			})

			return type
		} # }}}
	}
	constructor(@scope) { # {{{
		super(scope)
	} # }}}
	constructor(@scope, @type) { # {{{
		super(scope)
	} # }}}
	addGeneric(value: Generic) { # {{{
		@generics.push(value)
	} # }}}
	canBeBoolean() => @type.canBeBoolean()
	canBeEnum(any = true) => @type.canBeEnum(any)
	canBeFunction(any = true) => @type.canBeFunction(any)
	canBeNumber(any = true) => @type.canBeNumber(any)
	canBeObject(any = true) => @type.canBeObject(any)
	canBeString(any = true) => @type.canBeString(any)
	canBeVirtual(name: String) => @type.canBeVirtual(name)
	clone() { # {{{
		var clone = AliasType.new(@scope, @type.clone())

		clone._testIndex = @testIndex if ?@testIndex

		return clone
	} # }}}
	discard() => @type.discard()
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	override export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Alias
			of: @type.export(references, indexDelta, mode, module)
			@testIndex if ?@testIndex
			@generics if #@generics
		}
	} # }}}
	generics() => @generics
	getGenericIndex(name: String) { # {{{
		for var generic, index in @generics {
			return index if name == generic.name
		}

		return null
	} # }}}
	getProperty(index: Number) => @type.getProperty(index)
	getProperty(name: String): Type => @type.getProperty(name)
	getTestIndex() => @testIndex
	getTestName() => @type.getTestName()
	hasGenerics() => #@generics
	hasTest() => @type.hasTest()
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	override isDeferrable() => #@generics || @type.isDeferrable()
	isExclusion() => @type.isExclusion()
	isExportable() => @type.isExportable()
	isExportingFragment() => false
	isExportingType() => @type.isComplex()
	isFunction() => @type.isFunction()
	isFusion() => @type.isFusion()
	isNamespace() => @type.isNamespace()
	isNullable() => @type?.isNullable()
	isNumber() => @type.isNumber()
	isObject() => @type.isObject()
	isReducible() => true
	isString() => @type.isString()
	isStruct() => @type.isStruct()
	assist isSubsetOf(value: AliasType, generics, subtypes, mode) { # {{{
		return this == value
	} # }}}
	isTuple() => @type.isTuple()
	isUnion() => @type?.isUnion()
	listFunctions(name: String): Array => @type.listFunctions(name)
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array => @type.listFunctions(name, type, mode)
	listMissingProperties(class: ClassType | StructType | TupleType) => @type.listMissingProperties(class)
	matchContentOf(value: Type): Boolean => @type.matchContentOf(value)
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) { # {{{
		return [@toMetadata(references, indexDelta, mode, module), name]
	} # }}}
	parameter() => @type.parameter()
	properties() => @type.properties()
	reduce(type: Type) => @type.reduce(type)
	setNullable(nullable: Boolean) { # {{{
		throw NotImplementedException.new()
	} # }}}
	setTestIndex(@testIndex)
	setTestName(testName) => @type.setTestName(testName)
	shallBeNamed() => true
	override split(types) => @type.split(types)
	type() => @type
	type(@type) => this
	override toExportFragment(fragments, name, variable)
	override toBlindTestFunctionFragments(funcname, varname, testingType, generics, fragments, node) { # {{{
		@type.toBlindTestFunctionFragments(funcname, varname, testingType, @generics, fragments, node)
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('alias')

		@type.toVariations(variations)
	} # }}}

	proxy @type {
		canBeDeferred
		hasRest
		isComplex
		isVariant
		toAwareTestFunctionFragments
		toNegativeTestFragments
		toPositiveTestFragments
	}
}
