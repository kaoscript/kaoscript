class FunctionScope extends BlockScope {
	private {
		_extending: Boolean		= false
	}
	flagExtending() { // {{{
		@extending = true
	} // }}}
	protected declareVariable(name: String) { // {{{
		if name == 'this' || (@extending && name == 'super') {
			@declarations[name] = true

			return null
		}
		else if $keywords[name] == true || @declarations[name] == true {
			const newName = this.getNewName(name)

			if @variables[name] is not Array {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} // }}}
}