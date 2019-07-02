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

enum TypeKind<String> {
	Alias
	Array
	Class
	Enum
	Function
	Namespace
	Object
	OverloadedFunction
	Reference
	Sealable
}

abstract class Type {
	private {
		_alien: Boolean				= false
		_exported: Boolean			= false
		_referenced: Boolean		= false
		_referenceIndex: Number		= -1
		_required: Boolean 			= false
		_scope: Scope?
		_sealed: Boolean			= false
	}
	static {
		arrayOf(parameter: Type, scope: Scope) => new ReferenceType(scope, 'Array', false, [parameter])
		fromAST(data?, node: AbstractNode): Type => Type.fromAST(data, node.scope(), true, node)
		fromAST(data?, scope: Scope, defined: Boolean, node: AbstractNode): Type { // {{{
			if !?data {
				return Type.Any
			}
			else if data is Type {
				return data:Type
			}

			data = data as Any

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
				NodeKind::FunctionDeclaration, NodeKind::MethodDeclaration => {
					if data.parameters? {
						return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
					}
					else {
						return new FunctionType([new ParameterType(scope, Type.Any, 0, Infinity)], data, node)
					}
				}
				NodeKind::FunctionExpression, NodeKind::MethodDeclaration => {
					return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
				}
				NodeKind::Identifier => {
					if const variable = scope.getVariable(data.name) {
						return variable.getDeclaredType()
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
					let type = Type.fromAST(data.type, scope, defined, node)

					let default: Number = 0
					let min: Number = 1
					let max: Number = 1

					if data.defaultValue? {
						default = 1
						min = 0
					}

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

					let name = null
					if data.name? {
						if data.name.kind == NodeKind::Identifier {
							name = data.name.name
						}
					}
					else {
						type = type.setNullable(true)
					}


					return new ParameterType(scope, name, type, min, max, default)
				}
				NodeKind::TypeReference => {
					if data.elements? {
						const type = new ArrayType(scope)

						for const element in data.elements {
							type.addElement(Type.fromAST(element, scope, defined, node))
						}

						return type
					}
					else if data.properties? {
						const type = new ObjectType(scope)

						for property in data.properties {
							type.addProperty(property.name.name, Type.fromAST(property.type, scope, defined, node))
						}

						return type
					}
					else if data.typeName? {
						if data.typeName.kind == NodeKind::Identifier {
							if !defined || scope.hasVariable(data.typeName.name, -1) {
								if data.typeParameters? {
									const type = new ReferenceType(scope, data.typeName.name, data.nullable)

									for parameter in data.typeParameters {
										type._parameters.push(Type.fromAST(parameter, scope, defined, node))
									}

									return type
								}
								else {
									return scope.resolveReference(data.typeName.name, data.nullable)
								}
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
				NodeKind::VariableDeclarator, NodeKind::FieldDeclaration => {
					return Type.fromAST(data.type, scope, defined, node)
				}
			}

			console.info(data)
			throw new NotImplementedException(node)
		} // }}}
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			// console.log('-- fromMetadata --')
			// console.log(JSON.stringify(data, null, 2))

			if data is Number {
				let index = data
				while alterations[index]? {
					index = alterations[index]
				}

				if type ?= references[index] {
					return type
				}
				else {
					let type = Type.import(index, metadata, references, alterations, queue, scope, node)

					if type is AliasType || type is ClassType || type is EnumType {
						type = new NamedType(scope.acquireTempName(), type)

						scope.define(type.name(), true, type, node)
					}
					else if type is NamespaceType {
						type = new NamedContainerType(scope.acquireTempName(), type)

						scope.define(type.name(), true, type, node)
					}

					references[index] = type

					return type
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
					return UnionType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
				}
			}
			else if data.kind? {
				switch data.kind {
					TypeKind::Class => {
						return ClassType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Enum => {
						return EnumType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Function => {
						return FunctionType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Reference => {
						return ReferenceType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Sealable => {
						return SealableType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
					}
				}
			}
			else if data.reference? {
				const type = Type.fromMetadata(data.reference, metadata, references, alterations, queue, scope, node)

				if type is NamedType {
					return scope.reference(type)
				}
				else {
					return type
				}
			}
			else if data.type? {
				return Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node)
			}

			console.info(data)
			throw new NotImplementedException(node)
		} // }}}
		import(index, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const data = metadata.references[index]

			// console.log('-- import --')
			// console.log(JSON.stringify(data, null, 2))

			if !?data {
				return Type.Any
			}
			else if data is String {
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
					return UnionType.import(index, data, metadata, references, alterations, queue, scope, node)
				}
			}
			else if data.reference? {
				if references[data.reference]? {
					return scope.reference(references[data.reference])
				}
				else {
					let type = Type.import(data.reference, metadata, references, alterations, queue, scope, node)

					if type is AliasType || type is ClassType || type is EnumType {
						type = new NamedType(scope.acquireTempName(), type)

						scope.define(type.name(), true, type, node)
					}
					else if type is NamespaceType {
						type = new NamedContainerType(scope.acquireTempName(), type)

						scope.define(type.name(), true, type, node)
					}

					references[data.reference] = type

					return scope.reference(type)
				}
			}
			else if data.kind? {
				switch data.kind {
					TypeKind::Alias => {
						return AliasType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Class => {
						return ClassType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Enum => {
						return EnumType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Function => {
						return FunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Namespace => {
						return NamespaceType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Object => {
						return ObjectType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
				}
			}


			console.info(data)
			throw new NotImplementedException(node)
		} // }}}
		toNamedType(name: String, type: Type): Type { // {{{
			if type is AliasType || type is ClassType || type is EnumType {
				return new NamedType(name, type)
			}
			else if type is NamespaceType {
				return new NamedContainerType(name, type)
			}
			else {
				return type
			}
		} // }}}
		union(scope: Scope, ...types) { // {{{
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
	flagExported(explicitly: Boolean) { // {{{
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
	isCloned() => false
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
	isExplicitlyExported() => @exported
	isExportable() => this.isAlien() || this.isExported() || this.isNative() || this.isRequired()
	isExported() => @exported
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isMergeable(type) => false
	isNamed() => false
	isNamespace() => false
	isNative() => false
	isNumber() => false
	isNull() => false
	isObject() => false
	isPredefined() => false
	isReference() => false
	isReferenced() => @referenced
	isRequired() => @required
	isSealable() => false
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	isString() => false
	isVoid() => false
	matchContentOf(that: Type): Boolean => this.equals(that)
	matchSignatureOf(that: Type, matchables): Boolean => false
	reference(scope = @scope) => scope.reference(this)
	referenceIndex() => @referenceIndex
	scope() => @scope
	setNullable(nullable: Boolean) => this
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
	'./type/named'
	'./type/reference'
	'./type/sealable'
	'./type/alias'
	'./type/any'
	'./type/array'
	'./type/class'
	'./type/enum'
	'./type/namespace'
	'./type/null'
	'./type/object'
	'./type/parameter'
	'./type/union'
	'./type/void'
}

Type.Any = AnyType.Unexplicit
Type.Null = new NullType()
Type.Void = new VoidType()