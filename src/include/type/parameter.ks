bitmask PassingMode {
	NIL

	LABELED
	POSITIONAL

	BOTH = LABELED + POSITIONAL
}

class ParameterType extends Type {
	private late {
		@index: Number
	}
	private {
		@anonymous: Boolean					= false
		@comprehensive: Boolean				= true
		@default: Boolean
		@defaultValue: Any?
		@externalName: String?				= null
		@internalName: String?				= null
		@min: Number
		@max: Number
		@nullableByDefault: Boolean
		@passing: PassingMode
		@retained: Boolean					= false
		@type: Type
		@variableType: Type
	}
	static {
		fromAST(data, node: AbstractNode): ParameterType => ParameterType.fromAST(data, false, node.scope(), true, null, node)
		fromAST(data, overridable: Boolean, scope: Scope, defined: Boolean, generics: Generic[]?, node: AbstractNode): ParameterType { # {{{
			// TODO remove type
			var mut type: Type = ?data.type ? Type.fromAST(data.type, scope, defined, generics, node) : AnyType.Unexplicit

			var mut default = false
			var mut min = 1
			var mut max = 1
			var mut nullable = false

			if ?data.defaultValue {
				default = true
				min = 0
			}

			for var modifier in data.modifiers {
				match ModifierKind(modifier.kind) {
					ModifierKind.Nullable {
						type = type.setNullable(true)
					}
					ModifierKind.Rest {
						if modifier.arity {
							min = modifier.arity.min
							max = modifier.arity.max
						}
						else {
							min = 0
							max = Infinity
						}
					}
				}
			}

			var externalName = data.external?.name
			var internalName = data.internal?.name

			if !?internalName && min == 0 {
				type = type.setNullable(true)
			}

			var parameter = ParameterType.new(scope, externalName, internalName, type, min, max, default)

			if default {
				parameter.setDefaultValue(data.defaultValue, true, node)
			}

			for var attribute in data.attributes {
				if attribute.kind == NodeKind.AttributeDeclaration && attribute.declaration.kind == NodeKind.Identifier && attribute.declaration.name == 'retain' {
					parameter.flagRetained()
				}
			}

			return parameter
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ParameterType { # {{{
			var data = index
			var subtype = Type.import(data.type, metadata, references, alterations, queue, scope, node)
			var passing = ?data.passing ? PassingMode(data.passing) : PassingMode.BOTH
			var type = ParameterType.new(scope, data.external, data.internal, passing, subtype, data.min, data.max, data.default)

			if data.default {
				if data.comprehensive {
					type.setDefaultValue(JSON.parse(Buffer.from(data.defaultValue, 'base64').toString('utf8')), true, node)
				}
				else {
					type.setDefaultValue(data.defaultValue, false, node)
				}

			}

			if data.retained {
				type.flagRetained()
			}

			return type
		} # }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1, @default = false) { # {{{
		super(scope)

		@passing = PassingMode.POSITIONAL
		@variableType = @type
		@nullableByDefault = @min == 0 && @max == 1 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}
	} # }}}
	constructor(@scope, @externalName, @internalName, @passing = PassingMode.BOTH, @type, @min = 1, @max = 1, @default = false) { # {{{
		super(scope)

		@variableType = @type
		@nullableByDefault = @min == 0 && @max == 1 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}

		@anonymous = !?@externalName

