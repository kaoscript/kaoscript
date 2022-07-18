class DiscloseDeclaration extends Statement {
	private lateinit {
		@type: Type
	}
	analyse()
	enhance() { # {{{
		const variable = @scope.getVariable(@data.name.name)

		unless variable? {
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

		for const data in @data.members {
			@type.addPropertyFromAST(data, this)
		}

		if @options.rules.nonExhaustive {
			@type.setExhaustive(false)
		}
		else {
			@type.setExhaustive(true)
		}
	} # }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}
