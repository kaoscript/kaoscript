class NamespaceScope extends BlockScope {
	constructor(@parent) { # {{{
		super(parent)

		@parent = parent.authority()
		@authority = this
	} # }}}
	override define(name, immutable, type, initialized, overwrite, node) { # {{{
		var variable = super(name, immutable, type, initialized, overwrite, node)

		if node is Statement {
			variable.declaration(node)
		}

		return variable
	} # }}}
}

class NamespaceTypeScope extends BlockScope {
	addVariable(name: String, variable: Variable) { # {{{
		if $keywords[name] == true {
			var newName = @getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}
		else {
			@declarations[name] = true
		}

		@variables[name] = [@line(), variable]
	} # }}}
}
