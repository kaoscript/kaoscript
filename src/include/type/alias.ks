class AliasType extends Type {
	private {
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
	isExclusion() => @type.isExclusion()
	isMatching(value: AliasType, mode: MatchingMode) { // {{{
		return this == value
	} // }}}
	isNumber() => @type.isNumber()
	isReducible() => true
	isString() => @type.isString()
	isUnion() => @type.isUnion()
	isExportable() => @type.isExportable()
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	parameter() => @type.parameter()
	reduce(type: Type) => @type.reduce(type)
	type() => @type
	type(@type) => this
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
}