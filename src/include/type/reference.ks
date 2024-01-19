var $weightTOFs = { # {{{
	Array: 1
	Boolean: 2
	Class: 11
	Enum: 4
	Function: 3
	Namespace: 8
	Number: 5
	Object: 12
	Primitive: 7
	RegExp: 9
	String: 6
	Struct: 10
	Tuple: 10
} # }}}

class ReferenceType extends Type {
	private late {
		@type: Type
		@variable: Variable
	}
	private {
		@alias: String?
		@assessment							= null
		@explicitlyNull: Boolean
		@name: String
		@native: Boolean
		@nullable: Boolean
		@parameters: Type[]
		@predefined: Boolean				= false
		@spread: Boolean					= false
		@strict: Boolean					= false
		@subtypes: AltType[]
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ReferenceType { # {{{
			var name =
				if data.name is Number {
					var reference = Type.import({ reference: data.name }, metadata, references, alterations, queue, scope, node)

					set reference.name()
				}
				else {
					set data.name
				}

			var type = ReferenceType.new(scope, name:!(String), data.nullable!?)

			if ?data.parameters || ?data.subtypes {
				queue.push(() => {
					if ?data.parameters {
						for var data of data.parameters {
							type.addParameter(Type.import(data, metadata, references, alterations, queue, scope, node))
						}
					}

					if ?data.subtypes {
						var subtypes = []

						for var { name, type % subtype } of data.subtypes {
							subtypes.push({
								name
								subtype: Type.import(subtype, metadata, references, alterations, queue, scope, node)
							})
						}

						queue.push(() => {
							for var { name, subtype } in subtypes {
								type.addSubtype(name, subtype, node)
							}

							type.flagComplete()
						})
					}
					else {
						type.flagComplete()
					}
				})
			}
			else {
				type.flagComplete()
			}

			return type
		} # }}}
		toQuote(name: String, nullable: Boolean, parameters: Type[], subtypes: AltType[]): String { # {{{
			if name == 'this' {
				return 'typeof this'
			}

			var fragments = [name]

			if ?#parameters {
				fragments.push('<')

				for var parameter, index in parameters {
					if index != 0 {
						fragments.push(', ')
					}

					fragments.push(parameter.toQuote())
				}

				fragments.push('>')
			}

			if ?#subtypes {
				fragments.push('(')

				for var { name }, index in subtypes {
					if index != 0 {
						fragments.push(', ')
					}

					fragments.push(name)
				}

				fragments.push(')')
			}

			if nullable {
				fragments.push('?')
			}

