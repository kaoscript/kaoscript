class ImportScope extends BlockScope {
	private {
		_matchingTypes: Dictionary<Array>	= {}
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
	isMatchingType(a: Type, b: Type, mode: MatchingMode) { // {{{
		const hash = a.toQuote()

		if const matches = @matchingTypes[hash] {
			for const type, i in matches by 2 {
				if type == b {
					return matches[i + 1]
				}
			}
		}
		else {
			@matchingTypes[hash] = []
		}

		@matchingTypes[hash].push(b, false)

		const index = @matchingTypes[hash].length

		const match = a.isMatching(b, mode)

		@matchingTypes[hash][index - 1] = match

		return match
	} // }}}
	resolveReference(name: String, nullable: Boolean, parameters: Array) { // {{{
		const hash = ReferenceType.toQuote(name, nullable, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable, parameters)
		}

		return @references[hash]
	} // }}}
}