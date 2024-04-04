class ValueOfType extends ReferenceType {
	private {
		@expression: Expression?
		@this: Boolean				= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ValueOfType { # {{{
			return ValueOfType.new(references[data.name], scope)
		} # }}}
	}
	constructor(@expression) { # {{{
		var type = expression.type()

		if type is ReferenceType {
			super(type._scope, type._name, type._nullable, type._parameters)

			@this ||= expression is IdentifierLiteral && expression.name() == 'this'
		}
		else {
			super(expression.scope(), type.setNullable(false).hashCode(), type.isNullable())

			@type = type
		}
	} # }}}
	constructor(@type, @scope) { # {{{
		super(scope, 'this')

		@this = true
	} # }}}
	override discardAlias() { # {{{
		return @type().discardAlias()
	} # }}}
	override discardReference() { # {{{
		return @type().discardReference()
	} # }}}
	expression() => @expression
	isThisReference(): valueof @this
	override isValueOf() => true
	override toQuote() { # {{{
		if @this {
			return 'valueof this'
		}
		else {
			return super()
		}
	} # }}}
	override toReference(references, indexDelta, mode, module) { # {{{
		if @this {
			return {
				kind: TypeKind.ValueOf
				name: 'this'
			}
		}
		else {
			return super(references, indexDelta, mode, module)
		}
	} # }}}
}
