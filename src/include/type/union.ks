class UnionType extends Type {
	private {
		_any: Boolean				= false
		_explicit: Boolean
		_explicitNullity: Boolean	= false
		_nullable: Boolean			= false
		_types: Array<Type>			= []
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new UnionType(scope, [Type.fromMetadata(item, metadata, references, alterations, queue, scope, node) for const item in data.types])

			if data.nullable? {
				type._nullable = data.nullable
				type._explicitNullity = true
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new UnionType(scope)

			if data.nullable? {
				type._nullable = data.nullable
				type._explicitNullity = true
			}

			queue.push(() => {
				for const item in data.types {
					type.addType(Type.fromMetadata(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} // }}}
	}
	constructor(@scope, types: Array = [], @explicit = true) { // {{{
		super(scope)

		for const type in types {
			if type.isNull() && (type.isReference() || type.isExplicit()) {
				@nullable = true
				@explicitNullity = true
			}
			else if type.isAny() {
				@types = [type]

				@any = true
				@nullable = type.isNullable()

				break
			}
			else {
				@types.push(type)

				if type.isNullable() {
					@nullable = true
				}
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
		else if type.isNull() {
			@nullable = true
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

			if !@nullable && type.isNullable() {
				@nullable = true
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
	canBeBoolean() { // {{{
		for const type in @types {
			if type.canBeBoolean() {
				return true
			}
		}

		return false
	} // }}}
	canBeNumber(any = true) { // {{{
		for const type in @types {
			if type.canBeNumber(any) {
				return true
			}
		}

		return false
	} // }}}
	canBeString(any = true) { // {{{
		for const type in @types {
			if type.canBeString(any) {
				return true
			}
		}

		return false
	} // }}}
	canBeVirtual(name: String) { // {{{
		for const type in @types {
			if type.canBeVirtual(name) {
				return true
			}
		}

		return false
	} // }}}
	clone() { // {{{
		const that = new UnionType(@scope)

		that._any = @any
		that._explicit = @explicit
		that._explicitNullity = @explicitNullity
		that._nullable = @nullable
		that._types = [...@types]

		return that
	} // }}}
	export(references, mode) { // {{{
		if @explicitNullity {
			return {
				kind: TypeKind::Union
				nullable: @nullable
				types: [type.toReference(references, mode) for type in @types]
			}
		}
		else {
			return {
				kind: TypeKind::Union
				types: [type.toReference(references, mode) for type in @types]
			}
		}
	} // }}}
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
	hashCode(): String { // {{{
		const elements = [type.hashCode() for type in @types]

		return elements.join('|')
	} // }}}
	isAssignableToVariable(value, downcast) { // {{{
		if value.isAny() {
			if this.isNullable() {
				return value.isNullable()
			}
			else {
				return true
			}
		}
		else {
			for const type in @types {
				if !type.isAssignableToVariable(value, downcast) {
					return false
				}
			}

			return true
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
		if that.isAny() {
			return true
		}

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
	isReducible() => true
	isUnion() => true
	length() => @types.length
	matchContentOf(that: Type) { // {{{
		for const type in @types {
			if !type.matchContentOf(that) {
				return false
			}
		}

		return true
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
	setNullable(nullable: Boolean) { // {{{
		if @nullable == nullable {
			return this
		}
		else if nullable {
			const that = this.clone()

			that._nullable = true
			that._explicitNullity = true

			return that
		}
		else if @explicitNullity {
			const that = this.clone()

			that._nullable = false
			that._explicitNullity = false

			return that
		}
		else {
			NotImplementedException.throw()
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => [type.toQuote() for const type in @types].join('|')
	toQuote(double: Boolean): String { // {{{
		const elements = [type.toQuote() for type in @types]

		lateinit const last
		if @explicitNullity {
			last = 'Null'
		}
		else {
			last = elements.pop()
		}

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
			if i != 0 {
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