class ParameterType extends Type {
	private {
		_default: Number
		_min: Number
		_max: Number
		_name: String?			= null
		_type: Type
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)

			return new ParameterType(scope, data.name, type, data.min, data.max, data.default)
		} // }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1, @default = 0) { // {{{
		super(scope)

		if @min == 0 && @default != 0 {
			@type = @type.setNullable(true)
		}
	} // }}}
	constructor(@scope, @name, @type, @min = 1, @max = 1, @default = 0) { // {{{
		super(scope)

		if @min == 0 && @default != 0 {
			@type = @type.setNullable(true)
		}
	} // }}}
	clone() => new ParameterType(@scope, @name, @type, @min, @max, @default)
	export(references, mode) { // {{{
		const export = {}

		if @name != null {
			export.name = @name
		}

		export.type = @type.toReference(references, mode)
		export.min = @min
		export.max = @max
		export.default = @default

		return export
	} // }}}
	hasDefaultValue() => @default != 0
	isAny() => @type.isAny()
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
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, node)
	} // }}}
	type() => @type
}