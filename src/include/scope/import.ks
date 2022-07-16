class ImportScope extends BlockScope {
	private {
		_scopeRenames				= {}
	}
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

			variable.renameAs(newName)
		}
		else {
			@declarations[name] = true
		}

		@variables[name] = [@line, variable]
	} // }}}
	isRenamed(name: String, newName: String, scope: Scope, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Renamed {
			if const renames = @scopeRenames[name] {
				for const rename in renames {
					if rename.name == newName {
						return true
					}
				}
			}
		}

		return name == newName
	} // }}}
	rename(name: String, newName: String, scope: Scope) { // {{{
		if newName != name {
			if const renames = @scopeRenames[name] {
				renames.push({
					name: newName
					scope
				})
			}
			else {
				@scopeRenames[name] = [{
					name: newName
					scope
				}]
			}
		}
	} // }}}
	resetReference(name: String)
	resolveReference(name: String, explicitlyNull: Boolean = false, parameters: Array = []) { // {{{
		const hash = ReferenceType.toQuote(name, explicitlyNull, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, explicitlyNull, parameters)
		}

		return @references[hash]
	} // }}}
}
