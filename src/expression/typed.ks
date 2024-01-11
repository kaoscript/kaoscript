class TypedExpression extends Expression {
	private late {
		@expression: Expression
		@generics: Generic[]		= []
		@parameters: Type[]
	}
	override analyse() { # {{{
		@expression = $compile.expression(@data.expression, this)
			..analyse()

		@parameters = [Type.fromAST(parameter, this) for var parameter in @data.typeParameters]
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(target, targetMode)

		var type = @expression.type()

		if type is NamedType {
			if var originals ?#= type.type().generics() {
				if @parameters.length > originals.length {
					NotImplementedException.throw()
				}

				for var { name }, index in originals {
					if var type ?= @parameters[index] {
						@generics.push({ name, type })
					}
					else {
						@generics.push({ name, type : AnyType.NullableUnexplicit })
					}
				}
			}
		}
	} # }}}
	override translate() { # {{{
		@expression.translate()
	} # }}}
	override makeMemberCallee(property: String, generics: Generic[]?, node: CallExpression) { # {{{
		@expression.type().makeMemberCallee(property, @generics, node)
	} # }}}

	proxy @expression {
		toFragments
	}
}
