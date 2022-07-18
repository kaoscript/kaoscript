class ParameterType extends Type {
	private {
		_comprehensive: Boolean				= true
		_default: Boolean
		_defaultValue: Any?
		_min: Number
		_max: Number
		_name: String?						= null
		_nullableByDefault: Boolean
		_type: Type
		_variableType: Type
	}
	static {
		fromAST(data, node: AbstractNode): ParameterType => ParameterType.fromAST(data, false, node.scope(), true, node)
		fromAST(data, overridable: Boolean, scope: Scope, defined: Boolean, node: AbstractNode): ParameterType { # {{{
			let type = ?data.type ? Type.fromAST(data.type, scope, defined, node) : AnyType.Unexplicit

			auto default = false
			auto min = 1
			auto max = 1

			if data.defaultValue? {
				default = true
				min = 0
			}

			let nf = true
			for modifier in data.modifiers while nf {
				if modifier.kind == ModifierKind::Rest {
					if modifier.arity {
						min = modifier.arity.min
						max = modifier.arity.max
					}
					else {
						min = 0
						max = Infinity
					}

					nf = true
				}
			}

			let name = null
			if data.name? {
				if data.name.kind == NodeKind::Identifier {
					name = data.name.name
				}
			}
			else {
				type = type.setNullable(true)
			}


			const parameter = new ParameterType(scope, name, type, min, max, default)

			if default && overridable {
				parameter.setDefaultValue(data.defaultValue, true)
			}

			return parameter
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ParameterType { # {{{
			const data = index
			const subtype = Type.import(data.type, metadata, references, alterations, queue, scope, node)
			const type = new ParameterType(scope, data.name, subtype, data.min, data.max, data.default)

			if data.default {
				if data.comprehensive {
					type.setDefaultValue(JSON.parse(Buffer.from(data.defaultValue, 'base64').toString('utf8')), true)
				}
				else {
					type.setDefaultValue(data.defaultValue, false)
				}

			}

			return type
		} # }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1, @default = false) { # {{{
		super(scope)

		@variableType = @type
		@nullableByDefault = @min == 0 && @max == 1 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}
	} # }}}
	constructor(@scope, @name, @type, @min = 1, @max = 1, @default = false) { # {{{
		super(scope)

		@variableType = @type
		@nullableByDefault = @min == 0 && @max == 1 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}
	} # }}}
	clone() => new ParameterType(@scope, @name, @type, @min, @max, @default)
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		const export = {}

		if @name != null {
			export.name = @name
		}

		export.type = @variableType.toReference(references, indexDelta, mode, module)
		export.min = @min
		export.max = @max
		export.default = @default

		if @default && @defaultValue? {
			export.comprehensive = @comprehensive

			if @comprehensive {
				export.defaultValue = Buffer.from(JSON.stringify(@defaultValue)).toString('base64')
			}
			else {
				export.defaultValue = @defaultValue
			}
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
	getVariableType() => @variableType
	hasDefaultValue() => @default
	isAny() => @type.isAny()
	isComprehensive() => @comprehensive
	isExportable() => @type.isExportable()
	isMorePreciseThan(value: ParameterType) => @type.isMorePreciseThan(value.type())
	isMorePreciseThan(value: Type) => @type.isMorePreciseThan(value)
	isMissingType() => !@type.isExplicit()
	isNullable() => @type.isNullable()
	isSubsetOf(value: ParameterType, mode: MatchingMode) { # {{{

		if mode !~ MatchingMode::IgnoreName && @name != value.name() != null {
			return false
		}

		if mode ~~ MatchingMode::MissingDefault && @default && !value.hasDefaultValue() {
			return false unless @type.setNullable(false).isSubsetOf(value.type(), mode)
		}
		else if mode ~~ MatchingMode::NonNullToNull && !@type.isNullable() && value.type().isNullable() {
			return false unless @type.setNullable(true).isSubsetOf(value.type(), mode)
		}
		else if mode ~~ MatchingMode::Subset {
			const oldType = @getArgumentType()
			const newType = value.getArgumentType()
			return false unless newType.isSubsetOf(oldType, mode) || oldType.isSubsetOf(newType, mode)
		}
		else {
			return false unless @getArgumentType().isSubsetOf(value.getArgumentType(), mode)
		}

		if @max > 1 {
			if mode !~ MatchingMode::MissingArity || value.max() > 1 {
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

		const type = value.type()

		if type.matchContentOf(@type) {
			if type.isReference() && type.isEnum() && !@type.isEnum() && !@type.isAny() {
				value.setCastingEnum(true)
			}

			return true
		}
		else {
			return false
		}
	} # }}}
	matchArgument(value: Parameter) => this.matchArgument(value.type())
	matchArgument(value: Type) => value.matchContentOf(@type)
	max(): @max
	min(): @min
	name() => @name
	setDefaultValue(@defaultValue, @comprehensive = true) { # {{{
		@default = true
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	toQuote() { # {{{
		auto fragments = ''

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

		if @name != null {
			fragments += @name
		}
		else {
			fragments += '_'
		}

		fragments += ': '

		fragments += @type.toQuote()

		if @min == 0 && @max != Infinity && !@type.isNullable() {
			fragments += '?'
		}

		return fragments
	} # }}}
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		@type.toNegativeTestFragments(fragments, node, junction)
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		@type.toPositiveTestFragments(fragments, node, junction)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('param', @name, @min, @max, @default)

		@type.toVariations(variations)
	} # }}}
	type() => @type
}
