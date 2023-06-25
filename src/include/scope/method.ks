class MethodScope extends BlockScope {
	private {
		@extending: Boolean		= false
	}
	constructor(@parent) { # {{{
		super(parent)

		@parent = @authority
		@authority = this
	} # }}}
	protected declareVariable(name: String, scope: Scope) { # {{{
		if name == 'this' || (@extending && name == 'super') {
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
	flagExtending() { # {{{
		@extending = true
	} # }}}
}