			return fragments.join('')
		} # }}}
	}
	constructor(@scope, name: String, @explicitlyNull = false, @parameters = [], @subtypes = []) { # {{{
		super(scope)

		@name = $types[name] ?? name
		@native = $natives[@name]
		@nullable = @explicitlyNull
	} # }}}
	addParameter(parameter: Type) { # {{{
		@parameters.push(parameter)
	} # }}}
	addSubtype(name: String, type: Type, node) { # {{{
		@resolve()

		var variant = @type.discard().getVariantType()

		if var mainName ?= variant.getMainName(name) {
			for var { name } in @subtypes {
				return if name == mainName
			}

			@subtypes.push({ name: mainName, type })
		}
		else if !variant.isComplete() {
			for var subtype in @subtypes {
				return if name == subtype.name
			}

			@subtypes.push({ name, type })
		}
		else {
			ReferenceException.throwUndefinedVariantField(@name, name, node)
		}
	} # }}}
	override applyGenerics(generics) { # {{{
		var result = @clone()

		for var parameter, index in result._parameters {
			if parameter is DeferredType {
				var deferName = parameter.name()

				for var { name, type } in generics {
					if name == deferName {
						result._parameters[index] = type
						break
					}
				}
			}
			else if parameter.isDeferrable() {
				result._parameters[index] = parameter.applyGenerics(generics)
			}
		}

		return result
	} # }}}
	canBeArray(any = true) => @isUnion() ? @type.canBeArray(any) : super(any)
	canBeBoolean() => @isUnion() ? @type.canBeBoolean() : super()
	canBeFunction(any = true) => @isUnion() ? @type.canBeFunction(any) : super(any)
	canBeNumber(any = true) => @isUnion() ? @type.canBeNumber(any) : super(any)
	canBeObject(any = true) { # {{{
		if @isUnion() {
			return @type.canBeObject(any)
		}
		else if any && @isAny() {
			return true
		}
		else {
			return @name == 'Object' || @type().isObject() || @type().isStruct() || (@type().isClass() && !@isPrimitive() && !@isArray() && !@isBitmask() && !@isEnum())
		}
	} # }}}
	override canBeRawCasted() { # {{{
		return true if @type().canBeRawCasted()

		for var parameter in @parameters {
			return true if parameter.canBeRawCasted()
		}

		return false
	} # }}}
	canBeString(any = true) => @isString() || @type.canBeString(any)
	clone(): ReferenceType { # {{{
		var type = ReferenceType.new(@scope, @name, @nullable, [...@parameters], [...@subtypes])

		type._sealed = @sealed
		type._spread = @spread
		type._strict = @strict

		return type
	} # }}}
	compareTo(value: Type) { # {{{
		if this == value {
			return 0
		}
		else if @matchContentOf(value) {
			return -1
		}
		else if value.matchContentOf(this) {
			return 1
		}
		else if @isTypeOf() {
			if value.isTypeOf() {
				return $weightTOFs[@name] - $weightTOFs[value.name()]
			}
			else if value.discardReference().isClass() {
				return -1
			}
			else {
				return 1
			}
		}
		else if @type().isClass() {
			if value.isTypeOf() {
				return 1
			}
			else if value.discardReference().isClass() {
				return Helper.compareString(@type.name(), value.discardReference().name())
			}
			else {
				return 1
			}
		}
		else {
			return -1
		}
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) { # {{{
		if @isAny() {
			if @nullable == value.isNullable() {
				return 0
			}
			else if @nullable {
				return 1
			}
			else {
				return -1
			}
		}
		else {
			return -1
		}
	} # }}}
	compareToRef(value: ArrayType, equivalences: String[][]? = null) { # {{{
		if @name == 'Array' {
			if @parameters.length == 0 {
				if value.hasRest() {
					return -1
				}
				else {
					return 0
				}
			}
			else {
				if value.hasRest() {
					return @parameters[0].compareTo(value.getRestType())
				}
				else {
					return 1
				}
			}
		}


		if value.hasRest() {
			return @compareToRef(@scope.resolveReference('Array', false, [value.getRestType()]), equivalences)
		}
		else {
			return @compareToRef(@scope.reference('Array'), equivalences)
		}
	} # }}}
	compareToRef(value: NullType, equivalences: String[][]? = null) { # {{{
		if @isNull() {
			return 0
		}
		else {
			return -1
		}
	} # }}}
	compareToRef(value: ObjectType, equivalences: String[][]? = null) { # {{{
		if @isObject() {
			if @parameters.length == 0 {
				if value.hasRest() {
					return -1
				}
				else {
					return 0
				}
			}
			else {
				if value.hasRest() {
					return @parameters[0].compareTo(value.getRestType())
				}
				else {
					return 1
				}
			}
		}


		if value.hasRest() {
			return @compareToRef(@scope.resolveReference('Object', false, [value.getRestType()]), equivalences)
		}
		else {
			return @compareToRef(@scope.reference('Object'), equivalences)
		}
	} # }}}
	compareToRef(value: ReferenceType, equivalences: String[][]? = null) { # {{{
		if @name == value.name() {
			if @isNullable() != value.isNullable() {
				return @nullable ? 1 : -1
			}

			if @parameters.length == 0 {
				if value.hasParameters() {
					return -1
				}
				else {
					return 0
				}
			}

			return @parameters[0].compareTo(value.parameter(0))
		}

		if @isTypeOf() {
			if value.type().isBitmask() || value.type().isEnum() {
				return $weightTOFs[@name] - $weightTOFs.Enum
			}

			if @isNullable() != value.isNullable() {
				return @nullable ? 1 : -1
			}

			if value.isTypeOf() {
				if @hasParameters() {
					if value.hasParameters() {
						return $weightTOFs[@name] - $weightTOFs[value.name()]
					}
					else {
						return 1
					}
				}
				else if value.hasParameters() {
					return -1
				}
				else {
					return $weightTOFs[@name] - $weightTOFs[value.name()]
				}
			}

			if @hasParameters() {
				if value.hasParameters() {
					return -1
				}
				else {
					return 1
				}
			}

			return @isObject() ? 1 : -1
		}

		if value.isTypeOf() {
			if @type().isBitmask() || @type().isEnum() {
				return $weightTOFs.Enum - $weightTOFs[value.name()]
			}

			if @isNullable() != value.isNullable() {
				return @nullable ? 1 : -1
			}

			if value.hasParameters() {
				if @hasParameters() {
					return 1
				}
				else {
					return -1
				}
			}

			return 1
		}

		var valType = value.type()

		if (@type().isClass() && valType.isClass()) || (@type.isStruct() && valType.isStruct()) || (@type.isTuple() && valType.isTuple()) {
			if @type.isInheriting(valType) {
				return -1
			}
			else if valType.isInheriting(@type) {
				return 1
			}
			else if @isNullable() != value.isNullable() {
				return @nullable ? 1 : -1
			}
		}

		if ?equivalences {
			if equivalences.length == 0 {
				equivalences.push([@hashCode(), value.hashCode()])
			}
			else {
				var tHash = @hashCode()
				var vHash = value.hashCode()

				var mut nf = true

				for var eq in equivalences while nf {
					if eq.contains(tHash) {
						eq.pushUniq(vHash)

						nf = false
					}
					else if eq.contains(vHash) {
						eq.pushUniq(tHash)

						nf = false
					}
				}

				if nf {
					equivalences.push([tHash, vHash])
				}
			}
		}

		return Helper.compareString(@type.name(), valType.name())
	} # }}}
	compareToRef(value: UnionType, equivalences: String[][]? = null) { # {{{
		return -value.compareToRef(this, equivalences)
	} # }}}
	discard() => @discardReference()?.discard()
	discardAlias() { # {{{
		var dyn variable

		if @name == 'Any' {
			return Type.Any
		}
		else if @name == 'this' {
			return @type()
		}
		else if var variable ?= @scope.getVariable(@name) ;; variable.getRealType() is not ReferenceType || variable.name() != @name {
			return variable.getRealType().discardAlias()
		}
		else {
			return @type().discardAlias()
		}
	} # }}}
	discardReference(): Type? { # {{{
		var dyn variable, type

		if @name == 'Any' {
			return @nullable ? AnyType.NullableExplicit : AnyType.Explicit
		}
		else if @name == 'this' {
			return @type()
		}
		else if {
			var variable ?= @scope.getVariable(@name, -1)
			var type ?= variable.getRealType() ;; variable.name() != @name || type is not ReferenceType || type.scope() != @scope
		}
		then {
			return type.discardReference()
		}
		else {
			return null
		}
	} # }}}
	discardSpread() { # {{{
		if @spread {
			if @parameters?.length > 0 {
				return @parameters[0]
			}
			else {
				return AnyType.NullableUnexplicit
			}
		}
		else {
			return this
		}
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if ?#@parameters || ?#@subtypes || (!@native && !@type.isExported()) {
			var export = {
				kind: TypeKind.Reference
				name: @type.isExported() ? @name : @type.toMetadata(references, indexDelta, mode, module)
			}

			if @explicitlyNull {
				export.nullable = @explicitlyNull
			}

			if ?#@parameters {
				export.parameters = [parameter.toGenericParameter(references, indexDelta, mode, module) for var parameter in @parameters]
			}

			if ?#@subtypes {
				export.subtypes = [{ name, type: type.toReference(references, indexDelta, mode, module) } for var { name, type } in @subtypes]
			}

			return export
		}
		else {
			return @nullable ? `\(@name)?` : @name
		}
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name) { # {{{
		if @nullable || ?#@parameters || ?#@subtypes {
			var export = {
				kind: TypeKind.Reference
				name: name.reference ?? name
			}

			if @explicitlyNull {
				export.nullable = @explicitlyNull
			}

			if ?#@parameters {
				export.parameters = [parameter.toReference(references, indexDelta, mode, module) for var parameter in @parameters]
			}

			if ?#@subtypes {
				export.subtypes = [{ name, type: type.toReference(references, indexDelta, mode, module) } for var { name, type } in @subtypes]
			}

			return export
		}
		else {
			return name
		}
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if !@isAny() && !@isVoid() {
			@type().flagExported(explicitly).flagReferenced()
		}

		return super.flagExported(explicitly)
	} # }}}
	override flagReferenced() { # {{{
		if @referenced || @native {
			return this
		}
		else if !?#@parameters && !?#@subtypes {
			@referenced = true
		}

		@type().flagReferenced()

		return this
	} # }}}
	flagSealed(): ReferenceType { # {{{
		return this if @sealed

		var type = @clone()

		type._sealed = true

		return type
	} # }}}
	flagSpread(): ReferenceType { # {{{
		return this if @spread

		var type = @clone()

		type._spread = true

		return type
	} # }}}
	flagStrict(): ReferenceType { # {{{
		return this if @strict

		var type = @clone()

		type._strict = true

		return type
	} # }}}
	override getGenericMapper() { # {{{
		@resolve()

		var mut generics = null

		if @type is NamedType {
			if var originals ?#= @type.type().generics() {
				if @parameters.length > originals.length {
					NotImplementedException.throw()
				}

				generics = []

				for var { name }, index in originals {
					if var type ?= @parameters[index] {
						generics.push({ name, type })
					}
					else {
						generics.push({ name, type : AnyType.NullableUnexplicit })
					}
				}
			}
		}

		var mut subtypes = null

		if ?#@subtypes {
			unless @type.isObject() && @type.isVariant() {
				NotImplementedException.throw()
			}

			subtypes = @subtypes
		}

		return { type: @discard()!?, generics, subtypes }
	} # }}}
	getMajorReferenceIndex() => @referenceIndex == -1 ? @type().getMajorReferenceIndex() : @referenceIndex
	override getProperty(index): Type { # {{{
		if @name == 'Array' {
			if @parameters.length > 0 {
				return @parameters[0]
			}

			return AnyType.NullableUnexplicit
		}

		@resolve()

		if @type.isArray() || @type.isTuple() {
			return @discard().getProperty(index)
		}
		else {
			return @getProperty(index.toString())
		}
	} # }}}
	override getProperty(name): Type => @getProperty(name, null)
	override getProperty(name, node): Type { # {{{
		if @isAny() {
			return AnyType.NullableUnexplicit
		}
		else if @name == 'Object' {
			if @parameters.length > 0 {
				return @parameters[0]
			}

			return Type.Undecided
		}

		var mut type: Type = @type()

		if type is NamedType {
			type = type.type()
		}

		if type.isClass() {
			return type.getInstantiableProperty(name)
		}
		else if type.isVariant() {
			if var property ?= type.getProperty(name) {
				return property
			}
			else if ?#@subtypes {
				var propname = name
				var variant = type.discard().getVariantType()

				if @subtypes.length == 1 {
					var { name } = @subtypes[0]

					if var { type % subtype } ?= variant.getField(name) {
						var property = subtype.getProperty(propname)

						if property is DeferredType {
							return AnyType.NullableUnexplicit if !?#@parameters

							var index = type.getGenericIndex(property.name())

							return @parameters[index] ?? AnyType.NullableUnexplicit
						}

						return property
					}
					else if variant.hasSubtype(name) {
						return null
					}
					else {
						ReferenceException.throwUndefinedVariantField(@name, name, node)
					}
				}
				else {
					return null
				}
			}
			else {
				var master = type.discard().getVariantType().getMaster()

				if master.hasProperty(name) {
					return ReferenceType.new(@scope, @name, null, null, [{ name: name, type: master }])
				}
				else {
					return AnyType.NullableUnexplicit
				}
			}
		}
		else {
			var property = type.getProperty(name)

			if property is DeferredType {
				return AnyType.NullableUnexplicit if !?#@parameters

				var index = type.getGenericIndex(property.name())

				return @parameters[index] ?? AnyType.NullableUnexplicit
			}

			return property
		}
	} # }}}
	getSealedPath() => @type().getSealedPath()
	getSubtypes(): AltType[] => @subtypes
	getSubtypesCount(): Number => @subtypes.length
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut hash = ''

		if @name == 'Array' && @parameters.length == 1 && !?#@subtypes {
			hash = `\(@parameters[0].hashCode())[]`
		}
		else if @name == 'Object' && @parameters.length == 1 && !?#@subtypes {
			hash = `\(@parameters[0].hashCode()){}`
		}
		else {
			hash = @name

			if ?#@parameters {
				hash += '<'

				for var parameter, i in @parameters {
					if i != 0 {
						hash += ','
					}

					hash += parameter.hashCode()
				}

				hash += '>'
			}

			if ?#@subtypes {
				hash += '('

				for var { name }, i in @subtypes {
					if i != 0 {
						hash += ','
					}

					hash += name
				}

				hash += ')'
			}
		}

		if @explicitlyNull {
			if fattenNull {
				hash += '|Null'
			}
			else {
				hash += '?'
			}
		}

		return hash
	} # }}}
	hasParameters() => ?#@parameters
	hasProperty(index: Number) { # {{{
		if @name == 'Array' {
			return false
		}

		@resolve()

		if @type.isArray() || @type.isTuple() {
			return @discard().hasProperty(index)
		}
		else {
			return @hasProperty(index.toString())
		}
	} # }}}
	hasProperty(name: String) { # {{{
		if @isAny() {
			return false
		}
		else if @name == 'Object' {
			return false
		}

		@resolve()

		return @type.hasProperty(name)
	} # }}}
	hasRest() => @name == 'Object' || @type().hasRest()
	override hasSameParameters(value) { # {{{
		if !?#@parameters {
			return !value.hasParameters()
		}
		else if !value.hasParameters() {
			return false
		}

		for var type in value.parameters() {
			if !@parameters.contains(type) {
				return false
			}
		}

		return true
	} # }}}
	hasSubtypes() => ?#@subtypes
	isAlias() => @type().isAlias()
	isAlien() => @type().isAlien()
	isAny() => @name == 'Any'
	isArray() => @name == 'Array' || @type().isArray()
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
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
		else if value is ReferenceType {
			if @name == value.name() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				if !downcast || (?#value.parameters() && ?#@parameters) {
					for var index from 0 to~ Math.max(@parameters.length, value.parameters().length) {
						if !@parameter(index).isAssignableToVariable(value.parameter(index), anycast, nullcast, downcast) {
							return false
						}
					}
				}

				if ?#@subtypes {
					if value.hasSubtypes() {
						var variant: VariantType = @discard().getVariantType()

						var names = variant.explodeVarnames(...value.getSubtypes())

						for var { name } in @subtypes {
							return false unless names.contains(name)
						}
					}
				}
				else {
					return !value.hasSubtypes()
				}

				return true
			}
			else if (value.name() == 'Bitmask' && @type().isBitmask()) || (@name == 'Bitmask' && value.type().isBitmask()) {
				return false
			}
			else if (value.name() == 'Class' && @type().isClass()) || (@name == 'Class' && value.type().isClass()) {
				return false
			}
			else if (value.name() == 'Enum' && @type().isEnum()) || (@name == 'Enum' && value.type().isEnum()) {
				return false
			}
			else if (value.name() == 'Namespace' && @type().isNamespace()) || (@name == 'Namespace' && value.type().isNamespace()) {
				return false
			}
			else if (value.name() == 'Struct' && @type().isStruct()) || (@name == 'Struct' && value.type().isStruct()) {
				return false
			}
			else if (value.name() == 'Tuple' && @type().isTuple()) || (@name == 'Tuple' && value.type().isTuple()) {
				return false
			}
			else if value.name() == 'Object' && @canBeObject() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				return true
			}
			else if value.name() == 'Array' && @canBeArray() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				return true
			}
			else if value.isAlias() {
				return @isAssignableToVariable(value.discardAlias(), anycast, nullcast, downcast)
			}
			else {
				return @type().isAssignableToVariable(value.type(), anycast, nullcast, downcast)
			}
		}
		else if value is UnionType {
			if @nullable {
				if !nullcast && !value.isNullable() {
					return false
				}

				return @setNullable(false).isAssignableToVariable(value, anycast, nullcast, downcast, limited)
			}
			else {
				for var type in value.types() {
					if @isAssignableToVariable(type, anycast, nullcast, downcast, limited) {
						return true
					}
				}

				return false
			}
		}
		else if value is DeferredType {
			return false unless !@nullable || nullcast || value.isNullable()

			if value.isConstrainted() {
				return @isAssignableToVariable(value.constraint(), anycast, true, downcast)
			}

			return true
		}
		else if value is FusionType {
			for var type in value.types() {
				if !@isAssignableToVariable(type, anycast, nullcast, downcast) {
					return false
				}
			}

			return true
		}
		else if value is ArrayType {
			return false unless @isBroadArray()
			return false unless !@nullable || nullcast || value.isNullable()

			if anycast && !@isAlias() && !@isFusion() && !@isInstance() && !@isUnion() {
				return true if @parameters.length == 0

				var parameter = @parameters[0]

				if parameter.isAny() && !parameter.isExplicit() {
					return true
				}
			}

			return @isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass)
		}
		else if value is ObjectType {
			return false unless @isBroadObject()
			return false unless !@nullable || nullcast || value.isNullable()

			var mode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass

			return @isSubsetOf(value, mode)
		}
		else {
			return @type().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
	} # }}}
	isAsync() => false
	isBitmask() => @name == 'Bitmask' || @type().isBitmask()
	isBoolean() => @name == 'Boolean' || @type().isBoolean()
	isBroadArray() => @name == 'Array' || @type().isArray() || @type().isTuple()
	isBroadObject() => @name == 'Object' || @type().isObject() || @type().isStruct() || (@type().isClass() && !@isPrimitive() && !@isArray() && !@isBitmask() && !@isEnum())
	isClass() => @name == 'Class'
	isClassInstance() => @name != 'Object' && @type().isClass()
	override isComparableWith(type) => @type().isComparableWith(type)
	override isComplete() => @type().isComplete()
	override isDeferrable() => ?#@parameters || @type().isDeferrable()
	isEnum() => @name == 'Enum' || @type().isEnum()
	isExhaustive() => @type().isExhaustive()
	isExplicit() => @type().isExplicit()
	isExplicitlyExported() => @type().isExplicitlyExported()
	isExplicitlyNull() => @explicitlyNull
	isExportable() => @type().isExportable()
	isExported() => @type().isExported()
	isExportingFragment() => true
	isExtendable() => @name == 'Function'
	isFunction() => @name == 'Function' || @type().isFunction()
	isFusion() => @type().isFusion()
	isHybrid() => @type().isHybrid()
	isInheriting(superclass) => @type().isInheriting(superclass)
	isInstance() => @type().isClass() || @type().isStruct() || @type().isTuple()
	isInstanceOf(value: AnyType) => false
	isInstanceOf(value: ReferenceType) { # {{{
		@resolve()

		return false unless @type.isClass()

		if @name == value.name() || value.isAny() {
			return true
		}

		if var type ?= value.discardAlias() {
			if type is UnionType {
				for var type in type.types() {
					if @isInstanceOf(type) {
						return true
					}
				}
			}
			else if type.isClass() {
				return @type.type().isInstanceOf(type.discardAlias().type())
			}
		}

		return false
	} # }}}
	isInstanceOf(value: UnionType) { # {{{
		for var type in value.types() {
			if @isInstanceOf(type) {
				return true
			}
		}

		return false
	} # }}}
	isInstantiable() => @name == 'Class' | 'Struct' | 'Tuple'
	isIterable() => @type().isIterable() || @isArray() || @isObject() || @isString()
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return !@isAny() || (value.isNullable() && !@nullable)
		}

		if @isAny() {
			return false
		}

		if value is ReferenceType {
			if value.name() == @name {
				if value.isNullable() && !@nullable {
					return true
				}

				if @hasParameters() {
					return true if !value.hasParameters()

					var parameters = value.parameters()

					return true if Type.getParameterCount(@parameters) < Type.getParameterCount(parameters)

					if #@parameters == #parameters == 1 {
						return true if @parameters[0].isMorePreciseThan(parameters[0])
					}
				}

				if @hasSubtypes() {
					return true if !value.hasSubtypes()

					var variant = @discard().getVariantType()

					if variant.canBeBoolean() {
						return @getSubtypesCount() < value.getSubtypesCount()
					}

					var enum = variant.getEnumType()

					return enum.getOriginalValueCount(...@subtypes) < enum.getOriginalValueCount(...value.getSubtypes())
				}

				return false
			}

			if @isView() {
				var master = @discard().master()

				return master.path() == value.path()
			}
		}

		if value.isUnion() {
			for var type in value.discard().types() {
				if @matchContentOf(type) || @isMorePreciseThan(type) {
					return true
				}
			}

			return false
		}

		if @name == 'Array' && value.isBroadArray() {
			return true
		}

		if @name == 'Object' && value.isBroadObject() {
			return true
		}

		var a: Type = @discardReference()!?
		var b: Type = value.discardReference()!?

		return a.isMorePreciseThan(b)
	} # }}}
	isNamespace() => @name == 'Namespace' || @type().isNamespace()
	isNative() => $natives[@name] == true
	isNever() => @name == 'Never' || @type().isNever()
	isNull() => @name == 'Null'
	isNullable() { # {{{
		@resolve()

		return @nullable
	} # }}}
	isNumber() => @name == 'Number' || @type().isNumber()
	isObject() => @name == 'Object' || @type().isObject()
	isPrimitive() => @isBoolean() || @isNumber() || @isString()
	isReference() => true
	isReducible() => true
	isSameVariance(value: ReferenceType) => @name == value.name() && @isVariant() && value.isVariant()
	isSpread() => @spread
	isStrict() => @strict
	isString() => @name == 'String' || @type().isString()
	isStruct() => @name == 'Struct' || @type().isStruct()
	override isSubsetOf(value: Type, generics, subtypes, mode) { # {{{
		if @isAlias() {
			return @discardAlias().isSubsetOf(value, mode)
		}

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			if value.isAny() && !value.isExplicit() && mode ~~ MatchingMode.Missing {
				return true
			}
			else {
				return false
			}
		}
		else {
			if value.isObject() && @type().isClass() {
				return @type.type().matchInstanceWith(value, [])
			}
			else {
				return value.isAny()
			}
		}
	} # }}}
	assist isSubsetOf(value: ArrayType, generics, subtypes, mode) { # {{{
		return false unless @isBroadArray()

		if @isNullable() && !value.isNullable() {
			return false
		}

		return @discard().isSubsetOf(value, mode) unless @isArray()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless !value.hasProperties()
			return false unless !value.hasRest()

			if ?#@parameters {
				var type = @parameters[0]

				for var property in value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				return @parameters[0].isSubsetOf(value.getRestType(), mode)
			}
			else {
				return value.getRestType().isAny() && value.getRestType().isNullable() == @nullable
			}
		}
		else {
			if ?#@parameters {
				var type = @parameters[0]

				for var property in value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				if value.hasRest() {
					return false unless type.isSubsetOf(value.getRestType(), mode)
				}
			}
		}

		if @isAlias() {
			var unalias = @discardAlias()

			return unalias.isSubsetOf(value, mode)
		}

		for var type in value.properties() {
			return false unless type.isNullable()
		}

		return true
	} # }}}
	assist isSubsetOf(value: DeferredType, generics, subtypes, mode) { # {{{
		if ?#generics {
			var valname = value.name()

			for var { name, type } in generics {
				if name == valname {
					if ?type {
						return @isSubsetOf(type, generics, subtypes, mode)
					}
					else {
						return true
					}
				}
			}
		}
		else if value.isConstrainted() {
			return @isSubsetOf(value.constraint(), generics, subtypes, mode)
		}

		return mode ~~ MatchingMode.IgnoreDeferred
	} # }}}
	assist isSubsetOf(value: FunctionType, generics, subtypes, mode) { # {{{
		if @isAlias() {
			return @discardAlias().isSubsetOf(value, mode)
		}

		return false unless @isFunction()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false if @name == 'Function'
		}
		else {
			return true if @name == 'Function'
		}

		return @discard().isSubsetOf(value, mode)
	} # }}}
	assist isSubsetOf(value: ObjectType, generics, subtypes, mode) { # {{{
		return false unless @isBroadObject()

		if @isNullable() && !value.isNullable() {
			return false
		}

		return @discard().isSubsetOf(value, mode) unless @isObject()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless !value.hasProperties()
			return false unless !value.hasRest()

			if ?#@parameters {
				var type = @parameters[0]

				for var property of value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				return type.isSubsetOf(value.getRestType(), mode)
			}
			else {
				return value.getRestType().isAny() && value.getRestType().isNullable() == @nullable
			}
		}
		else if !@isVariant() && ?#@parameters {
			var type = @parameters[0]

			for var property of value.properties() {
				return false unless type.isSubsetOf(property, mode)
			}

			if value.hasRest() {
				return false unless type.isSubsetOf(value.getRestType(), mode)
			}
		}

		if @isAlias() {
			var { type, generics, subtypes } = @getGenericMapper()

			return type.isSubsetOf(value, generics, subtypes, mode + MatchingMode.Reference)
		}

		for var type of value.properties() {
			return false unless type.isNullable()
		}

		return true
	} # }}}
	assist isSubsetOf(value: ReferenceType, generics, subtypes, mode) { # {{{
		if this == value {
			return true
		}
		else if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			if @name != value._name || @parameters.length != value._parameters.length || @subtypes.length != value._subtypes.length {
				return false
			}

			if mode ~~ MatchingMode.NonNullToNull {
				if @isNullable() && !value.isNullable() {
					return false
				}
			}
			else if @isNullable() != value.isNullable() {
				return false
			}

			var parameters = value.parameters()

			for var parameter, index in @parameters {
				if !parameter.isSubsetOf(parameters[index], mode) {
					return false
				}
			}

			var subtypes = value.getSubtypes()

			for var { name, type }, index in @subtypes {
				if name != subtypes[index].name || type != subtypes[index].type {
					return false
				}
			}

			return true
		}
		else {
			if @isNullable() && !value.isNullable() {
				return false
			}

			if value.scope().isRenamed(value.name(), @name, @scope, mode) {
				var parameters = value.parameters()

				if parameters.length == @parameters.length {
					for var parameter, index in @parameters {
						if !parameter.isSubsetOf(parameters[index], mode) {
							return false
						}
					}
				}
				else if parameters.length > @parameters.length {
					return false
				}

				if value.hasSubtypes() {
					var variant: VariantType = value.discard().getVariantType()

					var names = variant.explodeVarnames(...value.getSubtypes())

					if ?#@subtypes {
						for var { name } in @subtypes {
							return false unless names.contains(name)
						}
					}
					else {
						return false
					}
				}

				return true
			}
			else {
				if $virtuals[value.name()] {
					return @type().canBeVirtual(value.name())
				}

				if @isAlias() {
					return @discardAlias().isSubsetOf(value, null, @subtypes, mode)
				}

				return @scope.isMatchingType(@discardReference()!?, value.discardReference()!?, mode)
			}
		}
	} # }}}
	assist isSubsetOf(value: UnionType, generics, subtypes, mode) { # {{{
		return false if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass
		return false if @isNullable() && !value.isNullable()

		var nonNullType = @nullable ? @setNullable(false) : this

		for var type in value.types() {
			if nonNullType.isSubsetOf(type, mode) {
				return true
			}
		}

		return false
	} # }}}
	assist isSubsetOf(value: VariantType, generics, subtypes, mode) { # {{{
		return @isSubsetOf(value.getMaster(), mode)
	} # }}}
	isSubtypeOf(value: DeferredType) { # {{{
		if value.isConstrainted() {
			return @isSubtypeOf(value.constraint())
		}

		return false
	} # }}}
	isSubtypeOf(value: ReferenceType) => @name == value.name()
	isSubtypeOf(value: Type) => false
	isTuple() => @name == 'Tuple' || @type().isTuple()
	isTypeOf(): Boolean => $typeofs[@name]
	isUnion() => @type().isUnion()
	isVariant() => @type().isVariant()
	isView() => @type().isView()
	isVirtual() => @type().isVirtual()
	isVoid() => @name == 'Void' || @type().isVoid()
	listFunctions(name: String): Array => @type().listFunctions(name)
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array => @type().listFunctions(name, type, mode)
	listMissingProperties(class: ClassType | StructType | TupleType) => @type().listMissingProperties(class)
	override makeCallee(name, generics, node) { # {{{
		if @canBeFunction() {
			node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
		}
		else {
			if @isExhaustive(node) {
				TypeException.throwNotFunction(name, node)
			}
			else {
				node.addCallee(DefaultCallee.new(node.data(), node.object(), null, node))
			}
		}
	} # }}}
	override makeMemberCallee(property, generics, node) { # {{{
		if @isNullable() && !node.isMisfit() {
			unless node.data().callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind.Nullable) {
				TypeException.throwNotNullableCaller(property, node)
			}
		}

		if property == 'new' && @isInstantiable() {
			node.prepareArguments()

			node.addCallee(ConstructorCallee.new(node.data(), node.object(), this, null, null, node))
		}
		 else if ?#@parameters && !?#generics {
			var { type, generics } = @getGenericMapper()

			type.makeMemberCallee(property, this, generics, node)
		}
		else {
			@type().makeMemberCallee(property, this, generics, node)
		}
	} # }}}
	override makeMemberCallee(property, reference, generics, node) { # {{{
		@type().makeMemberCallee(property, this, generics, node)
	} # }}}
	matchContentOf(value: Type) { # {{{
		if this == value {
			return true
		}
		else if @nullable && !value.isNullable() {
			return false
		}
		else if value.isAny() {
			return true
		}
		else if this.isSubsetOf(value, MatchingMode.Exact) {
			return true
		}
		else if @isFunction() {
			return value.isFunction()
		}
		else {
			var a: Type = @discardReference()!?
			var b: Type = value.discardReference()!?

			if a is ReferenceType || b is ReferenceType || !a.matchContentOf(b) {
				return false
			}

			if value is ReferenceType && value.hasParameters() {
				if @parameters.length == 0 {
					return true
				}

				var parameters = value.parameters()

				if @parameters.length != parameters.length {
					return false
				}

				for var parameter, index in @parameters {
					if !parameter.matchContentOf(parameters[index]) {
						return false
					}
				}
			}

			return true
		}
	} # }}}
	matchDeferred(type: Type, generics: Type{}) { # {{{
		if ?#@parameters {
			return {
				type: this
				match: false
			}
		}

		return {
			type: this
			match: false
		}
	} # }}}
	mergeSubtypes(value: ReferenceType): ReferenceType { # {{{
		var nullable = @isNullable() || value.isNullable()

		return this.setNullable(nullable) unless ?#@subtypes
		return value.setNullable(nullable) unless value.hasSubtypes()

		var variant = @discard().getVariantType()
		var subtypes = []

		if variant.canBeBoolean() {
			var names = {}
			var mut count = 0

			for var subtype in @subtypes {
				names[variant.getMainName(subtype.name)] = subtype
				count += 1
			}

			for var subtype in value.getSubtypes() {
				var name = variant.getMainName(subtype.name)

				if !?names[name] {
					names[name] = subtype
					count += 1
				}
			}

			if count == 1 {
				for var subtype of names {
					subtypes.push(subtype)
				}
			}
		}
		else {
			var enum = variant.getEnumType()
			var names = {}

			for var subtype in @subtypes {
				names[variant.getMainName(subtype.name)] = subtype
			}

			for var subtype in value.getSubtypes() {
				var name = variant.getMainName(subtype.name)

				if !?names[name] {
					names[name] = subtype
				}
			}

			for var subtype of names {
				subtypes.push(subtype)
			}
		}

		return ReferenceType.new(@scope, @name, nullable, null, subtypes)
	} # }}}
	name(): String => @name
	path() => @name
	parameter(index: Number = 0) { # {{{
		if @parameters.length == 0 {
			if @isAlias() {
				return @discardAlias().parameter()
			}
			else if @isArray() {
				return @type().parameter()
			}
			else {
				return AnyType.NullableUnexplicit
			}
		}
		else if index >= @parameters.length {
			return AnyType.NullableUnexplicit
		}
		else {
			return @parameters[index]
		}
	} # }}}
	parameters(): Type[] => @parameters
	parameters(@parameters)
	properties() => []
	reassign(@name, @scope) { # {{{
		@reset()

		return this
	} # }}}
	resolve(): Void { # {{{
		if !?@type || @type.isCloned() {
			if @name == 'Any' {
				@type = AnyType.Unexplicit
				@predefined = true
			}
			else if @name == 'Never' {
				@type = Type.Never
				@predefined = true
			}
			else if @name == 'Null' {
				@type = Type.Null
				@nullable = true
				@predefined = true
			}
			else if @name == 'Void' {
				@type = Type.Void
				@predefined = true
			}
			else {
				var names = @name.split('.')

				if names.length == 1 {
					if @variable ?= @scope.getVariable(@name, -1) {
						@type = @variable.getRealType()
						@nullable = @nullable || @type.isNullable()
						@predefined = @variable.isPredefined() || @type.isPredefined()

						if @type is AliasType {
							@type = @type.type()
						}
						if @type is ReferenceType {
							@type = @type.type()
						}
					}
					else {
						echo(@name)
						NotSupportedException.throw()
					}
				}
				else {
					var mut fullname = names[0]
					var mut type = @scope.getVariable(fullname, -1)?.getRealType()

					if !?type {
						NotSupportedException.throw()
					}

					for var name in names from 1 {
						fullname += name

						if type !?= type.getProperty(name) {
							echo(@name)
							NotSupportedException.throw()
						}
					}

					@type = type
					@nullable = @nullable || type.isNullable()
					@predefined = type.isPredefined()
				}

				if @type is AliasType {
					@type = @type.type()
				}
				if @type is ReferenceType {
					@type = @type.type()
				}
			}

			// if ?#@parameters && !(@isArray() || @isObject() || @isAlias()) {
			// 	NotImplementedException.throw()
			// }
		}
	} # }}}
	reset(): valueof this { # {{{
		Object.delete(this, '_type')
		@nullable = @explicitlyNull
		@predefined = false
	} # }}}
	setNullable(nullable: Boolean): ReferenceType { # {{{
		if @isNull() {
			return this
		}
		else if @explicitlyNull {
			if nullable {
				return this
			}
			else {
				return @scope.reference(@name, false, [...@parameters], [...@subtypes])
			}
		}
		else {
			@resolve()

			if @nullable == nullable {
				return this
			}
			else if @type.isUnion() {
				if nullable {
					if @type.isAlias() {
						return @scope.reference(@name, true, [...@parameters], [...@subtypes])
					}

					var types: Array = @type.discard().types()

					types.push(Type.Null)

					return Type.union(@scope, ...types)
				}
				else {
					var types = []

					for var type in @type.discard().types() {
						if type.isNull() {
							continue
						}

						if type.isNullable() {
							types.push(type.setNullable(false))
						}
						else {
							types.push(type)
						}
					}

					return Type.union(@scope, ...types)
				}
			}
			else {
				return @scope.reference(@name, nullable, [...@parameters], [...@subtypes])
			}
		}
	} # }}}
	override setProperty(name, type) { # {{{
		return if !?#@parameters

		var property = @getProperty(name)

		for var parameter, index in @parameters {
			if property == parameter {
				@parameters[index] = type

				break
			}
		}
	} # }}}
	setSubtypes(@subtypes)
	split(types: Array) { # {{{
		@resolve()

		if ?#@parameters || ?#@subtypes {
			return super(types)
		}
		else if @type.isAlias() {
			var alias = @type.discardName()

			if @nullable && !alias.isNullable() {
				types.pushUniq(Type.Null)
			}

			if alias.hasGenerics() {
				return super(types)
			}
			else {
				return alias.split(types)
			}
		}
		else if @type.isUnion() {
			return @type.split(types)
		}
		else {
			return super(types)
		}
	} # }}}
	override toAssertFunctionFragments(value, nullable, fragments, node) { # {{{
		if $typeofs[@name] {
			fragments.code(`\($runtime.helper(node)).assert\(@name)(`).compile(value).code(`, \(nullable ? '1' : '0'))`)
		}
		else {
			super(value, nullable, fragments, node)
		}
	} # }}}
	toExportFragment(fragments, name, variable) { # {{{
		var varname = variable.name?()

		if name == varname {
			fragments.line(name)
		}
		else {
			fragments.newLine().code(`\(name): `).compile(variable).done()
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		@resolve()

		if @type.isView() {
			@type.discard().toFragments(fragments, node)
		}
		else {
			fragments.code(@name)
		}
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		@resolve()

		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if @predefined {
			return super.toMetadata(references, indexDelta, mode, module)
		}
		else if !@variable.getRealType().isClass() {
			@referenceIndex = @variable.getRealType().toMetadata(references, indexDelta, mode, module)
		}
		else if @type.isAlien() && @type.isPredefined() {
			return super.toMetadata(references, indexDelta, mode, module)
		}
		else {
			var index = references.length

			@referenceIndex = index + indexDelta

			// reserve position
			references.push(null)

			references[index] = @variable.getRealType().toReference(references, indexDelta, mode, module)
		}

		return @referenceIndex
	} # }}}
	toQuote() => ReferenceType.toQuote(@name, @explicitlyNull, @parameters, @subtypes)
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		@resolve()

		if @predefined {
			return @export(references, indexDelta, mode, module)
		}
		else if @name == 'this' {
			return {
				kind: TypeKind.Reference
				@name
			}
		}
		else if mode ~~ ExportMode.Alien {
			if @type.isClass() {
				return @export(references, indexDelta, mode, module, @type.toReference(references, indexDelta, mode, module))
			}
			else {
				return super(references, indexDelta, mode, module)
			}
		}
		else if mode ~~ ExportMode.Requirement {
			if @type.isRequirement() || !@type.isNative() {
				if @type.isClass() {
					return @export(references, indexDelta, mode, module, @type.toReference(references, indexDelta, mode, module))
				}
				else {
					return super(references, indexDelta, mode, module)
				}
			}
			else if @type.isExplicitlyExported() {
				return @export(references, indexDelta, mode, module, @type.toAlterationReference(references, indexDelta, mode, module))
			}
			else {
				return @export(references, indexDelta, mode, module)
			}
		}
		else {
			if !@type.isClass() {
				return super.toReference(references, indexDelta, mode, module)
			}
			else if @type.isExplicitlyExported() || @type.isRequirement() {
				return @export(references, indexDelta, mode, module, @type.toReference(references, indexDelta, mode, module))
			}
			else if @isNative() {
				return @export(references, indexDelta, mode, module)
			}
			else {
				return @export(references, indexDelta, mode, module, @type.toReference(references, indexDelta, mode, module))
			}
		}
	} # }}}
	override toAwareTestFunctionFragments(varname, nullable, casting, blind, mut generics, subtypes, fragments, node) { # {{{
		@resolve()

		if @type.isAlias() && @type is NamedType {
			if var names ?#= @type.type().generics() {
				if @parameters.length > names.length {
					NotImplementedException.throw()
				}

				generics = []

				for var name, index in names {
					if var type ?= @parameters[index] {
						generics.push({ name, type })
					}
					else {
						generics.push({ name, type : AnyType.NullableUnexplicit })
					}
				}
			}
			// else if ?#@parameters {
			// 	NotImplementedException.throw()
			// }
		}
		// else if ?#@parameters {
		// 	NotImplementedException.throw()
		// }

		if ?#@subtypes {
			unless @type.isObject() && @type.isVariant() {
				NotImplementedException.throw()
			}

			@discard().toAwareTestFunctionFragments(varname, @nullable, casting, blind, generics, @subtypes, fragments, node)
		}
		else if ?#generics {
			@type.toAwareTestFunctionFragments(varname, @nullable, casting, blind, generics, subtypes, fragments, node)
		}
		else {
			var unalias = @discardAlias()
			var name = unalias.name?() ?? @name
			var tof = $runtime.typeof(name, node)

			if ?tof {
				if @nullable {
					fragments.code(`\(varname) => \(tof)(\(varname)) || \($runtime.type(node)).isNull(\(varname))`)
				}
				else {
					fragments.code(`\(tof)`)
				}
			}
			else if unalias.isObject() || unalias.isArray() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() || unalias.isView() {
				unalias.toAwareTestFunctionFragments(varname, @nullable, casting, blind, generics, subtypes, fragments, node)
			}
			else {
				super(varname, @nullable, casting, blind, generics, subtypes, fragments, node)
			}
		}
	} # }}}
	toCastFragments(varname, fragments, node) { # {{{
		var unalias = @discardAlias()

		unalias.type().toCastFragments(unalias.path(), varname, fragments, node)
	} # }}}
	override toCastFunctionFragments(value, nullable, fragments, node) { # {{{
		if $typeofs[@name] {
			fragments.code(`\($runtime.helper(node)).assert\(@name)(`).compile(value).code(`, \(nullable ? '1' : '0'))`)
		}
		else {
			var unalias = @discardAlias()

			if unalias.isObject() {
				fragments.code(`\($runtime.helper(node)).assert(`).compile(value).code(`, \($quote(@toQuote(true))), \(nullable ? '1' : '0'), `)

				unalias.toAwareTestFunctionFragments('value', false, true, false, null, null, fragments, node)

				fragments.code(')')
			}
			else {
				unalias.type().toCastFunctionFragments(unalias.path(), @toQuote(true), value, nullable, fragments, node)
			}
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, casting, propname, mut nullable, generics, fragments, node) { # {{{
		@resolve()

		nullable ||= @nullable

		if ?#@subtypes {
			unless @type.isObject() && @type.isVariant() {
				NotImplementedException.throw()
			}

			var { type, generics } = @getGenericMapper()

			type.toAwareTestFunctionFragments(varname, nullable, casting, true, generics, @subtypes, fragments, node)
		}
		else if @type.isBitmask() && ?propname {
			fragments.code(`() => \($runtime.helper(node)).castBitmask(\(varname), \(propname), `).compile(@discardAlias()).code(`, cast)`)
		}
		else if @type.isEnum() && ?propname {
			if @type.isView() {
				var view = @type.discard()

				fragments.code(`() => \($runtime.helper(node)).castEnumView(\(varname), \(propname), `).compile(view).code(`, cast, `)

				view.toAwareTestFunctionFragments(varname, nullable, casting, true, null, null, fragments, node)

				fragments.code(')')
			}
			else {
				fragments.code(`() => \($runtime.helper(node)).castEnum(\(varname), \(propname), `).compile(@type).code(`, cast)`)
			}
		}
		else {
			var unalias = @discardAlias()
			var name = unalias.name?() ?? @name
			var tof = $runtime.typeof(name, node)

			if ?tof {
				if @nullable {
					fragments.code(`\(varname) => \(tof)(\(varname)) || \($runtime.type(node)).isNull(\(varname))`)
				}
				else {
					fragments.code(`\(tof)`)
				}
			}
			else if unalias.isObject() || unalias.isArray() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() {
				var { generics } = @getGenericMapper()

				unalias.toBlindSubtestFunctionFragments(funcname, varname, casting, propname, nullable, generics, fragments, node)
			}
			else {
				super(funcname, varname, casting, propname, nullable, generics, fragments, node)
			}
		}
	} # }}}
	override toBlindTestFragments(funcname, varname, casting, generics, subtypes, junction, fragments, node) { # {{{
		@resolve()

		if @parameters.length == 0 && !@nullable {
			if var tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(\(varname))`)

				return
			}
		}

		var mut subjunction = null
		if @nullable && junction == Junction.AND {
			fragments.code('(')

			subjunction = Junction.OR
		}

		var unalias = @discardAlias()

		if ?#@subtypes {
			unalias.discard().toBlindTestFragments(funcname, varname, casting, generics, @subtypes, subjunction ?? junction, fragments, node)
		}
		else if unalias.isObject() || unalias.isArray() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() || unalias.isView() {
			unalias.toBlindTestFragments(funcname, varname, casting, generics, subtypes, subjunction ?? junction, fragments, node)
		}
		else {
			var name = unalias.name?() ?? @name

			if var tof ?= $runtime.typeof(name, node) {
				fragments.code(`\(tof)(\(varname)`)
			}
			else {
				fragments.code(`\($runtime.type(node)).`)

				if unalias.isBitmask() {
					fragments.code(`isBitmaskInstance`)
				}
				else if unalias.isClass() {
					fragments.code(`isClassInstance`)
				}
				else if unalias.isEnum() {
					fragments.code(`isEnumInstance`)
				}
				else if unalias.isStruct() {
					fragments.code(`isStructInstance`)
				}
				else if unalias.isTuple() {
					fragments.code(`isTupleInstance`)
				}
				else {
					throw NotSupportedException.new()
				}

				fragments.code(`(\(varname), `)

				if unalias is NamedType {
					fragments.code(unalias.path())
				}
				else {
					fragments.code(name)
				}
			}
		}

		if @parameters.length != 0 {
			fragments.code(', ')

			@parameters[0].toBlindTestFunctionFragments(funcname, varname, casting, true, generics, fragments, node)
		}

		if !@type.isAlias() {
			fragments.code(')')
		}

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(\(varname))`)

			if ?subjunction {
				fragments.code(')')
			}
		}
	} # }}}
	override toNegativeTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		@resolve()

		if @type.isVariant() {
			if ?#@subtypes && @isSubtypeOf(node.type()) {
				if ?#@parameters && !?#parameters {
					if !?#subtypes {
						var { type, generics, subtypes } = @getGenericMapper()

						type.toNegativeTestFragments(generics, subtypes, junction, fragments, node)
					}
					else {
						var { type, generics } = @getGenericMapper()

						type.toVariantTestFragments(subtypes[0].name, generics, junction, fragments.code('!'), node)
					}
				}
				else {
					var root = @type.discard()
					var variantType = root.getVariantType()
					var property = root.getVariantName()

					if variantType.canBeBoolean() {
						for var { name, type }, index in @subtypes {
							fragments
								..code(' && ') if index > 0
								..code('!') if variantType.isTrueValue(name)
								..compile(node).code(`.\(property)`)
						}
					}
					else {
						for var { name, type }, index in @subtypes {
							fragments.code(' && ') if index > 0

							var value = type.discard().getValue(name)

							if value.isAlias() {
								if value.isDerivative() {
									fragments.code('!').compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))(`).compile(node).code(`.\(property))`)
								}
								else {
									fragments.compile(node).code(`.\(property) !== `).compile(type).code(`.\(value.original())`)
								}
							}
							else {
								fragments.compile(node).code(`.\(property) !== `).compile(type).code(`.\(name)`)
							}
						}
					}
				}
			}
			else {
				var { type, generics, subtypes } = @getGenericMapper()

				type.toNegativeTestFragments(generics, subtypes, junction, fragments, node)
			}
		}
		else if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toNegativeTestFragments(parameters, subtypes, junction, fragments, node)
		}
		else {
			@toReferenceTestFragments(junction, fragments.code('!'), node)
		}
	} # }}}
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		@resolve()

		if @type.isVariant() {
			if ?#@subtypes && @isSubtypeOf(node.type()) {
				if ?#@parameters && !?#parameters {
					if !?#subtypes {
						var { type, generics, subtypes } = @getGenericMapper()

						type.toPositiveTestFragments(generics, subtypes, junction, fragments, node)
					}
					else {
						var { type, generics } = @getGenericMapper()

						type.toVariantTestFragments(subtypes[0].name, generics, junction, fragments, node)
					}
				}
				else {
					var root = @type.discard()
					var variantType = root.getVariantType()
					var property = root.getVariantName()

					if variantType.canBeBoolean() {
						for var { name, type }, index in @subtypes {
							fragments
								..code(' || ') if index > 0
								..code('!') if variantType.isFalseValue(name)
								..compile(node).code(`.\(property)`)
						}
					}
					else {
						for var { name, type }, index in @subtypes {
							fragments.code(' || ') if index > 0

							var value = type.discard().getValue(name)

							if value.isAlias() {
								if value.isDerivative() {
									fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))(`).compile(node).code(`.\(property))`)
								}
								else {
									fragments.compile(node).code(`.\(property) === `).compile(type).code(`.\(value.original())`)
								}
							}
							else {
								fragments.compile(node).code(`.\(property) === `).compile(type).code(`.\(name)`)
							}
						}
					}
				}
			}
			else {
				var { type, generics, subtypes } = @getGenericMapper()

				type.toPositiveTestFragments(generics, subtypes, junction, fragments, node)
			}
		}
		else if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toPositiveTestFragments(parameters, subtypes, junction, fragments, node)
		}
		else {
			@toReferenceTestFragments(junction, fragments, node)
		}
	} # }}}
	override toRouteTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if @nullable && junction == Junction.AND

		@toReferenceTestFragments(junction, fragments, node)

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(`).compile(node).code(')')
		}

		fragments.code(')') if @nullable && junction == Junction.AND
	} # }}}
	override toRouteTestFragments(fragments, node, argName, from, to, default, junction) { # {{{
		@resolve()

		fragments.code(`\($runtime.type(node)).isVarargs(\(argName), \(from), \(to), \(default), `)

		var literal = Literal.new(false, node, node.scope(), 'value')

		if node._options.format.functions == 'es5' {
			fragments.code('function(value) { return ')

			if @nullable {
				@toReferenceTestFragments(Junction.OR, fragments, literal)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toReferenceTestFragments(Junction.NONE, fragments, literal)
			}

			fragments.code('; }')
		}
		else {
			fragments.code('value => ')

			if @nullable {
				@toReferenceTestFragments(Junction.OR, fragments, literal, Junction.OR)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toReferenceTestFragments(Junction.NONE, fragments, literal)
			}
		}

		fragments.code(')')
	} # }}}
	override toVariations(variations) { # {{{
		@resolve()

		variations.push('ref', @name, @spread, @nullable)

		if @type.isPredefined() {
			variations.push(true)
		}
		else {
			@type.toVariations(variations)
		}
	} # }}}
	override trimOff(type) { # {{{
		if this == type {
			return Type.Void
		}
		else if type is ReferenceType && @name == type.name() {
			var mut nullable = false

			if @isNullable() && !type.isNullable() {
				nullable = true
			}

			var parameters = type.parameters()
			var newParameters = []

			if ?#parameters {
				if ?#@parameters {
					for var index from 0 to~ Math.max(@parameters.length, parameters.length) {
						newParameters.push(@parameters[index].trimOff(parameters[index]))
					}
				}
			}

			var subtypes = type.getSubtypes()
			var newSubtypes = []

			if ?#subtypes {
				var variant: VariantType = @type.discard().getVariantType()
				var master = variant.getMaster()

				var names = variant.explodeVarnames(...@subtypes)
				var offNames = variant.explodeVarnames(...subtypes)

				names.remove(...offNames)

				if ?#names {
					for var name in names {
						newSubtypes.push({ name, type: master })
					}
				}
				else {
					newSubtypes.push(...subtypes)
				}
			}

			return ReferenceType.new(@scope, @name, @nullable, newParameters, newSubtypes)
		}
		else {
			var reduced = @type().trimOff(type)

			if @nullable && !type.isNullable() {
				return (reduced.isUnion() ? reduced : @scope.reference(reduced)).setNullable(true)
			}
			else {
				return reduced.isUnion() ? reduced : @scope.reference(reduced)
			}
		}
	} # }}}
	override tryCastingTo(value) { # {{{
		if @isAlias() && @type.isObject() && !value.isAlias() && value.isObject() {
			var parameters = []
			var subtypes = []
			var mut cast = true
			var mut subtypeObject = null
			var object = @type.discard()

			if object.isVariant() {
				var name = object.getVariantName()
				var variant = object.getVariantType()

				if var property ?= value.getProperty(name) ;; property.isValue() {
					var value = property.value()

					subtypes.push({ name: variant.getMainName(value), type: variant.getMaster()})

					if var field ?= variant.getField(value) {
						subtypeObject = field.type
					}
				}
				else {
					cast = false
				}
			}

			var perNames = {}

			for var property, name of object.properties() {
				if property is DeferredType {
					if var value ?= value.getProperty(name)  {
						perNames[name] ??= []
							..push(value.type().reference())
					}
				}
			}
			if ?subtypeObject {
				for var property, name of subtypeObject.properties() {
					if property is DeferredType {
						if var value ?= value.getProperty(name)  {
							perNames[name] ??= []
								..push(value.type().reference())
						}
					}
				}
			}

			for var types, name of perNames {
				parameters.push(Type.union(@scope, ...types!?))
			}

			if cast && (?#parameters || ?#subtypes) {
				return @clone()
					..parameters(parameters)
					..setSubtypes(subtypes)
			}
		}

		if value.isMorePreciseThan(this) {
			return value
		}

		return this
	} # }}}
	override tune(value) { # {{{
		@resolve()

		return null unless @type is NamedType && @type.isAlias() && @type.isObject() && value is ObjectType

		var alias = @type.type()

		return null unless alias.hasGenerics() || alias.isVariant()

		var generics = alias.generics()
		var object = alias.discard()
		var parameters = []
		var subtypes = []
		var properties = {...object.properties()!?}

		if object.isVariant() && !?#@subtypes {
			var name = object.getVariantName()
			var variant = object.getVariantType()
			var property = value.getProperty(name)

			if property is ValueType {
				subtypes.push({ name: property.value(), type: variant.getMaster() })

				if var { type % subtype } ?= variant.getField(property.value()) {
					Object.merge(properties, subtype.properties())
				}
			}
		}

		if generics.length > @parameters.length {
			var map = {}

			for var type, name of properties when type is DeferredType {
				map[type.name()] = value.getProperty(name)
			}

			for var { name } in generics while ?map[name] {
				parameters.push(map[name])
			}
		}
		else if ?#subtypes {
			parameters.push(...@parameters)
		}
		else {
			return null
		}

		if parameters.length > @parameters.length || subtypes.length > @subtypes.length {
			return ReferenceType.new(@scope, @name, @nullable, parameters, subtypes)
		}
		else {
			return null
		}
	} # }}}
	type() { # {{{
		@resolve()

		return @type
	} # }}}
	unflagStrict(): ReferenceType { # {{{
		return this unless @strict

		var type = @clone()

		type._strict = false

		return type
	} # }}}

	private toReferenceTestFragments(junction, fragments, node) { # {{{
		if @nullable && junction == Junction.AND {
			fragments.code('(')
		}

		if var tof ?= $runtime.typeof(@name, node) {
			fragments.code(`\(tof)(`).compileReusable(node)
		}
		else {
			fragments.code(`\($runtime.type(node)).`)

			if @type.isBitmask() {
				fragments.code(`isBitmaskInstance`)
			}
			else if @type.isClass() {
				fragments.code(`isClassInstance`)
			}
			else if @type.isEnum() {
				fragments.code(`isEnumInstance`)
			}
			else if @type.isStruct() {
				fragments.code(`isStructInstance`)
			}
			else if @type.isTuple() {
				fragments.code(`isTupleInstance`)
			}

			fragments.code(`(`).compileReusable(node).code(`, `)

			if @type is NamedType {
				fragments.code(@type.path())
			}
			else {
				fragments.code(@name)
			}
		}

		if @parameters.length != 0 {
			fragments.code(', ')

			var literal = Literal.new(false, node, node.scope(), 'value')

			if node._options.format.functions == 'es5' {
				fragments.code('function(value) { return ')

				@parameters[0].toReferenceTestFragments(Junction.NONE, fragments, literal)

				fragments.code('; }')
			}
			else {
				fragments.code('value => ')

				@parameters[0].toReferenceTestFragments(Junction.NONE, fragments, literal)
			}
		}

		fragments.code(')')

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(`).compile(node).code(`)`)

			if junction == Junction.AND {
				fragments.code(')')
			}
		}
	} # }}}
}
