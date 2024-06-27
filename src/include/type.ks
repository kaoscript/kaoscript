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
	IgnoreDeferred
	IgnoreError
	IgnoreName
	IgnoreNullable
	IgnoreRetained
	IgnoreReturn

	TypeCasting

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
	Bitmask
	Class
	Deferred
	Enum
	EnumView
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

	Implements
}

bitmask LibSTDMode {
	// TODO!
	No			 = 1
	Yes

	Closed
	Opened

	Augmented
}

type AltType = {
	name: String
	type: Type
}
// TODO
// type AltTypes = AltType[]

type Generic = {
	name: String
	type: Type?
}
type Variant = {
	names: String[]
	type: Type
	value: ValueType?
}

abstract class Type {
	private {
		@alien: Boolean					= false
		@auxiliary: Boolean				= false
		@complete: Boolean				= false
		@constant: Boolean?				= null
		@exhaustive: Boolean? 			= null
		@exported: Boolean				= false
		@mutable: Boolean?				= null
		@origin: TypeOrigin?			= null
		@predefined: Boolean			= false
		@referenced: Boolean			= false
		@referenceIndex: Number			= -1
		@required: Boolean 				= false
		@requirement: Boolean			= false
		@scope: Scope?
		@sealed: Boolean				= false
		@specter: Boolean				= false
		@system: Boolean				= false
		@standardLibrary: LibSTDMode	= .No
	}
	static {
		arrayOf(parameter: Type, scope: Scope) { # {{{
			var type = ArrayType.new(scope)

			type.setRestType(parameter)

			return type
		} # }}}
		fromAST(mut data?, scope: Scope = node.scope(), defined: Boolean = true, generics: Generic[]? = null, node: AbstractNode): Type { # {{{
			if !?data {
				return AnyType.NullableUnexplicit
			}
			else if data is Type {
				return data
			}

			data = data:&(Any)

			match AstKind(data.kind) {
				AstKind.ArrayExpression {
					var type = ArrayType.new(scope)

					for var value in data.values {
						type.addProperty(Type.fromAST(value, scope, defined, generics, node))
					}

					return type.flagComplete()
				}
				AstKind.ArrayType {
					var mut type: Type = ArrayType.new(scope)

					for var modifier in data.modifiers {
						match ModifierKind(modifier.kind) {
							ModifierKind.Nullable {
								type = type.setNullable(true)
							}
						}
					}

					if ?#data.properties || ?data.rest {
						for var property in data.properties {
							type.addProperty(Type.fromAST(property.type, scope, defined, generics, node))
						}

						if ?data.rest {
							type.setRestType(Type.fromAST(data.rest.type, scope, defined, generics, node))
						}
					}
					else {
						type = type.unspecify()
					}

					return type.flagComplete()
				}
				AstKind.ClassDeclaration {
					var type = ClassType.new(scope)

					for var modifier in data.modifiers {
						match ModifierKind(modifier.kind) {
							ModifierKind.Abstract {
								type.flagAbstract()
							}
							ModifierKind.Sealed {
								type.flagSealed()
							}
						}
					}

					return NamedType.new(data.name.name, type.flagComplete())
				}
				AstKind.ExclusionType {
					return ExclusionType.new(scope, [Type.fromAST(type, scope, defined, generics, node) for var type in data.types])
				}
				AstKind.FunctionDeclaration, AstKind.MethodDeclaration {
					if ?data.parameters {
						return FunctionType.new([ParameterType.fromAST(parameter, false, scope, defined, generics, node) for var parameter in data.parameters], data, node).flagComplete()
					}
					else {
						return FunctionType.new([ParameterType.new(scope, AnyType.NullableUnexplicit, 0, Infinity)]:!!!(Array<ParameterType>), data, node).flagComplete()
					}
				}
				AstKind.FunctionExpression {
					var parameters = [ParameterType.fromAST(parameter, false, scope, defined, generics, node) for var parameter in data.parameters]

					return FunctionType.new(parameters:!!!(Array<ParameterType>), generics, data, node).flagComplete()
				}
				AstKind.FusionType {
					return FusionType.new(scope, [Type.fromAST(type, scope, defined, generics, node) for var type in data.types])
				}
				AstKind.Identifier {
					if var variable ?= scope.getVariable(data.name) {
						return variable.getDeclaredType()
					}
					else if $runtime.getVariable(data.name, node) != null {
						return Type.Any
					}
					else if scope.isMacro() {
						return Type.Unknown
					}
					else {
						ReferenceException.throwNotDefinedType(data.name, node)
					}
				}
				AstKind.LambdaExpression {
					var parameters = [ParameterType.fromAST(parameter, false, scope, defined, generics, node) for var parameter in data.parameters]

					return FunctionType.new(parameters:!!!(Array<ParameterType>), generics, data, node).flagComplete()
				}
				AstKind.Literal {
					return scope.reference('String')
				}
				AstKind.MemberExpression {
					var object = Type.fromAST(data.object, scope, defined, generics, node)

					if object.isAny() {
						return Type.Any
					}
					else {
						return object.getProperty(data.property.name)
					}
				}
				AstKind.NumericExpression {
					return scope.reference('Number')
				}
				AstKind.ObjectExpression {
					var type = ObjectType.new(scope)

					for var { name, value } in data.properties {
						if name.kind == AstKind.Literal {
							type.addProperty(name.name, Type.fromAST(value, scope, defined, generics, node))
						}
					}

					return type.flagComplete()
				}
				AstKind.ObjectType {
					var mut type: Type = ObjectType.new(scope)

					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Nullable {
							type = type.setNullable(true)
						}
					}

					if ?#data.properties || ?data.rest {
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
							else if data.modifiers.some(({ kind }) => ModifierKind(kind) == ModifierKind.Nullable) {
								type.setRestType(AnyType.NullableUnexplicit)
							}
							else {
								type.setRestType(AnyType.Unexplicit)
							}
						}


					}
					else {
						type = type.unspecify()
					}

