class AnyType extends Type {
	static {
		Explicit = AnyType.new(true, false)
		NullableExplicit = AnyType.new(true, true)
		Unexplicit = AnyType.new(false, false)
		NullableUnexplicit = AnyType.new(false, true)
	}
	private {
		@explicit: Boolean	= true
		@nullable: Boolean	= false
	}
	constructor() { # {{{
		super(null)
	} # }}}
	constructor(@explicit, @nullable) { # {{{
		this()
	} # }}}
	clone() { # {{{
		var that = AnyType.new(@explicit, @nullable)

		return that.copyFrom(this)
	} # }}}
	copyFrom(src: AnyType): valueof this { # {{{
		@alien = src._alien
		@required = src._required
	} # }}}
	compareTo(value: Type) { # {{{
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
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) { # {{{
		if @nullable == value.isNullable() {
			return 0
		}
		else if @nullable {
			return 1
		}
		else {
			return -1
		}
	} # }}}
	compareToRef(value: NullType, equivalences: String[][]? = null) => -1
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) { # {{{
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
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @toReference(references, indexDelta, mode, module)
	flagAlien() { # {{{
		if @alien {
			return this
		}

		var type = @clone()

		type._alien = true

		return type
	} # }}}
	flagRequired() { # {{{
		if @required {
			return this
		}

		var type = @clone()

		type._required = true

		return type
	} # }}}
	override getProperty(name) => AnyType.NullableUnexplicit
	hashCode(fattenNull: Boolean = false): String => if @nullable set if fattenNull set `Any|Null` else `Any?` else `Any`
	isAny() => true
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if anycast && !@explicit {
			if value.isNull() {
				return @nullable
			}
			else {
				return true
			}
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
	} # }}}
	isComplete() => true
	isExplicit() => @explicit
	override isExportable() => true
	override isExportable(module) => true
	override isInstanceOf(value, generics, subtypes) => false
	isIterable() => true
	isMorePreciseThan(value: Type) => value.isAny() && (@nullable -> value.isNullable())
	isNullable() => @nullable
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		if mode ~~ MatchingMode.Anycast && !@explicit {
			return !@nullable || value.isNullable() || mode ~~ MatchingMode.NonNullToNull
		}
		else if mode ~~ MatchingMode.Exact {
			return false unless value.isAny()

			if mode ~~ MatchingMode.NullToNonNull {
				return !@nullable || value.isNullable()
			}
			else {
				return @nullable == value.isNullable()
			}
		}
		else if mode ~~ MatchingMode.Missing && !@explicit {
			return !@nullable || value.isNullable()
		}
		else {
			return value.isAny() && (!@nullable || value.isNullable())
		}
	} # }}}
	override makeCallee(name, generics, node) { # {{{
		node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))

		return null
	} # }}}
	override makeMemberCallee(property, path, generics, node) { # {{{
		if property == 'new' {
			node.addCallee(ConstructorCallee.new(node.data(), node.object(), AnyType.NullableUnexplicit, null, null, node))
		}
		else {
			node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
		}

		return null
	} # }}}
	override makeMemberCallee(property, path, reference, generics, node) { # {{{
		return @makeMemberCallee(property, path, generics, node)
	} # }}}
	matchContentOf(value) => !@explicit || (value.isAny() && (@nullable -> value.isNullable()))
	parameter() => AnyType.NullableUnexplicit
	reference() => this
	setNullable(nullable: Boolean): Type { # {{{
		var late type

		if @nullable == nullable {
			return this
		}
		else if @explicit {
			type = if nullable set AnyType.NullableExplicit else AnyType.Explicit
		}
		else {
			type = if nullable set AnyType.NullableUnexplicit else AnyType.Unexplicit
		}

		if @alien {
			return type.flagAlien()
		}
		else {
			return type
		}
	} # }}}
	split(types: Array) { # {{{
		types.pushUniq(if @explicit set AnyType.Explicit else AnyType.Unexplicit)

		if @nullable {
			types.pushUniq(Type.Null)
		}

		return types
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, _, _, _, generics, subtypes, fragments, node) { # {{{
		if nullable || @nullable {
			fragments.code(`\($runtime.type(node)).any`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue`)
		}
	} # }}}
	override toBlindTestFragments(_, varname, _, _, _, _, fragments, node) { # {{{
		if @nullable {
			fragments.code(`\($runtime.type(node)).any(\(varname))`)
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue(\(varname))`)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		fragments.code(if @nullable set `Any?` else `Any`)
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => @toReference(references, indexDelta, mode, module)
	toQuote(): String => if @nullable set `Any?` else `Any`
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @explicit {
			return if @nullable set `Any!?` else `Any!`
		}
		else {
			return if @nullable set `Any?` else `Any`
		}
	} # }}}
	override toNegativeTestFragments(_, _, _, fragments, node) { # {{{
		if @nullable {
			fragments.code('false')
		}
		else {
			fragments.code(`\($runtime.type(node)).isNull(`).compile(node).code(`)`)
		}
	} # }}}
	override toPositiveTestFragments(_, _, _, fragments, node) { # {{{
		if @nullable {
			fragments.code('true')
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue(`).compile(node).code(`)`)
		}
	} # }}}
	override toRouteTestFragments(fragments, node, junction) => @toPositiveTestFragments(fragments, node, junction)
	override toRouteTestFragments(fragments, node, argName, from, to, default, junction) { # {{{
		fragments.code(`\($runtime.type(node)).isVarargs(\(argName), \(from), \(to), \(default), `)

		var literal = Literal.new(false, node, node.scope(), 'value')

		if @nullable {
			if node._options.format.functions == 'es5' {
				fragments.code(`function() { return true; }`)
			}
			else {
				fragments.code(`() => true`)
			}
		}
		else {
			fragments.code(`\($runtime.type(node)).isValue`)
		}

		fragments.code(')')
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('any', @explicit, @nullable)
	} # }}}
}
