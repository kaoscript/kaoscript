class InlineBlockScope extends BlockScope {
	private {
		_tempParentNames	= {}
		_upatedInferables	= {}
	}
	acquireTempName(declare: Boolean = true): String { # {{{
		if var name = this.acquireUnusedTempName() {
			return name
		}

		if @tempIndex == -1 {
			@tempIndex = @parent.getTempIndex()
		}

		var name = `__ks_\(++@tempIndex)`

		@tempNames[name] = false

		if declare {
			@tempDeclarations.push(name)
		}

		return name
	} # }}}
	acquireUnusedTempName(): String? { # {{{
		for var _, name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		if var name = this.parent().acquireUnusedTempName() {
			@tempParentNames[name] = true

			return name
		}

		return null
	} # }}}
	private declareVariable(name: String, scope: Scope) { # {{{
		if $keywords[name] == true || (@declarations[name] && @variables[name] is Array) || (scope.isBleeding() && this.hasBleedingVariable(name)) {
			var newName = this.getNewName(name)

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
	getNewName(name: String): String { # {{{
		var mut index = this.getRenamedIndex(name)
		var mut newName = '__ks_' + name + '_' + (++index)

		while this.hasRenamedVariable(newName) {
			newName = '__ks_' + name + '_' + (++index)
		}

		@renamedIndexes[name] = index

		return newName
	} # }}}
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getTempIndex() { # {{{
		if @tempIndex == -1 {
			@tempIndex = @parent.getTempIndex()
		}

		return @tempIndex
	} # }}}
	hasBleedingVariable(name: String) => super(name) || @parent.hasBleedingVariable(name)
	hasRenamedVariable(name: String): Boolean { # {{{
		var mut parent = this
		do {
			if parent.hasDeclaredVariable(name) {
				return true
			}

			parent = parent.parent()
		}
		while parent.isInline()

		return parent.hasDeclaredVariable(name)
	} # }}}
	isInline() => true
	listUpdatedInferables() => @upatedInferables
	releaseTempName(name) { # {{{
		if @tempParentNames[name] == true {
			this.parent().releaseTempName(name)

			@tempParentNames[name] = false
		}
		else {
			@tempNames[name] = true
		}
	} # }}}
	rename(name) { # {{{
		return if @renamedVariables[name] is String

		var mut parent = @parent
		var mut nf = !parent.hasDeclaredVariable(name)

		while nf && parent.isInline() {
			parent = parent.parent()

			nf = !parent.hasDeclaredVariable(name)
		}

		if !nf {
			@renamedIndexes[name] = parent.getRenamedIndex(name)
		}

		var newName = this.declareVariable(name, this)

		@renamedVariables[name] = newName
		@declarations[newName] = true

		var variable = this.getVariable(name)

		variable.renameAs(newName)

		return newName
	} # }}}
	renameNext(name, line) { # {{{
		return if @renamedVariables[name] is String

		var newName = this.declareVariable(name, this)

		@renamedVariables[name] = newName
		@declarations[newName] = true

		var variables: Array = @variables[name]

		var mut i = 0
		while i < variables.length && variables[i] < line {
			i += 2
		}

		var variable: Variable = variables[i + 1]

		variable.renameAs(newName)
	} # }}}
	replaceVariable(name: String, mut variable: Variable): Variable { # {{{
		variable = super.replaceVariable(name, variable)

		if !@declarations[name] {
			@upatedInferables[name] = {
				isVariable: true
				type: variable.getRealType()
			}
		}

		return variable
	} # }}}
	replaceVariable(name: String, type: Type, downcast: Boolean = false, absolute: Boolean = true, node: AbstractNode): Variable { # {{{
		var variable = super.replaceVariable(name, type, downcast, absolute, node)

		if !@declarations[name] {
			@upatedInferables[name] = {
				isVariable: true
				type: variable.getRealType()
			}
		}

		return variable
	} # }}}
}

class LaxInlineBlockScope extends InlineBlockScope {
	private declareVariable(name: String, scope: Scope) { # {{{
		if $keywords[name] == true || this.hasRenamedVariable(name) {
			var newName = this.getNewName(name)

			if @variables[name] is not Variable {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} # }}}
	isBleeding() => true
}
