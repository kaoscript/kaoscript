class NamespaceScope extends BlockScope {
	constructor(@parent) { # {{{
		super(parent)

		@parent = parent.authority()
		@authority = this
	} # }}}
}

class NamespaceTypeScope extends BlockScope {
	addVariable(name: String, variable: Variable) { # {{{
		if $keywords[name] == true {
			const newName = this.getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}
		else {
			@declarations[name] = true
		}

		@variables[name] = [@line, variable]
	} # }}}
}
