class DiscloseDeclaration extends Statement {
	analyse()
	prepare() {
		const variable = @scope.getVariable(@data.name.name)

		unless variable? {
			ReferenceException.throwNotDefined(@data.name.name, this)
		}

		unless variable.type() is NamedType {
			TypeException.throwNotClass(@data.name.name, this)
		}

		unless variable.type().isAlien() {
			TypeException.throwNotAlien(@data.name.name, this)
		}

		variable.prepareAlteration()

		const type = variable.type().type()

		for const data in @data.members {
			type.addPropertyFromAST(data, this)
		}
	}
	translate()
	toStatementFragments(fragments, mode)
}