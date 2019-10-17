class ExclusionType extends Type {
	private {
		_types: Array<Type>
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new ExclusionType(scope, [Type.fromMetadata(item, metadata, references, alterations, queue, scope, node) for const item in data.types])

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new ExclusionType(scope)

			queue.push(() => {
				for const item in data.types {
					type.addType(Type.fromMetadata(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} // }}}
	}
	constructor(@scope, @types = []) { // {{{
		super(scope)
	} // }}}
	clone() { // {{{
		const that = new ExclusionType(@scope)

		that._types = [...@types]

		return that
	} // }}}
	export(references, mode) { // {{{
		return {
			kind: TypeKind::Exclusion
			types: [type.toReference(references, mode) for type in @types]
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for const type in @types {
			type.flagExported(explicitly)
		}

		return this
	} // }}}
	isExclusion() => true
	isExportable() { // {{{
		for type in @types {
			if !type.isExportable() {
				return false
			}
		}

		return true
	} // }}}
	isMatching(value: Type, mode: MatchingMode) { // {{{
		console.log(value)
		NotImplementedException.throw()
	} // }}}
	isMatchedBy(value: NamedType) { // {{{
		if !value.matchContentOf(@types[0]) {
			return false
		}

		for const type in @types from 1 {
			if value.matchContentOf(type) {
				return false
			}
		}

		return true
	} // }}}
	length() => @types.length
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => [type.toQuote() for const type in @types].join('^')
	toReference(references, mode) => this.export(references, mode)
	toTestFragments(fragments, node) { // {{{
		fragments.code('(')

		if @types[0].isAny() {
			fragments.code('!')

			@types[1].toTestFragments(fragments, node)

			for const type in @types from 2 {
				fragments.code(' && !')

				type.toTestFragments(fragments, node)
			}
		}
		else {
			@types[0].toTestFragments(fragments, node)

			for const type in @types from 1 {
				fragments.code(' && !')

				type.toTestFragments(fragments, node)
			}
		}

		fragments.code(')')
	} // }}}
}