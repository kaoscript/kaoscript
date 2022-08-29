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
			var type = new UnionType(scope)

			if ?data.nullable {
				type._nullable = data.nullable
				type._explicitNullity = true
			}

			queue.push(() => {
				for var item in data.types {
					type.addType(Type.import(item, metadata, references, alterations, queue, scope, node))
				}
			})

			return type
		} # }}}
	}
	constructor(@scope, types: Array = [], @explicit = true) { # {{{
		super(scope)

		for var type in types {
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
			for var type in type.discard().types() {
				this.addType(type)
			}
		}
		else {
			var mut notMatched = true

			if type.isNullable() {
				for var t, i in @types while notMatched {
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
				for var t, i in @types while notMatched {
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
		for var type in @types {
			if type.canBeBoolean() {
				return true
			}
		}

		return false
	} # }}}
	canBeFunction(any = true) { # {{{
		for var type in @types {
			if type.canBeFunction(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeNumber(any = true) { # {{{
		for var type in @types {
			if type.canBeNumber(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeString(any = true) { # {{{
		for var type in @types {
			if type.canBeString(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeVirtual(name: String) { # {{{
		for var type in @types {
			if type.canBeVirtual(name) {
				return true
			}
		}

		return false
	} # }}}
	clone() { # {{{
		var that = new UnionType(@scope)

		that._any = @any
		that._explicit = @explicit
		that._explicitNullity = @explicitNullity
		that._nullable = @nullable
		that._types = [...@types]

		return that
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) { # {{{
		return -1
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	compareToRef(value: DictionaryType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	compareToRef(value: NullType, equivalences: String[][]? = null) { # {{{
		return -1
	} # }}}
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	compareToRef(value: UnionType, equivalences: String[][]? = null) { # {{{
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
	getProperty(index: Number) { # {{{
		var types = []

		for var type in @types {
			var mut property = type.getProperty(index) ?? Type.Any

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
	getProperty(name: String) { # {{{
		var types = []

		for var type in @types {
			var mut property = type.getProperty(name) ?? Type.Any

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
		var elements = [type.hashCode() for type in @types]

		return elements.join('|')
	} # }}}
	isArray() { # {{{
		for var type in @types {
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
			for var type in @types {
				if type.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return true
				}
			}

			return false
		}
		else {
			for var type in @types {
				if !type.isAssignableToVariable(value, anycast, nullcast, downcast) {
					return false
				}
			}

			return true
		}
	} # }}}
	isDictionary() { # {{{
		for var type in @types {
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
		for var type in @types {
			if type.isMatchingParameter(value) {
				return true
			}
		}

		return false
	} # }}}
	isMorePreciseThan(mut value: Type) { # {{{
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

			var mut match = 0
			for var aType in @types {
				for var bType in value.types() {
					if aType.isSubsetOf(bType, mode) {
						match += 1
						break
					}
				}
			}

			return match == @types.length
		}
		else {
			for var type in @types {
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
		for var type in @types {
			if !type.matchContentOf(value) {
				return false
			}
		}

		return true
	} # }}}
	parameter() { # {{{
		var types = [type.parameter() for var type in @types]

		return Type.union(@scope, ...types)
	} # }}}
	reduce(type: Type) { # {{{
		var types = [t for var t in @types when !t.matchContentOf(type)]

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
			var that = this.clone()

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
			var index = a.compareToRef(b)

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
		for var type in @types {
			type.split(types)
		}

		return types
	} # }}}
	toCastFragments(fragments) { # {{{
		for var type in @types {
			type.toCastFragments(fragments)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	toQuote() => [type.toQuote() for var type in @types].join('|')
	toQuote(double: Boolean): String { # {{{
		var elements = [type.toQuote() for type in @types]

		var last = elements.pop()

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

		for var type, index in @types {
			fragments.code(' || ') if index != 0

			type.toTestFunctionFragments(fragments, node, Junction::OR)
		}

		fragments.code(')') if junction == Junction::AND
	} # }}}
	override toTestType() { # {{{
		var types = []

		for var t1 in @types {
			if t1.isInstance() {
				var mut add = true

				for var t2 in @types while add when t2 != t1 {
					if t1.isInheriting(t2) {
						add = false
					}
				}

				if add {
					types.push(t1)
				}
			}
			else {
				types.push(t1)
			}
		}

		if types.length == 1 {
			var type = @types[0]

			if @nullable == type.isNullable() {
				return type
			}
			else {
				return type.setNullable(@nullable)
			}
		}
		else if types.length != @types.length {
			var clone = @clone()

			clone._types = types

			return clone
		}

		return this
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('union')

		for var type in @types {
			type.toVariations(variations)
		}
	} # }}}
	type() { # {{{
		if @types.length == 1 {
			var type = @types[0]

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
