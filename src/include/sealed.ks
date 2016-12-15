const $sealed = {
	callee(data, node) { // {{{
		if data.computed {
			return false
		}
		else {
			let variable = $variable.fromAST(data.object, node)
			//console.log('callee.data', data)
			//console.log('callee.variable', variable)
			
			return $sealed.filter(variable, data.property.name, node)
		}
	} // }}}
	class(node, fragments) { // {{{
		let clazz = fragments
			.newControl()
			.code('class ', node._name)
		
		if node._extends {
			clazz.code(' extends ', node._extendsName)
		}
		
		clazz.step()
		
		let noinit = Type.isEmptyObject(node._instanceVariables)
		
		if !noinit {
			noinit = true
			
			for name, field of node._instanceVariables while noinit {
				if field.data.defaultValue {
					noinit = false
				}
			}
		}
		
		let ctrl
		if node._extends {
			ctrl = fragments
				.newControl()
				.code('__ks_init()')
				.step()
				
			ctrl.line(node._extendsName, '.prototype.__ks_init.call(this)')
			
			if !noinit {
				for name, field of node._instanceVariables when field.data.defaultValue? {
					ctrl
						.newLine()
						.code('this.' + name + ' = ')
						.compile(field.defaultValue)
						.done()
				}
			}
			
			ctrl.done()
		}
		else {
			ctrl = clazz
				.newControl()
				.code('constructor()')
				.step()
		
			if !noinit {
				for name, field of node._instanceVariables when field.data.defaultValue? {
					ctrl
						.newLine()
						.code('this.' + name + ' = ')
						.compile(field.defaultValue)
						.done()
				}
			}
			
			ctrl.line('this.__ks_cons(arguments)')
			
			ctrl.done()
		}
		
		let reflect = {
			sealed: true
			inits: 0
			constructors: []
			instanceVariables: node._instanceVariables
			classVariables: node._classVariables
			instanceMethods: {}
			classMethods: {}
		}
		
		for method in node._constructors {
			$continuous.constructor(node, clazz, method.statement, method.signature, method.parameters, reflect)
		}
		
		$helper.constructor(node, clazz, reflect)
		
		for name, methods of node._instanceMethods {
			for method in methods {
				$continuous.instanceMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.instanceMethod(node, clazz, reflect, name)
		}
		
		for name, methods of node._classMethods {
			for method in methods {
				$continuous.classMethod(node, clazz, method.statement, method.signature, method.parameters, reflect, name)
			}
			
			$helper.classMethod(node, clazz, reflect, name)
		}
		
		clazz.done()
		
		for name, field of node._classVariables when field.defaultValue? {
			fragments
				.newLine()
				.code(`\(node._name).\(name) = `)
				.compile(field.defaultValue)
				.done()
		}
		
		$helper.reflect(node, fragments, reflect)
		
		if references ?= node.module().listReferences(node._name) {
			for ref in references {
				fragments.line(ref)
			}
		}
	} // }}}
	filter(variable?, name, node, instance = false) { // {{{
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
			else if variable.kind == VariableKind::TypeAlias {
				if variable.type?.types? {
					let variables = []
					
					for type in variable.type.types {
						return false unless v = $sealed.filter($variable.fromType(type, node), name, node, true)
						
						variables.push(v)
					}
					
					return variables[0]	if variables.length == 1
					return variables	if variables.length > 0
				}
				else {
					return $sealed.filter(variable, name, node, true) if variable ?= $variable.fromType(variable.type, node)
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
					return $sealed.filterType(variable.type, name, node)
				}
			}
		}
		
		return false
	} // }}}
	filterType(type, name, node) { // {{{
		if type.typeName? {
			return $sealed.filter($variable.fromType(type, node), name, node, true)
		}
		else if type.types? {
			let variables = []
			
			for t in type.types {
				return false unless v = $sealed.filter($variable.fromType(t, node), name, node, true)
				
				variables.push(v)
			}
			
			return variables[0]	if variables.length == 1
			return variables	if variables.length > 0
		}
		else {
			$throw('Not implemented', node)
		}
		
		return false
	} // }}}
}