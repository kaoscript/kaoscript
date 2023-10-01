class BlockScope extends Scope {
	private {
		@authority: Scope
		@chunkTypes							= {}
		@declarations						= {}
		@implicitType: Type?				= null
		@implicitVarname: String?			= null
		@macros								= {}
		@matchingTypes: Object<Array>		= {}
		@module: ModuleScope
		@parent: Scope
		@references							= {}
		@renamedIndexes 					= {}
		@renamedVariables					= {}
		@reservedIndex						= -1
		@stashes							= {}
		@tempDeclarations: Array			= []
		@tempIndex 							= -1
		@tempNames							= {}
		@variables							= {}
	}
	constructor(@parent) { # {{{
		super()

		@authority = @parent.authority()
		@module = @parent.module()!?
	} # }}}
	acquireTempName(declare: Boolean = true): String { # {{{
		for var _, name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		@tempIndex += 1

		var name = `__ks_\(@tempIndex)`

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

		return null
	} # }}}
	addMacro(name: String, macro: MacroDeclaration) { # {{{
		if @macros[name] is Array {
			var type = macro.type()
			var mut notAdded = true

			for var m, index in @macros[name] while notAdded {
				if m.type().isSubsetOf(type, MatchingMode.Signature) {
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
	} # }}}
	addStash(name, ...fn) { # {{{
		if ?@stashes[name] {
			@stashes[name].push(fn)
		}
		else {
			@stashes[name] = [fn]
		}
	} # }}}
	authority() => @authority
	block() => this
	commitTempVariables(variables: Array) { # {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} # }}}
	protected declareVariable(name: String, scope: Scope) { # {{{
		if $keywords[name] == true || @declarations[name] == true {
			var newName = @getNewName(name)

			if !?@variables[name] {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		}
	} # }}}
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
			var variables: Array = @variables[name]

			if variables.last() is Variable {
				SyntaxException.throwAlreadyDeclared(name, node)
			}

			variables.push(@line(), variable)
		}
		else {
			if var newName ?= @declareVariable(name, this) {
				@renamedVariables[name] = newName

				variable.renameAs(newName)
			}

			@variables[name] = [@line(), variable]
		}

		if var reference ?= @references[name] {
			reference.reset()
		}
	} # }}}
	getChunkType(name, line: Number = @line()) { # {{{
		if @chunkTypes[name] is Array {
			var types: Array = @chunkTypes[name]
			var mut type = null

			if line == -1 || line > @line() {
				type = types.last()
			}
			else {
				for var i from 0 to~ types.length step 2 while types[i] <= line {
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

			if @isAtLastLine() {
				variable = variables.last()
			}
			else {
				var line = @line()

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
	override getImplicitVariable() { # {{{
		if ?@implicitVarname {
			return {
				name: @implicitVarname
				type: @implicitType
			}
		}
		else {
			return @parent.getImplicitVariable()
		}
	} # }}}
	getLineOffset() => @module.getLineOffset()
	getMacro(name) { # {{{
		return @macros[name] ?? @parent.getMacro(name)
	} # }}}
	getNewName(name: String): String { # {{{
		var mut index = @renamedIndexes[name] is Number ? @renamedIndexes[name] + 1 : 1
		var mut newName = '__ks_' + name + '_' + index

		while @declarations[newName] {
			index += 1
			newName = '__ks_' + name + '_' + index
		}

		@renamedIndexes[name] = index

		return newName
	} # }}}
	getRawLine() => @module.getRawLine()
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getReservedName() { # {{{
		@reservedIndex += 1

		return `__ks_00\(@reservedIndex)`
	} # }}}
	getTempIndex() => @tempIndex
	getVariable(name, line: Number = @line()): Variable? { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line() {
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

		return @parent.getVariable(name, -1)
	} # }}}
	hasDeclaredVariable(name: String) => @declarations[name] || ?@renamedVariables[name]
	hasDefinedVariable(name: String) => @hasDefinedVariable(name, @line())
	hasDefinedVariable(name: String, line: Number) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line() {
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
	override hasImplicitVariable() => ?@implicitVarname || @parent.hasImplicitVariable()
	hasMacro(name) => @macros[name] is Array || @parent.hasMacro(name)
	hasVariable(name: String, line: Number = @line()) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line() {
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

		return @parent.hasVariable(name, -1)
	} # }}}
	isAtLastLine() => @module.isAtLastLine()
	isMatchingType(a: Type, b: Type, mode: MatchingMode) { # {{{
		var hash = a.toQuote()

		if var matches ?= @matchingTypes[hash] {
			for var type, i in matches step 2 {
				if type == b {
					return matches[i + 1]
				}
			}
		}
		else {
			@matchingTypes[hash] = []
		}

		@matchingTypes[hash].push(b, false)

		var index = @matchingTypes[hash].length

		var match = a.isSubsetOf(b, mode)

		@matchingTypes[hash][index - 1] = match

		return match
	} # }}}
	isRedeclaredVariable(name: String) { # {{{
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	} # }}}
	isRenamedVariable(name: String) { # {{{
		if ?@variables[name] {
			return ?@renamedVariables[name]
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} # }}}
	line() => @module.line()
	line(line: Number) => @module.line(line)
	listCompositeMacros(name) { # {{{
		var regex = RegExp.new(`^\(name)\.`)
		var list = []

		for var m, n of @macros when regex.test(n) {
			list.push(...m)
		}

		return list
	} # }}}
	listDefinedVariables() { # {{{
		var variables = []

		for var array of @variables {
			variables.push(array[array.length - 1])
		}

		return variables
	} # }}}
	listMacros(name): Array { # {{{
		if @macros[name] is Array {
			return @macros[name]
		}
		else {
			return @parent.listMacros(name)
		}
	} # }}}
	module() => @module
	parent() => @parent
	processStash(name) { # {{{
		var stash = @stashes[name]
		if ?stash {
			Object.delete(@stashes, name)

			var mut variable = @getVariable(name)
			for var mut fn in stash {
				if fn[0](variable) {
					break
				}
			}

			variable = @getVariable(name)
			for var mut fn in stash {
				fn[1](variable)
			}

			return true
		}
		else {
			return false
		}
	} # }}}
	reassignReference(oldName, newName, newScope) { # {{{
		if var reference ?= @references[oldName] {
			reference.reassign(newName, newScope)
		}

		if var reference ?= newScope._references[newName] {
			reference.reset()
		}
	} # }}}
	releaseTempName(name) { # {{{
		@tempNames[name] = true
	} # }}}
	removeVariable(name) { # {{{
		if @variables[name] is Array {
			@variables[name].push(@line(), false)
		}
		else {
			@parent.removeVariable(name)
		}
	} # }}}
	rename(name) { # {{{
		return if @renamedVariables[name] is String

		var index = @getRenamedIndex(name) + 1
		var newName = `__ks_\(name)_\(index)`

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName

		var variable = @getVariable(name)

		variable.renameAs(newName)
	} # }}}
	rename(name, newName) { # {{{
		if newName == name {
			if ?@renamedVariables[name] {
				Object.delete(@renamedVariables, name)

				var variable = @getVariable(name)

				variable.renameAs(name)
			}
		}
		else {
			@renamedVariables[name] = newName

			var variable = @getVariable(name)

			variable.renameAs(newName)
		}
	} # }}}
	replaceVariable(name: String, variable: Variable): Variable { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var line = @line()

			var mut i = 0
			while i + 2 < variables.length && variables[i + 2] <= line {
				i += 2
			}

			if variables[i] <= line {
				variables[i + 1] = variable
			}
		}
		else {
			@variables[name] = [@line(), variable]
		}

		if var reference ?= @references[name] {
			reference.reset()
		}

		return variable
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

		if var reference ?= @references[name] {
			reference.reset()
		}

		return variable
	} # }}}
	resetReferences() { # {{{
		for var reference of @references {
			reference.reset()
		}
	} # }}}
	resolveReference(name: String, explicitlyNull: Boolean = false, parameters: Array = []) { # {{{
		if @variables[name] is Array {
			var hash = ReferenceType.toQuote(name, explicitlyNull, parameters)

			if @references[hash] is not ReferenceType {
				@references[hash] = ReferenceType.new(this, name, explicitlyNull, parameters)
			}

			return @references[hash]
		}
		else {
			return @parent.resolveReference(name, explicitlyNull, parameters)
		}
	} # }}}
	setImplicitVariable(@implicitVarname, @implicitType)
	setLineOffset(offset: Number) => @module.setLineOffset(offset)
	updateInferable(name, data, node) { # {{{
		if data.isVariable {
			if @hasVariable(name) {
				@replaceVariable(name, data.type, true, true, node)
			}
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
		getPredefinedType
		hasPredefinedVariable
	}
}
