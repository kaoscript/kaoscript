var $importTypeModifiers = /^(\w+)(!)?(\?)?$/

var $natives = { # {{{
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
	Tuple: true
	tuple: true
	Void: true
	void: true
} # }}}

var $types = { # {{{
	any: 'Any'
	array: 'Array'
	bool: 'Boolean'
	class: 'Class'
	date: 'Date'
	enum: 'Enum'
	func: 'Function'
	never: 'Never'
	number: 'Number'
	object: 'Object'
	string: 'String'
	struct: 'Struct'
	void: 'Void'
} # }}}

var $virtuals = {
	Enum: true
	Namespace: true
	Primitive: true
	Struct: true
	Tuple: true
}

bitmask ExportMode {
	Default

	Alien
	Export
	Requirement

	OverloadedFunction
}

bitmask MatchingMode<u48> {
	Default

	Exact
	ExactError
	ExactParameter
	ExactReturn

	Similar
	SimilarErrors
	SimilarParameter
	SimilarReturn

	Missing
	MissingArity
	MissingDefault
	MissingError
	MissingParameter
	MissingParameterArity
	MissingParameterDefault
	MissingParameterType
	MissingReturn
	MissingType

	Subclass
	SubclassError
	SubclassParameter
	SubclassReturn

	Subset
	SubsetParameter

	Superclass

	NonNullToNull
	NonNullToNullParameter

	NullToNonNull
	NullToNonNullParameter

	Anycast
	AnycastParameter

	AdditionalParameter
	// TODO reenable
	// AdditionalDefault
	// TODO reenable
	// AdditionalParameterDefault

	ShiftableParameters
	RequireAllParameters

	Renamed
	Reference

	IgnoreAnonymous
	IgnoreError
	IgnoreName
	IgnoreNullable
	IgnoreRetained
	IgnoreReturn

	AutoCast

	Signature = Similar + MissingParameter + ShiftableParameters + MissingParameterType + RequireAllParameters + MissingReturn
	FunctionSignature = ExactParameter +
		SubclassParameter +
		NonNullToNullParameter +
		MissingParameterDefault +
		// TODO reenable
		// AdditionalParameterDefault +
		// AdditionalDefault +
		MissingParameterType +
		MissingParameterArity +
		IgnoreAnonymous
}

enum MatchingScope {
	Element
	Global
}

bitmask QuoteMode {
	None
	Double
	Single
}

enum TypeKind<String> {
	Alias
	Array
	Class
	Deferred
	Enum
	Exclusion
	Function
	Fusion
	Namespace
	Object
	OverloadedFunction
	Reference
	Sealable
	Struct
	Tuple
	Union
	ValueOf
	Variant
}

enum Junction {
	NONE
	AND
	OR
}

bitmask TypeOrigin {
	None

	Extern
	ExternOrRequire
	Import
	Require
	RequireOrExtern
}

type AltType = {
	name: String
	type: Type
}
// TODO!
// type AltTypes = AltType[]

type Variant = {
	names: String[]
	type: Type
}

