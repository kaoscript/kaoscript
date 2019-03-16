class UnionType extends Type {
	private {
		_types: Array<Type>
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			return new UnionType(scope, [Type.fromMetadata(type, metadata, references, alterations, queue, scope, node) for type in data])
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new UnionType(scope)

			queue.push(() => {
				for item in data {
					type.addType(Type.fromMetadata(item, metadata, references, alterations, queue, scope, node))
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
	getProperty(name: String) { // {{{
		const types = []

		for const type in @types {
			const property = type.getProperty(name)

			if !types.some(t => t.matchContentTo(property)) {
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
		if value is UnionType {
			let nf

			for const vType in value._types {
				nf = true

				for const tType in @types while nf {
					if tType.matchContentOf(vType) {
						nf = false
					}
				}

				if nf {
					return false
				}
			}

			return true
		}
		else {
			for type in @types {
				if type.matchContentOf(value) {
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