class FusionType extends Type {
	private {
		_nullable: Boolean			= false
		_types: Array<Type>
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			return new FusionType(scope, [Type.fromMetadata(type, metadata, references, alterations, queue, scope, node) for const type in data.types])
		} // }}}
	}
	constructor(@scope, @types = []) { // {{{
		super(scope)

		for const type in @types {
			if type.isNullable() {
				@nullable = true

				break
			}
		}
	} // }}}
	addType(type: Type) { // {{{
		@types.push(type)

		if type.isNullable() {
			@nullable = true
		}
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	export(references, mode) { // {{{
		return {
			kind: TypeKind::Fusion
			types: [type.toReference(references, mode) for type in @types]
		}
	} // }}}
	getProperty(name: String): Type? { // {{{
		for const type in @types {
			if const property = type.getProperty(name) {
				return property
			}
		}

		return null
	} // }}}
	isArray() { // {{{
		if @types.length != 0 {
			return @types[0].isArray()
		}
		else {
			return false
		}
	} // }}}
	isDictionary() { // {{{
		if @types.length != 0 {
			return @types[0].isDictionary()
		}
		else {
			return false
		}
	} // }}}
	isExportable() => true
	isFusion() => true
	isMatching(value: FusionType, mode: MatchingMode) { // {{{
		if @types.length != value._types.length {
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
	isNullable() => @nullable
	parameter() { // {{{
		for const type in @types when type.isArray() {
			return type.parameter()
		}

		return AnyType.NullableUnexplicit
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toNegativeTestFragments(fragments, node) { // {{{
		fragments.code('(')

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toNegativeTestFragments(fragments, node)
		}

		fragments.code(')')
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		fragments.code('(')

		for type, i in @types {
			if i != 0 {
				fragments.code(' && ')
			}

			type.toPositiveTestFragments(fragments, node)
		}

		fragments.code(')')
	} // }}}
	type() { // {{{
		if @types.length == 1 {
			const type = @types[0]

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
	} // }}}
}