abstract class Type {
	private {
		@alien: Boolean					= false
		@complete: Boolean				= false
		@constant: Boolean?				= null
		@exhaustive: Boolean? 			= null
		@exported: Boolean				= false
		@mutable: Boolean?				= null
		@origin: TypeOrigin?			= null
		@referenced: Boolean			= false
		@referenceIndex: Number			= -1
		@required: Boolean 				= false
		@requirement: Boolean			= false
		@scope: Scope?
		@sealed: Boolean				= false
		@system: Boolean				= false
	}
	static {
		arrayOf(parameter: Type, scope: Scope) { # {{{
			var type = ArrayType.new(scope)

			type.setRestType(parameter)

			return type
		} # }}}
		fromAST(mut data?, scope: Scope = node.scope(), defined: Boolean = true, generics: String[]? = null, node: AbstractNode): Type { # {{{
			if !?data {
				return AnyType.NullableUnexplicit
			}
			else if data is Type {
				return data
			}

			data = data as Any

			match data.kind {
				NodeKind.ArrayType {
					var mut type = ArrayType.new(scope)

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Nullable {
							type = type.setNullable(true)
						}
					}

					for var property in data.properties {
						type.addProperty(Type.fromAST(property.type, scope, defined, node))
					}

					if ?data.rest {
						type.setRestType(Type.fromAST(data.rest.type, scope, defined, node))
					}

					return type
				}
				NodeKind.ClassDeclaration {
					var type = ClassType.new(scope)

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Abstract {
							type._abstract = data.abstract
						}
						else if modifier.kind == ModifierKind.Sealed {
							type.flagSealed()
						}
					}

					return NamedType.new(data.name.name, type.flagComplete())
				}
				NodeKind.ExclusionType {
					return ExclusionType.new(scope, [Type.fromAST(type, scope, defined, node) for var type in data.types])
				}
				NodeKind.FunctionDeclaration, NodeKind.MethodDeclaration {
					if ?data.parameters {
						return FunctionType.new([ParameterType.fromAST(parameter, false, scope, defined, node) for var parameter in data.parameters], data, node).flagComplete()
					}
					else {
						return FunctionType.new([ParameterType.new(scope, AnyType.NullableUnexplicit, 0, Infinity)] as Array<ParameterType>, data, node).flagComplete()
					}
				}
				NodeKind.FunctionExpression {
					return FunctionType.new([ParameterType.fromAST(parameter, false, scope, defined, node) for var parameter in data.parameters] as Array<ParameterType>, data, node).flagComplete()
				}
				NodeKind.FusionType {
					return FusionType.new(scope, [Type.fromAST(type, scope, defined, node) for var type in data.types])
				}
				NodeKind.Identifier {
					if var variable ?= scope.getVariable(data.name) {
						return variable.getDeclaredType()
					}
					else if $runtime.getVariable(data.name, node) != null {
						return Type.Any
					}
					else {
						ReferenceException.throwNotDefinedType(data.name, node)
					}
				}
				NodeKind.MemberExpression {
					var object = Type.fromAST(data.object, scope, defined, node)

					if object.isAny() {
						return Type.Any
					}
					else {
						return object.getProperty(data.property.name)
					}
				}
				NodeKind.NumericExpression {
					return scope.reference('Number')
				}
				NodeKind.ObjectType {
					var mut type = ObjectType.new(scope)

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Nullable {
							type = type.setNullable(true)
						}
					}

					for var property in data.properties {
						var mut prop = if ?property.type {
							set Type.fromAST(property.type, scope, defined, generics, node)
						}
						else {
							set AnyType.Unexplicit
						}

						for var modifier in property.modifiers {
							if modifier.kind == ModifierKind.Nullable {
								prop = prop.setNullable(true)
							}
						}

						type.addProperty(property.name.name, prop)
					}

					if ?data.rest {
						if ?data.rest.type {
							type.setRestType(Type.fromAST(data.rest.type, scope, defined, generics, node))
						}
						else if data.modifiers.some(({ kind }) => kind == ModifierKind.Nullable) {
							type.setRestType(AnyType.NullableUnexplicit)
						}
						else {
							type.setRestType(AnyType.Unexplicit)
						}
					}

					return type.flagComplete()
				}
				NodeKind.TypeList {
					var mut type = NamespaceType.new(scope)

					for var property in data.types {
						type.addProperty(property.name.name, Type.fromAST(property, scope, defined, node))
					}

					return type.flagComplete()
				}
				NodeKind.TypeReference {
					var mut nullable = false

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Nullable {
							nullable = true
						}
					}

