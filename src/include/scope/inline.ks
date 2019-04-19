class InlineBlockScope extends BlockScope {
	private {
		_tempParentNames	= {}
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
	acquireUnusedTempName() { // {{{
		for const name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		if const name = this.parent().acquireUnusedTempName() {
			@tempParentNames[name] = true

			return name
		}

		return null
	} // }}}
	/* private declareVariable(name: String) { // {{{
		if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Variable) {
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
	} // }}} */
	private declareVariable(name: String) { // {{{
		if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Array) {
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getTempIndex() { // {{{
		if @tempIndex == -1 {
			@tempIndex = @parent.getTempIndex()
		}

		return @tempIndex
	} // }}}
	isInline() => true
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

		const newName = this.declareVariable(name)

		@renamedVariables[name] = newName
		@declarations[newName] = true

		return newName
	} // }}}
}

class LaxInlineBlockScope extends InlineBlockScope {
	private declareVariable(name: String) { // {{{
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
	getNewName(name: String): String { // {{{
		let index = this.getRenamedIndex(name)
		let newName = '__ks_' + name + '_' + (++index)

		while this.hasRenamedVariable(newName) {
			newName = '__ks_' + name + '_' + (++index)
		}

		@renamedIndexes[name] = index

		return newName
	} // }}}
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
	isBleeding() => true
}