class OperationScope extends InlineBlockScope {
	define(name: String, immutable: Boolean, type: Type = null, node: AbstractNode): Variable => @parent.define(name, immutable, type, node)
	replaceVariable(name: String, type: Type, node): Variable { // {{{
		let variable = this.getVariable(name)

		if variable.isDefinitive() {
			if type.isAny() {
				return variable
			}

			if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(node)
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
}