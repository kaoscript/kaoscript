// predefined
class ModuleScope extends Scope {
	private {
		_declarations				= {}
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
		if $keywords[name] == true || (@declarations[name] == true && @variables[name] is Variable) {
			const newName = this.getNewName(name)

			if @variables[name] is not Variable {
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
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type)

		this.defineVariable(variable, node)

		return variable
	} // }}}
	defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		if const newName = this.declareVariable(name) {
			@renamedVariables[name] = newName
		}

		@variables[name] = variable
	} // }}}
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return null
		}
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
	getVariable(name): Variable { // {{{
		if $types[name] is String {
			name = $types[name]
		}

		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		}
	} // }}}
	hasDeclaredVariable(name: String) => @declarations[name] == true
	hasDefinedVariable(name: String) =>	@variables[name] is Variable
	hasMacro(name) => @macros[name] is Array
	hasVariable(name: String) =>	@variables[name] is Variable
									|| $types[name] is String
									|| $natives[name] == true
									|| @predefined[`__\(name)`] is Variable
	isRenamedVariable(name: String) { // {{{
		return @renamedVariables[name] is String
	} // }}}
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
	releaseTempName(name) { // {{{
		@tempNames[name] = true
	} // }}}
	removeVariable(name) { // {{{
		if @variables[name] is Variable {
			@variables[name] = false
		}
	} // }}}
	replaceVariable(name: String, variable: Variable) { // {{{
		@variables[name] = variable
	} // }}}
	replaceVariable(name: String, immutable: Boolean, type: Type) { // {{{
		@variables[name] = new Variable(name, immutable, false, type)
	} // }}}
	private resolveReference(name: String, nullable = false) { // {{{
		const hash = `\(name)\(nullable ? '?' : '')`

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable)
		}

		return @references[hash]
	} // }}}
}