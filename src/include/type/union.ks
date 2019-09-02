class UnionType extends Type {
	private {
		_any: Boolean			= false
		_explicit: Boolean
		_nullable: Boolean		= false
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

		for const type in @types until @nullable {
			if type.isNullable() {
				@nullable = true
			}
		}
	} // }}}
	addType(type: Type) { // {{{
		if @any {
			if !@nullable && type.isNullable() {
				@types[0] = AnyType.NullableUnexplicit

				@nullable = true
			}
		}
		else if type.isAny() {
			@types = [type]

			@any = true
			@nullable = type.isNullable()
		}
		else if type.isUnion() {
			for const type in type.discardAlias().types() {
				this.addType(type)
			}
		}
		else {
			let notMatched = true

			for const t, i in @types while notMatched {
				if t.matchContentOf(type) {
					notMatched = false

					if !t.equals(type) {
						@types[i] = type

						if !@nullable && type.isNullable() {
							@nullable = true
						}
					}
				}
			}

			if notMatched {
				@types.push(type)

				if !@nullable && type.isNullable() {
					@nullable = true
				}
			}
		}
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
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
	export(references, mode) => [type.toReference(references, mode) for type in @types]
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
			const property = type.getProperty(name) ?? Type.Any

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
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if value is not UnionType || @types.length != value._types.length {
			return false
		}

		let match = 0
		for aType in @types {
			for bType in value._types {
				if aType.isMatching(bType, mode) {
					match++
					break
				}
			}
		}

		return match == @types.length
	} // }}}
	isMorePreciseThan(that: Type) { // {{{
		if that is ReferenceType {
			if !@nullable && that.isNullable() {
				return true
			}

			that = that.discardAlias()
		}

		if that is UnionType {
			if !@nullable && that.isNullable() {
				return true
			}

			return @types.length < that.types().length
		}

		return false
	} // }}}
	isNullable() => @nullable
	isUnion() => true
	length() => @types.length
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
	reduce(type: Type) { // {{{
		const types = [t for const t in @types when !t.matchContentOf(type)]

		if types.length == 1 {
			return types[0]
		}
		else {
			return Type.union(@scope, ...types)
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => [type.toQuote() for const type in @types].join('|')
	toQuote(double: Boolean): String { // {{{
		const elements = [type.toQuote() for type in @types]
		const last = elements.pop()

		if double {
			return `"\(elements.join(`", "`))" or "\(last)"`
		}
		else {
			return `'\(elements.join(`', '`))' or '\(last)'`
		}
	} // }}}
	toReference(references, mode) => this.export(references, mode)
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
	type() { // {{{
		if @types.length == 1 {
			return @types[0]
		}
		else {
			return this
		}
	} // }}}
	types() => @types
}