const $natives = { // {{{
	Any: true
	any: true
	Array: true
	array: true
	Boolean: true
	bool: true
	Class: true
	class: true
	Date: true
	date: true
	Enum: true
	enum: true
	Error: true
	Function: true
	func: true
	Number: true
	number: true
	Object: true
	object: true
	RegExp: true
	regex: true
	String: true
	string: true
	Void: true
	void: true
} // }}}

const $types = { // {{{
	any: 'Any'
	array: 'Array'
	bool: 'Boolean'
	class: 'Class'
	date: 'Date'
	enum: 'Enum'
	func: 'Function'
	number: 'Number'
	object: 'Object'
	string: 'String'
	void: 'Void'
} // }}}

enum Accessibility {
	Private = 1
	Protected
	Public
}

enum EnumKind {
	Flags
	Number
	String
}

enum TypeKind<String> {
	Alias
	Class
	Enum
	Function
	Namespace
	Object
	OverloadedFunction
}

abstract class Type {
	private {
		_alien: Boolean				= false
		_exported: Boolean			= false
		_referenced: Boolean		= false
		_referenceIndex: Number		= -1
		_required: Boolean 			= false
		_scope: AbstractScope?
		_sealed: Boolean			= false
	}
	static {
		arrayOf(parameter: Type, scope: AbstractScope) => new ReferenceType(scope, 'Array', false, [parameter])
		fromAST(data?, node: AbstractNode): Type => Type.fromAST(data, node.scope(), true, node)
		fromAST(data?, scope: AbstractScope, defined: Boolean, node: AbstractNode): Type { // {{{
			if !?data {
				return Type.Any
			}
			else if data is Type {
				return data:Type
			}

			switch data.kind {
				NodeKind::ClassDeclaration => {
					const type = new ClassType(scope)

					for modifier in data.modifiers {
						if modifier.kind == ModifierKind::Abstract {
							type._abstract = data.abstract
						}
						else if modifier.kind == ModifierKind::Sealed {
							type.flagSealed()
						}
					}

					return new NamedType(data.name.name, type)
				}
				NodeKind::FunctionDeclaration => {
					if data.parameters? {
						return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
					}
					else {
						return new FunctionType([new ParameterType(scope, Type.Any, 0, Infinity)], data, node)
					}
				}
				NodeKind::FunctionExpression => {
					return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
				}
				NodeKind::Identifier => {
					if type ?= scope.getVariable(data.name) {
						return type.type()
					}
					else if $runtime.isDefined(data.name, node) {
						return Type.Any
					}
					else {
						ReferenceException.throwNotDefined(data.name, node)
					}
				}
				NodeKind::MemberExpression => {
					const object = Type.fromAST(data.object, scope, defined, node)

					if object.isAny() {
						return Type.Any
					}
					else {
						return object.getProperty(data.property.name)
					}
				}
				NodeKind::NumericExpression => {
					return scope.reference('Number')
				}
				NodeKind::Parameter => {
					const type = Type.fromAST(data.type, scope, defined, node)

					let min: Number = data.defaultValue? ? 0 : 1
					let max: Number = 1

					let nf = true
					for modifier in data.modifiers while nf {
						if modifier.kind == ModifierKind::Rest {
							if modifier.arity {
								min = modifier.arity.min
								max = modifier.arity.max
							}
							else {
								min = 0
								max = Infinity
							}

							nf = true
						}
					}

					return new ParameterType(scope, type, min, max)
				}
				NodeKind::TypeReference => {
					if data.properties? {
						const type = new ObjectType(scope)

						for property in data.properties {
							type.addProperty(property.name.name, Type.fromAST(property.type, scope, defined, node))
						}

						return type
					}
					else if data.typeName? {
						if data.typeName.kind == NodeKind::Identifier {
							if !defined || scope.hasVariable(data.typeName.name) {
								const type = new ReferenceType(scope, data.typeName.name, data.nullable)

								if data.typeParameters? {
									for parameter in data.typeParameters {
										type._parameters.push(Type.fromAST(parameter, scope, defined, node))
									}
								}

								return type
							}
							else {
								ReferenceException.throwNotDefined(data.typeName.name, node)
							}
						}
						else if data.typeName.kind == NodeKind::MemberExpression && !data.typeName.computed {
							const namespace = Type.fromAST(data.typeName.object, scope, defined, node)

							const type = new ReferenceType(namespace.scope(), data.typeName.property.name, data.nullable)

							if data.typeParameters? {
								for parameter in data.typeParameters {
									type._parameters.push(Type.fromAST(parameter, scope, defined, node))
								}
							}

							return type
						}
					}
				}
				NodeKind::UnionType => {
					return new UnionType(scope, [Type.fromAST(type, scope, defined, node) for type in data.types])
				}
				NodeKind::VariableDeclarator => {
					return Type.fromAST(data.type, scope, defined, node)
				}
			}

			console.log(data)
			throw new NotImplementedException(node)
		} // }}}
		fromMetadata(data, references: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			// console.log('-- fromMetadata --')
			// console.log(JSON.stringify(data, null, 2))

			if data is Number {
				if type ?= references[data] {
					return type
				}
				else {
					console.log(data)
					throw new NotImplementedException(node)
				}
			}
			else if data is String {
				return data == 'Any' ? Type.Any : scope.reference(data)
			}
			else if data is Array {
				if data[0] is Number {
					let type = references[data[0]]

					if type is not NamedType {
						type = new NamedType(data[1], type)
					}

					return type
				}
				else {
					return UnionType.fromMetadata(data, references, scope, node)
				}
			}
			else if data.reference? {
				if type ?= references[data.reference] {
					if type is NamedType {
						return scope.reference(type)
					}
					else {
						return type
					}
				}
				else {
					console.log(data)
					throw new NotImplementedException(node)
				}
			}
			else if data.name? {
				return new ReferenceType(scope, data.name, data.nullable, [])
			}
			else {
				switch data.type {
					TypeKind::Enum => {
						return EnumType.fromMetadata(data, references, scope, node)
					}
					TypeKind::Function => {
						return FunctionType.fromMetadata(data, references, scope, node)
					}
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.fromMetadata(data, references, scope, node)
					}
					=> {
						console.log(data)
						throw new NotImplementedException(node)
					}
				}
			}
		} // }}}
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			//console.log('-- import --')
			//console.log(JSON.stringify(data, null, 2))

