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
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	private declareVariable(name: String) => @parent.declareVariable(name)
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable { // {{{
		if this.hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type)

		this.defineVariable(variable, node)

		return variable
	} // }}}
	/* defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = variable

		if const newName = @parent.declareVariable(name) {
			@renamedVariables[name] = newName
		}
	} // }}} */
	defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		if @variables[name] is Array {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = [@parent.line(), variable]

		if const newName = @parent.declareVariable(name) {
			@renamedVariables[name] = newName
		}
	} // }}}
	/* getDefinedVariable(name: String) { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return null
		}
	} // }}} */
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getRenamedVariable(name: String) { // {{{
		/* if @variables[name] is Variable { */
		if @variables[name] is Array {
			if @renamedVariables[name] is String {
				return @renamedVariables[name]
			}
			else {
				return name
			}
		}
		else {
			return @parent.getRenamedVariable(name)
		}
	} // }}}
	getTempIndex() => @parent.getTempIndex()
	/* getVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return @parent.getVariable(name)
		}
	} // }}} */
	/* getVariable(name): Variable => this.getVariable(name, 0)
	getVariable(name, delta: Number): Variable { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

			if @parent.isAtLastLine() {
				variable = variables.last()
			}
			else {
				const line = @parent.line() + delta

				for const i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable == false {
				return @parent.getVariable(name)
			}
			else if variable != null {
				return variable
			}
		}

		return @parent.getVariable(name)
	} // }}} */
	getVariable(name): Variable => this.getVariable(name, @parent.line())
	getVariable(name, line: Number): Variable { // {{{
		/* console.log('bleeding', name, line) */
		if @variables[name] is Array {
			const variables:Array = @variables[name]
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
			/* console.log(variable == false, variable != null) */

			if variable == false {
				return @parent.getVariable(name, -1)
			}
			else if variable != null {
				return variable
			}
		}

		return @parent.getVariable(name, -1)
	} // }}}
	/* hasDeclaredVariable(name: String) => @variables[name] is Variable || @parent.hasDeclaredVariable(name)
	hasDefinedVariable(name: String) => @variables[name] is Variable
	hasVariable(name: String) => @variables[name] is Variable || @parent.hasVariable(name) */
	/* hasDeclaredVariable(name: String) => @variables[name] is Array || @parent.hasDeclaredVariable(name) */
	hasDeclaredVariable(name: String) => @variables[name] is Array || @parent.hasDeclaredVariable(name)
	/* hasDefinedVariable(name: String) => @variables[name] is Array */
	hasDefinedVariable(name: String) => this.hasDefinedVariable(name, @parent.line())
	hasDefinedVariable(name: String, line: Number) {
		if @variables[name] is Array {
			const variables:Array = @variables[name]
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
	}
	hasVariable(name: String) => @variables[name] is Array || @parent.hasVariable(name)
	hasVariable(name: String, line: Number) => @variables[name] is Array || @parent.hasVariable(name, line)
	isBleeding() => true
	isInline() => true
	isRedeclaredVariable(name: String) {
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	}
	isRenamedVariable(name: String) { // {{{
		/* if @variables[name] is Variable { */
		if @variables[name] is Array {
			return @renamedVariables[name] is String
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} // }}}
	parent() => @parent
	reference(value) => @parent.reference(value)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	rename(name) { // {{{
		return if @renamedVariables[name] is String

		let index = @parent.getRenamedIndex(name)

		let newName = '__ks_' + name + '_' + (++index)

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName
	} // }}}
	private resolveReference(name: String, nullable = false) => @parent.resolveReference(name, nullable)
}