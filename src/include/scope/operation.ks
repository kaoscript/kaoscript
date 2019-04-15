class OperationScope extends InlineBlockScope {
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable => @parent.define(name, immutable, type, node)
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
}