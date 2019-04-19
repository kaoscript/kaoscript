class HollowScope extends Scope {
	private {
		_parent: Scope
		_variables					= {}
	}
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String => @parent.acquireTempName(declare)
	acquireUnusedTempName() => @parent.acquireUnusedTempName()
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	private declareVariable(name: String): String? => @parent.declareVariable(name)
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

		@parent.defineVariable(variable, node)

		/* @variables[name] = variable */
		@variables[name] = [@parent.line(), variable]
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
	getRenamedIndex(name: String): Number => @parent.getRenamedIndex(name)
	getRenamedVariable(name: String): String => @parent.getRenamedVariable(name)
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
		/* console.log('hollow', name, line) */
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
	hasDefinedVariable(name: String): Boolean => @parent.hasDefinedVariable(name)
	hasDeclaredVariable(name: String): Boolean => @parent.hasDeclaredVariable(name)
	hasVariable(name: String): Boolean => @parent.hasVariable(name)
	hasVariable(name: String, line: Number) => @parent.hasVariable(name, line)
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
	parent() => @parent
	reference(value): ReferenceType => @parent.reference(value)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	/* replaceVariable(name: String, type: Type, node) { // {{{
		const variable = this.getVariable(name)

		if variable.isDefinitive() {
			return if type.isAny()

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Variable {
				variable.setRealType(type)
			}
			else {
				@variables[name] = variable.clone().setRealType(type)
			}
		}
	} // }}} */
	replaceVariable(name: String, type: Type, node) { // {{{
		const variable = this.getVariable(name)

		if variable.isDefinitive() {
			return if type.isAny()

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Array {
				variable.setRealType(type)
			}
			else {
				@variables[name] = [@parent.line(), variable.clone().setRealType(type)]
			}
		}
	} // }}}
	private resolveReference(name: String, nullable = false) => @parent.resolveReference(name, nullable)
}