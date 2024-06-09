class AliasType extends Type {
	private late {
		@alteration: Boolean				= false
		@alterationReference: AliasType?
		@exhaustiveness						= {
			instanceMethods: {}
			staticMethods: {}
		}
		@generics: Generic[]				= []
		@instanceAssessments: Object		= {}
		@instanceMethods: Object			= {}
		@sequences	 						= {
			instanceMethods:	{}
			staticMethods:		{}
		}
		@staticAssessments: Object			= {}
		@staticMethods: Object				= {}
		@type: Type
		@testIndex: Number?					= null
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
				type.type(Type.import(data.of, metadata, references, alterations, queue, scope, node))

				if ?data.instanceMethods {
					for var methods, name of data.instanceMethods {
						for var method in methods {
							type.dedupInstanceMethod(name, VirtualMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					for var methods, name of data.staticMethods {
						for var method in methods {
							type.dedupStaticMethod(name, VirtualMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					type.flagSpecter()
				}

				type.flagComplete()
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
	addInstanceMethod(name: String, type: VirtualMethodType): Number? { # {{{
		@sequences.instanceMethods[name] ??= 0

		var mut index = type.index()
		if index == -1 {
			index = @sequences.instanceMethods[name]

			@sequences.instanceMethods[name] += 1

			type.index(index)
		}
		else {
			if index >= @sequences.instanceMethods[name] {
				@sequences.instanceMethods[name] = index + 1
			}
		}

		if @instanceMethods[name] is Array {
			@instanceMethods[name].push(type)
		}
		else {
			@instanceMethods[name] = [type]
		}

		type.flagInstance()

		if @alteration {
			type.flagAlteration()
		}

		return index
	} # }}}
	addStaticMethod(name: String, type: VirtualMethodType): Number? { # {{{
		if @staticMethods[name] is not Array {
			@staticMethods[name] = []
			@sequences.staticMethods[name] = 0
		}

		var mut index = type.index()
		if index == -1 {
			index = @sequences.staticMethods[name]

			@sequences.staticMethods[name] += 1

			type.index(index)
		}
		else {
			if index >= @sequences.staticMethods[name] {
				@sequences.staticMethods[name] = index + 1
			}
		}

		@staticMethods[name].push(type)

		if @alteration {
			type.flagAlteration()
		}

		return index
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
	dedupInstanceMethod(name: String, type: VirtualMethodType): Number? { # {{{
		var index = type.index()

		if ?@instanceMethods[name] {
			for var method in @instanceMethods[name] {
				if method.index() == index {
					return index
				}
			}
		}

		return @addInstanceMethod(name, type)
	} # }}}
	dedupStaticMethod(name: String, type: VirtualMethodType): Number? { # {{{
		var index = type.index()

		if ?@staticMethods[name] {
			for var method in @staticMethods[name] {
				if method.index() == index {
					return index
				}
			}
		}

		return @addStaticMethod(name, type)
	} # }}}
	discard() => @type?.discard()
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	override export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {
			kind: TypeKind.Alias
			of: @type.export(references, indexDelta, mode, module)
			@testIndex if ?@testIndex
			@generics if ?#@generics
		}

		if @specter {
			export.instanceMethods = {}
			export.staticMethods = {}

			for var methods, name of @instanceMethods {
				var exports = [method.export(references, indexDelta, mode, module) for var method in methods when method.isExportable(mode, module)]

				export.instanceMethods[name] = exports if ?#exports
			}

			for var methods, name of @staticMethods {
				var exports = [method.export(references, indexDelta, mode, module) for var method in methods when method.isExportable(mode, module)]

				export.staticMethods[name] = exports if ?#exports
			}

			if @isExhaustive() {
				var exhaustiveness = {}
				var mut notEmpty = false

				if !Object.isEmpty(@exhaustiveness.staticMethods) {
					exhaustiveness.staticMethods = @exhaustiveness.staticMethods
					notEmpty = true
				}

				if !Object.isEmpty(@exhaustiveness.instanceMethods) {
					exhaustiveness.instanceMethods = @exhaustiveness.instanceMethods
					notEmpty = true
				}

				if notEmpty {
					export.exhaustiveness = exhaustiveness
				}
			}
		}

		return export
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@type.flagExported(explicitly)

		return this
	} # }}}
	flagReferenced() { # {{{
		@type.flagReferenced()

		return this
	} # }}}
	generics() => @generics
	getGenericIndex(name: String) { # {{{
		for var generic, index in @generics {
			return index if name == generic.name
		}

		return null
	} # }}}
	getInstanceAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment ?= @instanceAssessments[name] {
			return assessment
		}
		else if var methods ?= @instanceMethods[name] {
			var assessment = Router.assess([...methods], name, node)

			@instanceAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} # }}}
	getInstanceVariable(name: String) => @type.getInstanceVariable(name)
	getInstantiableMethod(name: String, type: FunctionType, mode: MatchingMode) { # {{{
		var result = []

		if var methods ?= @instanceMethods[name] {
			for var method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length == 1 {
			return result[0]
		}
		else {
			return null
		}
	} # }}}
	getInstantiableProperty(name: String) { # {{{
		if ?#@instanceMethods[name] {
			if #@instanceMethods[name] == 1 {
				return @instanceMethods[name][0]
			}
			else {
				return ClassMethodGroupType.new(@scope, @instanceMethods[name])
			}
		}

		return @type.getProperty(name)
	} # }}}
	getProperty(index: Number) => @type.getProperty(index)
	getProperty(name: String): Type => @type.getProperty(name)
	getStaticAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment ?= @staticAssessments[name] {
			return assessment
		}
		else if var methods ?= @staticMethods[name] {
			var assessment = Router.assess([...methods], name, node)

			@staticAssessments[name] = assessment

			return assessment
		}
		else {
			return null
		}
	} # }}}
	getStaticMethod(name: String): Type? { # {{{
		if var methods ?#= @staticMethods[name] {
			if methods.length == 1 {
				return methods[0]
			}
		}

		return null
	} # }}}
	getTestIndex() => @testIndex
	getTestName() => @type.getTestName()
	hasGenerics() => ?#@generics
	hasInstanceMethod(name) { # {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} # }}}
	hasInstantiableMethod(name) { # {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else {
			return false
		}
	} # }}}
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	hasMatchingStaticMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @staticMethods[name] is Array {
			for var method in @staticMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	hasTest() => @type.hasTest()
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	override isDeferrable() => ?#@generics || @type.isDeferrable()
	isExclusion() => @type.isExclusion()
	isExhaustiveInstanceMethod(name) { # {{{
		if @exhaustiveness.instanceMethods[name] == false {
			return false
		}
		else {
			return true
		}
	} # }}}
	isExhaustiveInstanceMethod(name, node) => @isExhaustive(node) && @isExhaustiveInstanceMethod(name)
	isExportingFragment() => @specter
	isExportingType() => !@specter && @type.isComplex()
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
	isUsingAuxiliary() => true
	isVirtual() => @specter
	listFunctions(name: String): Array => @type.listFunctions(name)
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array => @type.listFunctions(name, type, mode)
	listInstantiableMethods(name: String): VirtualMethodType[] => @instanceMethods[name] ?? []
	listMissingProperties(class: ClassType | StructType | TupleType) => @type.listMissingProperties(class)
	override makeMemberCallee(property, path, reference, generics, node) { # {{{
		if !?@instanceMethods[property] {
			return @type.makeMemberCallee(property, path, reference, generics, node)
		}

		var assessment = @getInstanceAssessment(property, node)

		match var result = node.matchArguments(assessment) {
			is LenientCallMatchResult {
				// node.addCallee(EnumMethodCallee.new(node.data(), reference.discardReference():!!!(NamedType<EnumType>), `__ks_func_\(property)`, result.possibilities, node))
				NotImplementedException.throw(node)
			}
			is PreciseCallMatchResult with var { matches } {
				if matches.length == 1 {
					var match = matches[0]

					node.addCallee(InvertedPreciseMethodCallee.new(node.data(), reference.discardReference():&(NamedType), property, true, assessment, match, node))
				}
				else {
					var functions = [match.function for var match in matches]

					// node.addCallee(EnumMethodCallee.new(node.data(), reference.discardReference():!!!(NamedType<EnumType>), `__ks_func_\(property)`, functions, node))
					NotImplementedException.throw(node)
				}
			}
			else {
				return () => {
					if @isExhaustiveInstanceMethod(property, node) {
						ReferenceException.throwNoMatchingEnumMethod(property, reference.name(), node.arguments(), node)
					}
					else {
						// node.addCallee(EnumMethodCallee.new(node.data(), reference.discardReference():!!!(NamedType<EnumType>), `__ks_func_\(property)`, null, node))
						NotImplementedException.throw(node)
					}
				}
			}
		}

		return null
	} # }}}
	matchContentOf(value: Type): Boolean => @type.matchContentOf(value)
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) { # {{{
		return [@toMetadata(references, indexDelta, mode, module), name]
	} # }}}
	parameter() => @type.parameter()
	properties() => @type.properties()
	setAlterationReference(@alterationReference) { # {{{
		@alteration = true
	} # }}}
	setNullable(nullable: Boolean) { # {{{
		throw NotImplementedException.new()
	} # }}}
	setTestIndex(@testIndex)
	setTestName(testName) => @type.setTestName(testName)
	shallBeNamed() => true
	override split(types) => @type.split(types)
	trimOff(type: Type) => @type.trimOff(type)
	type() => @type
	type(@type) => this
	override toBlindTestFunctionFragments(funcname, varname, casting, testingType, generics, fragments, node) { # {{{
		@type.toBlindTestFunctionFragments(funcname, varname, casting, testingType, @generics, fragments, node)
	} # }}}
	override toExportFragment(fragments, name, variable, module)
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('alias')

		@type.toVariations(variations)
	} # }}}

	proxy @type {
		canBeArray
		canBeDeferred
		canBeRawCasted
		extractFunction
		getStandardLibrary
		hasInvalidProperty
		hasProperty
		hasRest
		isComplex
		isEnum
		isExportable
		isReferenced
		isStandardLibrary
		isVariant
		isView
		setStandardLibrary
		toAwareTestFunctionFragments
		toNegativeTestFragments
		toPositiveTestFragments
	}
}
