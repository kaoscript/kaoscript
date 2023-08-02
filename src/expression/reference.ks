class ReferenceExpression extends Expression {
	private {
		@expression: Expression
	}
	constructor(@expression, data, parent, scope) { # {{{
		super(data, parent, scope)
	} # }}}
	override isReferenced() => true
	override isUndisruptivelyNullable() => false

	proxy @expression {
		analyse
		prepare
		translate
		acquireReusable
		isComputed
		isNullable
		isNullableComputed
		releaseReusable
		toConditionFragments
		toFragments
		toQuote
		toReusableFragments
		type
	}
}
