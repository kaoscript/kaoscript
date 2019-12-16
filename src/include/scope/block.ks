class BlockScope extends Scope {
	private {
		_chunkTypes					= {}
		_declarations				= {}
		_macros						= {}
		_module: ModuleScope
		_parent: Scope
		_references					= {}
		_renamedIndexes 			= {}
		_renamedVariables			= {}
		_stashes					= {}
		_tempDeclarations: Array	= []
		_tempIndex 					= -1
		_tempNames					= {}
		_variables					= {}
	}
	constructor(@parent) { // {{{
		super()

		@module = @parent.module()
	} // }}}
	acquireTempName(declare: Boolean = true): String { // {{{
		for const _, name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
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

		return null
	} // }}}
	addMacro(name: String, macro: MacroDeclaration) { // {{{
		if @macros[name] is Array {
			const type = macro.type()
			let notAdded = true

			for const m, index in @macros[name] while notAdded {
				if m.type().isMatching(type, MatchingMode::Signature) {
					@macros[name].splice(index, 0, macro)

					notAdded = false
				}
			}

			if notAdded {
				@macros[name].push(macro)
			}
		}
		else {
			@macros[name] = [macro]
		}
	} // }}}
	addStash(name, ...fn) { // {{{
		if ?@stashes[name] {
			@stashes[name].push(fn)
		}
		else {
			@stashes[name] = [fn]
		}
	} // }}}
	block() => this
	commitTempVariables(variables: Array) { // {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} // }}}
	protected declareVariable(name: String, scope: Scope) { // {{{
		if $keywords[name] == true || @declarations[name] == true {
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
	define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable { // {{{
		if this.hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type, initialized)

		this.defineVariable(variable, node)

		return variable
	} // }}}
	defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		if @variables[name] is Array {
			const variables: Array = @variables[name]

			if variables.last() is Variable {
				SyntaxException.throwAlreadyDeclared(name, node)
			}

			variables.push(@line, variable)
		}
		else {
			if const newName = this.declareVariable(name, this) {
				@renamedVariables[name] = newName

				variable.renameAs(newName)
			}

			@variables[name] = [@line, variable]
		}
	} // }}}
	getChunkType(name, line: Number = @line) { // {{{
		if @chunkTypes[name] is Array {
			const types: Array = @chunkTypes[name]
			let type = null

			if line == -1 || line > @line {
				type = types.last()
			}
			else {
				for const i from 0 til types.length by 2 while types[i] <= line {
					type = types[i + 1]
				}
			}

			if type != null {
				return type
			}
		}

		return @parent.getChunkType(name, -1)
	} // }}}
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			let variable = null

			if this.isAtLastLine() {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= @line {
					variable = variables[i + 1]
				}
			}

			if variable == false {
				return null
			}
			else if variable != null {
				return variable
			}
		}

		return null
	} // }}}
	getLineOffset() => @module.getLineOffset()
	getMacro(data, parent) { // {{{
		if data.callee.kind == NodeKind::Identifier {
			if @macros[data.callee.name]? {
				for macro in @macros[data.callee.name] {
					if macro.matchArguments(data.arguments) {
						return macro
					}
				}
			}
			else {
				return @parent.getMacro(data, parent)
			}

			SyntaxException.throwUnmatchedMacro(data.callee.name, parent, data)
		}
		else {
			const path = Generator.generate(data.callee)

			if @macros[path]? {
				for macro in @macros[path] {
					if macro.matchArguments(data.arguments) {
						return macro
					}
				}
			}
			else {
				return @parent.getMacro(data, parent)
			}

			SyntaxException.throwUnmatchedMacro(path, parent, data)
		}
	} // }}}
	getNewName(name: String): String { // {{{
		let index = @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
		let newName = '__ks_' + name + '_' + (++index)

		while @declarations[newName] {
			newName = '__ks_' + name + '_' + (++index)
		}

		@renamedIndexes[name] = index

		return newName
	} // }}}
	getRawLine() => @module.getRawLine()
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getTempIndex() => @tempIndex
	getVariable(name): Variable => this.getVariable(name, @line)
	getVariable(name, line: Number): Variable { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			let variable: Variable? = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable == false {
				return @parent.getVariable(name, -1)
			}
			else if variable != null {
				return variable
			}
		}

		return @parent.getVariable(name, -1)
	} // }}}
	hasDeclaredVariable(name: String) => @declarations[name] == true
	hasDefinedVariable(name: String) => this.hasDefinedVariable(name, @line)
	hasDefinedVariable(name: String, line: Number) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			let variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return false
	} // }}}
	hasMacro(name) => @macros[name] is Array || @parent.hasMacro(name)
	hasVariable(name: String) => this.hasVariable(name, @line)
	hasVariable(name: String, line: Number) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			let variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return @parent.hasVariable(name, -1)
	} // }}}
	isAtLastLine() => @module.isAtLastLine()
	isRedeclaredVariable(name: String) { // {{{
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	} // }}}
	isRenamedVariable(name: String) { // {{{
		if @variables[name] is Array {
			return @renamedVariables[name] is String
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} // }}}
	line() => @module.line()
	line(line: Number) => @module.line(line)
	listCompositeMacros(name) { // {{{
		const regex = new RegExp(`^\(name)\.`)
		const list = []

		for m, n of @macros when regex.test(n) {
			list.push(...m)
		}

		return list
	} // }}}
	listDefinedVariables() { // {{{
		const variables = []

		for const array of @variables {
			variables.push(array[array.length - 1])
		}

		return variables
	} // }}}
	listMacros(name): Array { // {{{
		if @macros[name] is Array {
			return @macros[name]
		}
		else {
			return @parent.listMacros(name)
		}
	} // }}}
	module() => @module
	parent() => @parent
	processStash(name) { // {{{
		const stash = @stashes[name]
		if ?stash {
			delete @stashes[name]

			let variable = this.getVariable(name)
			for let fn in stash {
				if fn[0](variable) {
					break
				}
			}

			variable = this.getVariable(name)
			for let fn in stash {
				fn[1](variable)
			}

			return true
		}
		else {
			return false
		}
	} // }}}
	reassignReference(oldName, newName, newScope) { // {{{
		if @references[oldName]? {
			@references[oldName].reassign(newName, newScope)
		}
	} // }}}
	reference(value, nullable: Boolean = false, parameters: Array = []) { // {{{
		switch value {
			is AnyType => return this.resolveReference('Any', nullable, parameters)
			is ClassVariableType => return this.reference(value.type(), nullable, parameters)
			is NamedType => {
				if value.hasContainer() {
					return value.container().scope().reference(value.name(), nullable, parameters)
				}
				else {
					return this.resolveReference(value.name(), nullable, parameters)
				}
			}
			is ReferenceType => return this.resolveReference(value.name(), value.isNullable(), parameters)
			is String => return this.resolveReference(value, nullable, parameters)
			is Variable => return this.resolveReference(value.name(), nullable, parameters)
			=> {
				console.info(value)
				throw new NotImplementedException()
			}
		}
	} // }}}
	releaseTempName(name) { // {{{
		@tempNames[name] = true
	} // }}}
	removeVariable(name) { // {{{
		if @variables[name] is Array {
			@variables[name].push(@line, false)
		}
		else {
			@parent.removeVariable(name)
		}
	} // }}}
	rename(name) { // {{{
		return if @renamedVariables[name] is String

		let index = this.getRenamedIndex(name)

		let newName = '__ks_' + name + '_' + (++index)

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName

		const variable = this.getVariable(name)

		variable.renameAs(newName)
	} // }}}
	rename(name, newName) { // {{{
		if newName != name {
			@renamedVariables[name] = newName

			const variable = this.getVariable(name)

			variable.renameAs(newName)
		}
	} // }}}
	replaceVariable(name: String, variable: Variable): Variable { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]

			let i = 0
			while i + 2 < variables.length && variables[i + 2] <= @line {
				i += 2
			}

			if variables[i] <= @line {
				variables[i + 1] = variable
			}
		}
		else {
			@variables[name] = [@line, variable]
		}

		return variable
	} // }}}
	replaceVariable(name: String, type: Type, downcast: Boolean = false, node: AbstractNode): Variable { // {{{
		let variable = this.getVariable(name)

		if variable.isDefinitive() {
			if !type.isAssignableToVariable(variable.getDeclaredType(), downcast) {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Array {
				variable = variable.setRealType(type)

				@variables[name].push(@line, variable)
			}
			else {
				variable = variable.clone().setRealType(type)

				@variables[name] = [@line, variable]
			}
		}

		return variable
	} // }}}
	resolveReference(name: String, nullable: Boolean, parameters: Array) { // {{{
		if @variables[name] is Array {
			const hash = ReferenceType.toQuote(name, nullable, parameters)

			if @references[hash] is not ReferenceType {
				@references[hash] = new ReferenceType(this, name, nullable, parameters)
			}

			return @references[hash]
		}
		else {
			return @parent.resolveReference(name, nullable, parameters)
		}
	} // }}}
	setLineOffset(offset: Number) => @module.setLineOffset(offset)
	updateInferable(name, data, node) { // {{{
		if data.isVariable {
			this.replaceVariable(name, data.type, true, node)
		}
		else {
			if @chunkTypes[name] is Array {
				@chunkTypes[name].push(@line, data.type)
			}
			else {
				@chunkTypes[name] = [@line, data.type]
			}
		}
	} // }}}
}