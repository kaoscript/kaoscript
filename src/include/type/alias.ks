class AliasType extends Type {
	private lateinit {
		_type: Type
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): AliasType { # {{{
			const type = new AliasType(scope)

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
		throw new NotSupportedException()
	} # }}}
	discard() => @type.discard()
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	override export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind::Alias
			of: @type.export(references, indexDelta, mode, module)
		}
	} # }}}
	getProperty(name: String): Type => @type.getProperty(name)
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	isDictionary() => @type.isDictionary()
	isExclusion() => @type.isExclusion()
	isExportable() => @type.isExportable()
	isExportingFragment() => false
	isFunction() => @type.isFunction()
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
		throw new NotImplementedException()
	} # }}}
	shallBeNamed() => true
	override split(types) => @type.split(types)
	type() => @type
	type(@type) => this
	toExportFragment(fragments, name, variable)
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	toCastFragments(fragments) { # {{{
		@type.toCastFragments(fragments)
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) => @type.toNegativeTestFragments(fragments, node, junction)
	override toPositiveTestFragments(fragments, node, junction) => @type.toPositiveTestFragments(fragments, node, junction)
	override toVariations(variations) { # {{{
		variations.push('alias')

		@type.toVariations(variations)
	} # }}}
}
