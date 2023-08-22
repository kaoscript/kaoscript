// declare variable at parent
class BleedingScope extends Scope {
	private {
		@parent: Scope
		@renamedIndexes 			= {}
		@renamedVariables			= {}
		@variables					= {}
	}
	constructor(@parent)
	private declareVariable(name: String, scope: Scope) => @parent.declareVariable(name, scope)
	define(name: String, immutable: Boolean, type: Type? = null, initialized: Boolean = false, node: AbstractNode): Variable { # {{{
		if @hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}
		else if @hasPredefinedVariable(name) {
			var variable = @getPredefinedType(name)

			if variable.isVirtual() {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
			else if ?type && !(type.isAlien() || type.isSystem()) {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
		}

		var variable = Variable.new(name, immutable, false, type, initialized)

		@defineVariable(variable, node)

		return variable
	} # }}}
	defineVariable(variable: Variable, node: AbstractNode) { # {{{
		var name = variable.name()

		if @variables[name] is Array {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = [@parent.line(), variable]

		if var newName ?= @parent.declareVariable(name, this) {
			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}
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

				for var i from 0 to~ variables.length step 2 while variables[i] <= line {
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getVariable(name, line: Number = @parent.line()): Variable? { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var currentLine = @parent.line()
			var mut variable = null

			if line == -1 || line > currentLine {
				variable = variables.last()
			}
			else {
				for var i from 0 to~ variables.length step 2 while variables[i] <= line {
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
	hasDeclaredVariable(name: String) => @variables[name] is Array || @parent.hasDeclaredVariable(name)
	hasDefinedVariable(name: String) => @hasDefinedVariable(name, @parent.line())
	hasDefinedVariable(name: String, line: Number) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var currentLine = @parent.line()
			var mut variable = null

			if line == -1 || line > currentLine {
				variable = variables.last()
			}
			else {
				for var i from 0 to~ variables.length step 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return false
	} # }}}
	hasVariable(name: String, line: Number? = null) => @variables[name] is Array || @parent.hasVariable(name, line)
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
	isRenamedVariable(name: String) { # {{{
		if @variables[name] is Array {
			return @renamedVariables[name] is String
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} # }}}
	parent() => @parent
	rename(name) { # {{{
		return if @renamedVariables[name] is String

		var index = @parent.getRenamedIndex(name) + 1
		var newName = '__ks_' + name + '_' + index

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName

		var variable = @getVariable(name)

		variable.renameAs(newName)
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
				variable = variable.setRealType(type, absolute, this)

				@variables[name].push(@line(), variable)
			}
			else {
				variable = variable.clone().setRealType(type, absolute, this)

				@variables[name] = [@line(), variable]
			}
		}

		return variable
	} # }}}
	updateInferable(name, data, node) { # {{{
		if data.isVariable {
			if @hasVariable(name) {
				@replaceVariable(name, data.type, true, true, node)
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
		getChunkType
		getMacro
		getPredefinedType
		getRawLine
		getTempIndex
		hasMacro
		hasPredefinedVariable
		isMatchingType
		line
		module
		releaseTempName
		reference
		resolveReference
	}
}
