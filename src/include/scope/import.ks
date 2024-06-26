class ImportScope extends BlockScope {
	private {
		@scopeRenames				= {}
	}
	addVariable(name: String, variable: Variable, node?) { # {{{
		if @hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if $keywords[name] == true || @renamedIndexes[name] is Number {
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
	isRenamed(name: String, newName: String, scope: Scope, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode.Renamed {
			if var renames ?= @scopeRenames[name] {
				for var rename in renames {
					if rename.name == newName {
						return true
					}
				}
			}
		}

		return name == newName
	} # }}}
	hasDefinedVariable(name: String, line: Number) { # {{{
		if ?@variables[name] {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line() {
				variable = variables.last()
			}
			else {
				for var i from 0 to~ variables.length step 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return false
	} # }}}
	rename(name: String, newName: String, scope: Scope) { # {{{
		if newName != name {
			if var renames ?= @scopeRenames[name] {
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
	} # }}}
	resetReference(name: String)
	override resolveReference(name, explicitlyNull, parameters, subtypes) { # {{{
		var hash = ReferenceType.toQuote(name, explicitlyNull, parameters, subtypes)

		@references[hash] ??= ReferenceType.new(this, name, explicitlyNull, parameters, subtypes)

		return @references[hash]
	} # }}}
}
