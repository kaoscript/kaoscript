const $importTypeModifiers = /^(\w+)(!)?(\?)?$/

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
	Dictionary: true
	dict: true
	Enum: true
	enum: true
	Error: true
	Function: true
	func: true
	Never: true
	never: true
	Namespace: true
	Null: true
	null: true
	Number: true
	number: true
	Primitive: true
	Object: true
	object: true
	RegExp: true
	regex: true
	String: true
	string: true
	Struct: true
	struct: true
	Void: true
	void: true
} // }}}

const $types = { // {{{
	any: 'Any'
	array: 'Array'
	bool: 'Boolean'
	class: 'Class'
	date: 'Date'
	dict: 'Dictionary'
	enum: 'Enum'
	func: 'Function'
	never: 'Never'
	number: 'Number'
	object: 'Object'
	string: 'String'
	struct: 'Struct'
	void: 'Void'
} // }}}

const $virtuals = {
	Enum: true
	Namespace: true
	Primitive: true
	Struct: true
}

#[flags]
enum ExportMode {
	Default

	IgnoreAlteration
	OverloadedFunction
}

#[flags]
enum MatchingMode {
	Default

	Exact
	ExactParameters
	ExactReturn
	Similar
	SimilarParameters
	SimilarReturn

	MissingParameters
	MissingReturn

	MissingType
	MissingParameterType

	ShiftableParameters
	RequireAllParameters

	Signature = Similar | MissingParameters | ShiftableParameters | MissingParameterType | RequireAllParameters | MissingReturn
}

#[flags]
enum QuoteMode {
	None
	Double
	Single
}

enum TypeKind<String> {
	Alias
	Array
	Class
	Dictionary
	Enum
	Exclusion
	Function
	Fusion
	Namespace
	OverloadedFunction
	Reference
	Sealable
	Struct
	Union
}

