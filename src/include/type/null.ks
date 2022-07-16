class NullType extends Type {
	static {
		Explicit = new NullType(true)
		Unexplicit = new NullType(false)
	}
	private {
		_explicit: Boolean	= false
	}
	constructor() { // {{{
		super(null)
	} // }}}
	constructor(@explicit) { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	compareToRef(value: AnyType) => -value.compareToRef(this)
	compareToRef(value: NullType) => 0
	compareToRef(value: ReferenceType) => -value.compareToRef(this)
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module)
	getProperty(name) => AnyType.NullableUnexplicit
	hashCode() => 'Null'
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) => nullcast || value.isNullable()
	isExplicit() => @explicit
	isExportable() => true
	isInstanceOf(target: Type) => true
	isMorePreciseThan(value: Type) => value.isAny() || value.isNullable()
	isNull() => true
	isNullable() => true
	isSplittable() => false
	isSubsetOf(value: NullType, mode: MatchingMode) => true
	isSubsetOf(value: Type, mode: MatchingMode) => value.isNullable()
	matchContentOf(value: Type) => value.isNullable()
	setNullable(nullable: Boolean) { // {{{
		if nullable {
			return this
		}
		else {
			return AnyType.Unexplicit
		}
	} // }}}
	split(types: Array) { // {{{
		types.pushUniq(this)

		return types
	} // }}}
	toFragments(fragments, node)
	toQuote() => 'Null'
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => 'Null'
	override toPositiveTestFragments(fragments, node, junction)
	override toTestFunctionFragments(fragments, node) { // {{{
		fragments.code(`\($runtime.type(node)).isNull`)
	} // }}}
	override toTestFunctionFragments(fragments, node, junction) { // {{{
		fragments.code(`\($runtime.type(node)).isNull(value)`)
	} // }}}
	override toVariations(variations) { // {{{
		variations.push('null')
	} // }}}
}
