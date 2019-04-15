class HollowScope extends Scope {
	private {
		_parent: Scope
		_variables					= {}
	}
	constructor(@parent)
	acquireTempName(declare: Boolean = true): String => @parent.acquireTempName(declare)
	acquireUnusedTempName() => @parent.acquireUnusedTempName()
	commitTempVariables(variables: Array) => @parent.commitTempVariables(variables)
	private declareVariable(name: String): String? => @parent.declareVariable(name)
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

		@parent.defineVariable(variable, node)

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
	getRenamedIndex(name: String): Number => @parent.getRenamedIndex(name)
	getRenamedVariable(name: String): String => @parent.getRenamedVariable(name)
	getTempIndex() => @parent.getTempIndex()
	getVariable(name): Variable { // {{{
		if @variables[name] is Variable {
			return @variables[name]
		}
		else {
			return @parent.getVariable(name)
		}
	} // }}}
	hasDefinedVariable(name: String): Boolean => @parent.hasDefinedVariable(name)
	hasDeclaredVariable(name: String): Boolean => @parent.hasDeclaredVariable(name)
	hasVariable(name: String): Boolean => @parent.hasVariable(name)
	isBleeding() => true
	isInline() => true
	parent() => @parent
	reference(value): ReferenceType => @parent.reference(value)
	releaseTempName(name: String) => @parent.releaseTempName(name)
	replaceVariable(name: String, type: Type, node) { // {{{
		const variable = this.getVariable(name)

		if variable.isDefinitive() {
			return if type.isAny()

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
			}
		}

		if !type.equals(variable.getRealType()) {
			if @variables[name] is Variable {
				variable.setRealType(type)
			}
			else {
				@variables[name] = variable.clone().setRealType(type)
			}
		}
	} // }}}
	private resolveReference(name: String, nullable = false) => @parent.resolveReference(name, nullable)
}