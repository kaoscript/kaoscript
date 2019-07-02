class UnionType extends Type {
	private {
		_explicit: Boolean
		_types: Array<Type>
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			return new UnionType(scope, [Type.fromMetadata(type, metadata, references, alterations, queue, scope, node) for type in data])
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new UnionType(scope)

			queue.push(() => {
				for item in data {
					type.addType(Type.fromMetadata(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} // }}}
	}
	constructor(@scope, @types = [], @explicit = true) { // {{{
		super(scope)
	} // }}}
	addType(type: Type) { // {{{
		@types.push(type)
	} // }}}
	equals(b?): Boolean { // {{{
		if !?b || b is not UnionType || @types.length != b._types.length {
			return false
		}

		let match = 0
		for aType in @types {
			for bType in b._types {
				if aType.equals(bType) {
					match++
					break
				}
			}
		}

		return match == @types.length
	} // }}}
	export(references, ignoreAlteration) => [type.toReference(references, ignoreAlteration) for type in @types]
	flagExported(explicitly: Boolean) { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for type in @types {
			type.flagExported(explicitly)
		}

		return this
	} // }}}
	getProperty(name: String) { // {{{
		const types = []

		for const type in @types {
			const property = type.getProperty(name)

			if !types.some(t => property.matchContentOf(t)) {
				types.push(property)
			}
		}

		if types.length == 1 {
			return types[0]
		}
		else {
			return Type.union(@scope, ...types)
		}
	} // }}}
	isExplicit() => @explicit
	isExportable() { // {{{
		for type in @types {
			if !type.isExportable() {
				return false
			}
		}

		return true
	} // }}}
	isInstanceOf(target) { // {{{
		for type in @types {
			if type.isInstanceOf(target) {
				return true
			}
		}

		return false
	} // }}}
	isMorePreciseThan(that: Type) { // {{{
		return that is UnionType && @types.length < that._types.length
	} // }}}
	isNullable() { // {{{
		for type in @types {
			if type.isNullable() {
				return true
			}
		}

		return false
	} // }}}
	matchContentOf(that: Type) { // {{{
		if @explicit {
			for const type in @types {
				if !type.matchContentOf(that) {
					return false
				}
			}

			return true
		}
		else {
			for const type in @types {
				if type.matchContentOf(that) {
					return true
				}
			}

			return false
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		const elements = [type.toQuote() for type in @types]
		const last = elements.pop()

		return `\(elements.join(', ')) or \(last)`
	} // }}}
	toReference(references, ignoreAlteration) => this.export(references, ignoreAlteration)
	toTestFragments(fragments, node) { // {{{
		fragments.code('(')

		for type, i in @types {
			if i {
				fragments.code(' || ')
			}

			type.toTestFragments(fragments, node)
		}

		fragments.code(')')
	} // }}}
	types() => @types
}