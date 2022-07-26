class UnionType extends Type {
	private {
		_any: Boolean				= false
		_explicit: Boolean
		_explicitNullity: Boolean	= false
		_nullable: Boolean			= false
		_types: Array<Type>			= []
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): UnionType { # {{{
			const type = new UnionType(scope)

			if data.nullable? {
				type._nullable = data.nullable
				type._explicitNullity = true
			}

			queue.push(() => {
				for const item in data.types {
					type.addType(Type.import(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	constructor(@scope, types: Array = [], @explicit = true) { # {{{
		super(scope)

		for const type in types {
			if type.isNull() {
				if !@nullable {
					@types.push(Type.Null)

					@nullable = true
				}

				@explicitNullity = true
			}
			else if @any {
				if type.isNullable() {
					@nullable = true
				}
			}
			else if type.isAny() {
				@types = [type]

				@any = true

				if type.isNullable() {
					@nullable = true
				}
			}
			else {
				@types.push(type)

				if type.isNullable() {
					@nullable = true
				}
			}
		}
	} # }}}
	addType(type: Type) { # {{{
		if @any {
			if !@nullable && type.isNullable() {
				@types[0] = AnyType.NullableUnexplicit

				@nullable = true
			}
		}
		else if type.isNull() {
			if !@nullable {
				@types.push(Type.Null)

				@nullable = true
			}
			@explicitNullity = true
		}
		else if type.isAny() {
			@types = [type]

			@any = true

			if type.isNullable() {
				@nullable = true
			}
		}
		else if type.isUnion() {
			for const type in type.discard().types() {
				this.addType(type)
			}
		}
		else {
			auto notMatched = true

			if type.isNullable() {
				for const t, i in @types while notMatched {
					if t.matchContentOf(type) {
						notMatched = false

						if !t.equals(type) {
							@types[i] = type

							@nullable = true
						}
					}
				}

				if notMatched {
					@types.push(type)

					@nullable = true
				}
			}
			else {
				for const t, i in @types while notMatched {
					if type.matchContentOf(t) {
						notMatched = false

						if !t.equals(type) {
							@types[i] = type
						}
					}
				}

				if notMatched {
					@types.push(type)
				}
			}
		}

		return this
	} # }}}
	canBeBoolean() { # {{{
		for const type in @types {
			if type.canBeBoolean() {
				return true
			}
		}

		return false
	} # }}}
	canBeFunction(any = true) { # {{{
		for const type in @types {
			if type.canBeFunction(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeNumber(any = true) { # {{{
		for const type in @types {
			if type.canBeNumber(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeString(any = true) { # {{{
		for const type in @types {
			if type.canBeString(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeVirtual(name: String) { # {{{
		for const type in @types {
			if type.canBeVirtual(name) {
				return true
			}
		}

		return false
	} # }}}
	clone() { # {{{
		const that = new UnionType(@scope)

		that._any = @any
		that._explicit = @explicit
		that._explicitNullity = @explicitNullity
		that._nullable = @nullable
		that._types = [...@types]

		return that
	} # }}}
	compareToRef(value: AnyType) { # {{{
		return -1
	} # }}}
	compareToRef(value: NullType) { # {{{
		return -1
	} # }}}
	compareToRef(value: ReferenceType) { # {{{
		return 1
	} # }}}
	compareToRef(value: UnionType) { # {{{
		return 1
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @explicitNullity {
			return {
				kind: TypeKind::Union
				nullable: @nullable
				types: [type.toReference(references, indexDelta, mode, module) for type in @types]
			}
		}
		else {
			return {
				kind: TypeKind::Union
				types: [type.toReference(references, indexDelta, mode, module) for type in @types]
			}
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
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
	} # }}}
	getProperty(name: String) { # {{{
		const types = []

		for const type in @types {
			let property = type.getProperty(name) ?? Type.Any

			if property is StructFieldType {
				property = property.discardVariable()
			}

			if !types.some((t, _, _) => property.matchContentOf(t)) {
				types.push(property)
			}
		}

		if types.length == 1 {
			return types[0]
		}
		else {
			return Type.union(@scope, ...types)
		}
	} # }}}
	hashCode(): String { # {{{
		const elements = [type.hashCode() for type in @types]

		return elements.join('|')
	} # }}}
	isArray() { # {{{
		for const type in @types {
			if !type.isArray() {
				return false
			}
		}

		return true
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if this.isNullable() {
				return nullcast || limited || value.isNullable()
			}
			else {
				return true
			}
		}
		else if limited {
			for const type in @types {
				if type.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return true
				}
			}

			return false
		}
		else {
			for const type in @types {
				if !type.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return false
				}
			}

			return true
		}
	} # }}}
	isDictionary() { # {{{
		for const type in @types {
			if !type.isDictionary() {
				return false
			}
		}

		return true
	} # }}}
	isExplicit() => @explicit
	isExportable() { # {{{
		for type in @types {
			if !type.isExportable() {
				return false
			}
		}

		return true
	} # }}}
	isInstanceOf(target) { # {{{
		for type in @types {
			if type.isInstanceOf(target) {
				return true
			}
		}

		return false
	} # }}}
	isMatchingParameter(value) { # {{{
		for const type in @types {
			if type.isMatchingParameter(value) {
				return true
			}
		}

		return false
	} # }}}
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return true
		}

		if value is ReferenceType {
			if !@nullable && value.isNullable() {
				return true
			}

			value = value.discardAlias()
		}

		if value is UnionType {
			if !@nullable && value.isNullable() {
				return true
			}

			return @types.length < value.types().length
		}

		return false
	} # }}}
	isNullable() => @nullable
	isReducible() => true
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			if value is not UnionType || @types.length != value.length() {
				return false
			}

			let match = 0
			for const aType in @types {
				for const bType in value.types() {
					if aType.isSubsetOf(bType, mode) {
						match++
						break
					}
				}
			}

			return match == @types.length
		}
		else {
			for const type in @types {
				if !type.isSubsetOf(value, mode) {
					return false
				}
			}

			return true
		}
	} # }}}
	isUnion() => true
	length() => @types.length
	matchContentOf(value: Type) { # {{{
		for const type in @types {
			if !type.matchContentOf(value) {
				return false
			}
		}

		return true
	} # }}}
	parameter() { # {{{
		const types = [type.parameter() for const type in @types]

		return Type.union(@scope, ...types)
	} # }}}
	reduce(type: Type) { # {{{
		const types = [t for const t in @types when !t.matchContentOf(type)]

		if types.length == 1 {
			return types[0]
		}
		else {
			return Type.union(@scope, ...types)
		}
	} # }}}
	setNullable(nullable: Boolean) { # {{{
		if @nullable == nullable {
			return this
		}
		else if nullable {
			return this.clone().addType(Type.Null)
		}
		else if @explicitNullity {
			const that = this.clone()

			that._types:Array.remove(Type.Null)
			that._nullable = false
			that._explicitNullity = false

			return that
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	sort(): UnionType { # {{{
		@types.sort((a, b) => {
			const index = a.compareToRef(b)
			if index == 0 {
				return a.hashCode().localeCompare(b.hashCode())
			}
			else {
				return index
			}
		})
		return this
	} # }}}
	split(types: Array) { # {{{
		for const type in @types {
			type.split(types)
		}

		return types
	} # }}}
	toCastFragments(fragments) { # {{{
		for const type in @types {
			type.toCastFragments(fragments)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	toQuote() => [type.toQuote() for const type in @types].join('|')
	toQuote(double: Boolean): String { # {{{
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
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => this.export(references, indexDelta, mode, module)
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::OR

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toNegativeTestFragments(fragments, node, Junction::AND)
		}

		fragments.code(')') if junction == Junction::OR
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::AND

		for type, i in @types {
			if i != 0 {
				fragments.code(' || ')
			}

			type.toPositiveTestFragments(fragments, node, Junction::OR)
		}

		fragments.code(')') if junction == Junction::AND
	} # }}}
	override toRouteTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::AND

		for type, i in @types {
			if i != 0 {
				fragments.code(' || ')
			}

			type.toRouteTestFragments(fragments, node, Junction::OR)
		}

		fragments.code(')') if junction == Junction::AND
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::AND

		for const type, index in @types {
			fragments.code(' || ') if index != 0

			type.toTestFunctionFragments(fragments, node, Junction::OR)
		}

		fragments.code(')') if junction == Junction::AND
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('union')

		for const type in @types {
			type.toVariations(variations)
		}
	} # }}}
	type() { # {{{
		if @types.length == 1 {
			const type = @types[0]

			if @nullable == type.isNullable() {
				return type
			}
			else {
				return type.setNullable(@nullable)
			}
		}

		return this
	} # }}}
	types() => @types
}
