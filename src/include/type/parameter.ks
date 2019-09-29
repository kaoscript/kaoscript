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
			return new ParameterType(scope, data.name, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node), data.min, data.max, data.default)
		} // }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1, @default = 0) { // {{{
		super(scope)
	} // }}}
	constructor(@scope, @name, @type, @min = 1, @max = 1, @default = 0) { // {{{
		super(scope)
	} // }}}
	clone() => new ParameterType(@scope, @name, @type, @min, @max, @default)
	equals(b?): Boolean { // {{{
		if b is not ParameterType {
			return false
		}

		return @min == b.min() && @max == b.max() && @type.equals(b.type())
	} // }}}
	isMatching(value: ParameterType, mode: MatchingMode) => @min == value.min() && @max == value.max() && @type.isMatching(value.type(), mode)
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
	isNullable() => @type.isNullable()
	matchContentOf(type: Type) => @type.matchContentOf(type)
	matchContentOf(type: ParameterType) => @type.matchContentOf(type.type())
	matchArgument(value: Expression) { // {{{
		value.setCastingEnum(false)

		const type = value.type()

		if type.matchContentOf(@type) || (type.isNullable() && @default != 0) {
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
	matchArgument(value: Type) => value.matchContentOf(@type) || (value.isNullable() && @default != 0)
	matchSignatureOf(type: ParameterType, matchables) => @type.matchSignatureOf(type.type(), matchables)
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