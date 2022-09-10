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
	dict: 'Dictionary'
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

	IgnoreError
	IgnoreName
	IgnoreReturn

	AutoCast

	Signature = Similar + MissingParameter + ShiftableParameters + MissingParameterType + RequireAllParameters + MissingReturn
	FunctionSignature = ExactParameter +
		SubclassParameter +
		NonNullToNullParameter +
		MissingParameterDefault +
		AdditionalParameter +
		// TODO reenable
		// AdditionalParameterDefault +
		// AdditionalDefault +
		MissingParameterType +
		MissingParameterArity
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
	Tuple
	Union
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

abstract class Type {
	private {
		@alien: Boolean					= false
		@exhaustive: Boolean? 			= null
		@exported: Boolean				= false
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
		arrayOf(parameter: Type, scope: Scope) => new ReferenceType(scope, 'Array', false, [parameter])
		fromAST(data?, node: AbstractNode): Type => Type.fromAST(data, node.scope(), true, node)
		fromAST(mut data?, scope: Scope, defined: Boolean, node: AbstractNode): Type { # {{{
			if !?data {
				return AnyType.NullableUnexplicit
			}
			else if data is Type {
				return data
			}

			data = data as Any

			switch data.kind {
				NodeKind::ArrayType => {
					var mut type = new ArrayType(scope)

					type.setRestType(Type.fromAST(data.element, scope, defined, node))

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind::Nullable {
							type = type.setNullable(true)
						}
					}

					return type
				}
				NodeKind::ClassDeclaration => {
					var type = new ClassType(scope)

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
					if ?data.parameters {
						return new FunctionType([ParameterType.fromAST(parameter, false, scope, defined, node) for parameter in data.parameters], data, node)
					}
					else {
						return new FunctionType([new ParameterType(scope, AnyType.NullableUnexplicit, 0, Infinity)] as Array<ParameterType>, data, node)
					}
				}
				NodeKind::FunctionExpression, NodeKind::MethodDeclaration => {
					return new FunctionType([ParameterType.fromAST(parameter, false, scope, defined, node) for parameter in data.parameters] as Array<ParameterType>, data, node)
				}
				NodeKind::FusionType => {
					return new FusionType(scope, [Type.fromAST(type, scope, defined, node) for type in data.types])
				}
				NodeKind::Identifier => {
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
				NodeKind::MemberExpression => {
					var object = Type.fromAST(data.object, scope, defined, node)

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
				NodeKind::ObjectType => {
					var mut type = new DictionaryType(scope)

					type.setRestType(Type.fromAST(data.element, scope, defined, node))

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind::Nullable {
							type = type.setNullable(true)
						}
					}

					return type
				}
				NodeKind::TypeReference => {
					if ?data.elements {
						var type = new ArrayType(scope)

						for var element in data.elements {
							if element.modifiers.length == 1 && element.modifiers[0].kind == ModifierKind::Rest {
								type.setRestType(Type.fromAST(element, scope, defined, node))
							}
							else {
								type.addProperty(Type.fromAST(element, scope, defined, node))
							}
						}

						return type
					}
					else if ?data.properties {
						var type = new DictionaryType(scope)

						for var property in data.properties {
							if ?property.name {
								type.addProperty(property.name.name, Type.fromAST(property.type, scope, defined, node))
							}
							else {
								type.setRestType(Type.fromAST(property.type, scope, defined, node))
							}
						}

						return type
					}
					else if ?data.typeName {
						var mut nullable = false

						for var modifier in data.modifiers {
							if modifier.kind == ModifierKind::Nullable {
								nullable = true
							}
						}

						if data.typeName.kind == NodeKind::Identifier {
							var name = Type.renameNative(data.typeName.name)

							if name == 'Any' {
								return nullable ? AnyType.NullableExplicit : AnyType.Explicit
							}
							else if !defined || Type.isNative(name) || scope.hasVariable(name, -1) {
								if ?data.typeParameters {
									var type = new ReferenceType(scope, name, nullable)

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
								ReferenceException.throwNotDefinedType(data.typeName.name, node)
							}
						}
						else if data.typeName.kind == NodeKind::MemberExpression && !data.typeName.computed {
							var namespace = Type.fromAST(data.typeName.object, scope, defined, node)

							var type = new ReferenceType(namespace.scope(), data.typeName.property.name, nullable)

							if ?data.typeParameters {
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
		} # }}}
		import(index, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): Type { # {{{
			var data = index is Number ? metadata[index] : index

			// console.log('-- import --')
			// console.log(JSON.stringify(data, null, 2))

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
						throw new NotImplementedException(node)
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
					if reference is ArrayType | DictionaryType | ReferenceType {
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
				switch data.kind {
					TypeKind::Alias => {
						return AliasType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Array => {
						return ArrayType.import(index, data, metadata, references, alterations, queue, scope, node)
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
					TypeKind::Fusion => {
						return FusionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Namespace => {
						return NamespaceType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::OverloadedFunction => {
						return OverloadedFunctionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Reference => {
						return ReferenceType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Struct => {
						return StructType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Tuple => {
						return TupleType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind::Union => {
						return UnionType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
				}
			}
			else if ?data.type {
				return Type.import(data.type, metadata, references, alterations, queue, scope, node)
			}
			else if ?data.originals {
				var first = references[data.originals[0]]
				var second = references[data.originals[1]]

				var requirement = first.origin() ~~ TypeOrigin::Require
				var [major, minor] = requirement ? [first, second] : [second, first]
				var origin = requirement ? TypeOrigin::RequireOrExtern : TypeOrigin::ExternOrRequire

				var type = new ClassType(scope)

				type.origin(origin).originals(major.type(), minor.type())

				queue.push(() => {
					type.copyFrom(major.type())
				})

				return type
			}

			console.info(data)
			throw new NotImplementedException(node)
		} # }}}
		isNative(name: String) => $natives[name] == true
		renameNative(name: String) => $types[name] is String ? $types[name] : name
		toNamedType(name: String, type: Type): Type { # {{{
			return type unless type.shallBeNamed()

			if type.isContainer() {
				return new NamedContainerType(name, type)
			}
			else {
				return new NamedType(name, type)
			}
		} # }}}
		toNamedType(type: Type, declare: Boolean, scope: Scope, node: AbstractNode): Type { # {{{
			return type unless type.shallBeNamed()

			var namedType = type.isContainer() ? new NamedContainerType(scope.acquireTempName(declare), type) : new NamedType(scope.acquireTempName(declare), type)

			scope.define(namedType.name(), true, namedType, node)

			return namedType
		} # }}}
		union(scope: Scope, ...types) { # {{{
			if types.length == 1 {
				return types[0]
			}

			var union = new UnionType(scope, types)

			return union.type()
		} # }}}
	}
	constructor(@scope)
	abstract clone(): Type
	abstract export(references: Array, indexDelta: Number, mode: ExportMode, module: Module)
	abstract toFragments(fragments, node)
	abstract toPositiveTestFragments(fragments, node, junction: Junction = Junction::NONE)
	abstract toVariations(variations: Array<String>): Void
	asReference(): this
	canBeBoolean(): Boolean => this.isAny() || this.isBoolean()
	canBeEnum(any: Boolean = true): Boolean => (any && this.isAny()) || this.isEnum()
	canBeFunction(any: Boolean = true): Boolean => (any && this.isAny()) || this.isFunction()
	canBeNumber(any: Boolean = true): Boolean => (any && this.isAny()) || this.isNumber()
	canBeString(any: Boolean = true): Boolean => (any && this.isAny()) || this.isString()
	canBeVirtual(name: String) { # {{{
		if this.isAny() {
			return true
		}

		switch name {
			'Enum'		=> return this.isEnum()
			'Namespace'	=> return this.isNamespace()
			'Struct'	=> return this.isStruct()
			'Tuple'		=> return this.isTuple()
		}

		return false
	} # }}}
	clone(scope: Scope): Type { # {{{
		var clone = this.clone()

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
	equals(value?): Boolean => ?value && this.isSubsetOf(value, MatchingMode::Exact)
	flagAlien() { # {{{
		@alien = true

		return this
	} # }}}
	flagAltering(): this
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

		return this.flagSealed()
	} # }}}
	getExhaustive() => @exhaustive
	getProperty(index: Number) => null
	getProperty(name: String) => null
	getMajorReferenceIndex() => @referenceIndex
	hashCode(): String => ''
	hashCode(fattenNull: Boolean) => this.hashCode()
	hasProperty(name: String): Boolean => false
	isAlias() => false
	isAlien() => @alien
	isAltering() => false
	isAny() => false
	isAnonymous() => false
	isArray() => false
	isAssignableToVariable(value: Type): Boolean => this.isAssignableToVariable(value, true, false, true)
	isAssignableToVariable(value: Type, downcast: Boolean): Boolean => this.isAssignableToVariable(value, true, false, downcast)
	isAssignableToVariable(value: Type, anycast: Boolean, nullcast: Boolean, downcast: Boolean, limited: Boolean = false): Boolean { # {{{
		if this == value {
			return true
		}
		else if value.isAny() {
			if this.isNullable() {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if this.isAlias() {
			return this.discardAlias().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
		else {
			return false
		}
	} # }}}
	isBoolean() => false
	isCloned() => false
	isClass() => false
	isClassInstance() => false
	isComparableWith(type: Type): Boolean => type.isAssignableToVariable(this, true, false, false)
	isContainedIn(types) { # {{{
		for type in types {
			if this.equals(type) {
				return true
			}
		}

		return false
	} # }}}
	isContainer() => false
	isDictionary() => false
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
	isExhaustive(node) => this.isExhaustive() && !node._options.rules.ignoreMisfit
	isExplicit() => true
	isExplicitlyExported() => @exported
	isExportable() => this.isAlien() || this.isExported() || this.isNative() || this.isRequirement() || @referenceIndex != -1
	isExportable(mode: ExportMode) => mode ~~ ExportMode::Requirement || this.isExportable()
	isExportingFragment() => (!this.isVirtual() && !this.isSystem()) || (this.isSealed() && this.isExtendable())
	isExported() => @exported
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isFusion() => false
	isHybrid() => false
	isImmutable() => false
	isInoperative() => this.isNever() || this.isVoid()
	isInstance() => false
	isIterable() => false
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
	isVirtual() => false
	isVoid() => false
	// TODO to remove
	matchContentOf(value: Type?): Boolean => this.equals(value)
	minorOriginal() => null
	origin(): @origin
	origin(@origin): this
	reduce(type: Type) => this
	reference(scope? = @scope) => scope.reference(this)
	referenceIndex() => @referenceIndex
	resetReferences() { # {{{
		@referenceIndex = -1
	} # }}}
	scope() => @scope
	setExhaustive(@exhaustive) => this
	setNullable(nullable: Boolean) => this
	setNullable(type: Type): Type { # {{{
		if !type.isNullable() {
			return this.setNullable(false)
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
		if !this.isVirtual() && !this.isSystem() {
			var varname = variable.name?()

			if name == varname {
				fragments.line(name)
			}
			else {
				fragments.newLine().code(`\(name): `).compile(variable).done()
			}
		}

		if this.isSealed() && this.isExtendable() {
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
		else if this.isReferenced() {
			return this.toMetadata(references, indexDelta, mode, module)
		}
		else {
			return this.export(references, indexDelta, mode, module)
		}
	} # }}}
	toExportOrReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if this.isReferenced() {
			return {
				reference: this.toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return this.export(references, indexDelta, mode, module)
		}
	} # }}}
	toGenericParameter(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var reference = this.getMajorReferenceIndex()
		if reference != -1 {
			return {
				reference
			}
		}
		else if this.isReferenced() {
			return {
				reference: this.toMetadata(references, indexDelta, mode, module)
			}
		}
		else {
			return this.export(references, indexDelta, mode, module)
		}
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex == -1 {
			var index = references.length

			@referenceIndex = index + indexDelta

			// reserve position
			references.push(null)

			references[index] = this.export(references, indexDelta, mode, module)
		}

		return @referenceIndex
	} # }}}
	toNegativeTestFragments(fragments, node, junction: Junction = Junction::NONE) => this.toPositiveTestFragments(fragments.code('!'), node, junction)
	toQuote(): String { # {{{
		throw new NotSupportedException()
	} # }}}
	toQuote(double: Boolean): String { # {{{
		if double {
			return `"\(this.toQuote())"`
		}
		else {
			return `'\(this.toQuote())'`
		}
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => { # {{{
		reference: this.toMetadata(references, indexDelta, mode, module)
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
	toTestFunctionFragments(fragments, node) { # {{{
		if node._options.format.functions == 'es5' {
			fragments.code('function(value) { return ')
		}
		else {
			fragments.code('value => ')
		}

		this.toTestFunctionFragments(fragments, node, Junction::NONE)

		if node._options.format.functions == 'es5' {
			fragments.code('; }')
		}
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		NotImplementedException.throw()
	} # }}}
	toTestType() => this
	toTypeQuote() => this.toQuote()
	// TODO
	// type(): this
	type() => this
	unflagAltering(): this
	unflagRequired(): this { # {{{
		@required = false
	} # }}}
	unflagStrict(): this
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
	'./type/class-constructor'
	'./type/class-destructor'
	'./type/class-method'
	'./type/class-variable'
	'./type/destructurable-object'
	'./type/enum'
	'./type/namespace'
	'./type/never'
	'./type/null'
	'./type/dictionary'
	'./type/parameter'
	'./type/struct'
	'./type/tuple'
	'./type/exclusion'
	'./type/fusion'
	'./type/union'
	'./type/void'
}

Type.Any = AnyType.Unexplicit
Type.Never = new NeverType()
Type.Null = NullType.Unexplicit
Type.Void = new VoidType()