			if data is String {
				return data == 'Any' ? Type.Any : scope.reference(data)
			}
			else if data is Array {
				if data[0] is Number {
					if data[0] == -1 {
						throw new NotImplementedException(node)
					}
					else {
						return references[data[0]].name(data[1])
					}
				}
				else {
					return UnionType.import(data, references, queue, scope, node)
				}
			}
			else if data.reference? {
				if references[data.reference]? {
					return references[data.reference]
				}
				else {
					throw new NotImplementedException(node)
				}
			}
			else {
				switch data.type {
					TypeKind::Alias => {
						return AliasType.import(data, references, queue, scope, node)
					}
					TypeKind::Class => {
						return ClassType.import(data, references, queue, scope, node)
					}
					TypeKind::Enum => {
						return EnumType.import(data, references, queue, scope, node)
					}
					TypeKind::Function => {
						return FunctionType.import(data, references, queue, scope, node)
					}
					TypeKind::Namespace => {
						return NamespaceType.import(data, references, queue, scope, node)
					}
					TypeKind::Object => {
						return ObjectType.import(data, references, queue, scope, node)
					}
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.import(data, references, queue, scope, node)
					}
					=> {
						console.log(data)
						throw new NotImplementedException(node)
					}
				}
			}
		} // }}}
		union(scope: AbstractScope, ...types) { // {{{
			for type in types {
				if type.isAny() {
					return Type.Any
				}
			}

			return new UnionType(scope, types)
		} // }}}
	}
	constructor(@scope)
	abstract equals(b?): Boolean
	abstract export(references, ignoreAlteration)
	abstract toQuote(): String
	abstract toFragments(fragments, node)
	abstract toTestFragments(fragments, node)
	condense(): Type => this
	discardAlias(): Type => this
	discardName(): Type => this
	discardReference(): Type? => this
	discardVariable() => this
	flagAlien() { // {{{
		@alien = true

		return this
	} // }}}
	flagExported() { // {{{
		@exported = true

		return this
	} // }}}
	flagReferenced() { // {{{
		@referenced = true

		return this
	} // }}}
	flagRequired() { // {{{
		@required = true

		return this
	} // }}}
	flagSealed() { // {{{
		@sealed = true

		return this
	} // }}}
	isAlias() => false
	isAlien() => @alien
	isAlteration() => false
	isAny() => false
	isAnonymous() => false
	isArray() => false
	isClass() => false
	isContainedIn(types) { // {{{
		for type in types {
			if this.equals(type) {
				return true
			}
		}

		return false
	} // }}}
	isEnum() => false
	isExported() => @exported
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isMergeable(type) => false
	isNamed() => false
	isNamespace() => false
	isNumber() => false
	isObject() => false
	isPredefined() => false
	isReferenced() => @referenced
	isRequired() => @required
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	isString() => false
	matchContentOf(that: Type): Boolean => this.equals(that)
	matchContentTo(that: Type): Boolean => that.matchContentOf(this)
	matchSignatureOf(that: Type): Boolean => false
	reference(scope = @scope) => scope.reference(this)
	scope() => @scope
	toExportOrIndex(references, ignoreAlteration) { // {{{
		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if this.isReferenced() {
			return this.toMetadata(references, ignoreAlteration)
		}
		else {
			return this.export(references, ignoreAlteration)
		}
	} // }}}
	toExportOrReference(references, ignoreAlteration) { // {{{
		if @referenceIndex == -1 {
			return this.export(references, ignoreAlteration)
		}
		else {
			return {
				reference: @referenceIndex
			}
		}
	} // }}}
	toMetadata(references, ignoreAlteration) { // {{{
		if @referenceIndex == -1 {
			@referenceIndex = references.length

			// reserve position
			references.push(null)

			references[@referenceIndex] = this.export(references, ignoreAlteration)
		}

		return @referenceIndex
	} // }}}
	toReference(references, ignoreAlteration) => { // {{{
		reference: this.toMetadata(references, ignoreAlteration)
	} // }}}
	type() => this
}

include {
	'./type/function'
	'./type/reference'
	'./type/alias'
	'./type/any'
	'./type/class'
	'./type/enum'
	'./type/namespace'
	'./type/object'
	'./type/parameter'
	'./type/sealed'
	'./type/union'
	'./type/void'
	'./type/named'
}

Type.Any = new AnyType(null)
Type.Void = new VoidType(null)

ParameterType.Any = new ParameterType(null, Type.Any)