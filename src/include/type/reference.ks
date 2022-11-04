var $weightTOFs = { # {{{
	Array: 1
	Boolean: 2
	Class: 12
	Dictionary: 10
	Enum: 4
	Function: 3
	Namespace: 8
	Number: 5
	Object: 12
	Primitive: 7
	RegExp: 9
	String: 6
	Struct: 11
	Tuple: 11
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
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ReferenceType { # {{{
			var late name
			if data.name is Number {
				var reference = Type.import({ reference: data.name }, metadata, references, alterations, queue, scope, node)

				name = reference.name()
			}
			else {
				name = data.name
			}

			var parameters = ?data.parameters ? [Type.import(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters] : null

			return new ReferenceType(scope, name as String, data.nullable!?, parameters)
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
	canBeBoolean() => @isUnion() ? @type.canBeBoolean() : super()
	canBeFunction(any = true) => @isUnion() ? @type.canBeFunction(any) : super(any)
	canBeNumber(any = true) => @isUnion() ? @type.canBeNumber(any) : super(any)
	canBeString(any = true) => @isUnion() ? @type.canBeString(any) : super(any)
	clone(): ReferenceType { # {{{
		var type = new ReferenceType(@scope, @name, @nullable, @parameters)

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
	compareToRef(value: DictionaryType, equivalences: String[][]? = null) { # {{{
		if @name == 'Dictionary' {
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
			return @compareToRef(@scope.resolveReference('Dictionary', false, [value.getRestType()]), equivalences)
		}
		else {
			return @compareToRef(@scope.reference('Dictionary'), equivalences)
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

			return -1
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
				kind: TypeKind::Reference
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
				kind: TypeKind::Reference
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
		else if @name == 'Dictionary' {
			if @parameters.length > 0 {
				return @parameters[0]
			}

			return AnyType.NullableUnexplicit
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
		else if @name == 'Dictionary' && @parameters.length == 1 {
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
	hasParameters() => @parameters.length > 0
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
		else if value is DestructurableObjectType {
			if @isDictionary() || @isObject() || @isStruct() {
				for var dType, name of value.properties() {
					if var sType ?= @getProperty(name) {
						return false unless sType.isAssignableToVariable(dType, anycast, nullcast, downcast)
					}
					else {
						return false
					}
				}
			}

			return true
		}
		else if value is ReferenceType {
			if @name == value.name() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				for var index from 0 til Math.max(@parameters.length, value.parameters().length) {
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
			else if value.name() == 'Object' && @isObject() {
				if @nullable && !nullcast && !value.isNullable() {
					return false
				}

				return true
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
		else if value is ArrayType {
			return false unless @isArray()
			return false unless !@nullable || nullcast || value.isNullable()

			if anycast && !@isFusion() && !@isUnion() {
				return true if @parameters.length == 0

				var parameter = @parameters[0]

				if parameter.isAny() && !parameter.isExplicit() {
					return true
				}
			}

			return this.isSubsetOf(value, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass + MatchingMode::AutoCast)
		}
		else if value is DictionaryType {
			return false unless @isDictionary()
			return false unless !@nullable || nullcast || value.isNullable()

			if anycast && !@isFusion() && !@isUnion() {
				return true if @parameters.length == 0

				var parameter = @parameters[0]

				if parameter.isAny() && !parameter.isExplicit() {
					return true
				}
			}

			return this.isSubsetOf(value, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass + MatchingMode::AutoCast)
		}
		else {
			return @type().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
	} # }}}
	isAsync() => false
	isBoolean() => @name == 'Boolean' || @type().isBoolean()
	isClass() => @name == 'Class'
	isClassInstance() => @type().isClass()
	override isComparableWith(type) => @type().isComparableWith(type)
	override isComplete() => @type().isComplete()
	isDictionary() => @name == 'Dictionary' || @type().isDictionary()
	isEnum() => @name == 'Enum' || @type().isEnum()
	isExhaustive() => @type().isExhaustive()
	isExplicit() => @type().isExplicit()
	isExplicitlyExported() => @type().isExplicitlyExported()
	isExplicitlyNull() => @explicitlyNull
	isExportable() => @type().isExportable()
	isExported() => @type().isExported()
	isExportingFragment() => !@isVirtual()
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
	isIterable() => @type().isIterable() || @isArray() || @isDictionary() || @isString()
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
	isObject() => @name == 'Object' || @isDictionary() || @type().isStruct() || (@type().isClass() && !@isPrimitive() && !@isArray() && !@isEnum())
	isPrimitive() => @isBoolean() || @isNumber() || @isString()
	isReference() => true
	isReducible() => true
	isSpread() => @spread
	isStrict() => @strict
	isString() => @name == 'String' || @type().isString()
	isStruct() => @name == 'Struct' || @type().isStruct()
	isSubsetOf(value: ArrayType, mode: MatchingMode) { # {{{
		return false unless @isArray()

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless !value.hasProperties()
			return false unless @hasParameters() == value.hasRest()

			if @hasParameters() {
				return @parameters[0].isSubsetOf(value.getRestType(), mode)
			}
		}
		else {
			if @hasParameters() {
				return false unless value.hasRest()

				var parameter = @parameters[0]

				return false unless parameter.isSubsetOf(value.getRestType(), mode)
			}
		}

		if @isAlias() {
			var unalias = @discardAlias()

			return unalias.isSubsetOf(value, mode)
		}

		return true
	} # }}}
	isSubsetOf(value: DictionaryType, mode: MatchingMode) { # {{{
		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			return false unless @isDictionary()
			return false unless !value.hasProperties()
			return false unless @hasParameters() == value.hasRest()

			if @hasParameters() {
				return @parameters[0].isSubsetOf(value.getRestType(), mode)
			}

			return true
		}
		else {
			return false unless @isDictionary() || @isInstance()

			return @discard().isSubsetOf(value, mode)
		}
	} # }}}
	isSubsetOf(value: FunctionType, mode: MatchingMode) { # {{{
		if @isAlias() {
			return @discardAlias().isSubsetOf(value, mode)
		}

		return false unless @isFunction()

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
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
		else if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			if @name != value._name || @parameters.length != value._parameters.length {
				return false
			}

			if mode ~~ MatchingMode::NonNullToNull {
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

			if mode ~~ MatchingMode::AutoCast {
				if @type().isEnum() {
					return @type().discard().type().isSubsetOf(value, mode)
				}
			}

			return @scope.isMatchingType(@discardReference()!?, value.discardReference()!?, mode)
		}
	} # }}}
	isSubsetOf(value: Type, mode: MatchingMode) { # {{{
		if @isAlias() {
			return @discardAlias().isSubsetOf(value, mode)
		}

		if mode ~~ MatchingMode::Exact && mode !~ MatchingMode::Subclass {
			if value.isAny() && !value.isExplicit() && mode ~~ MatchingMode::Missing {
				return true
			}
			else {
				return false
			}
		}
		else {
			if value.isDictionary() && @type().isClass() {
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
	isVoid() => @name == 'Void' || @type().isVoid()
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
		if @parameters.length == 0 && @isArray() {
			return @type().parameter()
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
		delete @type
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
	toCastFragments(fragments) { # {{{
		if @isTypeOf() {
			fragments.code($comma, 'null', $comma, $quote(@name))
		}
		else {
			@resolve()

			if @type.isClass() {
				fragments.code($comma, @name, $comma, '"Class"')
			}
			else if @type.isEnum() {
				fragments.code($comma, @name, $comma, '"Enum"')
			}
			else if @type.isStruct() {
				fragments.code($comma, @name, $comma, '"Struct"')
			}
			else if @type.isTuple() {
				fragments.code($comma, @name, $comma, '"Tuple"')
			}
			else {
				@type.toCastFragments(fragments)
			}
		}
	} # }}}
	toExportFragment(fragments, name, variable) { # {{{
		if !@isVirtual() {
			var varname = variable.name?()

			if name == varname {
				fragments.line(name)
			}
			else {
				fragments.newLine().code(`\(name): `).compile(variable).done()
			}
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
		else if mode ~~ ExportMode::Alien {
			if @type.isClass() {
				return @export(references, indexDelta, mode, module, @type.toReference(references, indexDelta, mode, module))
			}
			else {
				return super(references, indexDelta, mode, module)
			}
		}
		else if mode ~~ ExportMode::Requirement {
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
			@toTestFragments(fragments.code('!'), node, junction)
		}
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		@resolve()

		if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toPositiveTestFragments(fragments, node, junction)
		}
		else {
			@toTestFragments(fragments, node, junction)
		}
	} # }}}
	override toRouteTestFragments(fragments, node, junction) { # {{{
		fragments.code('(') if @nullable && junction == Junction::AND

		@toTestFragments(fragments, node, junction)

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(`).compile(node).code(')')
		}

		fragments.code(')') if @nullable && junction == Junction::AND
	} # }}}
	override toRouteTestFragments(fragments, node, argName, from, to, default, junction) { # {{{
		@resolve()

		fragments.code(`\($runtime.type(node)).isVarargs(\(argName), \(from), \(to), \(default), `)

		var literal = new Literal(false, node, node.scope(), 'value')

		if node._options.format.functions == 'es5' {
			fragments.code('function(value) { return ')

			if @nullable {
				@toTestFragments(fragments, literal, Junction::OR)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toTestFragments(fragments, literal, Junction::NONE)
			}

			fragments.code('; }')
		}
		else {
			fragments.code('value => ')

			if @nullable {
				@toTestFragments(fragments, literal, Junction::OR)

				fragments.code(` || \($runtime.type(node)).isNull(`).compile(literal).code(')')
			}
			else {
				@toTestFragments(fragments, literal, Junction::NONE)
			}
		}

		fragments.code(')')
	} # }}}
	private toTestFragments(fragments, node, junction) { # {{{
		if @nullable && junction == Junction::AND {
			fragments.code('(')
		}

		if tof ?= $runtime.typeof(@name, node) {
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

			var literal = new Literal(false, node, node.scope(), 'value')

			if node._options.format.functions == 'es5' {
				fragments.code('function(value) { return ')

				@parameters[0].toTestFragments(fragments, literal, Junction::NONE)

				fragments.code('; }')
			}
			else {
				fragments.code('value => ')

				@parameters[0].toTestFragments(fragments, literal, Junction::NONE)
			}
		}

		fragments.code(')')

		if @nullable {
			fragments.code(` || \($runtime.type(node)).isNull(`).compile(node).code(`)`)

			if junction == Junction::AND {
				fragments.code(')')
			}
		}
	} # }}}
	toTestFunctionFragments(fragments, node) { # {{{
		var unalias = @discardAlias()
		var name = unalias.name?() ?? @name
		var tof = $runtime.typeof(name, node)

		if !#@parameters && ?tof && !@nullable {
			fragments.code(`\(tof)`)
		}
		else if unalias.isDictionary() || unalias.isExclusion() || unalias.isFunction() || unalias.isUnion() {
			unalias.toTestFunctionFragments(fragments, node)
		}
		else {
			super.toTestFunctionFragments(fragments, node)
		}
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		@resolve()

		if @parameters.length == 0 && !@nullable {
			if var tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(value)`)

				return
			}
		}

		var mut subjunction = null
		if @nullable && junction == Junction::AND {
			fragments.code('(')

			subjunction = Junction::OR
		}

		var unalias = @discardAlias()

		if unalias.isDictionary() || unalias.isExclusion() || unalias.isFunction() || unalias.isFusion() || unalias.isUnion() {
			unalias.toTestFunctionFragments(fragments, node, subjunction ?? junction)
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
					throw new NotSupportedException()
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

			var literal = new Literal(false, node, node.scope(), 'value')

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
}
