class ReferenceExpression extends Expression {
	private {
		@expression: Expression
	}
	constructor(@expression, data, parent, scope) { # {{{
		super(data, parent, scope)
	} # }}}
	override analyse() => @expression.analyse()
	override prepare(target, targetMode) => @expression.prepare(target, targetMode)
	override translate() => @expression.translate()
	override isReferenced() => true
	override isUndisruptivelyNullable() => false
	toFragments(fragments, mode) => @expression.toFragments(fragments, mode)

	proxy @expression {
		// TODO!
		// analyse
		// prepare
		// translate
		acquireReusable
		isComputed
		isNullable
		isNullableComputed
		releaseReusable
		toConditionFragments
		// TODO!
		// toFragments
		toQuote
		toReusableFragments
		type
	}
}
