// predefined
class ModuleScope extends Scope {
	private {
		_declarations				= {}
		_lastLine: Boolean			= false
		_line: Number				= 0
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
		@predefined.__Error = Variable.createPredefinedClass('Error', this)
		@predefined.__Function = Variable.createPredefinedClass('Function', this)
		@predefined.__Number = Variable.createPredefinedClass('Number', this)
		@predefined.__Object = Variable.createPredefinedClass('Object', this)
		@predefined.__String = Variable.createPredefinedClass('String', this)
		@predefined.__RegExp = Variable.createPredefinedClass('RegExp', this)

		@predefined.__false = new Variable('false', true, true, this.reference('Boolean'))
		@predefined.__null = new Variable('null', true, true, Type.Null)
		@predefined.__true = new Variable('true', true, true, this.reference('Boolean'))
		@predefined.__Infinity = new Variable('Infinity', true, true, this.reference('Number'))
		@predefined.__Math = new Variable('Math', true, true, this.reference('Object'))
		@predefined.__NaN = new Variable('NaN', true, true, this.reference('Number'))
	} // }}}
	acquireTempName(declare: Boolean = true): String { // {{{
		for const name of @tempNames when @tempNames[name] {
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
	acquireUnusedTempName(): String { // {{{
		for const name of @tempNames when @tempNames[name] {
			@tempNames[name] = false

			return name
		}

		return null
	} // }}}
	addMacro(name: String, macro: MacroDeclaration) { // {{{
		if @macros[name] is Array {
			const type = macro.type()
			let na = true

			for m, index in @macros[name] while na {
				if m.type().matchContentTo(type) {
					@macros[name].splice(index, 0, macro)

					na = false
				}
			}

			if na {
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
	commitTempVariables(variables: Array) { // {{{
		variables.pushUniq(...@tempDeclarations)

		@tempDeclarations.clear()
	} // }}}
	private declareVariable(name: String) { // {{{
		/* if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Variable) {
			const newName = this.getNewName(name)

			if @variables[name] is not Variable {
				@declarations[newName] = true
			}

			return newName
		}
		else {
			@declarations[name] = true

			return null
		} */
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
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable { // {{{
		/* if @variables[name] is Variable { */
		if this.hasDefinedVariable(name) {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type)

		this.defineVariable(variable, node)

		return variable
	} // }}}
	defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		/* if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if const newName = this.declareVariable(name) {
			@renamedVariables[name] = newName
		} */
		if @variables[name] is Array {
			const variables: Array = @variables[name]

			if variables.last() is Variable {
				SyntaxException.throwAlreadyDeclared(name, node)
			}

			variables.push(@line, variable)
		}
		else {
			if const newName = this.declareVariable(name) {
				@renamedVariables[name] = newName
			}

			@variables[name] = [@line, variable]
		}

		/* @variables[name] = variable */
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getRenamedVariable(name: String) { // {{{
		if @renamedVariables[name] is String {
			return @renamedVariables[name]
		}
		else {
			return name
		}
	} // }}}
	getTempIndex() => @tempIndex
	/* getVariable(name): Variable => this.getVariable(name, 0)
	getVariable(name, delta: Number): Variable { // {{{
		if $types[name] is String {
			name = $types[name]
		}

		/* if @variables[name] is Variable {
			return @variables[name]
		}
		else if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		} */
		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

			if @lastLine {
				variable = variables.last()
			}
			else {
				const line = @line + delta

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
	} // }}} */
	getVariable(name): Variable => this.getVariable(name, @line)
	getVariable(name, line: Number): Variable { // {{{
		/* console.log('module', name, line) */
		if $types[name] is String {
			name = $types[name]
		}

		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

			if line == -1 || line > @line {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= line {
					variable = variables[i + 1]
				}
			}
			/* console.log(variable == false, variable != null) */

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
	/* hasDefinedVariable(name: String) =>	@variables[name] is Variable */
	/* hasDefinedVariable(name: String) =>	@variables[name] is Array */
	hasDefinedVariable(name: String) => this.hasDefinedVariable(name, @line)
	hasDefinedVariable(name: String, line: Number) {
		if @variables[name] is Array {
			const variables:Array = @variables[name]
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
	}
	hasMacro(name) => @macros[name] is Array
	/* hasVariable(name: String) =>	@variables[name] is Variable
									|| $types[name] is String
									|| $natives[name] == true
									|| @predefined[`__\(name)`] is Variable */
	/* hasVariable(name: String) {
		if @variables[name] is Array {
			const variables:Array = @variables[name]
			let variable = null

			if @lastLine {
				variable = variables.last()
			}
			else {
				for const i from 0 til variables.length by 2 while variables[i] <= @line {
					variable = variables[i + 1]
				}
			}

			if variable != null {
				return variable != false
			}
		}

		return $types[name] is String || $natives[name] == true	|| @predefined[`__\(name)`] is Variable
	} */
	hasVariable(name: String) => this.hasVariable(name, @line)
	hasVariable(name: String, line: Number) {
		if @variables[name] is Array {
			const variables:Array = @variables[name]
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

		return $types[name] is String || $natives[name] == true	|| @predefined[`__\(name)`] is Variable
	}
	isAtLastLine() => @lastLine
	isRedeclaredVariable(name: String) {
		if @variables[name] is Array {
			return @variables[name].length != 2
		}
		else {
			return false
		}
	}
	isRenamedVariable(name: String) { // {{{
		return @renamedVariables[name] is String
	} // }}}
	line() => @line
	line(@line)
	/* line(line: Number) {
		if @line <= line {
			@line = line
		}
		else {
			@lastLine = true
		}
	} */
	listMacros(name): Array { // {{{
		if @macros[name] is Array {
			return @macros[name]
		}
		else {
			return []
		}
	} // }}}
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
	reference(value) { // {{{
		switch value {
			is AnyType => return this.resolveReference('Any')
			is ClassVariableType => return this.reference(value.type())
			is NamedType => {
				if value.hasContainer() {
					return value.container().scope().reference(value.name())
				}
				else {
					return this.resolveReference(value.name())
				}
			}
			is ReferenceType => return this.resolveReference(value.name(), value.isNullable())
			is String => return this.resolveReference(value)
			is Variable => return this.resolveReference(value.name())
			=> {
				console.log(value)
				throw new NotImplementedException()
			}
		}
	} // }}}
	/* reference(value: String, nullable: Boolean = false) { // {{{
		return this.resolveReference(value, nullable)
	} // }}} */
	releaseTempName(name) { // {{{
		@tempNames[name] = true
	} // }}}
	removeVariable(name) { // {{{
		/* if @variables[name] is Variable {
			@variables[name] = false
		} */
		if @variables[name] is Array {
			@variables[name].push(@line, false)
		}
	} // }}}
	/* replaceVariable(name: String, variable: Variable) { // {{{
		@variables[name] = variable
	} // }}} */
	replaceVariable(name: String, variable: Variable) { // {{{
		if @variables[name] is Array {
			const variables:Array = @variables[name]

			let i = 0
			while variables[i + 2] <= @line {
				i += 2
			}

			if variables[i] <= @line {
				variables[i + 1] = variable
			}
		}
		else {
			@variables[name] = [@line, variable]
		}
	} // }}}
	replaceVariable(name: String, type: Type, node) { // {{{
		const variable = this.getVariable(name)

		if variable.isDefinitive() {
			return if type.isAny()

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
			}
		}

		if !type.equals(variable.getRealType()) {
			/* if @variables[name] is Variable { */
			if @variables[name] is Array {
				variable.setRealType(type)
			}
			else {
				/* @variables[name] = variable.clone().setRealType(type) */
				@variables[name] = [@line, variable.clone().setRealType(type)]
			}
		}
	} // }}}
	private resolveReference(name: String, nullable: Boolean = false) { // {{{
		const hash = `\(name)\(nullable ? '?' : '')`

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable)
		}

		return @references[hash]
	} // }}}
}