					if data.typeName.kind == NodeKind.Identifier {
						var name = Type.renameNative(data.typeName.name)

						if name == 'Any' {
							return nullable ? AnyType.NullableExplicit : AnyType.Explicit
						}
						else if #data.typeParameters {
							match name {
								'Array' {
									var type = ArrayType.new(scope).setNullable(nullable)

									var parameter = data.typeParameters[0]

									type.setRestType(Type.fromAST(parameter, scope, defined, node))

									return type.flagComplete()
								}
								'Object' {
									var type = ObjectType.new(scope).setNullable(nullable)

									var parameter = data.typeParameters[0]

									type.setRestType(Type.fromAST(parameter, scope, defined, node))

									if var parameter ?= data.typeParameters[1] {
										type.setKeyType(Type.fromAST(parameter, scope, defined, node))
									}

									return type.flagComplete()
								}
								else {
									unless scope.hasVariable(name, -1) {
										ReferenceException.throwNotDefinedType(name, node)
									}

									var parameters = [Type.fromAST(parameter, scope, defined, node) for var parameter in data.typeParameters]

									var type = ReferenceType.new(scope, name, nullable, parameters)
									var root = type.discard()

									if root.isVariant() {
										var master = root.getVariantType().getMaster()

										if #data.typeSubtypes {
											for var subtype in data.typeSubtypes {
												type.addSubtype(subtype.name, master, node)
											}
										}
									}
									else if #data.typeSubtypes {
										NotImplementedException.throw()
									}

									return type.flagComplete()
								}
							}
						}
						else if #data.typeSubtypes {
							unless scope.hasVariable(name, -1) {
								ReferenceException.throwNotDefinedType(name, node)
							}

							var type = ReferenceType.new(scope, name, nullable)
							var root = type.discard()

							if root.isVariant() {
								var master = root.getVariantType().getMaster()

								for var subtype in data.typeSubtypes {
									type.addSubtype(subtype.name, master, node)
								}

								return type.flagComplete()
							}
							else {
								TypeException.throwNotVariant(name, node)
							}
						}
						else if generics?.contains(data.typeName.name) {
							return DeferredType.new(data.typeName.name, scope)
						}
						else if !defined || Type.isNative(name) || scope.hasVariable(name, -1) {
							if var variable ?= scope.getVariable(name, -1) {
								var type = variable.getDeclaredType()

								if type.isReference() || type.isAny() {
									TypeException.throwNotType(name, node)
								}
							}

							return scope.reference(name, nullable)
						}
						else {
							ReferenceException.throwNotDefinedType(data.typeName.name, node)
						}
					}
					else if data.typeName.kind == NodeKind.MemberExpression && !data.typeName.computed {
						var type = Type.fromAST(data.typeName.object, scope, defined, node)
						var property = data.typeName.property.name

						if type.isVariant() {
							var object = type.discard()

							if object.getVariantType().hasSubtype(property) {
								var variant = object.getVariantType()

								return ReferenceType.new(scope, type.name(), null, null, [{ name: property, type: variant.getMaster() }])
							}
						}
						else if !defined || type.scope().hasVariable(data.typeName.property.name, -1) {
							return ReferenceType.new(type.scope(), data.typeName.property.name, nullable)
						}
						else {
							ReferenceException.throwNotDefinedType($ast.path(data.typeName), node)
						}
					}
				}
				NodeKind.UnaryTypeExpression {
					match data.operator.kind {
						UnaryTypeOperatorKind.Constant {
							return Type.fromAST(data.argument, scope, defined, node).flagConstant()
						}
						UnaryTypeOperatorKind.TypeOf {
							if data.argument.kind == NodeKind.Identifier && data.argument.name == 'this' {
								return ReferenceType.new(scope, 'this')
							}
							else {
								var argument = $compile.expression(data.argument, node)

								argument
									..analyse()
									..prepare(AnyType.NullableUnexplicit)

								return argument.type()
							}
						}
						UnaryTypeOperatorKind.ValueOf {
							var argument = $compile.expression(data.argument, node)

							argument
								..analyse()
								..prepare(AnyType.NullableUnexplicit)

							return ValueOfType.new(argument)
						}
					}
				}
				NodeKind.UnionType {
					return UnionType.new(scope, [Type.fromAST(type, scope, defined, node) for var type in data.types])
				}
				NodeKind.VariableDeclarator, NodeKind.FieldDeclaration {
					return Type.fromAST(data.type, scope, defined, node)
				}
				NodeKind.VariantType {
					var type = VariantType.new(scope)
						..setMaster(Type.fromAST(data.master, scope, defined, generics, node))

					return type
				}
			}

			console.info(data)
			throw NotImplementedException.new(node)
		} # }}}
		fromAST(data, type: Type, node: AbstractNode): Type { # {{{
			if data.kind == NodeKind.TypeReference && data.typeName.kind == NodeKind.UnaryExpression && data.typeName.operator.kind == UnaryOperatorKind.Implicit {
				var property = data.typeName.argument.name

				if type.isEnum() {
					unless type.discard().hasVariable(property) {
						ReferenceException.throwNotDefinedEnumElement(property, type.name(), node)
					}

					return type.setNullable(false)
				}

				if type.isVariant() {
					var variant = type.discard().getVariantType()

					if variant.hasSubtype(property) {
						return ReferenceType.new(node.scope(), type.name(), null, null, [{ name: property, type: variant.getMaster() }])
					}
				}

				if var property ?= type.getProperty(property) {
					return property.discardVariable()
				}

				ReferenceException.throwUnresolvedImplicitProperty(property, node)
			}
			else {
				return Type.fromAST(data, node)
			}
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): Type { # {{{
			var data = index is Number ? metadata[index] : index

			// echo('-- import --')
			// echo(JSON.stringify(data, null, 2))

			if !?data {
				return Type.Any
			}
			else if data is String {
				if data == 'Null' {
					return Type.Null
				}

				if var match ?= $importTypeModifiers.exec(data) {
					var nullable = ?match[3]

					if match[1] == 'Any' {
						if ?match[2] {
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
				if data[0] is Number {
					if data[0] == -1 {
						throw NotImplementedException.new(node)
					}
					else if var type ?= references[data[0]] {
						return references[data[0]].name(data[1])
					}
					else {
						var type = Type.toNamedType(
							Type.import(data[0], metadata, references, alterations, queue, scope, node)
							false
							scope
							node
						)

						references[data[0]] = type

						return scope.reference(type)
					}
				}
			}
			else if ?data.reference {
				if var reference ?= references[data.reference] {
					if reference is ArrayType | FunctionType | ObjectType | ReferenceType {
						return reference
					}
					else {
						return scope.reference(reference)
					}
				}
				else {
					var type = Type.toNamedType(
						Type.import(data.reference, metadata, references, alterations, queue, scope, node)
						false
						scope
						node
					)

					references[data.reference] = type

					return scope.reference(type)
				}
			}
			else if ?data.kind {
				match data.kind {
					TypeKind.Alias {
						return AliasType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Array {
						return ArrayType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Class {
						return ClassType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Deferred {
						return DeferredType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Enum {
						return EnumType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Function {
						return FunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Fusion {
						return FusionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Namespace {
						return NamespaceType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Object {
						return ObjectType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.OverloadedFunction {
						return OverloadedFunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Reference {
						return ReferenceType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Struct {
						return StructType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Tuple {
						return TupleType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Union {
						return UnionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.ValueOf {
						return ValueOfType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Variant {
						return VariantType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
				}
			}
			else if ?data.type {
				return Type.import(data.type, metadata, references, alterations, queue, scope, node)
			}
			else if ?data.originals {
				var first = references[data.originals[0]]
				var second = references[data.originals[1]]

				var requirement = first.origin() ~~ TypeOrigin.Require
				var [major, minor] = requirement ? [first, second] : [second, first]
				var origin = requirement ? TypeOrigin.RequireOrExtern : TypeOrigin.ExternOrRequire

				var type = ClassType.new(scope)

				type.origin(origin).originals(major.type(), minor.type())

				queue.push(() => {
					type.copyFrom(major.type())
				})

				return type
			}

			console.info(data)
			throw NotImplementedException.new(node)
		} # }}}
		isNative(name: String) => $natives[name] == true
		objectOf(parameter: Type, scope: Scope) { # {{{
			var type = ObjectType.new(scope)

			type.setRestType(parameter)

			return type
		} # }}}
		renameNative(name: String) => $types[name] is String ? $types[name] : name
		toNamedType(name: String, type: Type): Type { # {{{
			return type unless type.shallBeNamed()

			if type is NamespaceType {
				return NamedContainerType.new(name, type)
			}
			else {
				return NamedType.new(name, type)
			}
		} # }}}
		toNamedType(type: Type, declare: Boolean, scope: Scope, node: AbstractNode): Type { # {{{
			return type unless type.shallBeNamed()

			var namedType = type is NamespaceType ? NamedContainerType.new(scope.acquireTempName(declare), type) : NamedType.new(scope.acquireTempName(declare), type)

			scope.define(namedType.name(), true, namedType, node)

			return namedType
		} # }}}
		union(scope: Scope, ...types) { # {{{
			if types.length == 1 {
				return types[0]
			}

			var union = UnionType.new(scope, types)

			return union.type()
		} # }}}
	}
	constructor(@scope)
	abstract clone(): Type
	abstract export(references: Array, indexDelta: Number, mode: ExportMode, module: Module)
	abstract toFragments(fragments, node)
	abstract toVariations(variations: Array<String>): Void
	asReference(): Type => this
	canBeArray(any: Boolean = true): Boolean => (any && @isAny()) || @isArray()
	canBeBoolean(): Boolean => @isAny() || @isBoolean()
	canBeDeferred(): Boolean => false
	canBeEnum(any: Boolean = true): Boolean => (any && @isAny()) || @isEnum()
	canBeFunction(any: Boolean = true): Boolean => (any && @isAny()) || @isFunction()
	canBeNumber(any: Boolean = true): Boolean => (any && @isAny()) || @isNumber()
	canBeObject(any: Boolean = true): Boolean => (any && @isAny()) || @isObject()
	canBeString(any: Boolean = true): Boolean => (any && @isAny()) || @isString()
	canBeVirtual(name: String) { # {{{
		if @isAny() {
			return true
		}

		match name {
			'Enum'		=> return @isEnum()
			'Namespace'	=> return @isNamespace()
			'Struct'	=> return @isStruct()
			'Tuple'		=> return @isTuple()
		}

		return false
	} # }}}
	clone(scope: Scope): Type { # {{{
		var clone = @clone()

		clone._scope = scope

		return clone
	} # }}}
	compareTo(value: Type) => false
	discard(): Type? => this
	discardAlias(): Type => this
	discardName(): Type => this
	discardReference(): Type? => this
	discardSpread(): Type => this
	discardValue(): Type => this
	discardVariable(): Type => this
	// TODO to remove
	equals(value?): Boolean => ?value && @isSubsetOf(value, MatchingMode.Exact)
	finalize(data, generics: String[], node: AbstractNode): Void
	flagAlien() { # {{{
		@alien = true

		return this
	} # }}}
	flagAltering(): valueof this
	flagComplete() { # {{{
		@complete = true

		return this
	} # }}}
	// TODO!
	// flagConstant(): typeof this {
	flagConstant() { # {{{
		if @constant {
			return this
		}
		else {
			var type = @clone()

			type._constant = true

			return type
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@exported = true

		return this
	} # }}}
	flagReferenced() { # {{{
		@referenced = true

		return this
	} # }}}
	flagRequired() { # {{{
		@required = true

		return this
	} # }}}
	flagRequirement() { # {{{
		@requirement = true

		return this
	} # }}}
	flagSealed() { # {{{
		@sealed = true

		return this
	} # }}}
	flagSystem() { # {{{
		@system = true

		return @flagSealed()
	} # }}}
	getExhaustive() => @exhaustive
	getGenericMapper(): { type: Type, generics: AltType[]?, subtypes: AltType[]? } => { type: this, generics: null, subtypes: null }
	getProperty(index: Number) => null
	getProperty(name: String) => null
	getProperty(name: String, node?) => @getProperty(name)
	getMajorReferenceIndex() => @referenceIndex
	// TODO merge
	hashCode(): String => ''
	hashCode(fattenNull: Boolean) => @hashCode()
	hasMutableAccess() => false
	hasProperty(name: String): Boolean => false
	hasRest() => false
	hasSameParameters(value: Type): Boolean => false
	hasTest() => false
	isAlias() => false
	isAlien() => @alien
	isAltering() => false
	isAny() => false
	isAnonymous() => false
	isArray() => false
	isAssignableToVariable(value: Type): Boolean => @isAssignableToVariable(value, true, false, true)
	isAssignableToVariable(value: Type, downcast: Boolean): Boolean => @isAssignableToVariable(value, true, false, downcast)
	isAssignableToVariable(value: Type, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		if this == value {
			return true
		}
		else if value.isAny() {
			if @isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if @isAlias() {
			return @discardAlias().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
		else {
			return false
		}
	} # }}}
	isBinding() => false
	isBoolean() => false
	isBroadArray() => @isArray()
	isBroadObject() => @isObject()
	isCloned() => false
	isClass() => false
	isClassInstance() => false
	isComparableWith(type: Type): Boolean => type.isAssignableToVariable(this, true, false, false)
	isComplete() => @complete
	isComplex() => false
	isContainedIn(types) { # {{{
		for var type in types {
			if @equals(type) {
				return true
			}
		}

		return false
	} # }}}
	isContainer() => @isClass() || @isStruct() || @isTuple()
	isDeferred() => false
	isEnum() => false
	isExclusion() => false
	isExhaustive() { # {{{
		if @exhaustive == null {
			return !@alien && !@required
		}
		else {
			return @exhaustive
		}
	} # }}}
	isExhaustive(node) => @isExhaustive() && !node._options.rules.ignoreMisfit
	isExplicit() => true
	isExplicitlyExported() => @exported
	isExportable() => @isAlien() || @isExported() || @isNative() || @isRequirement() || @referenceIndex != -1
	isExportable(mode: ExportMode) => mode ~~ ExportMode.Requirement || @isExportable()
	isExportingFragment() => (!@isVirtual() && !@isSystem()) || (@isSealed() && @isExtendable())
	isExportingType() => false
	isExported() => @exported
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isFusion() => false
	isHybrid() => false
	isImmutable() => false
	isInoperative() => @isNever() || @isVoid()
	isInstance() => false
	isIterable() => false
	isLiberal() => false
	isMergeable(type) => false
	isMethod() => false
	isMorePreciseThan(value: Type): Boolean => false
	isNamed() => false
	isNamespace() => false
	isNative() => false
	isNever() => false
	isNumber() => false
	isNull() => false
	isNullable() => false
	isNullable(generics: AltType[]?) => @isNullable()
	isObject() => false
	isPlaceholder() => false
	isPredefined() => false
	isPrimitive() => false
	isReducible() => false
	isReference() => false
	isReferenced() => @referenced
	isRequired() => @required
	isRequirement() => @requirement
	isSameVariance(value: Type) => false
	isSealable() => false
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	isSplittable() => @isNullable() || @isUnion()
	isSpread() => false
	isStrict() => false
	isString() => false
	isStruct() => false
	isSubsetOf(value: Type, generics: AltType[]? = null, subtypes: AltType[]? = null, mode: MatchingMode): Boolean => false
	// TODO!
	// assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
	// 	if #generics {
	// 		var valname = value.name()

	// 		for var { name, type } in generics {
	// 			if name == valname {
	// 				return @isSubsetOf(type, generics, subtypes, mode)
	// 			}
	// 		}
	// 	}

	// 	return true
	// } # }}}
	isSystem() => @system
	isTuple() => false
	isTypeOf() => false
	isUnion() => false
	isValue() => false
	isValueOf() => false
	isVariant() => false
	isVirtual() => false
	isVoid() => false
	// TODO to remove
	matchContentOf(value: Type?): Boolean => @equals(value)
	merge(value: Type, generics: AltType[]?, subtypes: AltType[]?, node): Type { # {{{
		return @isMorePreciseThan(value) ? this : value
	} # }}}
	minorOriginal() => null
	origin(): valueof @origin
	origin(@origin): valueof this
	parameter() => AnyType.NullableUnexplicit
	reduce(type: Type) => this
	reference(scope? = @scope) => scope.reference(this)
	referenceIndex() => @referenceIndex
	resetReferences() { # {{{
		@referenceIndex = -1
	} # }}}
	scope() => @scope
	setExhaustive(@exhaustive) => this
	// TODO!
	// setNullable(nullable: Boolean): typeof this => this
	setNullable(nullable: Boolean) => this
	// TODO!
	// setNullable(type: Type): typeof this { # {{{
	setNullable(type: Type): Type { # {{{
		if !type.isNullable() {
			return @setNullable(false)
		}
		else {
			return this
		}
	} # }}}
	shallBeNamed() => false
	sort() => this
	split(types: Array): Array { # {{{
		if @isNullable() {
			types.pushUniq(@setNullable(false), Type.Null)
		}
		else {
			types.pushUniq(this)
		}

		return types
	} # }}}
	toAwareTestFunctionFragments(varname: String, nullable: Boolean, generics: AltType[]?, subtypes: AltType[]?, fragments, node) { # {{{
		fragments.code(`\(varname) => `)

		@toBlindTestFragments(varname, null, Junction.NONE, fragments, node)
	} # }}}
	toBlindSubtestFunctionFragments(funcname: String?, varname: String, nullable: Boolean, generics: String[]?, fragments, node) { # {{{
		@toAwareTestFunctionFragments(varname, nullable, null, null, fragments, node)
	} # }}}
	toBlindTestFragments(varname: String, generics: String[]?, junction: Junction, fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	toBlindTestFunctionFragments(funcname: String?, varname: String, testingType: Boolean, generics: String[]?, fragments, node) { # {{{
		@toBlindSubtestFunctionFragments(funcname, varname, false, generics, fragments, node)
	} # }}}
	toExportFragment(fragments, name, variable) { # {{{
		if !@isVirtual() && !@isSystem() {
			var varname = variable.getSecureName?()

			if name == varname {
				fragments.line(name)
			}
			else {
				fragments.newLine().code(`\(name): `).compile(variable).done()
			}
		}

		if @isSealed() && @isExtendable() {
			var varname = this.getSealedName()

			if `__ks_\(name)` == varname {
				fragments.line(varname)
			}
			else {
				fragments.line(`__ks_\(name): \(this.getSealedName())`)
			}
		}
	} # }}}
	toExportOrIndex(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if @isReferenced() {
			return @toMetadata(references, indexDelta, mode, module)
		}
		else {
			return @export(references, indexDelta, mode, module)
		}
	} # }}}
	toExportOrReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if @isReferenced() {
			return {
				reference: @toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return @export(references, indexDelta, mode, module)
		}
	} # }}}
	toGenericParameter(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var reference = @getMajorReferenceIndex()
		if reference != -1 {
			return {
				reference
			}
		}
		else if @isReferenced() {
			return {
				reference: @toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return @export(references, indexDelta, mode, module)
		}
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex == -1 {
			var index = references.length

			@referenceIndex = index + indexDelta

			// reserve position
			references.push(null)

			references[index] = @export(references, indexDelta, mode, module)
		}

		return @referenceIndex
	} # }}}
	toNegativeTestFragments(parameters: AltType[]? = null, subtypes: AltType[]? = null, junction: Junction = Junction.NONE, fragments, node) { # {{{
		@toPositiveTestFragments(parameters, subtypes, junction, fragments.code('!'), node)
	} # }}}
	toPositiveTestFragments(parameters: AltType[]? = null, subtypes: AltType[]? = null, junction: Junction = Junction.NONE, fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	toQuote(): String { # {{{
		throw NotSupportedException.new()
	} # }}}
	toQuote(double: Boolean): String { # {{{
		if double {
			return `"\(@toQuote())"`
		}
		else {
			return `'\(@toQuote())'`
		}
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => { # {{{
		reference: @toMetadata(references, indexDelta, mode, module)
	} # }}}
	toRequiredMetadata(requirements: Array<Requirement>) { # {{{
		if @required {
			return true
		}

		for var requirement in requirements {
			if this == requirement.alternative() {
				return requirement.type().referenceIndex()
			}
		}

		return false
	} # }}}
	toRouteTestFragments(fragments, node, junction: Junction) { # {{{
		NotImplementedException.throw()
	} # }}}
	toRouteTestFragments(fragments, node, argName: String, from: Number, to: Number, default: Boolean, junction: Junction) { # {{{
		NotImplementedException.throw()
	} # }}}
	toTestType() => this
	toTypeQuote() => @toQuote()
	tryCasting(value: Type): Type { # {{{
		if value.isMorePreciseThan(this) {
			return value
		}
		else {
			return this
		}
	} # }}}
	tune(value: Type): Type? => null
	// TODO
	// type(): valueof this
	type() => this
	unflagAltering(): valueof this
	unflagRequired(): valueof this { # {{{
		@required = false
	} # }}}
	unflagStrict(): valueof this
	unspecify(): Type => this
}

include {
	'./type/function.ks'
	'./type/named.ks'
	'./type/reference.ks'
	'./type/sealable.ks'
	'./type/alias.ks'
	'./type/any.ks'
	'./type/array.ks'
	'./type/class.ks'
	'./type/class-constructor.ks'
	'./type/class-destructor.ks'
	'./type/class-method.ks'
	'./type/class-variable.ks'
	'./type/deferred.ks'
	'./type/enum.ks'
	'./type/namespace.ks'
	'./type/never.ks'
	'./type/null.ks'
	'./type/object.ks'
	'./type/parameter.ks'
	'./type/struct.ks'
	'./type/tuple.ks'
	'./type/exclusion.ks'
	'./type/fusion.ks'
	'./type/union.ks'
	'./type/value.ks'
	'./type/valueof.ks'
	'./type/variant.ks'
	'./type/void.ks'
}

Type.Any = AnyType.Unexplicit
Type.Never = NeverType.new()
Type.Null = NullType.Unexplicit
Type.Undecided = AnyType.new(false, true)
Type.Void = VoidType.new()
