const Type = {
	Any: 'Any'
	Array: 'Array'
	Boolean: 'Boolean'
	Function: 'Function'
	Number: 'Number'
	String: 'String'
	RegExp: 'RegExp'
	Void: null
	array(node, parameter) => Type.create(node, Type.Array, parameter)
	create(node, type, ...parameters) { // {{{
		if parameters.length == 0 {
			if type is String {
				return type
			}
			else if type is Array {
				return [Type.create(node, t) for t in type]
			}
			else {
				throw new NotImplementedException(node)
			}
		}
		else {
			if type is not String {
				throw new NotImplementedException(node)
			}
			
			return {
				name: type
				parameters: [Type.create(node, parameter) for parameter in parameters]
			}
		}
	} // }}}
	equals(a, b) { // {{{
		if a is String {
			return a == b
		}
		else if a is Array {
			return false if b is not Array || a.length != b.length
			
			for item, i in a {
				return false if !Type.equals(item, b[i])
			}
			
			return true
		}
		else {
			return false if b is not Object || a.name != b.name || a.parameters.length != b.parameters.length
			
			for parameter, i in a.parameters {
				return false if !Type.equals(parameter, b.parameters[i])
			}
			
			return true
		}
	} // }}}
	/* isFunction(type?) => (type is String && type == 'Function') || (type is Object && type.name == 'Function') */
	isString(type?) => type == 'String'
	union(node, ...types) => [Type.create(node, type) for type in types]
}