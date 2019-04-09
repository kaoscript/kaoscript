// natives
class MacroScope extends Scope {
	private {
		_natives			= {}
		_references			= {}
		_renamedIndexes 	= {}
		_renamedVariables	= {}
		_variables			= {}
	}
	addNative(name: String) { // {{{
		@natives[name] = new Variable(name, true, false, Type.Any)
	} // }}}
	addNative(name: String, type: String) { // {{{
		@natives[name] = new Variable(name, true, false, this.reference(type))
	} // }}}
	private declareVariable(name: String) { // {{{
		if $keywords[name] == true || @renamedIndexes[name] is Number {
			let index = @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
			let newName = '__ks_' + name + '_' + (++index)

			while @variables[newName] is Variable {
				newName = '__ks_' + name + '_' + (++index)
			}

			@renamedIndexes[name] = index

			return newName
		}
		else {
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

		@variables[name] = variable

		if const newName = this.declareVariable(name) {
			@renamedVariables[name] = newName
		}
	} // }}}
	getDefinedVariable(name: String) { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return null
		}
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
	getVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @natives[name] is Variable {
			return @natives[name]
		}
		else {
			return null
		}
	} // }}}
	hasDeclaredVariable(name: String) => @variables[name] is Variable
	hasDefinedVariable(name: String) => @variables[name] is Variable
	hasVariable(name: String) => @variables[name] is Variable
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
	private resolveReference(name: String, nullable = false) { // {{{
		const hash = `\(name)\(nullable ? '?' : '')`

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable)
		}

		return @references[hash]
	} // }}}
}
