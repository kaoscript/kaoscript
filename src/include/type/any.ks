class AnyType extends Type {
	static {
		Explicit = new AnyType(true, false)
		NullableExplicit = new AnyType(true, true)
		Unexplicit = new AnyType(false, false)
		NullableUnexplicit = new AnyType(false, true)
	}
	private {
		_explicit: Boolean	= true
		_nullable: Boolean	= false
	}
	constructor() { // {{{
		super(null)
	} // }}}
	constructor(@explicit, @nullable) { // {{{
		super(null)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	compareTo(value: Type) { // {{{
		if value.isAny() {
			if @nullable == value.isNullable() {
				return 0
			}
			else if @nullable {
				return 1
			}
			else {
				return -1
			}
		}
		else {
			return 1
		}
	} // }}}
	export(references, mode) => this.toReference(references, mode)
	flagAlien() { // {{{
		if @alien == true {
			return this
		}

		const type = new AnyType(@explicit, @nullable)

		type._alien = true

		return type
	} // }}}
	flagRequired() => this
	getProperty(name) => AnyType.NullableUnexplicit
	hashCode() => @nullable ? `Any?` : `Any`
	isAny() => true
	isAssignableToVariable(value, anycast, nullcast, downcast) { // {{{
		if anycast && !@explicit {
			return true
		}
		else if value.isAny() {
			if @nullable {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else {
			return false
		}
	} // }}}
	isExplicit() => @explicit
	isExportable() => true
	isInstanceOf(target: Type) => true
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Exact {
			return value.isAny() && !value.isNull() && @nullable == value.isNullable()
		}
		else if mode ~~ MatchingMode::MissingType && !@explicit {
			return @nullable || !value.isNullable()
		}
		else {
			return value.isAny() && (@nullable || !value.isNullable())
		}
	} // }}}
	isMorePreciseThan(type: Type) => type.isAny() && @nullable != type.isNullable()
	isNullable() => @nullable
	matchContentOf(b) => !@explicit || (b.isAny() && (@nullable -> b.isNullable()))
	parameter() => AnyType.NullableUnexplicit
	reference() => this
	setNullable(nullable: Boolean): Type { // {{{
		let type

		if @nullable == nullable {
			return this
		}
		else if @explicit {
			type = nullable ? AnyType.NullableExplicit : AnyType.Explicit
		}
		else {
			type = nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
		}

		if @alien {
			return type.flagAlien()
		}
		else {
			return type
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		fragments.code(@nullable ? `Any?` : `Any`)
	} // }}}
	toMetadata(references, mode) => this.toReference(references, mode)
	toQuote(): String => @nullable ? `Any?` : `Any`
	toReference(references, mode) { // {{{
		if @explicit {
			return @nullable ? `Any!?` : `Any!`
		}
		else {
			return @nullable ? `Any?` : `Any`
		}
	} // }}}
	override toNegativeTestFragments(fragments, node, junction) { // {{{
		if @nullable {
			fragments.code('false')
		}
		else {
			fragments.code(`!\($runtime.type(node)).isValue(`).compile(node).code(`)`)
		}
	} // }}}
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		if @nullable {
			fragments.code('true')
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue(`).compile(node).code(`)`)
		}
	} // }}}
}