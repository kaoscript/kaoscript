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
	export(references, mode) => 'Any'
	flagAlien() { // {{{
		if @alien == true {
			return this
		}

		const type = new AnyType(@explicit, @nullable)

		type._alien = true

		return type
	} // }}}
	flagRequired() => this
	getProperty(name) => @nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
	hashCode() => 'Any'
	isAny() => true
	isExplicit() => @explicit
	isExportable() => true
	isInstanceOf(target: Type) => true
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return value.isAny() && !value.isNull() && @nullable == value.isNullable()
		}
		else if mode & MatchingMode::MissingType != 0 && !@explicit {
			return @nullable || !value.isNullable()
		}
		else {
			return value.isAny() && (@nullable || !value.isNullable())
		}
	} // }}}
	isMorePreciseThan(type: Type) => type.isAny() && @nullable != type.isNullable()
	isNullable() => @nullable
	matchContentOf(b) => !@explicit || (b.isAny() && (@nullable -> !b.isNullable()))
	parameter() => @nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
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
		fragments.code('Any')
	} // }}}
	toMetadata(references, mode) => -1
	toQuote(): String => @nullable ? `Any?` : `Any`
	toReference(references, mode) => 'Any'
	toTestFragments(fragments, node) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}