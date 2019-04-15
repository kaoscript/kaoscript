// declare variable at parent
class BleedingScope extends Scope {
	private {
		_parent: Scope
		_renamedIndexes 			= {}
		_renamedVariables			= {}
		_variables					= {}
	}
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String => @parent.acquireTempName(declare)
	acquireUnusedTempName() => @parent.acquireUnusedTempName()
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	private declareVariable(name: String) => @parent.declareVariable(name)
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

		if const newName = @parent.declareVariable(name) {
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
	getRenamedIndex(name: String) => @renamedIndexes[name] is Number ? @renamedIndexes[name] : @parent.getRenamedIndex(name)
	getRenamedVariable(name: String) { // {{{
		if @variables[name] is Variable {
			if @renamedVariables[name] is String {
				return @renamedVariables[name]
			}
			else {
				return name
			}
		}
		else {
			return @parent.getRenamedVariable(name)
		}
	} // }}}
	getTempIndex() => @parent.getTempIndex()
	getVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return @parent.getVariable(name)
		}
	} // }}}
	hasDeclaredVariable(name: String) => @variables[name] is Variable || @parent.hasDeclaredVariable(name)
	hasDefinedVariable(name: String) => @variables[name] is Variable
	hasVariable(name: String) => @variables[name] is Variable || @parent.hasVariable(name)
	isBleeding() => true
	isInline() => true
	isRenamedVariable(name: String) { // {{{
		if @variables[name] is Variable {
			return @renamedVariables[name] is String
		}
		else {
			return @parent.isRenamedVariable(name)
		}
	} // }}}
	parent() => @parent
	reference(value) => @parent.reference(value)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	rename(name) { // {{{
		return if @renamedVariables[name] is String

		let index = @parent.getRenamedIndex(name)

		let newName = '__ks_' + name + '_' + (++index)

		@renamedIndexes[name] = index
		@renamedVariables[name] = newName
	} // }}}
	private resolveReference(name: String, nullable = false) => @parent.resolveReference(name, nullable)
}