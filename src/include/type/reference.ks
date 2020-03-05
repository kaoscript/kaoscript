const $weightTOFs = { // {{{
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
} // }}}

class ReferenceType extends Type {
	private lateinit {
		_type: Type
		_variable: Variable
	}
	private {
		_name: String
		_nullable: Boolean					= false
		_parameters: Array<ReferenceType>
		_predefined: Boolean				= false
		_spread: Boolean					= false
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const name = data.name is Number ? Type.fromMetadata(data.name, metadata, references, alterations, queue, scope, node).name() : data.name
			const parameters = ?data.parameters ? [Type.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters] : null

			return new ReferenceType(scope, name, data.nullable, parameters)
		} // }}}
		toQuote(name, nullable, parameters) { // {{{
			const fragments = [name]

			if parameters.length != 0 {
				fragments.push('<')

				for const parameter, index in parameters {
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
		} // }}}
	}
	constructor(@scope, name: String, @nullable = false, @parameters = []) { // {{{
		super(scope)

		@name = $types[name] ?? name

		if @name == 'Null' {
			@nullable = true
		}
	} // }}}
	canBeBoolean() => this.isUnion() ? @type.canBeBoolean() : super()
	canBeNumber(any = true) => this.isUnion() ? @type.canBeNumber(any) : super(any)
	canBeString(any = true) => this.isUnion() ? @type.canBeString(any) : super(any)
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	compareTo(value: Type) { // {{{
		if this == value {
			return 0
		}
		else if this.matchContentOf(value) {
			return -1
		}
		else if value.matchContentOf(this) {
			return 1
		}
		else if this.isTypeOf() {
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
		else if this.type().isClass() {
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
	} // }}}
	discard() => this.discardReference()?.discard()
	discardAlias() { // {{{
		if @name == 'Any' {
			return Type.Any
		}
		else if (variable ?= @scope.getVariable(@name)) && (variable.getRealType() is not ReferenceType || variable.name() != @name || variable.scope() != @scope) {
			return variable.getRealType().discardAlias()
		}
		else {
			return this
		}
	} // }}}
	discardReference(): Type? { // {{{
		if @name == 'Any' {
			return @nullable ? AnyType.NullableExplicit : AnyType.Explicit
		}
		else if (variable ?= @scope.getVariable(@name, -1)) && (type ?= variable.getRealType()) && (type is not ReferenceType || variable.name() != @name || type.scope() != @scope) {
			return type.discardReference()
		}
		else {
			return null
		}
	} // }}}
	discardSpread() { // {{{
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
	} // }}}
	export(references, mode) { // {{{
		if @parameters.length == 0 {
			return @nullable ? `\(@name)?` : @name
		}
		else {
			const export = {
				kind: TypeKind::Reference
				name: @name
			}

			if @nullable {
				export.nullable = @nullable
			}

			if @parameters.length != 0 {
				export.parameters = [parameter.toReference(references, mode) for parameter in @parameters]
			}

			return export
		}
	} // }}}
	export(references, mode, name) { // {{{
		if @nullable || @parameters.length != 0 {
			const export = {
				kind: TypeKind::Reference
				name: name.reference ?? name
			}

			if @nullable {
				export.nullable = @nullable
			}

			if @parameters.length != 0 {
				export.parameters = [parameter.toReference(references, mode) for parameter in @parameters]
			}

			return export
		}
		else {
			return name
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if !this.isAny() && !this.isVoid() {
			this.type().flagExported(explicitly).flagReferenced()
		}

		return super.flagExported(explicitly)
	} // }}}
	flagSealed(): ReferenceType { // {{{
		const type = new ReferenceType(@scope, @name, @nullable, @parameters)

		type._sealed = true

		return type
	} // }}}
	flagSpread(): ReferenceType { // {{{
		const type = new ReferenceType(@scope, @name, @nullable, @parameters)

		type._spread = true

		return type
	} // }}}
	getProperty(name: String): Type { // {{{
		if this.isAny() {
			return AnyType.NullableUnexplicit
		}

		let type: Type = this.type()

		if type is NamedType {
			type = type.type()
		}

		if type.isClass() {
			return type.getInstanceProperty(name)
		}
		else {
			return type.getProperty(name)
		}
	} // }}}
	hashCode(): String { // {{{
		let hash = @name

		if @parameters.length != 0 {
			hash += '<'

			for const parameter, i in @parameters {
				if i != 0 {
					hash += ','
				}

				hash += parameter.hashCode()
			}

			hash += '>'
		}

		if @nullable {
			hash += '?'
		}

		return hash
	} // }}}
	hasParameters() => @parameters.length != 0
	isAlien() => this.type().isAlien()
	isAny() => @name == 'Any'
	isArray() => @name == 'Array' || this.type().isArray()
	isAssignableToVariable(value, anycast, nullcast, downcast) { // {{{
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
		else if value is ReferenceType && @name == value.name() {
			if @nullable {
				return nullcast || value.isNullable()
			}
			else {
				return true
			}
		}
		else if value is UnionType {
			return this.type().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
		else if @name == 'Class' {
			return value.isClass()
		}
		else if @name == 'Struct' {
			return value.isStruct()
		}
		else if @name == 'Tuple' {
			return value.isTuple()
		}
		else {
			return this.type().isAssignableToVariable(value, anycast, nullcast, downcast)
		}
	} // }}}
	isAsync() => false
	isBoolean() => @name == 'Boolean' || this.type().isBoolean()
	isClass() => @name == 'Class'
	override isComparableWith(type) => this.type().isComparableWith(type)
	isDictionary() => @name == 'Dictionary' || this.type().isDictionary()
	isEnum() => @name == 'Enum' || this.type().isEnum()
	isExhaustive() => this.type().isExhaustive()
	isExplicit() => this.type().isExplicit()
	isExplicitlyExported() => this.type().isExplicitlyExported()
	isExportable() => this.type().isExportable()
	isExported() => this.type().isExported()
	isExportingFragment() => !this.isVirtual()
	isFunction() => @name == 'Function' || this.type().isFunction()
	isHybrid() => this.type().isHybrid()
	isInstanceOf(target: AnyType) => true
	isInstanceOf(target: ReferenceType) { // {{{
		if @name == target.name() || target.isAny() {
			return true
		}

		if const type = target.discardAlias() {
			if type is ClassType {
				if (thisClass ?= this.discardAlias()) && thisClass is ClassType {
					return thisClass.isInstanceOf(type)
				}
			}
			else if type is UnionType {
				for const type in type.types() {
					if this.isInstanceOf(type) {
						return true
					}
				}
			}
		}

		return false
	} // }}}
	isInstanceOf(target: UnionType) { // {{{
		for type in target.types() {
			if this.isInstanceOf(type) {
				return true
			}
		}

		return false
	} // }}}
	isMatching(value: Type, mode: MatchingMode) { // {{{
		if this == value {
			return true
		}
		else if mode ~~ MatchingMode::Exact {
			if value is ReferenceType {
				if @name != value._name || @nullable != value._nullable || @parameters.length != value._parameters.length {
					return false
				}

				// TODO: test @parameters

				return true
			}
			else {
				return value.isMatching(this, mode)
			}
		}
		else {
			if value is ReferenceType {
				if $virtuals[value.name()] {
					return this.type().canBeVirtual(value.name())
				}
				else {
					return @scope.isMatchingType(this.discardReference()!?, value.discardReference()!?, mode)
				}
			}
			else if value.isDictionary() && this.type().isClass() {
				return @type.type().matchInstanceWith(value, [])
			}
			else if value is UnionType {
				for const type in value.types() {
					if this.isMatching(type, mode) {
						return true
					}
				}

				return false
			}
			else {
				return value.isAny()
			}
		}
	} // }}}
	isMorePreciseThan(that: Type) { // {{{
		if that.isAny() {
			return !this.isAny() || (that.isNullable() && !@nullable)
		}
		else if this.isAny() {
			return false
		}
		else if that is ReferenceType && that.name() == @name {
			return that.isNullable() && !@nullable
		}
		else {
			const a: Type = this.discardReference()!?
			const b: Type = that.discardReference()!?

			return a.isMorePreciseThan(b)
		}
	} // }}}
	isNamespace() => @name == 'Namespace' || this.type().isNamespace()
	isNative() => $natives[@name] == true
	isNever() => @name == 'Never' || this.type().isNever()
	isNull() => @name == 'Null'
	isNullable() => @nullable || @name == 'Null'
	isNumber() => @name == 'Number' || this.type().isNumber()
	isObject() => @name == 'Object' || (this.type().isClass() && !(@name == 'Array' || @name == 'Boolean' || @name == 'Dictionary' || @name == 'Enum' || @name == 'Function' || @name == 'Namespace' || @name == 'Number' || @name == 'String' || @name == 'Struct' || @name == 'Tuple'))
	isReference() => true
	isReducible() => true
	isRequired() => this.type().isRequired()
	isSpread() => @spread
	isString() => @name == 'String' || this.type().isString()
	isStruct() => @name == 'Struct' || this.type().isStruct()
	isTuple() => @name == 'Tuple' || this.type().isTuple()
	isTypeOf(): Boolean => $typeofs[@name]
	isUnion() => this.type().isUnion()
	isVoid() => @name == 'Void' || this.type().isVoid()
	matchContentOf(that: Type) { // {{{
		if this == that {
			return true
		}
		else if @nullable && !that.isNullable() {
			return false
		}
		else if that.isAny() {
			return true
		}
		else if this.isFunction() {
			return that.isFunction()
		}
		else {
			const a: Type = this.discardReference()!?
			const b: Type = that.discardReference()!?

			if a is ReferenceType || b is ReferenceType {
				return false
			}

			if that is ReferenceType && that.hasParameters() {
				if @parameters.length == 0 {
					return true
				}

				const parameters = that.parameters()

				if @parameters.length != parameters.length || !a.matchContentOf(b) {
					return false
				}

				for const parameter, index in @parameters {
					if !parameter.matchContentOf(parameters[index]) {
						return false
					}
				}

				return true
			}
			else {
				return a.matchContentOf(b)
			}
		}
	} // }}}
	name(): String => @name
	parameter(index: Number = 0) { // {{{
		if @parameters.length == 0 && this.isArray() {
			return this.type().parameter()
		}
		else if index >= @parameters.length {
			return AnyType.NullableUnexplicit
		}
		else {
			return @parameters[index]
		}
	} // }}}
	parameters() => @parameters
	reassign(@name, @scope) => this
	reduce(type: Type) { // {{{
		if this == type {
			return this
		}
		else {
			return @scope.reference(this.type().reduce(type))
		}
	} // }}}
	resolveType() { // {{{
		if !?@type || @type.isCloned() {
			if @name == 'Any' {
				@type = Type.Any
				@predefined = true
			}
			else if @name == 'Never' {
				@type = Type.Never
				@predefined = true
			}
			else if @name == 'Null' {
				@type = Type.Null
				@predefined = true
			}
			else if @name == 'Void' {
				@type = Type.Void
				@predefined = true
			}
			else {
				const names = @name.split('.')

				if names.length == 1 {
					if @variable ?= @scope.getVariable(@name, -1) {
						@type = @variable.getRealType()
						@predefined = @variable.isPredefined() || @type.isPredefined()

						if @type is AliasType {
							@type = @type.type()
						}
						if @type is ReferenceType {
							@type = @type.type()
						}
					}
					else {
						console.info(this)
						throw new NotImplementedException()
					}
				}
				else {
					let type = @scope.getVariable(names[0], -1)?.getRealType()
					if !?type {
						console.info(this)
						throw new NotImplementedException()
					}

					for const name in names from 1 {
						if type !?= type.getProperty(name) {
							console.info(this)
							throw new NotImplementedException()
						}
					}

					@type = type
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
	} // }}}
	setNullable(nullable: Boolean): ReferenceType { // {{{
		if @nullable == nullable {
			return this
		}
		else {
			return @scope.reference(@name, nullable, [...@parameters])
		}
	} // }}}
	toCastFragments(fragments) { // {{{
		if this.isTypeOf() {
			fragments.code($comma, 'null', $comma, $quote(@name))
		}
		else {
			this.resolveType()

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
	} // }}}
	toExportFragment(fragments, name, variable) { // {{{
		if !this.isVirtual() {
			fragments.newLine().code(`\(name): `).compile(variable).done()
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		fragments.code(@name)
	} // }}}
	toMetadata(references, mode) { // {{{
		this.resolveType()

		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if @predefined {
			return super.toMetadata(references, mode)
		}
		else if !@variable.getRealType().isClass() {
			@referenceIndex = @variable.getRealType().toMetadata(references, mode)
		}
		else if @type.isAlien() && @type.isPredefined() {
			return super.toMetadata(references, mode)
		}
		else {
			const reference = @variable.getRealType().toReference(references, mode)

			@referenceIndex = references.length

			references.push(reference)
		}

		return @referenceIndex
	} // }}}
	toQuote() => ReferenceType.toQuote(@name, @nullable, @parameters)
	toReference(references, mode) { // {{{
		this.resolveType()

		if @predefined {
			return this.export(references, mode)
		}
		else if !@variable.getDeclaredType().isClass() {
			return super.toReference(references, mode)
		}
		else if @type.isExplicitlyExported() {
			if mode ~~ ExportMode::IgnoreAlteration && @type.isAlteration() {
				return this.export(references, mode, @type.toAlterationReference(references, mode))
			}
			else {
				return this.export(references, mode, @type.toReference(references, mode))
			}
		}
		else if this.isNative() {
			return this.export(references, mode)
		}
		else {
			return this.export(references, mode, @type.toReference(references, mode))
		}
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		this.resolveType()

		if @type.isAlias() || @type.isUnion() || @type.isExclusion() {
			@type.toPositiveTestFragments(fragments, node)
		}
		else {
			if tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(`).compile(node)
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

				fragments.code(`(`).compile(node).code(`, `)

				if @type is NamedType {
					fragments.code(@type.path())
				}
				else {
					fragments.code(@name)
				}
			}

			fragments.code(')')
		}
	} // }}}
	type() { // {{{
		this.resolveType()

		return @type
	} // }}}
}