class FunctionScope extends BlockScope {
	constructor(@parent) { # {{{
		super(parent)

		@parent = @authority

		while @parent is not ModuleScope & NamespaceScope {
			@parent = @parent.parent()!?
		}

		@authority = this
	} # }}}
	protected declareVariable(name: String, scope: Scope) { # {{{
		if name == 'this' {
			@declarations[name] = true

			return null
		}
		else if $keywords[name] == true || @declarations[name] == true {
			var newName = @getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} # }}}
}

class InlineFunctionScope extends BlockScope {
	constructor(@parent) { # {{{
		super(parent)

		@authority = this
	} # }}}
	protected declareVariable(name: String, scope: Scope) { # {{{
		if name == 'this' {
			@declarations[name] = true

			return null
		}
		else if $keywords[name] == true || @declarations[name] == true {
			var newName = @getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} # }}}
}
