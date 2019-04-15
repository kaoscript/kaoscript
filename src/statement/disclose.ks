class DiscloseDeclaration extends Statement {
	analyse()
	prepare() { // {{{
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

		const type = variable.getDeclaredType().type()

		for const data in @data.members {
			type.addPropertyFromAST(data, this)
		}
	} // }}}
	translate()
	toStatementFragments(fragments, mode)
}