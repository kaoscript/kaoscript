class AliasType extends Type {
	private late {
		@type: Type
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): AliasType { # {{{
			var type = AliasType.new(scope)

			queue.push(() => {
				type.type(Type.import(data.of, metadata, references, alterations, queue, scope, node))
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
		throw NotSupportedException.new()
	} # }}}
	discard() => @type.discard()
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	override export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Alias
			of: @type.export(references, indexDelta, mode, module)
		}
	} # }}}
	getProperty(name: String): Type => @type.getProperty(name)
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	isExclusion() => @type.isExclusion()
	isExportable() => @type.isExportable()
	isExportingFragment() => false
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
	matchContentOf(value: Type): Boolean => @type.matchContentOf(value)
	parameter() => @type.parameter()
	reduce(type: Type) => @type.reduce(type)
	setNullable(nullable: Boolean) { # {{{
		throw NotImplementedException.new()
	} # }}}
	shallBeNamed() => true
	override split(types) => @type.split(types)
	type() => @type
	type(@type) => this
	toExportFragment(fragments, name, variable)
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) => @type.toNegativeTestFragments(fragments, node, junction)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { # {{{
		variations.push('alias')

		@type.toVariations(variations)
	} # }}}

	proxy @type {
		hasRest
		isComplete
	}
}
