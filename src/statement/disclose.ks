class DiscloseDeclaration extends Statement {
	private late {
		@type: Type
	}
	analyse()
	enhance() { # {{{
		var variable = @scope.getVariable(@data.name.name)

		unless ?variable {
			ReferenceException.throwNotDefined(@data.name.name, this)
		}

		unless variable.getDeclaredType() is NamedType {
			TypeException.throwNotClass(@data.name.name, this)
		}

		unless variable.getDeclaredType().isAlien() {
			TypeException.throwNotAlien(@data.name.name, this)
		}

		variable.prepareAlteration()

		@type = variable.getDeclaredType().type()

		if ?#@data.typeParameters {
			var generics = [Type.toGeneric(parameter, this) for var parameter in @data.typeParameters]

			@type.generics(generics)
		}

		for var data in @data.members {
			@type.addPropertyFromAST(data, this)
		}

		if @options.rules.nonExhaustive {
			@type.setExhaustive(false)
		}
		else {
			@type.setExhaustive(true)
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode)
}
