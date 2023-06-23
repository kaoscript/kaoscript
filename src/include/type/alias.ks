class AliasType extends Type {
	private late {
		// @testIndex: Number?
		@type: Type
		// @typeTest: TypeTest?		= null
		@testIndex: Number?		= null
		// @testName: String?		= null
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): AliasType { # {{{
			var type = AliasType.new(scope)

			if ?data.testIndex {
				type.setTestIndex(data.testIndex)
				// type.setTypeTest({
				// 	holder: ''
				// 	path: `[\(data.testIndex)]`
				// 	index: data.testIndex
				// })
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
	canBeBoolean() => @type.canBeBoolean()
	canBeFunction(any = true) => @type.canBeFunction(any)
	canBeNumber(any = true) => @type.canBeNumber(any)
	canBeString(any = true) => @type.canBeString(any)
	clone() { # {{{
		var clone = AliasType.new(@scope, @type.clone())

		// 	// TODO!
		// 	// clone._typeTest = {...@typeTest}
		// 	clone._typeTest = {...@typeTest} as TypeTest
		clone._testIndex = @testIndex if ?@testIndex
		// clone._testName = @testName if ?@testName

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
			// testIndex: @typeTest.index if ?@typeTest?.index
		}
	} # }}}
	getProperty(name: String): Type => @type.getProperty(name)
	getTestIndex() => @testIndex
	// getTestName() => @testName
	// hasTest() => ?@testName
	getTestName() => @type.getTestName()
	hasTest() => @type.hasTest()
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
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
	isSubsetOf(value: AliasType, mode: MatchingMode) { # {{{
		return this == value
	} # }}}
	isTuple() => @type.isTuple()
	isUnion() => @type?.isUnion()
	listFunctions(name: String): Array => @type.listFunctions(name)
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array => @type.listFunctions(name, type, mode)
	listMissingProperties(class: ClassType) => @type.listMissingProperties(class)
	matchContentOf(value: Type): Boolean => @type.matchContentOf(value)
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) { # {{{
		return [@toMetadata(references, indexDelta, mode, module), name]
	} # }}}
	parameter() => @type.parameter()
	reduce(type: Type) => @type.reduce(type)
	setNullable(nullable: Boolean) { # {{{
		throw NotImplementedException.new()
	} # }}}
	setTestIndex(@testIndex)
	// setTestName(@testName)
	setTestName(testName) => @type.setTestName(testName)
	// setTypeTest(test) => @type.setTypeTest(test)
	// setTestHolder(holder: String): Void { # {{{
	// 	@typeTest.holder = holder
	// } # }}}
	// setTypeTest(@typeTest)
	shallBeNamed() => true
	override split(types) => @type.split(types)
	type() => @type
	type(@type) => this
	override toExportFragment(fragments, name, variable)
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) => @type.toNegativeTestFragments(fragments, node, junction)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	// override toTestFragments(fragments, node, junction) { # {{{
	// 	if ?@testName {
	// 		// var testName = `\(@typeTest.holder)\(@typeTest.path)`

	// 		if @type.isNullable() {
	// 			fragments.code('(') if junction == Junction.AND

	// 			fragments.code(`\(@testName)(value) || \($runtime.type(node)).isNull(value)`)

	// 			fragments.code(')') if junction == Junction.AND
	// 		}
	// 		else {
	// 			fragments.code(`\(@testName)(value)`)
	// 		}
	// 	}
	// 	else {
	// 		@type.toTestFragments(fragments, node, junction)
	// 	}
	// } # }}}
	// override toTestFunctionFragments(fragments, node) { # {{{
	// 	if ?@testName {
	// 		// var testName = `\(@typeTest.holder)\(@typeTest.path)`

	// 		if @type.isNullable() {
	// 			fragments.code(`value => \(@testName)(value) || \($runtime.type(node)).isNull(value)`)
	// 		}
	// 		else {
	// 			fragments.code(`\(@testName)`)
	// 		}
	// 	}
	// 	else {
	// 		@type.toTestFunctionFragments(fragments, node)
	// 	}
	// } # }}}
	// override toTestFunctionFragments(fragments, node, mode) { # {{{
	// 	if mode == .USE && ?@testName {
	// 		// var testName = `\(@typeTest.holder)\(@typeTest.path)`

	// 		if @type.isNullable() {
	// 			fragments.code(`value => \(@testName)(value) || \($runtime.type(node)).isNull(value)`)
	// 		}
	// 		else {
	// 			fragments.code(`\(@testName)`)
	// 		}
	// 	}
	// 	else {
	// 		@type.toTestFunctionFragments(fragments, node, mode)
	// 	}
	// } # }}}
	override toVariations(variations) { # {{{
		variations.push('alias')

		@type.toVariations(variations)
	} # }}}

	proxy @type {
		hasRest
		isComplex
		toTestFunctionFragments
	}
}
