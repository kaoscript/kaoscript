class NamespaceScope extends BlockScope {
	addVariable(name: String, variable: Variable) { // {{{
		if $keywords[name] == true {
			const newName = this.getNewName(name)

			/* if @variables[name] is not Variable { */
			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			@renamedVariables[name] = newName
		}
		else {
			@declarations[name] = true
		}

		/* @variables[name] = variable */
		@variables[name] = [@line, variable]
	} // }}}
}