class BlockScope extends Scope {
	private {
		_declarations				= {}
		_lastLine: Boolean			= false
		_line: Number				= 0
		_macros						= {}
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
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String { // {{{
		for const :name of @tempNames when @tempNames[name] {
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
	acquireUnusedTempName(): String { // {{{
		for const :name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		return null
	} // }}}
	addMacro(name: String, macro: MacroDeclaration) { // {{{
		if @macros[name] is Array {
			const type = macro.type()
			let notAdded = true

			for m, index in @macros[name] while notAdded {
				if type.matchContentOf(m.type()) {
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
	commitTempVariables(variables: Array) { // {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} // }}}
	private declareVariable(name: String) { // {{{
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
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable { // {{{
		if this.hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type)

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
			if const newName = this.declareVariable(name) {
				@renamedVariables[name] = newName
			}

			@variables[name] = [@line, variable]
		}
	} // }}}
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

			if @lastLine {
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getRenamedVariable(name: String) { // {{{
		if @renamedVariables[name] is String {
			return @renamedVariables[name]
		}
		else {
			return @parent.getRenamedVariable(name)
		}
	} // }}}
	getTempIndex() => @tempIndex
	getVariable(name): Variable => this.getVariable(name, @line)
	getVariable(name, line: Number): Variable { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

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
			const variables:Array = @variables[name]
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
			const variables:Array = @variables[name]
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
	isAtLastLine() => @lastLine
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
	line() => @line
	line(@line)
	listMacros(name): Array { // {{{
		if @macros[name] is Array {
			return @macros[name]
		}
		else {
			return @parent.listMacros(name)
		}
	} // }}}
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
	reference(value) { // {{{
		switch value {
			is AnyType => return this.resolveReference('Any')
			is ClassVariableType => return this.reference(value.type())
			is NamedType => {
				if value.hasContainer() {
					return value.container().scope().reference(value.name())
				}
				else {
					return this.resolveReference(value.name())
				}
			}
			is ReferenceType => return this.resolveReference(value.name(), value.isNullable())
			is String => return this.resolveReference(value)
			is Variable => return this.resolveReference(value.name())
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
	rename(name, newName) { // {{{
		if newName != name {
			@renamedVariables[name] = newName
		}
	} // }}}
	replaceVariable(name: String, variable: Variable): Variable { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]

			let i = 0
			while variables[i + 2] <= @line {
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
	replaceVariable(name: String, type: Type, node): Variable { // {{{
		let variable = this.getVariable(name)

		if variable.isDefinitive() {
			if type.isAny() {
				return variable
			}

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Array {
				variable.setRealType(type)
			}
			else {
				variable = variable.clone().setRealType(type)

				@variables[name] = [@line, variable]
			}
		}

		return variable
	} // }}}
	private resolveReference(name: String, nullable = false) { // {{{
		if @variables[name] is Array {
			const hash = `\(name)\(nullable ? '?' : '')`

			if @references[hash] is not ReferenceType {
				@references[hash] = new ReferenceType(this, name, nullable)
			}

			return @references[hash]
		}
		else {
			return @parent.resolveReference(name, nullable)
		}
	} // }}}
}