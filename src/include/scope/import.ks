class ImportScope extends BlockScope {
	addVariable(name: String, variable: Variable, node?) { // {{{
		if this.hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if $keywords[name] == true || @renamedIndexes[name] is Number {
			const newName = this.getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			@renamedVariables[name] = newName
		}
		else {
			@declarations[name] = true
		}

		@variables[name] = [@line, variable]
	} // }}}
}