					return type.flagComplete()
				}
				AstKind.TypeList {
					var mut type = NamespaceType.new(scope)

					for var property in data.types {
						type.addProperty(property.name.name, Type.fromAST(property, scope, defined, generics, node))
					}

					return type.flagComplete()
				}
				AstKind.TypeReference {
					var mut nullable = false

					for var modifier in data.modifiers {
						match ModifierKind(modifier.kind) {
							ModifierKind.Nullable {
								nullable = true
							}
						}
					}

					if AstKind(data.typeName.kind) == AstKind.Identifier {
						var name = Type.renameNative(data.typeName.name)

						if name == 'Any' {
							return if nullable set AnyType.NullableExplicit else AnyType.Explicit
						}
						else if ?#data.typeParameters {
							match name {
								'Array' {
									var type = ArrayType.new(scope).setNullable(nullable)

									var parameter = data.typeParameters[0]

									type.setRestType(Type.fromAST(parameter, scope, defined, generics, node))

									return type.flagComplete()
								}
								'Object' {
									var type = ObjectType.new(scope).setNullable(nullable)

									with var parameter = data.typeParameters[0] {
										type.setRestType(Type.fromAST(parameter, scope, defined, generics, node))
									}

									if var parameter ?= data.typeParameters[1] {
										type.setKeyType(Type.fromAST(parameter, scope, defined, generics, node))
									}

									return type.flagComplete()
								}
								else {
									unless scope.hasVariable(name, -1) {
										ReferenceException.throwNotDefinedType(name, node)
									}

									var parameters = [Type.fromAST(parameter, scope, defined, generics, node) for var parameter in data.typeParameters]

									var type = ReferenceType.new(scope, name, nullable, parameters)
									var root = type.discard()

									if root.isVariant() {
										var master = root.getVariantType().getMaster()

										if ?#data.typeSubtypes {
											for var subtype in data.typeSubtypes {
												type.addSubtype(subtype.name, master, node)
											}
										}
									}
									else if ?#data.typeSubtypes {
										NotImplementedException.throw()
									}

									return type.flagComplete()
								}
							}
						}
						else if ?#data.typeSubtypes {
							if var variable ?= scope.getVariable(name, -1) {
								var root = variable.getRealType().discard()

								if !?root {
									ReferenceException.throwNotYetDefinedType(name, node)
								}

								if root.isEnum() {
									var type = EnumViewType.new(scope)
										..master(ReferenceType.new(scope, name))

									if data.typeSubtypes is Array {
										if $ast.hasModifier(data.typeSubtypes[0], .Exclusion) {
											type.flagExclusion()
										}

										for var subtype in data.typeSubtypes {
											type.addElement(subtype.name)
										}
									}

									type.flagComplete()

									if nullable {
										return UnionType.new(scope, [type, Type.Null])
									}
									else {
										return type
									}
								}
								else if root.isVariant() {
									var type = ReferenceType.new(scope, name, nullable)
									var variant = root.getVariantType()
									var master = variant.getMaster()

									if $ast.hasModifier(data.typeSubtypes[0], .Exclusion) {
										var enum = variant.getEnumType()

										unless enum.isComplete() {
											ReferenceException.throwNotYetDefinedType(name, node)
										}

										var elements = []

										for var value in enum.values() {
											elements.push(value.name())
										}

										for var subtype in data.typeSubtypes {
											elements.remove(enum.getTopProperty(subtype.name))
										}

										for var element in elements {
											type.addSubtype(element, master, node)
										}
									}
									else {
										for var subtype in data.typeSubtypes {
											type.addSubtype(subtype.name, master, node)
										}
									}

									return type.flagComplete()
								}
								else {
									TypeException.throwNotVariant(name, node)
								}
							}
							else {
								ReferenceException.throwNotDefinedType(name, node)
							}
						}

						if ?#generics {
							for var generic in generics when generic.name == data.typeName.name {
								return DeferredType.new(generic, scope).setNullable(nullable)
							}
						}

						if !defined || Type.isNative(name) || scope.hasVariable(name, -1) {
							if var variable ?= scope.getVariable(name, -1) {
								var type = variable.getDeclaredType()

								if type.isReference() || type.isAny() {
									TypeException.throwNotType(name, node)
								}
							}

							return scope.reference(name, nullable)
						}
						else if scope.isMacro() {
							return Type.Unknown
						}
						else {
							ReferenceException.throwNotDefinedType(data.typeName.name, node)
						}
					}
					else if AstKind(data.typeName.kind) == AstKind.MemberExpression && !data.typeName.computed {
						var type = Type.fromAST(data.typeName.object, scope, defined, generics, node)
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
				AstKind.UnaryTypeExpression {
					match UnaryTypeOperatorKind(data.operator.kind) {
						UnaryTypeOperatorKind.Constant {
							return Type.fromAST(data.argument, scope, defined, generics, node).flagConstant()
						}
						UnaryTypeOperatorKind.TypeOf {
							if AstKind(data.argument.kind) == AstKind.Identifier && data.argument.name == 'this' {
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
				AstKind.UnionType {
					return Type.union(scope, ...[Type.fromAST(type, scope, defined, generics, node) for var type in data.types])
				}
				AstKind.VariableDeclarator, AstKind.FieldDeclaration {
					return Type.fromAST(data.type, scope, defined, generics, node)
				}
				AstKind.VariantType {
					var type = VariantType.new(scope)
						..setMaster(Type.fromAST(data.master, scope, defined, generics, node))

					return type
				}
			}

			console.info(data)
			throw NotImplementedException.new(node)
		} # }}}
		fromAST(data, type: Type, node: AbstractNode): Type { # {{{
			if data.kind == AstKind.TypeReference && data.typeName.kind == AstKind.UnaryExpression && data.typeName.operator.kind == UnaryOperatorKind.Implicit {
				var { name } = data.typeName.argument

				if type.isAny() {
					ReferenceException.throwUnresolvedImplicitProperty(name, node)
				}

				if type.isBitmask() {
					unless type.discard().hasValue(name) {
						ReferenceException.throwNotDefinedBitmaskElement(name, type.name(), node)
					}

					return type.setNullable(false)
				}


				if type.isEnum() {
					unless type.discard().hasValue(name) {
						ReferenceException.throwNotDefinedEnumElement(name, type.name(), node)
					}

					return type.setNullable(false)
				}

				if type.isVariant() {
					var variant = type.discard().getVariantType()

					if variant.hasSubtype(name) {
						return ReferenceType.new(node.scope(), type.name(), null, null, [{ name, type: variant.getMaster() }])
					}
				}

				if var property ?= type.getProperty(name) {
					return property.discardVariable()
				}

				ReferenceException.throwUnresolvedImplicitProperty(name, node)
			}
			else {
				return Type.fromAST(data, node)
			}
		} # }}}
		getParameterCount(types: Type[], names: String[] = []): Number { # {{{
			for var mut type in types {
				type = type.discardAlias()

				if type is UnionType {
					Type.getParameterCount(type.types(), names)
				}
				else {
					names.pushUniq(type.hashCode())
				}
			}

			return names.length
		} # }}}
		getASTNode(data, scope: Scope, node: AbstractNode): Type { # {{{
			match data {
				is Ast {
					var type = scope.reference('Ast').clone()
						..addSubtype(data.kind.name, scope.reference('AstKind'), node)

					return type
				}
			}

			NotImplementedException.throw()
		} # }}}
		import(index, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): Type { # {{{
			var data = if index is Number set metadata[index] else index

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
							return if nullable set AnyType.NullableExplicit else AnyType.Explicit
						}
						else {
							return if nullable set AnyType.NullableUnexplicit else AnyType.Unexplicit
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
						var type = Type.import(data[0], metadata, references, alterations, queue, scope, node)
						var named = Type.toNamedType(type, false, scope, node)

						references[data[0]] = named

						return scope.reference(named)
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
					var type = Type.import(data.reference, metadata, references, alterations, queue, scope, node)
					var named = Type.toNamedType(type, false, scope, node)

					references[data.reference] = named

					return scope.reference(named)
				}
			}
			else if ?data.kind {
				match TypeKind(data.kind) {
					TypeKind.Alias {
						return AliasType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Array {
						return ArrayType.import(index, data, metadata, references, alterations, queue, scope, node)
					}
					TypeKind.Bitmask {
						return BitmaskType.import(index, data, metadata, references, alterations, queue, scope, node)
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
					TypeKind.EnumView {
						return EnumViewType.import(index, data, metadata, references, alterations, queue, scope, node)
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
				var [major, minor] = if requirement set [first, second] else [second, first]
				var origin = if requirement set TypeOrigin.RequireOrExtern else TypeOrigin.ExternOrRequire

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
		renameNative(name: String) => if $types[name] is String set $types[name] else name
		setTrueSubtype(mut type: ReferenceType, scope: Scope, node): Type { # {{{
			if type.isNullable() {
				type = type.setNullable(false)
			}
			else {
				type = type.clone()
			}

			type.setSubtypes([{ name: 'true', type: scope.reference('Boolean') }])

			return type
		} # }}}
		setTrueSubtype(type % union: UnionType, scope: Scope, node): Type { # {{{
			var root = union.discard()
			var variant = root.getVariantType()
			var name = root.getVariantName()
			var types = []

			for var mut type in union.types() {
				if var subtypes ?#= type.getSubtypes() {
					if var filtereds ?#= [subtype for var subtype in subtypes when variant.getMainName(subtype.name) != 'false'] {
						if type.isNullable() {
							type = type.setNullable(false)
						}
						else {
							type = type.clone()
						}

						type.setSubtypes(filtereds)

						types.push(type)
					}
				}
				else {
					if type.isNullable() {
						type = type.setNullable(false)
					}
					else {
						type = type.clone()
					}

					type.addSubtype('true', scope.reference('Boolean'), node)

					types.push(type)
				}
			}

			return Type.union(scope, ...types)
		} # }}}
		// TODO!
		// sort<T>(values: T[], resolve: (value: T): Type?): T[] { # {{{
		sort(values: Array, resolve: Function): Array { # {{{
			var items = []

			for var value in values {
				var type = resolve(value) ?? AnyType.NullableUnexplicit

				items.push({
					value
					type
					children: []
					isAny: type.isAny() || type.isNull()
				})
			}

			for var node in items {
				if node.isAny {
					for var item in items when item != node {
						if !item.isAny {
							node.children.push(item)
						}
					}
				}
				else {
					for var item in items when item != node {
						if !item.isAny && item.type.isAssignableToVariable(node.type, true, true, false) {
							node.children.push(item)
						}
					}
				}
			}

			var equivalences = []

			items.sort((a, b) => {
				if a.children:!!!(Array).contains(b) {
					return 1
				}
				if b.children:!!!(Array).contains(a) {
					return -1
				}

				return a.type.compareToRef(b.type)
			})

			return [value for var { value } in items]
		} # }}}
		toGeneric({ name, constraint? }, node: AbstractNode): Generic { # {{{
			if ?constraint {
				return { name: name.name, type: Type.fromAST(constraint, node) }
			}
			else {
				return { name: name.name }
			}
		} # }}}
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

			var namedType = if type is NamespaceType set NamedContainerType.new(scope.acquireTempName(declare), type) else NamedType.new(scope.acquireTempName(declare), type)

			scope.define(namedType.name(), true, namedType, node)

			return namedType
		} # }}}
		union(scope: Scope, ...types: Type?) { # {{{
			if #types == 1 || (#types == 2 && types[0] == types[1]) {
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
	applyGenerics(generics: AltType[]): Type => this
	asReference(): Type => this
	buildGenericMap(position: CallMatchPosition, expressions: Expression[], decompose: (value: Type): Type, genericMap: Type[]{}): Void
	canBeArray(any: Boolean = true): Boolean => (any && @isAny()) || @isArray()
	canBeBitmask(any: Boolean = true): Boolean => (any && @isAny()) || @isBitmask()
	canBeBoolean(): Boolean => @isAny() || @isBoolean()
	canBeDeferred(): Boolean => false
	canBeEnum(any: Boolean = true): Boolean => (any && @isAny()) || @isEnum()
	canBeFunction(any: Boolean = true): Boolean => (any && @isAny()) || @isFunction()
	canBeNullable(): Boolean => true
	canBeNumber(any: Boolean = true): Boolean => (any && @isAny()) || @isNumber()
	canBeObject(any: Boolean = true): Boolean => (any && @isAny()) || @isObject()
	canBeRawCasted(): Boolean => false
	canBeString(any: Boolean = true): Boolean => (any && @isAny()) || @isString()
	canBeVirtual(name: String) { # {{{
		if @isAny() {
			return true
		}

		match name {
			'Bitmask'	=> return @isBitmask()
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
	discardDeferred(): Type => this
	discardName(): Type => this
	discardReference(): Type? => this
	discardSpread(): Type => this
	discardValue(): Type => this
	discardVariable(): Type => this
	// TODO to remove
	equals(value?): Boolean => ?value && @isSubsetOf(value, MatchingMode.Exact)
	extractFunction(): FunctionType? => null
	finalize(data, generics: Generic[], node: AbstractNode): Void
	flagAlien() { # {{{
		@alien = true

		return this
	} # }}}
	flagAltering(): valueof this
	flagAuxiliary() { # {{{
		@auxiliary = true
	} # }}}
	flagComplete() { # {{{
		@complete = true

		return this
	} # }}}
	// TODO
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
	flagExhaustive() { # {{{
		@exhaustive = true
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		@exported = true

		return this
	} # }}}
	flagIndirectlyReferenced() => @flagReferenced()
	flagPredefined() { # {{{
		@predefined = true
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
	flagSpecter() { # {{{
		@specter = true
	} # }}}
	flagSystem() { # {{{
		@system = true

		return @flagSealed()
	} # }}}
	generics(): Generic[] => []
	getExhaustive() => @exhaustive
	getGenericMapper(): { type: Type, generics: AltType[]?, subtypes: AltType[]? } => { type: this, generics: null, subtypes: null }
	getPrettyName(name: String): String => name
	getProperty(index: Number) => null
	getProperty(name: String) => null
	getProperty(name: String, node?) => @getProperty(name)
	getMajorReferenceIndex() => @referenceIndex
	getStandardLibrary(): LibSTDMode => @standardLibrary
	// TODO merge
	hashCode(): String => ''
	hashCode(fattenNull: Boolean) => @hashCode()
	hasAuxiliary() => @auxiliary
	hasInvalidProperty(name: String): Boolean => false
	hasKeyType() => false
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
	isAssertingWhenCasting(): Boolean => true
	isAssignableToVariable(value: Type, downcast: Boolean = false): Boolean => @isAssignableToVariable(value, true, false, downcast)
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
	isBitmask() => false
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
	isDeferrable() => false
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
	isExhaustive(node) => @isExhaustive() && !node.isMisfit()
	isExplicit() => true
	isExplicitlyExported() => @exported
	isExportable() => @isAlien() || @isExported() || @isNative() || @isRequirement() || @referenceIndex != -1
	isExportable(mode: ExportMode) => mode ~~ ExportMode.Requirement || @isExportable()
	isExportable(mode: ExportMode, module: Module) => mode ~~ ExportMode.Requirement || @isExportable(module)
	isExportable(module: Module) => @isExportable() && (module.isStandardLibrary() || @standardLibrary ~~ .No | .Opened)
	isExportingFragment() => ((!@isVirtual() && !@isSystem()) || (@isSealed() && @isExtendable())) && @standardLibrary ~~ .No | .Opened
	isExportingType() => false
	isExported() => @exported
	isExtendable() => false
	isFinite() => false
	isFlexible() => false
	isFunction() => false
	isFusion() => false
	isHybrid() => false
	isImmutable() => false
	isInoperative() => @isNever() || @isVoid()
	isInstance() => false
	isInstanceOf(value: Type, generics: AltType[]?, subtypes: AltType[]?): Boolean => false
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
	isPredefined() => @predefined
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
	isSpecific() => false
	isSpecter() => @specter
	isSplittable() => @isNullable() || @isUnion()
	isSpread() => false
	isStandardLibrary(mode: LibSTDMode): Boolean => @standardLibrary ~~ mode
	isStrict() => false
	isString() => false
	isStruct() => false
	isSubsetOf(value: Type, generics: AltType[]? = null, subtypes: AltType[]? = null, mode: MatchingMode): Boolean => false
	// TODO
	// assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
	// 	if ?#generics {
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
	isUsingAuxiliary() => @isSealed() && @isExtendable()
	isValue() => false
	isValueOf() => false
	isVariant() => false
	isView() => false
	isVirtual() => false
	isVoid() => false
	limitTo(value: Type): Type { # {{{
		var mut current = this

		if @isNullable() && !value.isNullable() {
			current = @setNullable(false)
		}

		if value.isMorePreciseThan(current) {
			return value
		}
		else {
			return current
		}
	} # }}}
	makeCallee(name: String, generics: AltType[] = [], node: CallExpression): VoidThunk? { # {{{
		NotSupportedException.throw(node)
	} # }}}
	makeMemberCallee(property: String, name: NamedType, generics: AltType[] = [], node: CallExpression): VoidThunk? { # {{{
		NotSupportedException.throw(node)
	} # }}}
	makeMemberCallee(property: String, path: String?, generics: AltType[] = [], node: CallExpression): VoidThunk? { # {{{
		NotSupportedException.throw(node)
	} # }}}
	makeMemberCallee(property: String, path: String?, reference: ReferenceType, generics: AltType[] = [], node: CallExpression): VoidThunk? { # {{{
		NotSupportedException.throw(node)
	} # }}}
	// TODO to remove
	matchContentOf(value: Type?): Boolean => @equals(value)
	merge(value: Type): Void { # {{{
		NotImplementedException.throw()
	} # }}}
	merge(value: Type, generics: AltType[]?, subtypes: AltType[]?, ignoreUndefined: Boolean, node): Type { # {{{
		return if @isMorePreciseThan(value) set this else value
	} # }}}
	minorOriginal() => null
	origin(): valueof @origin
	origin(@origin): valueof this
	parameter() => AnyType.NullableUnexplicit
	reference(scope? = @scope) => scope.reference(this)
	referenceIndex() => @referenceIndex
	resetReferences() { # {{{
		@referenceIndex = -1
	} # }}}
	scope() => @scope
	setExhaustive(@exhaustive) => this
	// TODO
	// setNullable(nullable: Boolean): typeof this => this
	setNullable(nullable: Boolean) => this
	// TODO
	// setNullable(type: Type): typeof this { # {{{
	setNullable(type: Type): Type { # {{{
		if !type.isNullable() {
			return @setNullable(false)
		}
		else {
			return this
		}
	} # }}}
	setProperty(name: String, type: Type)
	setStandardLibrary(@standardLibrary)
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
	toAssertFragments(value: Expression, fragments, node) { # {{{
		@setNullable(false).toAssertFunctionFragments(value, @isNullable(), fragments, node)
	} # }}}
	toAssertFunctionFragments(value: Expression, nullable: Boolean, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).assert(`).compile(value).code(`, \($quote(@toQuote(true))), \(if nullable set '1' else '0'), `)

		@toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)

		fragments.code(')')
	} # }}}
	toAssertFunctionFragments(name: String, quote: String, value: Expression, nullable: Boolean, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).assert(`).compile(value).code(`, \($quote(quote)), \(if nullable set '1' else '0'), \(name))`)
	} # }}}
	toAwareTestFunctionFragments(varname: String, nullable: Boolean, hasDeferred: Boolean, casting: Boolean, blind: Boolean, generics: AltType[]?, subtypes: AltType[]?, fragments, node) { # {{{
		fragments
			.code('(') if hasDeferred
			.code(`\(varname) => `)

		@toBlindTestFragments(null, varname, casting, null, null, Junction.NONE, fragments, node)

		fragments.code(')') if hasDeferred
	} # }}}
	toBlindSubtestFunctionFragments(funcname: String?, varname: String, casting: Boolean, propname: String?, nullable: Boolean, generics: Generic[]?, fragments, node) { # {{{
		@toAwareTestFunctionFragments(varname, nullable, false, casting, true, null, null, fragments, node)
	} # }}}
	toBlindTestFragments(funcname: String?, varname: String, casting: Boolean, generics: Generic[]?, subtypes: AltType[]?, junction: Junction, fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	toBlindTestFunctionFragments(funcname: String?, varname: String, casting: Boolean, testingType: Boolean, generics: Generic[]?, fragments, node) { # {{{
		@toBlindSubtestFunctionFragments(funcname, varname, casting, null, false, generics, fragments, node)
	} # }}}
	toCastFunctionFragments(value: Expression, nullable: Boolean, fragments, node) { # {{{
		@toAssertFunctionFragments(value, nullable, fragments, node)
	} # }}}
	toCastFunctionFragments(name: String, quote: String, value: Expression, nullable: Boolean, fragments, node) { # {{{
		fragments.code(`\($runtime.helper(node)).cast(`).compile(value).code(`, \($quote(quote)), \(if nullable set '1' else '0'), \(name))`)
	} # }}}
	toExportFragment(fragments, name, variable, module: Module) { # {{{
		if !@isVirtual() && !@isSystem() {
			var varname = variable.getSecureName?()

			if name == varname {
				fragments.line(name)
			}
			else {
				fragments.newLine().code(`\(name): `).compile(variable).done()
			}
		}

		var libstd = @getStandardLibrary()

		if @isUsingAuxiliary() && libstd ~~ .No | .Opened {
			if @hasAuxiliary() && libstd ~~ .No | .Augmented {
				var varname = @getAuxiliaryName()

				if `__ks_\(name)` == varname {
					fragments.line(varname)
				}
				else {
					fragments.line(`__ks_\(name): \(varname)`)
				}
			}
			else {
				fragments.line(`__ks_\(name): {}`)
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
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		return {
			reference: @toMetadata(references, indexDelta, mode, module)
		}
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
	trimOff(type: Type): Type => this
	tryCastingTo(value: Type): Type { # {{{
		var mut current = this

		if @isNullable() && !value.isNullable() {
			current = @setNullable(false)
		}

		if value.isMorePreciseThan(current) {
			return value
		}
		else {
			return current
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

enum Accessibility {
	Internal = 1
	Private
	Protected
	Public

	static isLessAccessibleThan(source: Accessibility, target: Accessibility): Boolean { # {{{
		return match source {
			.Public => false
			.Protected => target == .Public
			.Private => target == .Protected | .Public
			.Internal => target == .Private | .Protected | .Public
		}
	} # }}}
}

include {
	'./type/function.ks'
	'./type/named.ks'
	'./type/reference.ks'
	'./type/sealable.ks'
	'./type/alias.ks'
	'./type/any.ks'
	'./type/array.ks'
	'./type/bitmask.ks'
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
	'./type/virtual.ks'
	'./type/void.ks'
	'./type/enum-view.ks'
}

Type.Any = AnyType.Unexplicit
Type.Never = NeverType.new()
Type.Null = NullType.Unexplicit
Type.Undecided = AnyType.new(false, true)
Type.Unknown = AnyType.new(false, true)
Type.Void = VoidType.new()
