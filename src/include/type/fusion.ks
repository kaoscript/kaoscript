class FusionType extends Type {
	private {
		_array: Boolean			= false
		_nullable: Boolean		= false
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
			if type.isArray() {
				@array = true
			}
			if type.isNullable() {
				@nullable = true
			}
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
	isArray() => @array
	isExportable() => true
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
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	type() { // {{{
		if @types.length == 1 {
			return @types[0]
		}
		else {
			return this
		}
	} // }}}
}