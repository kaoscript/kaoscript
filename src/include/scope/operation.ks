class OperationScope extends InlineBlockScope {
	define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable => @parent.define(name, immutable, type, initialized, node)
	replaceVariable(name: String, type: Type, node): Variable { // {{{
		let variable = this.getVariable(name)

		if variable.isDefinitive() {
			if type.isNull() && !variable.getDeclaredType().isNullable() {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
			}
			else if type.isAny() && !variable.getDeclaredType().isAny() {
				if variable.getRealType().isNull() {
					variable.setRealType(variable.getDeclaredType())
				}

				return variable
			}
			else if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, node)
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