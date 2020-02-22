class HollowScope extends Scope {
	private {
		_chunkTypes					= {}
		_parent: Scope
		_variables					= {}
	}
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String => @parent.acquireTempName(declare)
	acquireUnusedTempName() => @parent.acquireUnusedTempName()
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	block() => @parent.block()
	private declareVariable(name: String, scope: Scope): String? => @parent.declareVariable(name, scope)
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

		@parent.defineVariable(variable, node)

		@variables[name] = [@parent.line(), variable]
	} // }}}
	getChunkType(name) => this.getChunkType(name, @line)
	getChunkType(name, line: Number) { // {{{
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

			if @parent.isAtLastLine() {
				variable = variables.last()
			}
			else {
				const line = @parent.line()

				for const i from 0 til variables.length by 2 while variables[i] <= line {
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
	getMacro(data, parent) => @parent.getMacro(data, parent)
	getRawLine() => @parent.getRawLine()
	getRenamedIndex(name: String): Number => @parent.getRenamedIndex(name)
	getTempIndex() => @parent.getTempIndex()
	getVariable(name): Variable? => this.getVariable(name, @parent.line())
	getVariable(name, line: Number): Variable? { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			const currentLine = @parent.line()
			let variable = null

			if line == -1 || line > currentLine {
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
				return variable!!
			}
		}

		return @parent.getVariable(name, line)
	} // }}}
	hasBleedingVariable(name: String) => @parent.hasBleedingVariable(name)
	hasDefinedVariable(name: String): Boolean => @parent.hasDefinedVariable(name, @line)
	hasDefinedVariable(name: String, line: Number): Boolean => @parent.hasDefinedVariable(name, line)
	hasDeclaredVariable(name: String): Boolean => @parent.hasDeclaredVariable(name)
	hasMacro(name) => @parent.hasMacro(name)
	hasVariable(name: String): Boolean => @parent.hasVariable(name)
	hasVariable(name: String, line: Number) => @parent.hasVariable(name, line)
	isBleeding() => true
	isInline() => true
	isRedeclaredVariable(name: String) { // {{{
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	} // }}}
	isRenamedVariable(name: String): Boolean => @parent.isRenamedVariable(name)
	line() => @parent.line()
	line(line: Number) => @parent.line(line)
	module() => @parent.module()
	parent() => @parent
	override reference(value, nullable: Boolean?, parameters: Array?) => @parent.reference(value, nullable, parameters)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	rename(name, newName) { // {{{
		if newName != name {
			const variable = this.getVariable(name).clone()

			variable.renameAs(newName)

			@variables[name] = [@parent.line(), variable]
		}
	} // }}}
	renameNext(name, line) => @parent.renameNext(name, line)
	replaceVariable(name: String, type: Type, downcast: Boolean = false, absolute: Boolean = true, node: AbstractNode): Variable { // {{{
		let variable = this.getVariable(name)!?

		if variable.isDefinitive() {
			if type.isAssignableToVariable(variable.getDeclaredType(), downcast) {
				// do nothing
			}
			else if variable.isInitialized() {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
			}
			else if type.isNullable() {
				unless type.setNullable(false).isAssignableToVariable(variable.getDeclaredType(), downcast) {
					TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
				}
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Array {
				variable.setRealType(type, absolute, this)
			}
			else {
				variable = variable.clone().setRealType(type, absolute, this)

				@variables[name] = [@parent.line(), variable]
			}
		}

		return variable
	} // }}}
	override resolveReference(name, nullable: Boolean, parameters: Array) => @parent.resolveReference(name, nullable, parameters)
	updateInferable(name, data, node) { // {{{
		if data.isVariable {
			this.replaceVariable(name, data.type, true, true, node)
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