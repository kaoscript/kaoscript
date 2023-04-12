class FusionType extends Type {
	private {
		@nullable: Boolean			= false
		@types: Array<Type>
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): FusionType { # {{{
			var fusion = FusionType.new(scope)

			queue.push(() => {
				for var type in data.types {
					fusion.addType(Type.import(type, metadata, references, alterations, queue, scope, node))
				}
			})

			return fusion
		} # }}}
	}
	constructor(@scope, @types = []) { # {{{
		super(scope)

		for var type in @types {
			if type.isNullable() {
				@nullable = true
			}
		}
	} # }}}
	addType(type: Type) { # {{{
		@types.push(type)

		if type.isNullable() {
			@nullable = true
		}
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind.Fusion
			types: [type.toExportOrReference(references, indexDelta, mode, module) for type in @types]
		}
	} # }}}
	getProperty(index: Number): Type? { # {{{
		for var type in @types {
			if var property ?= type.getProperty(index) {
				return property
			}
		}

		return null
	} # }}}
	getProperty(name: String): Type? { # {{{
		var mut undecided = false

		for var type in @types {
			if var property ?= type.getProperty(name) {
				if property == Type.Undecided {
					undecided = true
				}
				else {
					return property
				}
			}
		}

		if undecided {
			return AnyType.NullableUnexplicit
		}

		return null
	} # }}}
	hashCode(fattenNull: Boolean = false): String { # {{{
		var types = [type for var type in @types when !type.isObject()]

		if types.length == 1 {
			return types[0].hashCode(fattenNull)
		}

		throw NotImplementedException.new()
	} # }}}
	hasMutableAccess() { # {{{
		for var type in @types {
			if type.hasMutableAccess() {
				return true
			}
		}

		return false
	} # }}}
	isArray() { # {{{
		for var type in @types {
			if type.isArray() {
				return true
			}
		}

		return false
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}

		if @isNullable() && !nullcast && !value.isNullable() {
			return false
		}

		return @isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast)
	} # }}}
	isComplete() => true
	isExportable() => true
	isFusion() => true
	isNullable() => @nullable
	isObject() { # {{{
		for var type in @types {
			if type.isObject() {
				return true
			}
		}

		return false
	} # }}}
	isSubsetOf(value: FusionType, mode: MatchingMode) { # {{{
		if @types.length != value._types.length {
			return false
		}

		var mut match = 0
		for var aType in @types {
			for var bType in value._types {
				if aType.isSubsetOf(bType, mode) {
					match += 1
					break
				}
			}
		}

		return match == @types.length
	} # }}}
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		for var type in @types {
			if type.isSubsetOf(value, mode) {
				return true
			}
		}

		return false
	} # }}}
	parameter() { # {{{
		for var type in @types when type.isArray() {
			return type.parameter()
		}

		return AnyType.NullableUnexplicit
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction.OR

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toNegativeTestFragments(fragments, node, Junction.AND)
		}

		fragments.code(')') if junction == Junction.OR
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction.OR

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toPositiveTestFragments(fragments, node, Junction.AND)
		}

		fragments.code(')') if junction == Junction.OR
	} # }}}
	toQuote() => @hashCode()
	toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction.OR

		for var type, index in @types {
			fragments.code(' && ') if index != 0

			type.toTestFunctionFragments(fragments, node, Junction.AND)
		}

		fragments.code(')') if junction == Junction.OR
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('fusion', @nullable)

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
		else {
			return this
		}
	} # }}}
}
