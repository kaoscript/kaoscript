/* enum VariableKind {
	Class = 1
	Enum
	Function
	TypeAlias
	Variable
} */

/* const Variable = {
	castTo(variable, type, node) {
		if variable.kind != VariableKind::Variable {
		}
		
		const kind = Variable.kind(type)
		
		if kind == VariableKind::Variable {
			variable.type = type
		}
		else if kind == VariableKind::Function {
			variable.kind = kind
			variable.type = type
			
			variable.throws = []
		}
		else if kind == VariableKind::Class {
			variable.type = variable.name
			variable.kind = kind
			variable.constructors = []
			variable.destructors = 0
			variable.instanceVariables = {}
			variable.classVariables = {}
			variable.instanceMethods = {}
			variable.classMethods = {}
		}
		else {
			throw new NotImplementedException(node)
		}
	}
	create(name: String, immutable: Boolean) {
		return {
			name: name,
			kind: VariableKind::Variable
			new: true
			immutable: immutable
			type: 'Any'
		}
	}
	kind(type) { // {{{
		if type is String {
			
		}
		
		return VariableKind::Variable
	} // }}}
} */
enum Accessibility {
	Private = 1
	Protected
	Public
}

enum TypeKind {
	Function = 1
	Reference
	Union
}

enum VariableKind {
	Class = 1
	Enum
	Function
	TypeAlias
	Variable
}

class Type {
	private {
		_access: Accessibility
		_async: Boolean
		_kind: TypeKind			= TypeKind::Reference
		_min: Number
		_max: Number
		_parameters: Array
		_throws: Array
		_typeName: String
		_typeParameters: Array<Type>
	}
	static {
		Any: Type		= new Type('Any')
		Array: Type		= new Type('Array')
		Number: Type	= new Type('Number')
		String: Type	= new Type('String')
		fromAST(data?, node): Type {
			return Type.fromAST(data, node.scope(), node)
		}
		fromAST(data?, scope, node): Type { // {{{
			if !?data {
				return Type.Any
			}
			else if data is Type {
				return data
			}
			
			switch data.kind {
				NodeKind::ArrayComprehension, NodeKind::ArrayExpression, NodeKind::ArrayRange => {
					return Type.Array
				}
				NodeKind::TemplateExpression => {
					return Type.String
				}
				/* NodeKind::BinaryExpression => {
					/* if data.operator.kind == BinaryOperatorKind::TypeCasting {
						return $type.type(data.right, scope, node)
					}
					else if $operator.binaries[data.operator.kind] {
						return {
							typeName: {
								kind: NodeKind::Identifier
								name: 'Boolean'
							}
						}
					}
					else if $operator.lefts[data.operator.kind] {
						return $type.type(data.left, scope, node)
					}
					else if $operator.numerics[data.operator.kind] {
						return {
							typeName: {
								kind: NodeKind::Identifier
								name: 'Number'
							}
						}
					} */
				}
				NodeKind::CallExpression => {
					/* if (variable ?= $variable.fromAST(data, node)) && variable.type? {
						return variable.type
					} */
				}
				NodeKind::CreateExpression => {
					/* return {
						typeName: data.class
					} */
				}
				NodeKind::Identifier => {
					/* let variable = scope.getVariable(data.name)
					
					if variable && variable.type {
						return variable.type
					} */
				}
				NodeKind::Literal => {
					/* return {
						typeName: {
							kind: NodeKind::Identifier
							name: $literalTypes[data.value] || 'String'
						}
					} */
				}
				NodeKind::MemberExpression => {
					/* if (variable ?= $variable.fromAST(data, node)) && variable.type? {
						return variable.type
					} */
				}
				NodeKind::NumericExpression => {
					/* return {
						typeName: {
							kind: NodeKind::Identifier
							name: 'Number'
						}
					} */
				}
				NodeKind::ObjectExpression => {
					/* type = {
						typeName: {
							kind: NodeKind::Identifier
							name: 'Object'
						}
						properties: {}
					}
					
					let prop
					for property in data.properties {
						prop = {
							kind: $type.fromAST(property.value)
							name: property.name.name
						}
						
						if property.value.kind == NodeKind::FunctionExpression {
							prop.signature = $function.signature(property.value, node)
							
							if property.value.type {
								prop.type = $type.type(property.value.type, scope, node)
							}
						}
						
						type.properties[property.name.name] = prop
					} */
				}
				NodeKind::RegularExpression => {
					/* return {
						typeName: {
							kind: NodeKind::Identifier
							name: 'RegExp'
						}
					} */
				}
				NodeKind::ThisExpression => {
					/* if (variable ?= $variable.fromAST(data, node)) && variable.type? {
						return variable.type
					} */
				}
				NodeKind::TypeReference => {
					/* if data.typeName {
						if data.properties {
							type = {
								typeName: {
									kind: NodeKind::Identifier
									name: 'Object'
								}
								properties: {}
							}
							
							let prop
							for property in data.properties {
								prop = {
									kind: $type.fromAST(property.type)
									name: property.name.name
								}
								
								if property.type? {
									if property.type.kind == NodeKind::FunctionExpression {
										prop.signature = $function.signature(property.type, node)
										
										if property.type.type {
											prop.type = $type.type(property.type.type, scope, node)
										}
									}
									else {
										prop.type = $type.type(property.type, scope, node)
									}
								}
								
								type.properties[property.name.name] = prop
							}
						}
						else {
							type = {
								typeName: $type.typeName(data.typeName)
							}
							
							if data.nullable {
								type.nullable = true
							}
							
							if data.typeParameters {
								type.typeParameters = [$type.type(parameter, scope, node) for parameter in data.typeParameters]
							}
						}
					} */
				}
				NodeKind::UnionType => {
					/* return {
						types: [$type.type(type, scope, node) for type in data.types]
					} */
				} */
			}
			
			console.log(data)
			throw new NotImplementedException(node)
			
			return Type.Any
		} // }}}
		fromNode(parent) { // {{{
			let that = new Type(TypeKind::Function)
			
			/* let type, last
			for parameter in parent._parameters {
				type = parameter.type()
				
				if !type.equals(last) {
					if last? {
						if last.max == Infinity {
							if that.max == Infinity {
								SyntaxException.throwTooMuchRestParameter(parent)
							}
							else {
								that.max = Infinity
							}
						}
						else {
							that.max += last.max
						}
						
						that.min += last.min
					}
					
					that.parameters.push(last = type.clone())
				}
				else {
					if type.max == Infinity {
						last.max = Infinity
					}
					else {
						last.max += type.max
					}
					
					last.min += type.min
				}
			}
			
			if last? {
				if last.max == Infinity {
					if that.max == Infinity {
						SyntaxException.throwTooMuchRestParameter(parent)
					}
					else {
						that.max = Infinity
					}
				}
				else {
					that.max += last.max
				}
				
				that.min += last.min
			}
			
			for modifier in parent._data.modifiers {
				if modifier.kind == ModifierKind::Async {
					that.async = true
				}
				else if modifier.kind == ModifierKind::Private {
					that.access = Accessibility::Private
				}
				else if modifier.kind == ModifierKind::Protected {
					that.access = Accessibility::Protected
				}
			}
			
			if that.async {
				if type?.type == Type.Function {
					++type.min
					++type.max
				}
				else {
					that.parameters.push({
						type: Type.Function
						min: 1
						max: 1
					})
				}
				
				++that.min
				++that.max
			} */
			throw new NotImplementedException(parent)
			
			that.type = parent.type()
			
			if parent._data.throws? {
				that.throws = [t.name for t in parent._data.throws]
			}
			
			return that
		} // }}}
	}
	constructor(@kind) {
		if kind == TypeKind::Function {
			@access = Accessibility::Public
			@async = false
			@min = 0
			@max = 0
			@parameters = []
			@throws = []
		}
		else if kind == TypeKind::Union {
		}
	}
	constructor(@typeName)
	isString() => @kind == TypeKind::Reference && @typeName == 'String'
}

