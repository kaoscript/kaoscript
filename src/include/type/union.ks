class UnionType extends Type {
	private {
		_types: Array<Type>
	}
	static {
		fromMetadata(data, references: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			return new UnionType(scope, [Type.fromMetadata(type, references, scope, node) for type in data])
		} // }}}
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new UnionType(scope)

			queue.push(() => {
				for item in data {
					type.addType(Type.fromMetadata(item, references, scope, node))
				}
			})

			return type
		} // }}}
	}
	constructor(@scope, @types = []) { // {{{
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
	flagExported() { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for type in @types {
			type.flagExported()
		}

		return this
	} // }}}
	isInstanceOf(target) { // {{{
		for type in @types {
			if type.isInstanceOf(target) {
				return true
			}
		}

		return false
	} // }}}
	isNullable() { // {{{
		for type in @types {
			if type.isNullable() {
				return true
			}
		}

		return false
	} // }}}
	matchContentTo(value: Type) { // {{{
		for type in @types {
			if type.matchContentOf(value) {
				return true
			}
		}

		return false
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