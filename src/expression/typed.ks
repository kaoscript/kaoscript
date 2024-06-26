class TypedExpression extends Expression {
	private late {
		@expression: Expression
		@generics: AltType[]		= []
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

		var originals = type.generics()

		if ?#originals {
			if @parameters.length > originals.length {
				NotImplementedException.throw()
			}

			for var { name }, index in originals {
				@generics.push({ name, type: @parameters[index] ?? AnyType.NullableUnexplicit })
			}
		}
	} # }}}
	override translate() { # {{{
		@expression.translate()
	} # }}}
	override makeCallee(generics, node) { # {{{
		@expression.makeCallee(@generics, node)
	} # }}}
	override makeMemberCallee(property, testing, generics, node) { # {{{
		if var callback ?= @expression.type().makeMemberCallee(property, @expression.path(), @generics, node) {
			callback()
		}
	} # }}}

	proxy @expression {
		toFragments
	}
}
