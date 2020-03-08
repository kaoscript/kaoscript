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
	getMainType() => @types[0]
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
		console.error(value)
		NotImplementedException.throw()
	} // }}}
	length() => @types.length
	matchContentOf(value: Type?) { // {{{
		if !@types[0].matchContentOf(value) {
			return false
		}

		for const type in @types from 1 {
			if type.matchContentOf(value) {
				return false
			}
		}

		return true
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => [type.toQuote() for const type in @types].join('^')
	toReference(references, mode) => this.export(references, mode)
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		fragments.code('(') if junction == Junction::OR

		if @types[0].isAny() {
			@types[1].toNegativeTestFragments(fragments, node, Junction::AND)

			for const type in @types from 2 {
				fragments.code(' && ')

				type.toNegativeTestFragments(fragments, node, Junction::AND)
			}
		}
		else {
			@types[0].toPositiveTestFragments(fragments, node, Junction::AND)

			for const type in @types from 1 {
				fragments.code(' && ')

				type.toNegativeTestFragments(fragments, node, Junction::AND)
			}
		}

		fragments.code(')') if junction == Junction::OR
	} // }}}
	types() => @types
}