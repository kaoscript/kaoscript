class ModuleScope extends Scope {
	private {
		@chunkTypes							= {}
		@declarations						= {}
		@labelIndex							= -1
		@lastLine: Boolean					= false
		@line: Number						= 0
		@lineOffset: Number					= 0
		@macros: MacroDeclaration[]{}		= {}
		@matchingTypes: Object<Array>		= {}
		@predefined							= {}
		@references							= {}
		@renamedIndexes 					= {}
		@renamedVariables					= {}
		@reservedIndex		 				= -1
		@standardLibrary: Boolean			= false
		@stashes							= {}
		@tempDeclarations: Array			= []
		@tempIndex		 					= -1
		@tempNames							= {}
		@variables							= {}
	}
	constructor(@standardLibrary) { # {{{
		super()

		@predefined.__Array = Variable.createPredefinedClass('Array', this)
		@predefined.__Boolean = Variable.createPredefinedClass('Boolean', this)
		@predefined.__Class = Variable.createPredefinedClass('Class', this)
		@predefined.__Date = Variable.createPredefinedClass('Date', this)
		@predefined.__Enum = Variable.createPredefinedClass('Enum', this)
		@predefined.__Error = Variable.createPredefinedClass('Error', this)
		@predefined.__Function = Variable.createPredefinedClass('Function', this)
		@predefined.__Math = Variable.createPredefinedNamespace('Math', this)
		@predefined.__Namespace = Variable.createPredefinedClass('Namespace', this)
		@predefined.__Number = Variable.createPredefinedClass('Number', this)
		@predefined.__String = Variable.createPredefinedClass('String', this)
		@predefined.__Struct = Variable.createPredefinedClass('Struct', this)
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)
		@predefined.__Tuple = Variable.createPredefinedClass('Tuple', this)

		@predefined.__false = Variable.new('false', true, true, this.reference('Boolean'))
		@predefined.__null = Variable.new('null', true, true, NullType.Explicit)
		@predefined.__true = Variable.new('true', true, true, this.reference('Boolean'))
		@predefined.__Any = Variable.new('Any', true, true, AnyType.Explicit)
		@predefined.__Infinity = Variable.new('Infinity', true, true, this.reference('Number'))
		@predefined.__NaN = Variable.new('NaN', true, true, this.reference('Number'))
		@predefined.__Never = Variable.new('Null', true, true, Type.Never)
		@predefined.__Null = Variable.new('Null', true, true, NullType.Explicit)
		@predefined.__Primitive = Variable.new('Primitive', true, true, AliasType.new(this, UnionType.new(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')])))
		@predefined.__Object = Variable.createPredefinedClass('Object', ClassFeature.StaticMethod, this)
		@predefined.__Void = Variable.new('Void', true, true, Type.Void)
	} # }}}
	override acquireNewLabel() { # {{{
		@labelIndex += 1

		return `__ks_lbl_\(@labelIndex)`
	} # }}}
	acquireTempName(declare: Boolean = true): String { # {{{
		if declare {
			for var _, name of @tempNames when @tempNames[name] {
				@tempNames[name] = false

				return name
			}
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
		if ?@macros[name] {
			var type = macro.type()
			var mut notAdded = true

			for var m, index in @macros[name] while notAdded {
				if type.isSubsetOf(m.type(), MatchingMode.Signature) {
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
	override declareVariable(name, scope) { # {{{
		if $keywords[name] || (@declarations[name] && ?@variables[name]) {
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
	override define(name, immutable, type, initialized, overwrite, node) { # {{{
		if @hasDefinedVariable(name) {
			var variable = @getVariable(name)

			unless variable.isStandardLibrary() && node is DependencyStatement | ImplementDeclaration | Importer {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
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

		variable.flagModule()

		if node is Statement {
			variable.declaration(node)
		}

		@defineVariable(variable, node)

		return variable
	} # }}}
	override defineVariable(variable, node) { # {{{
		var name = variable.name()

		if ?@variables[name] {
			var variables: Array = @variables[name]
			var last = variables.last()

			if last is Variable {
				var declaration = last.declaration()

				if last.isStandardLibrary() && node is DependencyStatement {
					pass
				}
				else if declaration is ImportDeclarator {
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
				for var i from 0 to~ types.length step 2 while types[i] <= line {
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
	getLineOffset() => @lineOffset
	getMacro(name) => @macros[name]
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
	override getPredefinedType(name) { # {{{
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
		if !?@variables[name] && ?$types[name] {
			name = $types[name]
		}

		if ?@variables[name] {
			var variables = @variables[name]:!!!(Array)
			var mut variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for var i from 0 to~ variables.length step 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}

			if ?variable {
				return variable == false ? null : variable
			}
		}

		return @predefined[`__\(name)`] ?? null
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
	hasDefinedVariableBefore(name: String, line: Number) { # {{{
		if @variables[name] is Array {
			return @variables[name][0] < line
		}

		return false
	} # }}}
	hasMacro(name) => ?@macros[name]
	override hasPredefinedVariable(name) { # {{{
		return @predefined[`__\(name)`] is Variable
	} # }}}
	hasVariable(name: String, line: Number = @line) { # {{{
		if @variables[name] is Array {
			var variables: Array = @variables[name]
			var mut variable = null

			if line == -1 || line > @line {
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

		return @predefined[`__\(name)`] is Variable
	} # }}}
	isAtLastLine() => @lastLine
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
		return @renamedVariables[name] is String
	} # }}}
	isStandardLibrary() => @standardLibrary
	line() => @line
	line(line: Number) { # {{{
		@line = line + @lineOffset
	} # }}}
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
	listMacros(): MacroDeclaration[] => [...m for var m of @macros]
	listMacros(name): Array => @macros[name] ?? []
	module() => this
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
				TypeException.throwInvalidAssignment(name, variable.getDeclaredType(), type, node)
			}
			else if type.isNullable() {
				unless type.setNullable(false).isAssignableToVariable(variable.getDeclaredType(), downcast) {
					TypeException.throwInvalidAssignment(name, variable.getDeclaredType(), type, node)
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
	resetReferences() { # {{{
		for var reference of @references {
			reference.reset()
		}
	} # }}}
	override resolveReference(name, explicitlyNull, parameters, subtypes) { # {{{
		var hash = ReferenceType.toQuote(name, explicitlyNull, parameters, subtypes)

		@references[hash] ??= ReferenceType.new(this, name, explicitlyNull, parameters, subtypes)

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
