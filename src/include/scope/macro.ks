/// natives
class MacroScope extends Scope {
	private {
		_matchingTypes: Dictionary<Array>	= {}
		_predefined							= {}
		_references							= {}
		_renamedIndexes					 	= {}
		_renamedVariables					= {}
		_variables							= {}
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
		@predefined.__null = new Variable('null', true, true, Type.Null)
		@predefined.__true = new Variable('true', true, true, this.reference('Boolean'))
		@predefined.__Infinity = new Variable('Infinity', true, true, this.reference('Number'))
		@predefined.__Math = new Variable('Math', true, true, this.reference('Dictionary'))
		@predefined.__NaN = new Variable('NaN', true, true, this.reference('Number'))
		@predefined.__Object = new Variable('Object', true, true, new AliasType(this, new ExclusionType(this, [AnyType.Explicit, this.reference('Array'), this.reference('Boolean'), this.reference('Dictionary'), this.reference('Enum'), this.reference('Function'), this.reference('Namespace'), this.reference('Number'), this.reference('String'), this.reference('Struct'), this.reference('Tuple')])))
		@predefined.__Primitive = new Variable('Primitive', true, true, new AliasType(this, new UnionType(this, [this.reference('Boolean'), this.reference('Number'), this.reference('String')])))

		// macro types
		@predefined.__Expression = Variable.createPredefinedClass('Expression', this)
		@predefined.__Identifier = Variable.createPredefinedClass('Identifier', this)
	} # }}}
	acquireTempName(declare: Boolean = true) { # {{{
		throw new NotSupportedException()
	} # }}}
	authority() => this
	block() => this
	private declareVariable(name: String, scope: Scope) { # {{{
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
	} # }}}
	define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable { # {{{
		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		const variable = new Variable(name, immutable, false, type, initialized)

		this.defineVariable(variable, node)

		return variable
	} # }}}
	defineVariable(variable: Variable, node: AbstractNode) { # {{{
		const name = variable.name()

		if @variables[name] is Variable {
			SyntaxException.throwAlreadyDeclared(name, node)
		}

		@variables[name] = variable

		if const newName = this.declareVariable(name, this) {
			@renamedVariables[name] = newName

			variable.renameAs(newName)
		}

		if const reference = @references[name] {
			reference.reset()
		}
	} # }}}
	getDefinedVariable(name: String) { # {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return null
		}
	} # }}}
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : 0
	getVariable(name, line = -1): Variable? { # {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else if @predefined[`__\(name)`] is Variable {
			return @predefined[`__\(name)`]
		}
		else {
			return null
		}
	} # }}}
	hasDeclaredVariable(name: String) => @variables[name] is Variable
	hasDefinedVariable(name: String) => @variables[name] is Variable
	hasVariable(name: String, line = -1) => @variables[name] is Variable
	isMatchingType(a: Type, b: Type, mode: MatchingMode) { # {{{
		const hash = a.toQuote()

		if const matches = @matchingTypes[hash] {
			for const type, i in matches by 2 {
				if type == b {
					return matches[i + 1]
				}
			}
		}
		else {
			@matchingTypes[hash] = []
		}

		@matchingTypes[hash].push(b, false)

		const index = @matchingTypes[hash].length

		const match = a.isSubsetOf(b, mode)

		@matchingTypes[hash][index - 1] = match

		return match
	} # }}}
	reference(value) { # {{{
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
			is ReferenceType => return this.resolveReference(value.name(), value.isExplicitlyNull(), [...value.parameters()])
			is Variable => return this.resolveReference(value.name())
			=> {
				console.info(value)
				throw new NotImplementedException()
			}
		}
	} # }}}
	reference(value: String, nullable: Boolean = false, parameters: Array = []) { # {{{
		return this.resolveReference(value, nullable, parameters)
	} # }}}
	resolveReference(name: String, explicitlyNull: Boolean = false, parameters: Array = []) { # {{{
		const hash = ReferenceType.toQuote(name, explicitlyNull, parameters)

		if @references[hash] is not ReferenceType {
			@references[hash] = new ReferenceType(this, name, explicitlyNull, parameters)
		}

		return @references[hash]
	} # }}}
}
