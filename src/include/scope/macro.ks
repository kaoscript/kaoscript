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
		@predefined.__Object = new Variable('Object', true, true, new ExclusionType(this, [AnyType.Explicit, this.reference('Array'), this.reference('Boolean'), this.reference('Dictionary'), this.reference('Enum'), this.reference('Function'), this.reference('Namespace'), this.reference('Number'), this.reference('String')]))
		@predefined.__Primitive = new Variable('Primitive', true, true, new UnionType(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')]))

		// macro types
		@predefined.__Expression = Variable.createPredefinedClass('Expression', this)
		@predefined.__Identifier = Variable.createPredefinedClass('Identifier', this)
	} // }}}
	acquireTempName(declare: Boolean = true) { // {{{
		throw new NotSupportedException()
	} // }}}
	private declareVariable(name: String, scope: Scope) { // {{{
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
	define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable { // {{{
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type, initialized)

		this.defineVariable(variable, node)

		return variable
	} // }}}
	defineVariable(variable: Variable, node: AbstractNode) { // {{{
		const name = variable.name()

		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = variable

		if const newName = this.declareVariable(name, this) {
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
	hasVariable(name: String, line = -1) => @variables[name] is Variable
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
	resolveReference(name: String, nullable: Boolean, parameters: Array) { // {{{
		const hash = ReferenceType.toQuote(name, nullable, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, nullable, parameters)
		}

		return @references[hash]
	} // }}}
}
