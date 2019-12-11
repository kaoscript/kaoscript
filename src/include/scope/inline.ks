class InlineBlockScope extends BlockScope {
	private {
		_tempParentNames	= {}
		_upatedInferables	= {}
	}
	acquireTempName(declare: Boolean = true): String { // {{{
		if const name = this.acquireUnusedTempName() {
			return name
		}

		if @tempIndex == -1 {
			@tempIndex = @parent.getTempIndex()
		}

		const name = `__ks_\(++@tempIndex)`

		@tempNames[name] = false

		if declare {
			@tempDeclarations.push(name)
		}

		return name
	} // }}}
	acquireUnusedTempName(): String? { // {{{
		for const _, name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		if const name = this.parent().acquireUnusedTempName() {
			@tempParentNames[name] = true

			return name
		}

		return null
	} // }}}
	private declareVariable(name: String, scope: Scope) { // {{{
		if $keywords[name] == true || (@declarations[name] && @variables[name] is Array) || (scope.isBleeding() && this.hasBleedingVariable(name)) {
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
	getNewName(name: String): String { // {{{
		let index = this.getRenamedIndex(name)
		let newName = '__ks_' + name + '_' + (++index)

		while this.hasRenamedVariable(newName) {
			newName = '__ks_' + name + '_' + (++index)
		}

		@renamedIndexes[name] = index

		return newName
	} // }}}
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getTempIndex() { // {{{
		if @tempIndex == -1 {
			@tempIndex = @parent.getTempIndex()
		}

		return @tempIndex
	} // }}}
	hasBleedingVariable(name: String) => super(name) || @parent.hasBleedingVariable(name)
	hasRenamedVariable(name: String): Boolean { // {{{
		let parent = this
		do {
			if parent.hasDeclaredVariable(name) {
				return true
			}

			parent = parent.parent()
		}
		while parent.isInline()

		return parent.hasDeclaredVariable(name)
	} // }}}
	isInline() => true
	listUpdatedInferables() => @upatedInferables
	releaseTempName(name) { // {{{
		if @tempParentNames[name] == true {
			this.parent().releaseTempName(name)

			@tempParentNames[name] = false
		}
		else {
			@tempNames[name] = true
		}
	} // }}}
	rename(name) { // {{{
		return if @renamedVariables[name] is String

		let parent = @parent
		let nf = !parent.hasDeclaredVariable(name)

		while nf && parent.isInline() {
			parent = parent.parent()

			nf = !parent.hasDeclaredVariable(name)
		}

		if !nf {
			@renamedIndexes[name] = parent.getRenamedIndex(name)
		}

		const newName = this.declareVariable(name, this)

		@renamedVariables[name] = newName
		@declarations[newName] = true

		const variable = this.getVariable(name)

		variable.renameAs(newName)

		return newName
	} // }}}
	renameNext(name, line) { // {{{
		return if @renamedVariables[name] is String

		const newName = this.declareVariable(name, this)

		@renamedVariables[name] = newName
		@declarations[newName] = true

		const variables: Array = @variables[name]

		let i = 0
		while i < variables.length && variables[i] < line {
			i += 2
		}

		const variable: Variable = variables[i + 1]

		variable.renameAs(newName)
	} // }}}
	replaceVariable(name: String, variable: Variable): Variable { // {{{
		variable = super.replaceVariable(name, variable)

		if @declarations[name] != true {
			@upatedInferables[name] = {
				isVariable: true
				type: variable.getRealType()
			}
		}

		return variable
	} // }}}
	replaceVariable(name: String, type: Type, downcast: Boolean = false, node: AbstractNode): Variable { // {{{
		const variable = super.replaceVariable(name, type, downcast, node)

		if @declarations[name] != true {
			@upatedInferables[name] = {
				isVariable: true
				type: variable.getRealType()
			}
		}

		return variable
	} // }}}
}

class LaxInlineBlockScope extends InlineBlockScope {
	private declareVariable(name: String, scope: Scope) { // {{{
		if $keywords[name] == true || this.hasRenamedVariable(name) {
			const newName = this.getNewName(name)

			if @variables[name] is not Variable {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} // }}}
	isBleeding() => true
}