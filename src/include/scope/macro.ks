// natives
class MacroScope extends Scope {
	private {
		_predefined			= {}
		_references			= {}
		_renamedIndexes 	= {}
		_renamedVariables	= {}
		_variables			= {}
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

		// macro types
		@predefined.__Expression = Variable.createPredefinedClass('Expression', this)
		@predefined.__Identifier = Variable.createPredefinedClass('Identifier', this)
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

			variable.renameAs(newName)
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
	getVariable(name, line = -1): Variable? { // {{{
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
				console.info(value)
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
