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
	discardAlias() => @type.discardAlias()
	discardReference() => @type.discardAlias()
	equals(b?): Boolean { // {{{
		throw new NotImplementedException()
	} // }}}
	export(references, ignoreAlteration) { // {{{
		return {
			kind: TypeKind::Alias
			of: @type.export(references, ignoreAlteration)
		}
	} // }}}
	getProperty(name: String): Type => @type.getProperty(name)
	isAlias() => true
	matchContentOf(that: Type): Boolean => @type.matchContentOf(that)
	matchContentTo(that: Type): Boolean => @type.matchContentTo(that)
	type() => @type
	type(@type) => this
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, node)
	} // }}}
}