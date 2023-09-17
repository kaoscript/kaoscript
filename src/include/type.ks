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
}

enum Junction {
	NONE
	AND
	OR
}

enum TestFunctionMode {
	DEFINE
	USE
}

bitmask TypeOrigin {
	None

	Extern
	ExternOrRequire
	Import
	Require
	RequireOrExtern
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
		fromAST(mut data?, scope: Scope = node.scope(), defined: Boolean = true, node: AbstractNode): Type { # {{{
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
						if ?property.type {
							type.addProperty(property.name.name, Type.fromAST(property.type, scope, defined, node))
						}
						else {
							type.addProperty(property.name.name, AnyType.Unexplicit)
						}
					}

					if ?data.rest {
						if ?data.rest.type {
							type.setRestType(Type.fromAST(data.rest.type, scope, defined, node))
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
							var type = match name {
								'Array'		=> ArrayType.new(scope).setNullable(nullable)
								'Object'	=> ObjectType.new(scope).setNullable(nullable)
								else {
									return scope.reference(name, nullable)
								}
							}

							var parameter = data.typeParameters[0]

							type.setRestType(Type.fromAST(parameter, scope, defined, node))

							return type.flagComplete()
						}
						else if !defined || Type.isNative(name) || scope.hasVariable(name, -1) {
							if var variable ?= scope.getVariable(name, -1) {
								var type = variable.getDeclaredType()

								if type.isReference() || type.isAny() {
									ReferenceException.throwNotAType(name, node)
								}
							}

							return scope.reference(name, nullable)
						}
						else {
							ReferenceException.throwNotDefinedType(data.typeName.name, node)
						}
					}
					else if data.typeName.kind == NodeKind.MemberExpression && !data.typeName.computed {
						var namespace = Type.fromAST(data.typeName.object, scope, defined, node)

						if !defined || namespace.scope().hasVariable(data.typeName.property.name, -1) {
							return ReferenceType.new(namespace.scope(), data.typeName.property.name, nullable)
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
			}

			console.info(data)
			throw NotImplementedException.new(node)
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
	abstract toPositiveTestFragments(fragments, node, junction: Junction = Junction.NONE)
	abstract toVariations(variations: Array<String>): Void
	asReference(): Type => this
	canBeArray(any: Boolean = true): Boolean => (any && @isAny()) || @isArray()
	canBeBoolean(): Boolean => @isAny() || @isBoolean()
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
	discardVariable(): Type => this
	// TODO to remove
	equals(value?): Boolean => ?value && @isSubsetOf(value, MatchingMode.Exact)
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
	getProperty(index: Number) => null
	getProperty(name: String) => null
	getMajorReferenceIndex() => @referenceIndex
	// TODO merge
	hashCode(): String => ''
	hashCode(fattenNull: Boolean) => @hashCode()
	hasMutableAccess() => false
	hasProperty(name: String): Boolean => false
	hasRest() => false
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
	isObject() => false
	isPlaceholder() => false
	isPredefined() => false
	isPrimitive() => false
	isReducible() => false
	isReference() => false
	isReferenced() => @referenced
	isRequired() => @required
	isRequirement() => @requirement
	isSealable() => false
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	isSplittable() => @isNullable() || @isUnion()
	isSpread() => false
	isStrict() => false
	isString() => false
	isStruct() => false
	isSubsetOf(value: Type, mode: MatchingMode) => false
	isSystem() => @system
	isTuple() => false
	isTypeOf() => false
	isUnion() => false
	isValueOf() => false
	isVirtual() => false
	isVoid() => false
	// TODO to remove
	matchContentOf(value: Type?): Boolean => @equals(value)
	merge(value: Type, node): Type { # {{{
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
	toNegativeTestFragments(fragments, node, junction: Junction = Junction.NONE) => @toPositiveTestFragments(fragments.code('!'), node, junction)
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
	toTestFragments(fragments, node, junction: Junction) { # {{{
		NotImplementedException.throw()
	} # }}}
	toTestFunctionFragments(fragments, node) { # {{{
		if node._options.format.functions == 'es5' {
			fragments.code('function(value) { return ')
		}
		else {
			fragments.code('value => ')
		}

		@toTestFragments(fragments, node, Junction.NONE)

		if node._options.format.functions == 'es5' {
			fragments.code('; }')
		}
	} # }}}
	toTestFunctionFragments(fragments, node, mode: TestFunctionMode) { # {{{
		if mode == .USE {
			@toTestFunctionFragments(fragments, node)
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	toTestType() => this
	toTypeQuote() => @toQuote()
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
	'./type/valueof.ks'
	'./type/void.ks'
}

Type.Any = AnyType.Unexplicit
Type.Never = NeverType.new()
Type.Null = NullType.Unexplicit
Type.Undecided = AnyType.new(false, true)
Type.Void = VoidType.new()
