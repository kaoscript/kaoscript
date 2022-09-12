class HollowScope extends Scope {
	private {
		@chunkTypes					= {}
		@parent: Scope
		@variables					= {}
	}
	constructor(@parent)
	private declareVariable(name: String, scope: Scope): String? => @parent.declareVariable(name, scope)
	define(name: String, immutable: Boolean, type: Type? = null, initialized: Boolean = false, node: AbstractNode): Variable { # {{{
		if @hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		var variable = new Variable(name, immutable, false, type, initialized)

		@defineVariable(variable, node)

		return variable
	} # }}}
	defineVariable(variable: Variable, node: AbstractNode) { # {{{
		var name = variable.name()

		@parent.defineVariable(variable, node)

		@variables[name] = [@parent.line(), variable]
	} # }}}
	getChunkType(name, line: Number = @line()) { # {{{
		if @chunkTypes[name] is Array {
			var types: Array = @chunkTypes[name]
			var mut type = null

			if line == -1 || line > @line() {
				type = types.last()
			}
			else {
				for var i from 0 til types.length by 2 while types[i] <= line {
					type = types[i + 1]
				}
			}

			if type != null {
				return type
			}
		}

		return @parent.getChunkType(name, -1)
	} # }}}
	getDefinedVariable(name: String) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if @parent.isAtLastLine() {
				variable = variables.last()
			}
			else {
				var line = @parent.line()

				for var i from 0 til variables.length by 2 while variables[i] <= line {
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
	} # }}}
	getVariable(name, line: Number = @parent.line()): Variable? { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var currentLine = @parent.line()
			var mut variable = null

			if line == -1 || line > currentLine {
				variable = variables.last()
			}
			else {
				for var i from 0 til variables.length by 2 while variables[i] <= line {
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
	} # }}}
	hasDefinedVariable(name: String, line: Number = @line()): Boolean => @parent.hasDefinedVariable(name, line)
	hasDeclaredVariable(name: String): Boolean => @parent.hasDeclaredVariable(name)
	hasVariable(name: String, line: Number? = null) => @parent.hasVariable(name, line)
	isBleeding() => true
	isInline() => true
	isRedeclaredVariable(name: String) { # {{{
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	} # }}}
	parent() => @parent
	reference(value) => @parent.reference(value)
	reference(value: String, nullable: Boolean = false, parameters: Array = []) => @parent.resolveReference(value, nullable, parameters)
	rename(name, newName) { # {{{
		if newName != name {
			var variable = @getVariable(name).clone()

			variable.renameAs(newName)

			@variables[name] = [@parent.line(), variable]
		}
	} # }}}
	replaceVariable(name: String, type: Type, downcast: Boolean = false, absolute: Boolean = true, node: AbstractNode): Variable { # {{{
		var mut variable = @getVariable(name)!?

		if variable.isDefinitive() {
			if type.isAssignableToVariable(variable.getDeclaredType(), downcast) {
				pass
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
	} # }}}
	updateInferable(name, data, node) { # {{{
		if data.isVariable {
			@replaceVariable(name, data.type, true, true, node)
		}
		else {
			if @chunkTypes[name] is Array {
				@chunkTypes[name].push(@line(), data.type)
			}
			else {
				@chunkTypes[name] = [@line(), data.type]
			}
		}
	} # }}}
	proxy @parent {
		acquireTempName
		acquireUnusedTempName
		authority
		block
		commitTempVariables
		declareVariable
		getMacro
		getRawLine
		getRenamedIndex
		getTempIndex
		hasBleedingVariable
		hasMacro
		isRenamedVariable
		line
		module
		releaseTempName
		renameNext
		resolveReference
	}
}
