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
		@explicitlyNull: Boolean
		@name: String
		@nullable: Boolean
		@parameters: Array<Type>
		@predefined: Boolean				= false
		@spread: Boolean					= false
		@strict: Boolean					= false
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ReferenceType { # {{{
			var late name
			if data.name is Number {
				var reference = Type.import({ reference: data.name }, metadata, references, alterations, queue, scope, node)

				name = reference.name()
			}
			else {
				name = data.name
			}

			return ReferenceType.new(scope, name as String, data.nullable!?, null)
		} # }}}
		toQuote(name, nullable, parameters) { # {{{
			var fragments = [name]

			if parameters.length != 0 {
				fragments.push('<')

				for var parameter, index in parameters {
					if index != 0 {
						fragments.push(', ')
					}

					fragments.push(parameter.toQuote())
				}

				fragments.push('>')
			}

			if nullable {
				fragments.push('?')
			}

			return fragments.join('')
		} # }}}
	}
	constructor(@scope, name: String, @explicitlyNull = false, @parameters = []) { # {{{
		super(scope)

		@name = $types[name] ?? name
		@nullable = @explicitlyNull
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
			return @name == 'Object' || @type().isObject() || @type().isStruct() || (@type().isClass() && !@isPrimitive() && !@isArray() && !@isEnum())
		}
	} # }}}
	canBeString(any = true) => @isUnion() ? @type.canBeString(any) : super(any)
	clone(): ReferenceType { # {{{
		var type = ReferenceType.new(@scope, @name, @nullable, @parameters)

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
			if value.type().isEnum() {
				var name = value.discard().type().name()

				return $weightTOFs[@name] - $weightTOFs[name]
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
			if @type().isEnum() {
				var name = @discard().type().name()

				return $weightTOFs[@name] - $weightTOFs[name]
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
		if @name == 'Any' {
			return Type.Any
		}
		else if (variable ?= @scope.getVariable(@name)) && (variable.getRealType() is not ReferenceType || variable.name() != @name || variable.scope() != @scope) {
			return variable.getRealType().discardAlias()
		}
		else {
			return this
		}
	} # }}}
	discardReference(): Type? { # {{{
		if @name == 'Any' {
			return @nullable ? AnyType.NullableExplicit : AnyType.Explicit
		}
		else if (variable ?= @scope.getVariable(@name, -1)) && (type ?= variable.getRealType()) && (type is not ReferenceType || variable.name() != @name || type.scope() != @scope) {
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
		if @parameters.length == 0 {
			return @nullable ? `\(@name)?` : @name
		}
		else {
			var export = {
				kind: TypeKind.Reference
				name: @name
			}

			if @explicitlyNull {
				export.nullable = @explicitlyNull
			}

			if @parameters.length != 0 {
				export.parameters = [parameter.toGenericParameter(references, indexDelta, mode, module) for parameter in @parameters]
			}

			return export
		}
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name) { # {{{
		if @nullable || @parameters.length != 0 {
			var export = {
				kind: TypeKind.Reference
				name: name.reference ?? name
			}

			if @explicitlyNull {
				export.nullable = @explicitlyNull
			}

			if @parameters.length != 0 {
				export.parameters = [parameter.toReference(references, indexDelta, mode, module) for parameter in @parameters]
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
	getMajorReferenceIndex() => @referenceIndex == -1 ? @type().getMajorReferenceIndex() : @referenceIndex
	getProperty(index: Number): Type { # {{{
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
	getProperty(name: String): Type { # {{{
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
		else {
			return type.getProperty(name)
		}
	} # }}}
	getSealedPath() => @type().getSealedPath()
	hashCode(fattenNull: Boolean = false): String { # {{{
		var mut hash = ''

		if @name == 'Array' && @parameters.length == 1 {
			hash = `\(@parameters[0].hashCode())[]`
		}
		else if @name == 'Object' && @parameters.length == 1 {
			hash = `\(@parameters[0].hashCode()){}`
		}
		else {
			hash = @name

			if @parameters.length > 0 {
				hash += '<'

				for var parameter, i in @parameters {
					if i != 0 {
						hash += ','
					}

					hash += parameter.hashCode()
				}

				hash += '>'
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
	hasMutableAccess() => @name == 'Array' | 'Object' || @type().hasMutableAccess()
	hasParameters() => @parameters.length > 0
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

		var mut type: Type = @type()

		if type is NamedType {
			type = type.type()
		}

		if type.isClass() {
			return type.hasInstantiableProperty(name)
		}
		else {
			return type.hasProperty(name)
		}
	} # }}}
	hasRest() => @name == 'Object' || @type().hasRest()
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

				for var index from 0 to~ Math.max(@parameters.length, value.parameters().length) {
					if !@parameter(index).isAssignableToVariable(value.parameter(index), true, nullcast, downcast) {
						return false
					}
				}

				return true
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

			return @isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast)
		}
		else if value is ObjectType {
			return false unless @isBroadObject()
			return false unless !@nullable || nullcast || value.isNullable()

			return @isSubsetOf(value, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast)
		}
		else {
			return @type().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
	} # }}}
	isAsync() => false
	isBoolean() => @name == 'Boolean' || @type().isBoolean()
	isBroadArray() => @name == 'Array' || @type().isArray() || @type().isTuple()
	isBroadObject() => @name == 'Object' || @type().isObject() || @type().isStruct() || (@type().isClass() && !@isPrimitive() && !@isArray() && !@isEnum())
	isClass() => @name == 'Class'
	isClassInstance() => @name != 'Object' && @type().isClass()
	override isComparableWith(type) => @type().isComparableWith(type)
	override isComplete() => @type().isComplete()
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
		for type in value.types() {
			if @isInstanceOf(type) {
				return true
			}
		}

		return false
	} # }}}
	isIterable() => @type().isIterable() || @isArray() || @isObject() || @isString()
	isMorePreciseThan(value: Type) { # {{{
		if value.isAny() {
			return !@isAny() || (value.isNullable() && !@nullable)
		}
		else if @isAny() {
			return false
		}
		else if value is ReferenceType && value.name() == @name {
			if value.isNullable() && !@nullable {
				return true
			}
			else if @hasParameters() && !value.hasParameters() {
				return true
			}
			else {
				return false
			}
		}
		else if value.isUnion() {
			for var type in value.discard().types() {
				if @matchContentOf(type) || @isMorePreciseThan(type) {
					return true
				}
			}

			return false
		}
		else if @name == 'Array' && value.isBroadArray() {
			return true
		}
		else if @name == 'Object' && value.isBroadObject() {
			return true
		}
		else {
			var a: Type = @discardReference()!?
			var b: Type = value.discardReference()!?

			return a.isMorePreciseThan(b)
		}
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
	isSpread() => @spread
	isStrict() => @strict
	isString() => @name == 'String' || @type().isString()
	isStruct() => @name == 'Struct' || @type().isStruct()
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		return false unless @isBroadArray()
		return @discard().isSubsetOf(value, mode) unless @isArray()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless !value.hasProperties()
			return false unless @hasParameters() == value.hasRest()

			if @hasParameters() {
				var type = @parameters[0]

				for var property in value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				return @parameters[0].isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @hasParameters() {
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

		return true
	} # }}}
	isSubsetOf(value: ObjectType, mode: MatchingMode) { # {{{
		return false unless @isBroadObject()
		return @discard().isSubsetOf(value, mode) unless @isObject()

		if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			return false unless !value.hasProperties()
			return false unless @hasParameters() == value.hasRest()

			if @hasParameters() {
				var type = @parameters[0]

				for var property of value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				return type.isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @hasParameters() {
				var type = @parameters[0]

				for var property of value.properties() {
					return false unless type.isSubsetOf(property, mode)
				}

				if value.hasRest() {
					return false unless type.isSubsetOf(value.getRestType(), mode)
				}
			}
		}

		if @isAlias() {
			var unalias = @discardAlias()

			return unalias.isSubsetOf(value, mode + MatchingMode.Reference)
		}

		return true
	} # }}}
	isSubsetOf(value: FunctionType, mode: MatchingMode) { # {{{
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
	isSubsetOf(value: ReferenceType, mode: MatchingMode) { # {{{
		if this == value {
			return true
		}
		else if mode ~~ MatchingMode.Exact && mode !~ MatchingMode.Subclass {
			if @name != value._name || @parameters.length != value._parameters.length {
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

			if ?@parameters {
				if ?value._parameters && @parameters.length == value._parameters.length {
					for var parameter, i in @parameters {
						if !parameter.isSubsetOf(value._parameters[i], mode) {
							return false
						}
					}
				}
				else {
					return false
				}
			}
			else {
				if ?value._parameters {
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

					return true
				}
			}

			if $virtuals[value.name()] {
				return @type().canBeVirtual(value.name())
			}

			if mode ~~ MatchingMode.AutoCast {
				if @type().isEnum() {
					return @type().discard().type().isSubsetOf(value, mode)
				}
			}

			if @isAlias() {
				return @discardAlias().isSubsetOf(value, mode)
			}

			return @scope.isMatchingType(@discardReference()!?, value.discardReference()!?, mode)
		}
	} # }}}
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
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
			else if value is UnionType {
				for var type in value.types() {
					if this.isSubsetOf(type, mode) {
						return true
					}
				}

				return false
			}
			else {
				return value.isAny()
			}
		}
	} # }}}
	isTuple() => @name == 'Tuple' || @type().isTuple()
	isTypeOf(): Boolean => $typeofs[@name]
	isUnion() => @type().isUnion()
	isVirtual() => @type().isVirtual()
	isVoid() => @name == 'Void' || @type().isVoid()
	listFunctions(name: String): Array => @type().listFunctions(name)
	listFunctions(name: String, type: FunctionType, mode: MatchingMode): Array => @type().listFunctions(name, type, mode)
	listMissingProperties(class: ClassType) => @type().listMissingProperties(class)
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
	name(): String => @name
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
	parameters() => @parameters
	reassign(@name, @scope) { # {{{
		@reset()

		return this
	} # }}}
	reduce(type: Type) { # {{{
		if this == type {
			return this
		}
		else {
			var reduced = @type().reduce(type)

			if @nullable && !type.isNullable() {
				return (reduced.isUnion() ? reduced : @scope.reference(reduced)).setNullable(true)
			}
			else {
				return reduced.isUnion() ? reduced : @scope.reference(reduced)
			}
		}
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
				@nullable = false
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
		}
	} # }}}
	reset(): this { # {{{
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
				return @scope.reference(@name, false, [...@parameters])
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
						return @scope.reference(@name, true, [...@parameters])
					}

					var types = @type.discard().types()

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
				return @scope.reference(@name, nullable, [...@parameters])
			}
		}
	} # }}}
	split(types: Array) { # {{{
		@resolve()

		if @type.isAlias() || @type.isUnion() {
			return @type.split(types)
		}
		else {
			return super(types)
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
		fragments.code(@name)
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
	toQuote() => ReferenceType.toQuote(@name, @explicitlyNull, @parameters)
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		@resolve()

		if @predefined {
			return @export(references, indexDelta, mode, module)
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
	override toNegativeTestFragments(fragments, node, junction) { # {{{
		@resolve()

		if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toNegativeTestFragments(fragments, node, junction)
		}
		else {
			@toReferenceTestFragments(fragments.code('!'), node, junction)
		}
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		@resolve()

		if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toPositiveTestFragments(fragments, node, junction)
		}
		else {
			@toReferenceTestFragments(fragments, node, junction)
		}
	} # }}}
	override toRouteTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if @nullable && junction == Junction.AND

		@toReferenceTestFragments(fragments, node, junction)

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
				@toReferenceTestFragments(fragments, literal, Junction.OR)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toReferenceTestFragments(fragments, literal, Junction.NONE)
			}

			fragments.code('; }')
		}
		else {
			fragments.code('value => ')

			if @nullable {
				@toReferenceTestFragments(fragments, literal, Junction.OR)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toReferenceTestFragments(fragments, literal, Junction.NONE)
			}
		}

		fragments.code(')')
	} # }}}
	override toTestFragments(fragments, node, junction) { # {{{
		@resolve()

		if @parameters.length == 0 && !@nullable {
			if var tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(value)`)

				return
			}
		}

		var mut subjunction = null
		if @nullable && junction == Junction.AND {
			fragments.code('(')

			subjunction = Junction.OR
		}

		var unalias = @discardAlias()

		if unalias.isObject() || unalias.isArray() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() {
			unalias.toTestFragments(fragments, node, subjunction ?? junction)
		}
		else {
			var name = unalias.name?() ?? @name

			if var tof ?= $runtime.typeof(name, node) {
				fragments.code(`\(tof)(value`)
			}
			else {
				fragments.code(`\($runtime.type(node)).`)

				if unalias.isClass() {
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

				fragments.code(`(value, `)

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

			var literal = Literal.new(false, node, node.scope(), 'value')

			@parameters[0].toTestFunctionFragments(fragments, literal)
		}

		if !@type.isAlias() {
			fragments.code(')')
		}

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(value)`)

			if ?subjunction {
				fragments.code(')')
			}
		}
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		if @nullable {
			super.toTestFunctionFragments(fragments, node)
		}
		else {
			var unalias = @discardAlias()
			var name = unalias.name?() ?? @name
			var tof = $runtime.typeof(name, node)

			if !#@parameters && ?tof {
				fragments.code(`\(tof)`)
			}
			else if unalias.isObject() || unalias.isArray() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() {
				unalias.toTestFunctionFragments(fragments, node)
			}
			else {
				super.toTestFunctionFragments(fragments, node)
			}
		}
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

	private toReferenceTestFragments(fragments, node, junction) { # {{{
		if @nullable && junction == Junction.AND {
			fragments.code('(')
		}

		if var tof ?= $runtime.typeof(@name, node) {
			fragments.code(`\(tof)(`).compileReusable(node)
		}
		else {
			fragments.code(`\($runtime.type(node)).`)

			if @type.isClass() {
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

				@parameters[0].toReferenceTestFragments(fragments, literal, Junction.NONE)

				fragments.code('; }')
			}
			else {
				fragments.code('value => ')

				@parameters[0].toReferenceTestFragments(fragments, literal, Junction.NONE)
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
