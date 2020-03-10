class ParameterType extends Type {
	private {
		_comprehensive: Boolean				= true
		_default: Boolean
		_defaultValue
		_min: Number
		_max: Number
		_name: String?						= null
		_nullableByDefault: Boolean
		_type: Type
		_variableType: Type
	}
	static {
		fromAST(data, node: AbstractNode): ParameterType => ParameterType.fromAST(data, false, node.scope(), true, node)
		fromAST(data, overridable: Boolean, scope: Scope, defined: Boolean, node: AbstractNode): ParameterType { // {{{
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
		} // }}}
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const subtype = Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)
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
		} // }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1, @default = false) { // {{{
		super(scope)

		@variableType = @type
		@nullableByDefault = @min == 0 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}
	} // }}}
	constructor(@scope, @name, @type, @min = 1, @max = 1, @default = false) { // {{{
		super(scope)

		@variableType = @type
		@nullableByDefault = @min == 0 && @default && !@type.isNullable()

		if @nullableByDefault {
			@type = @type.setNullable(true)
		}
	} // }}}
	clone() => new ParameterType(@scope, @name, @type, @min, @max, @default)
	export(references, mode) { // {{{
		const export = {}

		if @name != null {
			export.name = @name
		}

		export.type = @variableType.toReference(references, mode)
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
	} // }}}
	getDefaultValue() => @defaultValue
	getVariableType() => @variableType
	hasDefaultValue() => @default
	isAny() => @type.isAny()
	isComprehensive() => @comprehensive
	isExportable() => @type.isExportable()
	isMatching(value: ParameterType, mode: MatchingMode) => @type.isMatching(value.type(), mode)
	isNullable() => @type.isNullable()
	matchContentOf(type: Type) => @type.matchContentOf(type)
	matchContentOf(type: ParameterType) => @type.matchContentOf(type.type())
	matchArgument(value: Expression) { // {{{
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
	} // }}}
	matchArgument(value: Parameter) => this.matchArgument(value.type())
	matchArgument(value: Type) => value.matchContentOf(@type)
	max() => @max
	min() => @min
	name() => @name
	setDefaultValue(@defaultValue, @comprehensive = true)
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() { // {{{
		const fragments = []

		if @name != null {
			fragments.push(@name)
		}

		fragments.push(': ', @type.toQuote())

		return fragments.join('')
	} // }}}
	override toNegativeTestFragments(fragments, node, junction) { // {{{
		@type.toNegativeTestFragments(fragments, node, junction)
	} // }}}
	override toPositiveTestFragments(fragments, node, junction) { // {{{
		@type.toPositiveTestFragments(fragments, node, junction)
	} // }}}
	type() => @type
}