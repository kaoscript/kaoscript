const $sealed = {
	callee(data, node) { // {{{
		if data.computed {
			return false
		}
		else {
			let variable = $variable.fromAST(data.object, node)
			//console.log('callee.data', data)
			//console.log('callee.variable', variable)
			
			return $sealed.filter(variable, data.property.name, data, node)
		}
	} // }}}
	filter(variable = null, name, data, node, instance = false) { // {{{
		if variable? {
			if variable.kind == VariableKind::Class {
				if variable.sealed? {
					if instance {
						if variable.sealed.instanceMethods[name] == true {
							return {
								kind: CalleeKind::InstanceMethod
								variable: variable
							}
						}
					}
					else {
						if variable.sealed.classMethods[name] == true {
							return {
								kind: CalleeKind::ClassMethod
								variable: variable
							}
						}
					}
				}
			}
			else if variable.kind == VariableKind::Enum {
				throw new NotSupportedException(node)
			}
			else if variable.kind == VariableKind::Function {
				return $sealed.filterType({
					kind: NodeKind::TypeReference
					typeName: {
						kind: NodeKind::Identifier
						name: 'Function'
					}
				}, name, data, node)
			}
			else if variable.kind == VariableKind::TypeAlias {
				if variable.type?.types? {
					let variables = []
					
					for type in variable.type.types {
						return false unless v = $sealed.filter($variable.fromType(type, node), name, data, node, true)
						
						variables.push(v)
					}
					
					return variables[0]	if variables.length == 1
					return variables	if variables.length > 0
				}
				else {
					return $sealed.filter(variable, name, data, node, true) if variable ?= $variable.fromType(variable.type, node)
				}
			}
			else if variable.kind == VariableKind::Variable {
				if variable.sealed? && variable.sealed.properties[name] is Object {
					return {
						kind: CalleeKind::VariableProperty
						variable: variable
					}
				}
				
				if variable.type? {
					return $sealed.filterType(variable.type, name, data, node)
				}
			}
			else {
				throw new NotImplementedException(node)
			}
		}
		
		return false
	} // }}}
	filterType(type, name, data, node) { // {{{
		if type.typeName? {
			return $sealed.filter($variable.fromType(type, node), name, data, node, true)
		}
		else if type.types? {
			let variables = []
			
			for t in type.types {
				return false unless v = $sealed.filter($variable.fromType(t, node), name, data, node, true)
				
				variables.push(v)
			}
			
			return variables[0]	if variables.length == 1
			return variables	if variables.length > 0
		}
		else {
			throw new NotImplementedException(node)
		}
		
		return false
	} // }}}
}