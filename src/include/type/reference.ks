class ReferenceType extends Type {
	private {
		_name: String
		_nullable: Boolean = false
		_parameters: Array<ReferenceType>
		_predefined: Boolean = false
		_type: Type
		_variable: Variable
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
	} // }}}
	canBeBoolean() => this.isUnion() ? @type.canBeBoolean() : super()
	canBeNumber(any = true) => this.isUnion() ? @type.canBeNumber(any) : super(any)
	canBeString(any = true) => this.isUnion() ? @type.canBeString(any) : super(any)
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
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
	equals(b?): Boolean { // {{{
		if b == null {
			return false
		}
		else if b is not ReferenceType {
			return b.equals(this)
		}
		else if @name != b._name || @nullable != b._nullable || @parameters.length != b._parameters.length {
			return false
		}

		// TODO: test @parameters

		return true
	} // }}}
	export(references, mode, name = @name) { // {{{
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
	getProperty(name: String): Type { // {{{
		if this.isAny() {
			return Type.Any
		}

		let type := this.type()

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
	isAny() => @name == 'Any' || this.type().isAny()
	isArray() => @name == 'Array' || this.type().isArray()
	isAsync() => false
	isBoolean() => @name == 'Boolean' || this.type().isBoolean()
	isClass() => @name == 'Class'
	isEnum() => @name == 'Enum' || this.type().isEnum()
	isExhaustive() => this.type().isExhaustive()
	isExplicitlyExported() => this.type().isExplicitlyExported()
	isExportable() => this.type().isExportable()
	isExported() => this.type().isExported()
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
		else if mode & MatchingMode::Exact != 0 {
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
				if this.isEnum() {
					return value.discardReference() is EnumType
				}
				else if value.isEnum() {
					return this.discardReference() is EnumType
				}
				else {
					return this.discardReference():Type.isMatching(value.discardReference():Type, mode)
				}
			}
			else if value.isObject() && this.type().isClass() {
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
		else if that.isNullable() && !@nullable {
			return true
		}
		else {
			const a: Type = this.discardReference()
			const b: Type = that.discardReference()

			return a.isMorePreciseThan(b)
		}
	} // }}}
	isNative() => $natives[@name] == true
	isNamespace() => @name == 'Namespace' || this.type().isNamespace()
	isNullable() => @nullable
	isNumber() => @name == 'Number' || this.type().isNumber()
	isObject() => @name == 'Object' || this.type().isObject()
	isReference() => true
	isRequired() => this.type().isRequired()
	isString() => @name == 'String' || this.type().isString()
	isVoid() => @name == 'Void' || this.type().isVoid()
	isUnion() => this.type().isUnion()
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
			const a: Type = this.discardReference()
			const b: Type = that.discardReference()

			if a is ReferenceType || b is ReferenceType {
				return false
			}

			if that is ReferenceType && that.hasParameters() {
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
	matchSignatureOf(value, matchables) { // {{{
		if value is ReferenceType {
			if value.name() == 'Enum' {
				return this.type().isEnum()
			}
			else if value.name() == 'Namespace' {
				return this.type().isNamespace()
			}
			else {
				return this.discardReference():Type.matchSignatureOf(value.discardReference():Type, matchables)
			}
		}
		else if value.isObject() && this.type().isClass() {
			return @type.type().matchInstanceWith(value, matchables)
		}
		else if value is AnyType {
			return this.discardReference():Type.matchSignatureOf(value, matchables)
		}
		else {
			return false
		}
	} // }}}
	name(): String => @name
	parameter(index: Number = 0) { // {{{
		if @parameters.length == 0 && this.isArray() {
			return this.type().parameter()
		}
		else if index >= @parameters.length {
			return Type.Any
		}
		else {
			return @parameters[index]
		}
	} // }}}
	parameters() => @parameters
	reassign(@name, @scope) => this
	resolveType() { // {{{
		if !?@type || @type.isCloned() {
			if @name == 'Any' {
				@type = Type.Any
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
			if mode & ExportMode::IgnoreAlteration != 0 && @type.isAlteration() {
				return this.export(references, mode, @type:ClassType.toAlterationReference(references, mode))
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
	toTestFragments(fragments, node) { // {{{
		this.resolveType()

		if @variable.getRealType().isAlias() {
			@variable.getRealType().toTestFragments(fragments, node)
		}
		else {
			if tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(`).compile(node)
			}
			else {
				fragments.code(`\($runtime.type(node)).`)

				if @type.isClass() {
					fragments.code(`isInstance`)
				}
				else {
					fragments.code(`isEnumMember`)
				}

				fragments.code(`(`).compile(node).code(`, `)

				if @type is NamedType {
					fragments.code(@type.path())
				}
				else {
					fragments.code(@name)
				}
			}

			for parameter in @parameters {
				fragments.code($comma)

				parameter.toFragments(fragments, node)
			}

			fragments.code(')')
		}
	} // }}}
	type() { // {{{
		this.resolveType()

		return @type
	} // }}}
}