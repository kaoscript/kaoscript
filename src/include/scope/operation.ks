class OperationScope extends InlineBlockScope {
	block() => @parent.block()
	define(name: String, immutable: Boolean, type: Type = null, initialized: Boolean = false, node: AbstractNode): Variable => @parent.define(name, immutable, type, initialized, node)
	replaceVariable(name: String, type: Type, downcast: Boolean = false, node: AbstractNode): Variable { // {{{
		let variable = this.getVariable(name)!?

		if variable.isDefinitive() {
			if !type.isAssignableToVariable(variable.getDeclaredType(), downcast) {
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