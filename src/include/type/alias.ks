class AliasType extends Type {
	private {
		_type: Type
	}
	static {
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new AliasType(scope)

			queue.push(() => {
				type.type(Type.fromMetadata(data.of, references, scope, node))
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
	export(references) { // {{{
		return {
			type: TypeKind::Alias
			of: @type.export(references)
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