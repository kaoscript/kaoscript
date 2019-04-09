class ImportScope extends BlockScope {
	addVariable(name: String, variable: Variable, node?) { // {{{
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if $keywords[name] == true || @renamedIndexes[name] is Number {
			const newName = this.getNewName(name)

			if @variables[name] is not Variable {
				@declarations[newName] = true
			}

			@renamedVariables[name] = newName
		}
		else {
			@declarations[name] = true
		}

		@variables[name] = variable
	} // }}}
}