abstract class Type {
	private {
		_alien: Boolean				= false
		_exhaustive: Boolean? 		= null
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
				return AnyType.NullableUnexplicit
			}
			else if data is Type {
				return data
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
				NodeKind::ExclusionType => {
					return new ExclusionType(scope, [Type.fromAST(type, scope, defined, node) for type in data.types])
				}
				NodeKind::FunctionDeclaration, NodeKind::MethodDeclaration => {
					if data.parameters? {
						return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters], data, node)
					}
					else {
						return new FunctionType([new ParameterType(scope, AnyType.NullableUnexplicit, 0, Infinity)] as Array<ParameterType>, data, node)
					}
				}
				NodeKind::FunctionExpression, NodeKind::MethodDeclaration => {
					return new FunctionType([Type.fromAST(parameter, scope, defined, node) for parameter in data.parameters] as Array<ParameterType>, data, node)
				}
				NodeKind::FusionType => {
					return new FusionType(scope, [Type.fromAST(type, scope, defined, node) for type in data.types])
				}
				NodeKind::Identifier => {
					if const variable = scope.getVariable(data.name) {
						return variable.getDeclaredType()
					}
					else if $runtime.getVariable(data.name, node) != null {
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
					let type = ?data.type ? Type.fromAST(data.type, scope, defined, node) : AnyType.Unexplicit

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
						const type = new DictionaryType(scope)

						for property in data.properties {
							type.addProperty(property.name.name, Type.fromAST(property.type, scope, defined, node))
						}

						return type
					}
					else if data.typeName? {
						let nullable = false

						for const modifier in data.modifiers {
							if modifier.kind == ModifierKind::Nullable {
								nullable = true
							}
						}

						if data.typeName.kind == NodeKind::Identifier {
							const name = Type.renameNative(data.typeName.name)

							if name == 'Any' {
								return nullable ? AnyType.NullableExplicit : AnyType.Explicit
							}
							else if !defined || Type.isNative(name) || scope.hasVariable(name, -1) {
								if data.typeParameters? {
									const type = new ReferenceType(scope, name, nullable)

									for parameter in data.typeParameters {
										type._parameters.push(Type.fromAST(parameter, scope, defined, node))
									}

									return type
								}
								else {
									return scope.reference(name, nullable)
								}
							}
							else {
								ReferenceException.throwNotDefined(data.typeName.name, node)
							}
						}
						else if data.typeName.kind == NodeKind::MemberExpression && !data.typeName.computed {
							const namespace = Type.fromAST(data.typeName.object, scope, defined, node)

							const type = new ReferenceType(namespace.scope(), data.typeName.property.name, nullable)

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
				if data == 'Null' {
					return Type.Null
				}

				if const match = $importTypeModifiers.exec(data) {
					const nullable = match[3]?

					if match[1] == 'Any' {
						if match[2]? {
							return nullable ? AnyType.NullableExplicit : AnyType.Explicit
						}
						else {
							return nullable ? AnyType.NullableUnexplicit : AnyType.Unexplicit
						}
					}
					else {
						return scope.reference(match[1], nullable)
					}
				}
				else {
					return scope.reference(data)
				}
			}
			else if data is Array {
				const index = data[0]

				if index is Number {
					let type = references[index]

					if !?type {
						type = Type.fromMetadata(index, metadata, references, alterations, queue, scope, node)
					}

					if type is not NamedType {
						type = new NamedType(data[1], type)

						references[index] = type
					}

					return type
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
					TypeKind::Fusion => {
						return FusionType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
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
					TypeKind::Union => {
						return UnionType.fromMetadata(data, metadata, references, alterations, queue, scope, node)
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
					TypeKind::Dictionary => {
						return DictionaryType.import(index, data, metadata, references, alterations, queue, scope, node)
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
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Struct => {
						return StructType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Union => {
						return UnionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
				}
			}


			console.info(data)
			throw new NotImplementedException(node)
		} // }}}
		isNative(name: String) => $natives[name] == true
		renameNative(name: String) => $types[name] is String ? $types[name] : name
		toNamedType(name: String, type: Type): Type { // {{{
			if type is AliasType || type is ClassType || type is EnumType || type is StructType {
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
			if types.length == 1 {
				return types[0]
			}

			const union = new UnionType(scope)

			for const type in types {
				union.addType(type)
			}

			return union.type()
		} // }}}
	}
	constructor(@scope)
	abstract clone(): Type
	abstract export(references, mode)
	abstract toFragments(fragments, node)
	abstract toTestFragments(fragments, node)
	canBeBoolean(): Boolean => this.isAny() || this.isBoolean()
	canBeNumber(any: Boolean = true): Boolean => (any && this.isAny()) || this.isNumber()
	canBeString(any: Boolean = true): Boolean => (any && this.isAny()) || this.isString()
	canBeVirtual(name: String) { // {{{
		if this.isAny() {
			return true
		}

		switch name {
			'Enum'		=> return this.isEnum()
			'Namespace'	=> return this.isNamespace()
			'Struct'	=> return this.isStruct()
		}

		return false
	} // }}}
	compareTo(type: Type) => false
	condense(): Type => this
	discard(): Type? => this
	discardAlias(): Type => this
	discardName(): Type => this
	discardReference(): Type? => this
	discardSpread(): Type => this
	discardVariable(): Type => this
	equals(value?): Boolean => value? && this.isMatching(value, MatchingMode::Exact)
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
	getProperty(name: String) => null
	hashCode(): String => ''
	hasProperty(name: String): Boolean => false
	isAlias() => false
	isAlien() => @alien
	isAlteration() => false
	isAny() => false
	isAnonymous() => false
	isArray() => false
	isAssignableToVariable(type: Type, downcast: Boolean): Boolean => this.isAssignableToVariable(type, true, false, downcast)
	isAssignableToVariable(type: Type, anycast: Boolean, nullcast: Boolean, downcast: Boolean): Boolean => this == type
	isBoolean() => false
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
	isDictionary() => false
	isEnum() => false
	isExclusion() => false
	isExhaustive() { // {{{
		if @exhaustive == null {
			return !@alien && !@required
		}
		else {
			return @exhaustive
		}
	} // }}}
	isExhaustive(node) => this.isExhaustive() && !node._options.rules.ignoreMisfit
	isExplicitlyExported() => @exported
	isExportable() => this.isAlien() || this.isExported() || this.isNative() || this.isRequired()
	isExported() => @exported
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isHybrid() => false
	isInoperative() => this.isNever() || this.isVoid()
	isMatching(value, mode: MatchingMode) => false
	isMergeable(type) => false
	isMethod() => false
	isMorePreciseThan(that: Type): Boolean => false
	isNamed() => false
	isNamespace() => false
	isNative() => false
	isNever() => false
	isNumber() => false
	isNull() => false
	isNullable() => false
	isObject() => false
	isPredefined() => false
	isPrimitive() => false
	isReducible() => false
	isReference() => false
	isReferenced() => @referenced
	isRequired() => @required
	isSealable() => false
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	isSpread() => false
	isString() => false
	isStruct() => false
	isTypeOf() => false
	isUnion() => false
	isVirtual() => false
	isVoid() => false
	matchContentOf(that: Type?): Boolean => this.equals(that)
	reduce(type: Type) => this
	reference(scope = @scope) => scope.reference(this)
	referenceIndex() => @referenceIndex
	scope() => @scope
	setExhaustive(@exhaustive) => this
	setNullable(nullable: Boolean) => this
	toExportOrIndex(references, mode) { // {{{
		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if this.isReferenced() {
			return this.toMetadata(references, mode)
		}
		else {
			return this.export(references, mode)
		}
	} // }}}
	toExportOrReference(references, mode) { // {{{
		if @referenceIndex == -1 {
			return this.export(references, mode)
		}
		else {
			return {
				reference: @referenceIndex
			}
		}
	} // }}}
	toMetadata(references, mode) { // {{{
		if @referenceIndex == -1 {
			@referenceIndex = references.length

			// reserve position
			references.push(null)

			references[@referenceIndex] = this.export(references, mode)
		}

		return @referenceIndex
	} // }}}
	toQuote(): String { // {{{
		throw new NotSupportedException()
	} // }}}
	toQuote(double: Boolean): String { // {{{
		if double {
			return `"\(this.toQuote())"`
		}
		else {
			return `'\(this.toQuote())'`
		}
	} // }}}
	toReference(references, mode) => { // {{{
		reference: this.toMetadata(references, mode)
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
	'./type/never'
	'./type/null'
	'./type/dictionary'
	'./type/parameter'
	'./type/struct'
	'./type/exclusion'
	'./type/fusion'
	'./type/union'
	'./type/void'
}

Type.Any = AnyType.Unexplicit
Type.Never = new NeverType()
Type.Null = NullType.Unexplicit
Type.Void = new VoidType()