		if @anonymous {
			@passing -= PassingMode.LABELED
		}
	} # }}}
	override applyGenerics(generics) { # {{{
		var result = @clone()

		if @type is DeferredType {
			var deferName = @type.name()
			var mut nf = true

			for var { name, type } in generics {
				if name == deferName {
					result._type = type
					nf = false

					break
				}
			}

			if nf {
				result._type =  @type.isNullable() ? AnyType.NullableUnexplicit : AnyType.Unexplicit
			}
		}
		else if @type.isDeferrable() {
			result._type = @type.applyGenerics(generics)
		}

		result._variableType = result._type

		return result
	} # }}}
	clone(): ParameterType { # {{{
		var that = ParameterType.new(@scope, @externalName, @internalName, @passing, @type, @min, @max, @default)

		if @retained {
			that.flagRetained()
		}

		that._index = @index

		return that
	} # }}}
	flagRetained(): valueof this { # {{{
		@retained = true
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var export = {}

		if @externalName != null {
			export.external = @externalName
		}
		if @internalName != null {
			export.internal = @internalName
		}

		export.type = @variableType.toReference(references, indexDelta, mode, module)
		export.min = @min
		export.max = @max
		export.default = @default

		if @default && ?@defaultValue {
			export.comprehensive = @comprehensive

			if @comprehensive {
				export.defaultValue = Buffer.from(JSON.stringify(@defaultValue)).toString('base64')
			}
			else {
				export.defaultValue = @defaultValue
			}
		}

		if !@anonymous && @passing != PassingMode.BOTH {
			export.passing = @passing
		}

		if @retained {
			export.retained = true
		}

		return export
	} # }}}
	getArgumentType(): Type { # {{{
		if @type.isNullable() {
			return @type
		}
		else if @min == @max == 1 && @default {
			return @type.setNullable(true)
		}
		else {
			return @type
		}
	} # }}}
	getDefaultValue() => @defaultValue
	getExternalName() => @externalName
	getInternalName() => @internalName
	getPassingMode() => @passing
	getVariableType() => @variableType
	hasDefaultValue() => @default
	hashCode() => @toQuote()
	index(): valueof @index
	index(@index): valueof this
	isAnonymous(): valueof @anonymous
	isAny() => @type.isAny()
	isComprehensive() => @comprehensive
	isLabeled() => @passing ~~ PassingMode.LABELED
	isLimited() => @max != Infinity
	isMorePreciseThan(value: ParameterType) => @type.isMorePreciseThan(value.type())
	isMorePreciseThan(value: Type) => @type.isMorePreciseThan(value)
	isMissingType() => !@type.isExplicit()
	isNullable() => @type.isNullable()
	isOnlyLabeled() => @passing == PassingMode.LABELED
	isOnlyPositional() => @passing == PassingMode.POSITIONAL
	isPositional() => @passing ~~ PassingMode.POSITIONAL
	isRequiringValue() => @required
	isRetained() => @retained
	assist isSubsetOf(value: ParameterType, generics, subtypes, mode) { # {{{
		if mode !~ MatchingMode.IgnoreRetained && @retained != value.isRetained() {
			return false
		}

		if mode ~~ MatchingMode.IgnoreName {
			return false unless ?@externalName == ?value.getExternalName()
		}
		else if mode ~~ MatchingMode.IgnoreAnonymous {
			return false if ?@externalName && ?value.getExternalName() && @externalName != value.getExternalName()
		}
		else {
			return false unless @externalName == value.getExternalName()
		}

		var mut submode = mode
		submode += MatchingMode.Missing - MatchingMode.MissingType if mode ~~ MatchingMode.MissingType

		if mode ~~ MatchingMode.MissingDefault && @default && !value.hasDefaultValue() {
			return false unless @type.setNullable(false).isSubsetOf(value.type(), submode)
		}
		else if mode ~~ MatchingMode.NonNullToNull && !@type.isNullable() && value.type().isNullable() {
			return false unless @type.setNullable(true).isSubsetOf(value.type(), submode)
		}
		else if mode ~~ MatchingMode.NullToNonNull && @type.isNullable() && !value.type().isNullable() {
			return false unless @type.setNullable(false).isSubsetOf(value.type(), submode)
		}
		else if mode ~~ MatchingMode.IgnoreNullable && @type.isNullable() && !value.type().isExplicit() {
			return false unless @type.setNullable(false).isSubsetOf(value.type(), submode)
		}
		else if mode ~~ MatchingMode.Subset {
			var oldType = @getArgumentType()
			var newType = value.getArgumentType()
			return false unless newType.isSubsetOf(oldType, submode) || oldType.isSubsetOf(newType, submode)
		}
		else {
			return false unless @getArgumentType().isSubsetOf(value.getArgumentType(), submode)
		}

		if @max > 1 {
			if mode !~ MatchingMode.MissingArity || value.max() > 1 {
				return false unless @min >= value.min() && @max <= value.max()
			}
		}

		return true
	} # }}}
	isVarargs() => @max > 1
	matchContentOf(value: Type) => @type.matchContentOf(value)
	matchContentOf(value: ParameterType) => @type.matchContentOf(value.type())
	matchArgument(value: Expression) { # {{{
		value.setCastingEnum(false)

		var type = value.type()

		if type.matchContentOf(@type) {
			if type.isReference() && !@type.isAny() && ((type.isBitmask() && !@type.isBitmask()) || (type.isEnum() && !@type.isEnum())) {
				value.setCastingEnum(true)
			}

			return true
		}
		else {
			return false
		}
	} # }}}
	matchArgument(value: Parameter) => @matchArgument(value.type())
	matchArgument(value: Type) => value.matchContentOf(@type)
	max(): valueof @max
	min(): valueof @min
	setDefaultValue(@defaultValue, @comprehensive = true, @required = false, node) { # {{{
		if !@variableType.isNullable() && defaultValue.kind == NodeKind.Identifier && defaultValue.name == 'null' {
			TypeException.throwInvalidAssignment(@internalName, @variableType, Type.Null, node)
		}

		@default = true

		@nullableByDefault = @max == 1 && !@required && !@type.isNullable()

		if @nullableByDefault {
			@min = 0
			@type = @type.setNullable(true)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		if @max > 1 {
			if @max == Infinity {
				if @min == 0 {
					fragments += '...'
				}
				else {
					fragments += `...{\(@min),}`
				}
			}
			else if @min == @max {
				fragments += `...{\(@min)}`
			}
			else {
				if @min == 0 {
					fragments += `...{,\(@max)}`
				}
				else {
					fragments += `...{\(@min),\(@max)}`
				}
			}
		}

		if @externalName != @internalName {
			if @externalName != null {
				fragments += @externalName
			}
			else {
				fragments += '_'
			}

			fragments += `\(@externalName ?? '_') % \(@internalName ?? '_')`
		}
		else if !@anonymous {
			fragments += @externalName ?? '_'
		}

		if @type.isExplicit() {
			fragments += ': '

			fragments += @type.toQuote()
		}

		if @min == 0 && @max != Infinity && !@type.isNullable() {
			fragments += '?'
		}

		return fragments
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('param', @externalName, @internalName, @min, @max, @default)

		@type.toVariations(variations)
	} # }}}
	type() => @type

	proxy @type {
		isComplete
		isDeferrable
		isExportable
		toNegativeTestFragments
		toPositiveTestFragments
	}
}
