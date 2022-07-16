abstract class Callee {
	private {
		_data
		_nullable: Boolean			= false
		_nullableProperty: Boolean	= false
	}
	constructor(@data) { // {{{
		for const modifier in data.modifiers {
			if modifier.kind == ModifierKind::Nullable {
				@nullable = true
			}
		}
	} // }}}
	abstract hashCode(): String?
	abstract toFragments(fragments, mode, node)
	abstract translate()
	abstract type(): Type
	acquireReusable(acquire)
	isNullable() => @nullable || @nullableProperty
	isNullableComputed() => @nullable && @nullableProperty
	isSkippable() => false
	mergeWith(that: Callee) { // {{{
		throw new NotSupportedException()
	} // }}}
	releaseReusable()
	validate(type: FunctionType, node) { // {{{
		for const error in type.listErrors() {
			Exception.validateReportedError(error.discardReference(), node)
		}
	} // }}}
}
