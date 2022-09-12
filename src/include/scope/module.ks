class ModuleScope extends Scope {
	private {
		@chunkTypes							= {}
		@declarations						= {}
		@lastLine: Boolean					= false
		@line: Number						= 0
		@lineOffset: Number					= 0
		@macros								= {}
		@matchingTypes: Dictionary<Array>	= {}
		@predefined							= {}
		@references							= {}
		@renamedIndexes 					= {}
		@renamedVariables					= {}
		@reservedIndex		 				= -1
		@stashes							= {}
		@tempDeclarations: Array			= []
		@tempIndex		 					= -1
		@tempNames							= {}
		@variables							= {}
	}
	constructor() { # {{{
		super()

		@predefined.__Array = Variable.createPredefinedClass('Array', this)
		@predefined.__Boolean = Variable.createPredefinedClass('Boolean', this)
		@predefined.__Class = Variable.createPredefinedClass('Class', this)
		@predefined.__Date = Variable.createPredefinedClass('Date', this)
		@predefined.__Dictionary = Variable.createPredefinedClass('Dictionary', this)
		@predefined.__Enum = Variable.createPredefinedClass('Enum', this)
		@predefined.__Error = Variable.createPredefinedClass('Error', this)
		@predefined.__Function = Variable.createPredefinedClass('Function', this)
		@predefined.__Namespace = Variable.createPredefinedClass('Namespace', this)
		@predefined.__Number = Variable.createPredefinedClass('Number', this)
		@predefined.__String = Variable.createPredefinedClass('String', this)
		@predefined.__Struct = Variable.createPredefinedClass('Struct', this)
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)
		@predefined.__Tuple = Variable.createPredefinedClass('Tuple', this)

		@predefined.__false = new Variable('false', true, true, this.reference('Boolean'))
		@predefined.__null = new Variable('null', true, true, NullType.Explicit)
		@predefined.__true = new Variable('true', true, true, this.reference('Boolean'))
		@predefined.__Infinity = new Variable('Infinity', true, true, this.reference('Number'))
		@predefined.__Math = new Variable('Math', true, true, this.reference('Dictionary'))
		@predefined.__NaN = new Variable('NaN', true, true, this.reference('Number'))
		@predefined.__Object = new Variable('Object', true, true, new AliasType(this, new ExclusionType(this, [AnyType.Explicit, this.reference('Array'), this.reference('Boolean'), this.reference('Dictionary'), this.reference('Enum'), this.reference('Function'), this.reference('Namespace'), this.reference('Number'), this.reference('String'), this.reference('Struct'), this.reference('Tuple')])))
		@predefined.__Primitive = new Variable('Primitive', true, true, new AliasType(this, new UnionType(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')])))
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
				if type.isSubsetOf(m.type(), MatchingMode::Signature) {
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
	authority() => this
	block() => this
	commitTempVariables(variables: Array) { # {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} # }}}
	private declareVariable(name: String, scope: Scope) { # {{{
		if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Array) {
			var newName = @getNewName(name)

			if @variables[name] is not Array {
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

		var variable = new Variable(name, immutable, false, type, initialized)

		variable.flagModule()

		if node is Statement {
			variable.declaration(node)
		}

		@defineVariable(variable, node)

		return variable
	} # }}}
	defineVariable(variable: Variable, node: AbstractNode) { # {{{
		var name = variable.name()

		if @variables[name] is Array {
			var variables: Array = @variables[name]

			var last = variables.last()
			if last is Variable {
				var declaration = last.declaration()
				if declaration is ImportDeclarator {
					SyntaxException.throwAlreadyImported(name, declaration.getModuleName(), declaration.line(), node)
				}
				else {
					SyntaxException.throwAlreadyDeclared(name, node)
				}
			}

			variables.push(@line, variable)
		}
		else {
			if var newName ?= @declareVariable(name, this) {
				@renamedVariables[name] = newName

				variable.renameAs(newName)
			}

			@variables[name] = [@line, variable]
		}

		if var reference ?= @references[name] {
			reference.reset()
		}
	} # }}}
	getChunkType(name) => @getChunkType(name, @line)
	getChunkType(name, line: Number) { # {{{
		if @chunkTypes[name] is Array {
			var types: Array = @chunkTypes[name]
			var mut type = null

			if line == -1 || line > @line {
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

		return null
	} # }}}
	getDefinedVariable(name: String) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if @lastLine {
				variable = variables.last()
			}
			else {
				var line = @line

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
	getLineOffset() => @lineOffset
	getMacro(data, parent) { # {{{
		if data.callee.kind == NodeKind::Identifier {
			if ?@macros[data.callee.name] {
				var arguments = MacroArgument.build(data.arguments)

				for var macro in @macros[data.callee.name] {
					if macro.matchArguments(arguments) {
						return macro
					}
				}
			}

			SyntaxException.throwUnmatchedMacro(data.callee.name, parent, data)
		}
		else {
			var path = Generator.generate(data.callee)

			if ?@macros[path] {
				var arguments = MacroArgument.build(data.arguments)

				for macro in @macros[path] {
					if macro.matchArguments(arguments) {
						return macro
					}
				}
			}

			SyntaxException.throwUnmatchedMacro(path, parent, data)
		}
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
	getPredefined(name: String): Type? { # {{{
		if ?@predefined[`__\(name)`] {
			return @predefined[`__\(name)`].getDeclaredType()
		}
		else {
			return null
		}
	} # }}}
	getRawLine() => @line - @lineOffset
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getReservedName() { # {{{
		@reservedIndex += 1

		return `__ks_00\(@reservedIndex)`
	} # }}}
	getTempIndex() => @tempIndex
	getVariable(mut name, line: Number = @line): Variable? { # {{{
		if @variables[name] is not Array && $types[name] is String {
			name = $types[name]
		}

		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
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

		if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		}
	} # }}}
	hasDeclaredVariable(name: String) => @declarations[name] == true
	hasDefinedVariable(name: String) => @hasDefinedVariable(name, @line)
	hasDefinedVariable(name: String, line: Number) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for var i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return false
	} # }}}
	hasDefinedVariableBefore(name: String, line: Number) { # {{{
		if @variables[name] is Array {
			return @variables[name][0] < line
		}

		return false
	} # }}}
	hasMacro(name) => @macros[name] is Array
	hasVariable(name: String, line: Number = @line) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for var i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return @predefined[`__\(name)`] is Variable
	} # }}}
	isAtLastLine() => @lastLine
	isMatchingType(a: Type, b: Type, mode: MatchingMode) { # {{{
		var hash = a.toQuote()

		if var matches ?= @matchingTypes[hash] {
			for var type, i in matches by 2 {
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
		return @renamedVariables[name] is String
	} # }}}
	line() => @line
	line(line: Number) { # {{{
		@line = line + @lineOffset
	} # }}}
	listCompositeMacros(name) { # {{{
		var regex = new RegExp(`^\(name)\.`)
		var list = []

		for m, n of @macros when regex.test(n) {
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
			return []
		}
	} # }}}
	module() => this
	processStash(name) { # {{{
		var stash = @stashes[name]
		if ?stash {
			delete @stashes[name]

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
	releaseTempName(name) { # {{{
		@tempNames[name] = true
	} # }}}
	removeVariable(name) { # {{{
		if @variables[name] is Array {
			@variables[name].push(@line, false)
		}
	} # }}}
	replaceVariable(name: String, variable: Variable): Variable { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var l = variables.length
			var line = @line

			var mut i = 0
			while i + 2 < l && variables[i + 2] <= line {
				i += 2
			}

			if variables[i] <= line {
				variables[i + 1] = variable
			}
		}
		else {
			@variables[name] = [@line, variable]
		}

		if var reference ?= @references[name] {
			reference.reset()
		}

		return variable
	} # }}}
	replaceVariable(name: String, type: Type, downcast: Boolean = false, absolute: Boolean = true, node: AbstractNode): Variable { # {{{
		var mut variable: Variable = @getVariable(name)!?

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

				@variables[name] = [@line, variable]
			}
		}

		if var reference ?= @references[name] {
			reference.reset()
		}

		return variable
	} # }}}
	resolveReference(name: String, explicitlyNull: Boolean = false, parameters: Array = []) { # {{{
		var hash = ReferenceType.toQuote(name, explicitlyNull, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, explicitlyNull, parameters)
		}

		return @references[hash]
	} # }}}
	setLineOffset(@lineOffset)
	updateInferable(name, data, node) { # {{{
		if data.isVariable {
			@replaceVariable(name, data.type, true, true, node)
		}
		else {
			if @chunkTypes[name] is Array {
				@chunkTypes[name].push(@line, data.type)
			}
			else {
				@chunkTypes[name] = [@line, data.type]
			}
		}
	} # }}}
}
