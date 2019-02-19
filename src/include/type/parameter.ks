class ParameterType extends Type {
	private {
		_min: Number
		_max: Number
		_type: Type
	}
	static {
		fromMetadata(data, references: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			return new ParameterType(scope, Type.fromMetadata(data.type, references, scope, node), data.min, data.max)
		} // }}}
	}
	constructor(@scope, @type, @min = 1, @max = 1) { // {{{
		super(scope)
	} // }}}
	clone() => new ParameterType(@scope, @type, @min, @max)
	equals(b?): Boolean { // {{{
		if b is not ParameterType {
			return false
		}

		return @min == b.min() && @max == b.max() && @type.equals(b.type())
	} // }}}
	export(references, ignoreAlteration) => { // {{{
		type: @type.toReference(references, ignoreAlteration)
		min: @min
		max: @max
	} // }}}
	isAny() => @type.isAny()
	matchContentTo(value: Type) { // {{{
		if value is ParameterType {
			if @min != value._min || @max != value._max {
				return false
			}

			return @type.matchContentTo(value.type())
		}
		else {
			if @type.isAny() || value.isAny() {
				return true
			}

			return @type.matchContentTo(value)
		}
	} // }}}
	matchSignatureOf(value: ParameterType, matchables) { // {{{
		if @min != value._min || @max != value._max {
			return false
		}

		if @type.isAny() {
			return true
		}

		return @type.matchSignatureOf(value.type(), matchables)
	} // }}}
	max() => @max
	min() => @min
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, node)
	} // }}}
	type() => @type
}