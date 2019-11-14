// predefined
class ModuleScope extends Scope {
	private {
		_chunkTypes					= {}
		_declarations				= {}
		_lastLine: Boolean			= false
		_line: Number				= 0
		_lineOffset: Number			= 0
		_macros						= {}
		_predefined					= {}
		_references					= {}
		_renamedIndexes 			= {}
		_renamedVariables			= {}
		_stashes					= {}
		_tempDeclarations: Array	= []
		_tempIndex 					= -1
		_tempNames					= {}
		_variables					= {}
	}
	constructor() { // {{{
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
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)

		@predefined.__false = new Variable('false', true, true, this.reference('Boolean'))
		@predefined.__null = new Variable('null', true, true, Type.Null)
		@predefined.__true = new Variable('true', true, true, this.reference('Boolean'))
		@predefined.__Infinity = new Variable('Infinity', true, true, this.reference('Number'))
		@predefined.__Math = new Variable('Math', true, true, this.reference('Dictionary'))
		@predefined.__NaN = new Variable('NaN', true, true, this.reference('Number'))
		@predefined.__Object = new Variable('Object', true, true, new AliasType(this, new ExclusionType(this, [AnyType.Explicit, this.reference('Array'), this.reference('Boolean'), this.reference('Dictionary'), this.reference('Enum'), this.reference('Function'), this.reference('Namespace'), this.reference('Number'), this.reference('String')])))
		@predefined.__Primitive = new Variable('Primitive', true, true, new AliasType(this, new UnionType(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')])))

	} // }}}
	acquireTempName(declare: Boolean = true): String { // {{{
		for const _, name of @tempNames when @tempNames[name] {
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
	acquireUnusedTempName(): String? { // {{{
		for const _, name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		return null
	} // }}}
	addMacro(name: String, macro: MacroDeclaration) { // {{{
		if @macros[name] is Array {
			const type = macro.type()
			let notAdded = true

			for const m, index in @macros[name] while notAdded {
				if m.type().isMatching(type, MatchingMode::Signature) {
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
	block() => this
	commitTempVariables(variables: Array) { // {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} // }}}
	private declareVariable(name: String, scope: Scope) { // {{{
		if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Array) {
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
			const variables: Array = @variables[name]

			if variables.last() is Variable {
				SyntaxException.throwAlreadyDeclared(name, node)
			}

			variables.push(@line, variable)
		}
		else {
			if const newName = this.declareVariable(name, this) {
				@renamedVariables[name] = newName

				variable.renameAs(newName)
			}

			@variables[name] = [@line, variable]
		}
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

		return null
	} // }}}
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			let variable: Variable? = null

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
	getLineOffset() => @lineOffset
	getMacro(data, parent) { // {{{
		if data.callee.kind == NodeKind::Identifier {
			if @macros[data.callee.name]? {
				for macro in @macros[data.callee.name] {
					if macro.matchArguments(data.arguments) {
						return macro
					}
				}
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
	getPredefined(name: String): Type? { // {{{
		if @predefined[`__\(name)`]? {
			return @predefined[`__\(name)`].getDeclaredType()
		}
		else {
			return null
		}
	} // }}}
	getRawLine() => @line - @lineOffset
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getTempIndex() => @tempIndex
	getVariable(name): Variable? => this.getVariable(name, @line)
	getVariable(name, line: Number): Variable? { // {{{
		if @variables[name] is not Array && $types[name] is String {
			name = $types[name]
		}

		if @variables[name] is Array {
			const variables: Array = @variables[name]
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
	} // }}}
	hasDeclaredVariable(name: String) => @declarations[name] == true
	hasDefinedVariable(name: String) => this.hasDefinedVariable(name, @line)
	hasDefinedVariable(name: String, line: Number) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
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
	hasMacro(name) => @macros[name] is Array
	hasVariable(name: String) => this.hasVariable(name, @line)
	hasVariable(name: String, line: Number) { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
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

		return @predefined[`__\(name)`] is Variable
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
		return @renamedVariables[name] is String
	} // }}}
	line() => @line
	line(line: Number) { // {{{
		@line = line + @lineOffset
	} // }}}
	listCompositeMacros(name) { // {{{
		const regex = new RegExp(`^\(name)\.`)
		const list = []

		for m, n of @macros when regex.test(n) {
			list.push(...m)
		}

		return list
	} // }}}
	listDefinedVariables() { // {{{
		const variables = []

		for const array of @variables {
			variables.push(array[array.length - 1])
		}

		return variables
	} // }}}
	listMacros(name): Array { // {{{
		if @macros[name] is Array {
			return @macros[name]
		}
		else {
			return []
		}
	} // }}}
	module() => this
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
	reference(value, nullable: Boolean = false, parameters: Array = []) { // {{{
		switch value {
			is AnyType => return this.resolveReference('Any', nullable, parameters)
			is ClassVariableType => return this.reference(value.type(), nullable, parameters)
			is NamedType => {
				if value.hasContainer() {
					return value.container().scope().reference(value.name(), nullable, parameters)
				}
				else {
					return this.resolveReference(value.name(), nullable, parameters)
				}
			}
			is ReferenceType => return this.resolveReference(value.name(), value.isNullable(), parameters)
			is String => return this.resolveReference(value, nullable, parameters)
			is Variable => return this.resolveReference(value.name(), nullable, parameters)
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
	} // }}}
	replaceVariable(name: String, variable: Variable): Variable { // {{{
		if @variables[name] is Array {
			const variables: Array = @variables[name]
			const l = variables.length

			let i = 0
			while i + 2 < l && variables[i + 2] <= @line {
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
		let variable: Variable = this.getVariable(name)!?

		if variable.isDefinitive() {
			if type.isNull() && !variable.getDeclaredType().isNullable() {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
			}
			else if type.isAny() && !variable.getDeclaredType().isAny() {
				if variable.getRealType().isNull() {
					variable.setRealType(variable.getDeclaredType())
				}

				if type.isNullable() {
					variable.setRealType(variable.getRealType().setNullable(true))
				}

				return variable
			}
			else if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
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
	resolveReference(name: String, nullable: Boolean, parameters: Array) { // {{{
		const hash = ReferenceType.toQuote(name, nullable, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable, parameters)
		}

		return @references[hash]
	} // }}}
	setLineOffset(@lineOffset)
	updateInferable(name, data, node) { // {{{
		if data.isVariable {
			this.replaceVariable(name, data.type, node)
		}
		else {
			if @chunkTypes[name] is Array {
				@chunkTypes.push(@line, data.type)
			}
			else {
				@chunkTypes[name] = [@line, data.type]
			}
		}
	} // }}}
}