class Variable {
	private {
		_classMethods: Object
		_classVariables: Object
		_constructors: Array
		_destructors: Number
		_instanceMethods: Object
		_instanceVariables: Object
		_immutable: Boolean
		_kind: VariableKind		= VariableKind::Variable
		_name: String
		_new: Boolean			= true
		_required: Boolean		= false
		_sealed: Object
		_throws: Array
		_type: Type				= Type.Any
	}
	static {
		kind(type) { // {{{
			return VariableKind::Variable
		} // }}}
	}
	constructor(@name, @immutable)
	constructor(@name, @immutable, @kind, type: Type = Type.Any) {
		if kind == VariableKind::Function {
			@type = type
			@throws = []
		}
		else if kind == VariableKind::Class {
			@type = new Type(@name)
			@constructors = []
			@destructors = 0
			@instanceVariables = {}
			@classVariables = {}
			@instanceMethods = {}
			@classMethods = {}
		}
		else {
			@type = type
		}
	}
	castTo(type, node) {
		if @kind != VariableKind::Variable {
			throw new NotImplementedException(node)
		}
		
		const kind = Variable.kind(type)
		
		if kind == VariableKind::Variable {
			@type = type
		}
		else if kind == VariableKind::Function {
			@kind = kind
			@type = type
			
			@throws = []
		}
		else if kind == VariableKind::Class {
			@type = new Type(@name)
			@kind = kind
			@constructors = []
			@destructors = 0
			@instanceVariables = {}
			@classVariables = {}
			@instanceMethods = {}
			@classMethods = {}
		}
		else {
			throw new NotImplementedException(node)
		}
	}
	isConstructor(name) => name == 'constructor'
	isDestructor(name) => name == 'destructor'
	kind() => @kind
	name() => @name
	require() {
		@required = true
	}
	seal() {
		if @kind == VariableKind::Class {
			@sealed = {
				name: `__ks_\(@name)`
				constructors: false
				instanceMethods: {}
				classMethods: {}
			}
		}
		else {
			@sealed = {
				name: `__ks_\(@name)`
				properties: {}
			}
		}
	}
	type() => @type
}