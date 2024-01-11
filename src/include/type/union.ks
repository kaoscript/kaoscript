class UnionType extends Type {
	private {
		@any: Boolean				= false
		@assessment					= null
		@explicit: Boolean
		@explicitNullity: Boolean	= false
		@never: Boolean				= false
		@nullable: Boolean			= false
		@types: Array<Type>			= []
		@void: Boolean				= true
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): UnionType { # {{{
			var type = UnionType.new(scope)

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
			@addType(type)
		}
	} # }}}
	addType(mut type: Type) { # {{{
		if @void {
			@void = false

			if type.isNever() {
				@never = true

				return this
			}
		}

		if @never {
			if type.isNever() {
				return this
			}
			else {
				@never = false
			}
		}

		if @any {
			if !@nullable && type.isNullable() {
				@nullable = true
				@types = [@types[0].setNullable(false), Type.Null]
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
			@any = true

			if @nullable || type.isNullable() {
				@nullable = true
				@types = [type.setNullable(false), Type.Null]
			}
			else {
				@types = [type]
			}
		}
		else if type.isUnion() {
			for var type in type.discard().types() {
				@addType(type)
			}
		}
		else if type.isNever() {
			pass
		}
		else if type.isNullable() {
			type = type.setNullable(false)

			var mut notMatched = true

			if type.isComplete() {
				for var t, i in @types while notMatched {
					if type.isAssignableToVariable(t, false, false, false) {
						notMatched = false

						if t.isStrict() != type.isStrict() {
							@types[i] = t.unflagStrict()
						}
					}
					else if type.isSameVariance(t) && type.hasSameParameters(t) {
						notMatched = false

						@types[i] = t.mergeSubtypes(type)
					}
				}
			}
			else {
				for var t in @types while notMatched {
					notMatched = t != type
				}
			}

			if notMatched {
				@types.push(type)
			}

			if !@nullable {
				@types.push(Type.Null)

				@nullable = true
				@explicitNullity = true
			}
		}
		else {
			var mut notMatched = true

			if type.isComplete() {
				for var t, i in @types while notMatched {
					if type.isAssignableToVariable(t, false, false, false) {
						notMatched = false

						if t.isStrict() != type.isStrict() {
							@types[i] = t.unflagStrict()
						}
					}
					else if type.isSameVariance(t) && type.hasSameParameters(t) {
						notMatched = false

						@types[i] = t.mergeSubtypes(type)
					}
				}
			}
			else {
				for var t in @types while notMatched {
					notMatched = t != type
				}
			}

			if notMatched {
				@types.push(type)
			}
		}

		return this
	} # }}}
	assessment(name: String, node: AbstractNode) { # {{{
		@assessment ??= Router.assess(@types, name, node)

		return @assessment
	} # }}}
	canBeArray(any = true) { # {{{
		for var type in @types {
			if type.canBeArray(any) {
				return true
			}
		}

		return false
	} # }}}
	canBeBoolean() { # {{{
		for var type in @types {
			if type.canBeBoolean() {
				return true
			}
		}

		return false
	} # }}}
	canBeEnum(any = true) { # {{{
		for var type in @types {
			if type.canBeEnum(any) {
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
	canBeObject(any = true) { # {{{
		for var type in @types {
			if type.canBeObject(any) {
				return true
			}
		}

		return false
	} # }}}
	override canBeRawCasted() { # {{{
		for var property in @types {
			if property.canBeRawCasted() {
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
		var that = UnionType.new(@scope)

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
	compareToRef(value: NullType, equivalences: String[][]? = null) { # {{{
		return -1
	} # }}}
	compareToRef(value: ObjectType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	compareToRef(value: UnionType, equivalences: String[][]? = null) { # {{{
		return 1
	} # }}}
	override discardValue() { # {{{
		var types = [type.discardValue() for var type in @types]

		return Type.union(@scope, ...types)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Union
			nullable: true if @explicitNullity
			types: [type.toReference(references, indexDelta, mode, module) for var type in @types]
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for var type in @types {
			type.flagExported(explicitly).flagReferenced()
		}

		return this
	} # }}}
	override flagIndirectlyReferenced()
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
		var elements = [type.hashCode() for var type in @types]

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
			if @isNullable() {
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
	isAsync() { # {{{
		for var type in @types {
			if !type.isAsync() {
				return false
			}
		}

		return true
	} # }}}
	isBitmask() { # {{{
		for var type in @types {
			if !type.isBitmask() {
				return false
			}
		}

		return true
	} # }}}
	isComplete() { # {{{
		for var type in @types {
			return false unless type.isComplete()
		}

		return true
	} # }}}
	isEnum() { # {{{
		for var type in @types {
			if !type.isEnum() {
				return false
			}
		}

		return true
	} # }}}
	isExplicit() => @explicit
	isExportable() { # {{{
		for var type in @types {
			if !type.isExportable() {
				return false
			}
		}

		return true
	} # }}}
	isFunction() { # {{{
		for var type in @types {
			if !type.isFunction() {
				return false
			}
		}

		return true
	} # }}}
	isInstanceOf(target) { # {{{
		for var type in @types {
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

			var mut count = 0

			for var type in @types {
				if type.isMorePreciseThan(value) {
					count += 1
				}
				else {
					break
				}
			}

			if count == @types.length {
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
	isObject() { # {{{
		for var type in @types {
			if !type.isObject() {
				return false
			}
		}

		return true
	} # }}}
	isReducible() => true
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
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
	isVariant() { # {{{
		for var type in @types {
			return false unless type.isVariant()
		}

		return true
	} # }}}
	length() => @types.length
	override limitTo(value) { # {{{
		var matches = []
		var variant = value.isVariant()

		for var type in @types {
			if type.isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				matches.push(type)
			}
			else if variant && type.isVariant() && value.isSubsetOf(type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				var result = type.tryCastingTo(value)

				if type != result {
					matches.push(result)
				}
			}
		}


		if matches.length == 0 {
			return value
		}
		else if matches.length == 1 {
			return matches[0]
		}
		else if matches.length == @types.length {
			return this
		}
		else {
			return Type.union(@scope, ...matches)
		}
	} # }}}
	override makeMemberCallee(property, generics, node) { # {{{
		for var type in @types {
			type.makeMemberCallee(property, generics, node)
		}
	} # }}}
	override makeMemberCallee(property, reference, generics, node) { # {{{
		for var type in @types {
			type.makeMemberCallee(property, generics, node)
		}
	} # }}}
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
	setNullable(nullable: Boolean) { # {{{
		if @nullable == nullable {
			return this
		}
		else if nullable {
			return @clone().addType(Type.Null)
		}
		else if @explicitNullity {
			var that = @clone()

			that._types:!(Array).remove(Type.Null)
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
	toAssertFunctionFragments(value, nullable, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).assert(`).compile(value).code(`, \($quote(@toQuote(true))), \(nullable ? '1' : '0'), `)

		@toAwareTestFunctionFragments('value', false, false, false, null, null, fragments, node)

		fragments.code(')')
	} # }}}
	override toAwareTestFunctionFragments(varname, mut nullable, casting, blind, generics, subtypes, fragments, node) { # {{{
		fragments.code(`\(varname) => `)

		for var type, index in @types {
			fragments.code(' || ') if index != 0

			type.toBlindTestFragments(null, varname, casting, null, subtypes, Junction.OR, fragments, node)
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, casting, propname, mut nullable, generics, fragments, node) { # {{{
		fragments.code(`\(varname) => `)

		for var type, index in @types {
			fragments.code(' || ') if index != 0

			type.toBlindTestFragments(funcname, varname, casting, generics, null, Junction.OR, fragments, node)
		}
	} # }}}
	override toBlindTestFragments(funcname, varname, casting, generics, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .AND

		var literal = Literal.new(false, node, node.scope(), varname)

		for var type, index in @types {
			fragments.code(' || ') if index != 0

			type.toBlindTestFragments(funcname, varname, casting, generics, subtypes, Junction.OR, fragments, literal)
		}

		fragments.code(')') if junction == .AND
	} # }}}
	toCastFunctionFragments(value, nullable, fragments, node) { # {{{
		var mut asserts = []
		var mut casts = []

		for var type in @types {
			if type.isObject() {
				asserts.push(type)
			}
			else {
				casts.push(type)
			}
		}

		if !?#casts {
			fragments.code(`\($runtime.helper(node)).assert(`).compile(value).code(`, \($quote(@toQuote(true))), \(nullable ? '1' : '0'), `)

			@toAwareTestFunctionFragments('value', false, true, false, null, null, fragments, node)

			fragments.code(')')
		}
		else {
			fragments.code(`\($runtime.helper(node)).cast(`).compile(value).code(`, \($quote(@toQuote(true))), \(nullable ? '1' : '0'), value =>`)

			var block = fragments.newBlock()

			if ?#asserts {
				var ctrl = block.newControl().code('if(')

				for var type, index in asserts {
					ctrl.code(' || ') if index != 0

					type.toBlindTestFragments(null, 'value', false, null, null, Junction.OR, ctrl, node)
				}

				ctrl
					.code(')').step()
					.line('return value')
					.done()
			}

			if casts.length == 1 {
				var line = block.newLine().code('return ')

				casts[0].toCastFragments('value', line, node)

				line.done()
			}
			else {
				block.line('let __ks_0')

				var ctrl = block.newControl().code('if(')

				for var type, index in casts {
					ctrl
						.code(' || ') if index != 0
						.code('(__ks_0 = ')

					type.toCastFragments('value', ctrl, node)

					ctrl.code(') !== null')
				}

				ctrl
					.code(')').step()
					.line('return __ks_0')
					.done()

				block.line('return null')
			}

			block.done()

			fragments.code(')')
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	toQuote() { # {{{
		if @nullable && @types.length == 2 {
			if @types[0] == Type.Null {
				return `\(@types[1].toQuote())?`
			}
			if @types[1] == Type.Null {
				return `\(@types[0].toQuote())?`
			}
		}

		return [type.toQuote() for var type in @types].join('|')
	} # }}}
	toQuote(double: Boolean): String { # {{{
		var quote = double ? `"` : `'`

		if @nullable && @types.length == 2 {
			if @types[0] == Type.Null {
				return `\(quote)\(@types[1].toQuote())?\(quote)`
			}
			if @types[1] == Type.Null {
				return `\(quote)\(@types[0].toQuote())?\(quote)`
			}
		}

		var elements = [type.toQuote() for var type in @types]
		var last = elements.pop()

		return `\(quote)\(elements.join(`\(quote), \(quote)`))\(quote) or \(quote)\(last)\(quote)`
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @export(references, indexDelta, mode, module)
	override toNegativeTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .OR

		for var type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toNegativeTestFragments(parameters, subtypes, Junction.AND, fragments, node)
		}

		fragments.code(')') if junction == .OR
	} # }}}
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code('(') if junction == .AND

		for var type, i in @types {
			if i != 0 {
				fragments.code(' || ')
			}

			type.toPositiveTestFragments(parameters, subtypes, Junction.OR, fragments, node)
		}

		fragments.code(')') if junction == .AND
	} # }}}
	override toRouteTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction.AND

		for var type, i in @types {
			if i != 0 {
				fragments.code(' || ')
			}

			type.toRouteTestFragments(fragments, node, Junction.OR)
		}

		fragments.code(')') if junction == Junction.AND
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
	trimOff(type: Type) { # {{{
		var types = [t for var t in @types when !t.isAssignableToVariable(type, false, false, false)]

		if types.length == 1 {
			return types[0]
		}
		else {
			return Type.union(@scope, ...types)
		}
	} # }}}
	type() { # {{{
		if @void {
			return Type.Void
		}
		if @never {
			return Type.Never
		}
		if @types.length == 1 {
			return @types[0]
		}
		if @types.length == 2 {
			if @types[0] is ValueType && @types[0].type().isBoolean() && @types[1] is ValueType && @types[1].type().isBoolean() {
				if (@types[0].value() == 'true' && @types[1].value() == 'false') || (@types[1].value() == 'true' && @types[0].value() == 'false') {
					return @scope.reference('Boolean')
				}
			}

			if @nullable {
				if @types[0] == Type.Null {
					return @types[1].setNullable(true)
				}
				if @types[1] == Type.Null {
					return @types[0].setNullable(true)
				}
			}
		}

		return this
	} # }}}
	types() => @types
}
