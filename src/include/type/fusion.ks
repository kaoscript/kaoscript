class FusionType extends Type {
	private {
		_nullable: Boolean			= false
		_types: Array<Type>
	}
	static {
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): FusionType { # {{{
			var fusion = new FusionType(scope)

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
		throw new NotSupportedException()
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			kind: TypeKind::Fusion
			types: [type.toExportOrReference(references, indexDelta, mode, module) for type in @types]
		}
	} # }}}
	getProperty(index: Number): Type? { # {{{
		for var type in @types {
			if var property = type.getProperty(index) {
				return property
			}
		}

		return null
	} # }}}
	getProperty(name: String): Type? { # {{{
		for var type in @types {
			if var property = type.getProperty(name) {
				return property
			}
		}

		return null
	} # }}}
	isArray() { # {{{
		if @types.length != 0 {
			return @types[0].isArray()
		}
		else {
			return false
		}
	} # }}}
	isDictionary() { # {{{
		if @types.length != 0 {
			return @types[0].isDictionary()
		}
		else {
			return false
		}
	} # }}}
	isExportable() => true
	isFusion() => true
	isNullable() => @nullable
	isSubsetOf(value: FusionType, mode: MatchingMode) { # {{{
		if @types.length != value._types.length {
			return false
		}

		var mut match = 0
		for aType in @types {
			for bType in value._types {
				if aType.isSubsetOf(bType, mode) {
					match++
					break
				}
			}
		}

		return match == @types.length
	} # }}}
	parameter() { # {{{
		for var type in @types when type.isArray() {
			return type.parameter()
		}

		return AnyType.NullableUnexplicit
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
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
		fragments.code('(') if junction == Junction::OR

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toPositiveTestFragments(fragments, node, Junction::AND)
		}

		fragments.code(')') if junction == Junction::OR
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code('(') if junction == Junction::OR

		for var type, index in @types {
			fragments.code(' && ') if index != 0

			type.toTestFunctionFragments(fragments, node, Junction::AND)
		}

		fragments.code(')') if junction == Junction::OR
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
