class NullType extends Type {
	static {
		Explicit = NullType.new(true)
		Unexplicit = NullType.new(false)
	}
	private {
		@explicit: Boolean	= false
	}
	constructor() { # {{{
		super(null)
	} # }}}
	constructor(@explicit) { # {{{
		super(null)
	} # }}}
	clone() { # {{{
		throw NotSupportedException.new()
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) => -value.compareToRef(this, equivalences)
	compareToRef(value: ArrayType, equivalences: String[][]? = null) => 1
	compareToRef(value: NullType, equivalences: String[][]? = null) => 0
	compareToRef(value: ObjectType, equivalences: String[][]? = null) => 1
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) => -value.compareToRef(this, equivalences)
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module)
	override getProperty(name) => AnyType.NullableUnexplicit
	hashCode() => 'Null'
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) => value.isNullable()
	isComplete() => true
	isExplicit() => @explicit
	override isExportable() => true
	override isExportable(module) => true
	override isInstanceOf(value: Type, generics, subtypes) => true
	isMorePreciseThan(value: Type) => value.isAny() || value.isNullable()
	isNull() => true
	isNullable() => true
	isSplittable() => false
	override isSubsetOf(value: Type, generics, subtypes, mode) => value.isNullable() || value.isNull()
	assist isSubsetOf(value: NullType, generics, subtypes, mode) => true
	override makeMemberCallee(property, path, generics, node) { # {{{
		if property == 'new' {
			node.addCallee(ConstructorCallee.new(node.data(), node.object(), AnyType.NullableUnexplicit, null, null, node))
		}
		else {
			node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
		}

		return null
	} # }}}
	matchContentOf(value: Type) => value.isNullable()
	setNullable(nullable: Boolean) { # {{{
		if nullable {
			return this
		}
		else {
			return AnyType.Unexplicit
		}
	} # }}}
	split(types: Array) { # {{{
		types.pushUniq(this)

		return types
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, _, _, generics, subtypes, fragments, node) { # {{{
		fragments.code(`\($runtime.type(node)).isNull`)
	} # }}}
	override toBlindTestFragments(_, varname, _, _, _, _, fragments, node) { # {{{
		fragments.code(`\($runtime.type(node)).isNull(\(varname))`)
	} # }}}
	toFragments(fragments, node)
	toQuote() => 'Null'
	override toPositiveTestFragments(_, _, _, fragments, node)
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Null'
	override toVariations(variations) { # {{{
		variations.push('null')
	} # }}}
}
