class AliasType extends Type {
	private lateinit {
		_type: Type
	}
	static {
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new AliasType(scope)

			queue.push(() => {
				type.type(Type.fromMetadata(data.of, metadata, references, alterations, queue, scope, node))
			})

			return type
		} // }}}
	}
	constructor(@scope) { // {{{
		super(scope)
	} // }}}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	canBeBoolean() => @type.canBeBoolean()
	canBeNumber(any = true) => @type.canBeNumber(any)
	canBeString(any = true) => @type.canBeString(any)
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	discard() => @type.discard()
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	export(references, mode) { // {{{
		return {
			kind: TypeKind::Alias
			of: @type.export(references, mode)
		}
	} // }}}
	getProperty(name: String): Type => @type.getProperty(name)
	isAlias() => true
	isArray() => @type.isArray()
	isBoolean() => @type.isBoolean()
	isDictionary() => @type.isDictionary()
	isExclusion() => @type.isExclusion()
	isExportable() => @type.isExportable()
	isExportingFragment() => false
	isFunction() => @type.isFunction()
	isMatching(value: AliasType, mode: MatchingMode) { // {{{
		return this == value
	} // }}}
	isNamespace() => @type.isNamespace()
	isNumber() => @type.isNumber()
	isObject() => @type.isObject()
	isReducible() => true
	isString() => @type.isString()
	isStruct() => @type.isStruct()
	isTuple() => @type.isTuple()
	isUnion() => @type.isUnion()
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	parameter() => @type.parameter()
	reduce(type: Type) => @type.reduce(type)
	type() => @type
	type(@type) => this
	toExportFragment(fragments, name, variable)
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toCastFragments(fragments) { // {{{
		@type.toCastFragments(fragments)
	} // }}}
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
}