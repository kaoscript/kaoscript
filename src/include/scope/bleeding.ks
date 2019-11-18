// declare variable at parent
class BleedingScope extends Scope {
	private {
		_parent: Scope
		_renamedIndexes 			= {}
		_renamedVariables			= {}
		_variables					= {}
	}
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String => @parent.acquireTempName(declare)
	acquireUnusedTempName() => @parent.acquireUnusedTempName()
	block() => @parent.block()
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	private declareVariable(name: String, scope: Scope) => @parent.declareVariable(name, scope)
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
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = [@parent.line(), variable]

		if const newName = @parent.declareVariable(name, this) {
			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}
	} // }}}
	getChunkType(name, line) => @parent.getChunkType(name, line)
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
	getRawLine() => @parent.getRawLine()
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getTempIndex() => @parent.getTempIndex()
	getVariable(name): Variable => this.getVariable(name, @parent.line())
	getVariable(name, line: Number): Variable { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			const currentLine = @parent.line()
			let variable: Variable? = null

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
				return variable
			}
		}

		return @parent.getVariable(name, line)
	} // }}}
	hasDeclaredVariable(name: String) => @variables[name] is Array || @parent.hasDeclaredVariable(name)
	hasDefinedVariable(name: String) => this.hasDefinedVariable(name, @parent.line())
	hasDefinedVariable(name: String, line: Number) { // {{{
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

			if variable != null {
				return variable != false
			}
		}

		return false
	} // }}}
	hasVariable(name: String) => @variables[name] is Array || @parent.hasVariable(name)
	hasVariable(name: String, line: Number) => @variables[name] is Array || @parent.hasVariable(name, line)
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
	isRenamedVariable(name: String) { // {{{
		if @variables[name] is Array {
			return @renamedVariables[name] is String
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} // }}}
	line() => @parent.line()
	line(line: Number) => @parent.line(line)
	module() => @parent.module()
	parent() => @parent
	override reference(value, nullable: Boolean?, parameters: Array?) => @parent.reference(value, nullable, parameters)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	rename(name) { // {{{
		return if @renamedVariables[name] is String

		let index = @parent.getRenamedIndex(name)

		let newName = '__ks_' + name + '_' + (++index)

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName

		const variable = this.getVariable(name)

		variable.renameAs(newName)
	} // }}}
	override resolveReference(name, nullable: Boolean, parameters: Array) => @parent.resolveReference(name, nullable, parameters)
}