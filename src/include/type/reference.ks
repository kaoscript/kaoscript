class ReferenceType extends Type {
	private {
		_name: String
		_nullable: Boolean = false
		_parameters: Array<Type>
		_predefined: Boolean = false
		_type: Type
		_variable: Variable
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const name = data.name is Number ? Type.fromMetadata(data.name, metadata, references, alterations, queue, scope, node).name() : data.name
			const parameters = ?data.parameters ? [Type.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters] : null

			return new ReferenceType(scope, name, data.nullable, parameters:Array)
		} // }}}
	}
	constructor(@scope, name: String, @nullable = false, @parameters = []) { // {{{
		super(scope)

		@name = $types[name] ?? name
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
	discardReference() { // {{{
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
		if b is not ReferenceType {
			return b.equals(this)
		}

		if @name != b._name || @nullable != b._nullable || @parameters.length != b._parameters.length {
			return false
		}

		// TODO: test @parameters

		return true
	} // }}}
	export(references, ignoreAlteration, name = @name) { // {{{
		if @nullable || @parameters.length != 0 {
			const export = {
				kind: TypeKind::Reference
				name: name.reference ?? name
			}

			if @nullable {
				export.nullable = @nullable
			}

			if @parameters.length != 0 {
				export.parameters = [parameter.toReference(references, ignoreAlteration) for parameter in @parameters]
			}

			return export
		}
		else {
			return name
		}
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if !this.isAny() && !this.isEnum() && !this.isVoid() {
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

		if type is ClassType {
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

			for parameter, i in @parameters {
				if i {
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
	isAlien() => this.type().isAlien()
	isAny() => @name == 'Any' || @name == 'any'
	isArray() => @name == 'Array' || @name == 'array'
	isAsync() => false
	isClass() => @name == 'Class' || @name == 'class'
	isEnum() => @name == 'Enum' || @name == 'enum'
	isExplicitlyExported() => this.type().isExplicitlyExported()
	isExportable() => this.isEnum() || this.type().isExportable()
	isExported() => this.type().isExported()
	isFunction() => @name == 'Function' || @name == 'function'
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
			const a = this.discardReference()
			const b = that.discardReference()

			return a.isMorePreciseThan(b)
		}
	} // }}}
	isNative() => $natives[@name] == true
	isNullable() => @nullable
	isNumber() => @name == 'Number' || @name == 'number'
	isObject() => @name == 'Object' || @name == 'object'
	isReference() => true
	isRequired() => this.type().isRequired()
	isString() => @name == 'String' || @name == 'string'
	isVoid() => @name == 'Void' || @name == 'void'
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
		else if this.isEnum() {
			return that.isEnum()
		}
		else if this.isFunction() {
			return that.isFunction()
		}
		else {
			const a = this.discardReference()
			const b = that.discardReference()

			if a is ReferenceType {
				if b is ReferenceType {
					return a._name == b._name
				}
				else {
					return false
				}
			}
			else {
				return a.matchContentOf(b)
			}
		}
	} // }}}
	matchSignatureOf(value, matchables) { // {{{
		if value is ReferenceType {
			if this.isEnum() {
				return value.discardReference() is EnumType
			}
			else if value.isEnum() {
				return this.discardReference() is EnumType
			}
			else {
				return this.discardReference().matchSignatureOf(value.discardReference(), matchables)
			}
		}
		else if value.isObject() && this.type().isClass() {
			return @type.type().matchInstanceWith(value, matchables)
		}
		else {
			return value.isAny()
		}
	} // }}}
	name(): String => @name
	parameter(index: Number = 0) { // {{{
		if index >= @parameters.length {
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
			if this.isAny() {
				@type = Type.Any
				@predefined = true
			}
			else if this.isEnum() {
				@predefined = true
			}
			else if this.isVoid() {
				@type = Type.Void
				@predefined = true
			}
			else if @variable ?= @scope.getVariable(@name, -1) {
				@type = @variable.getRealType()
				@predefined = @type.isPredefined()

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
	} // }}}
	setNullable(nullable: Boolean): ReferenceType { // {{{
		if @nullable == nullable {
			return this
		}
		else {
			return @scope.reference(@name, nullable)
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		fragments.code(@name)
	} // }}}
	toMetadata(references, ignoreAlteration) { // {{{
		this.resolveType()

		if @referenceIndex != -1 {
			return @referenceIndex
		}
		else if @predefined {
			return super.toMetadata(references, ignoreAlteration)
		}
		else if !@variable.getRealType().isClass() {
			@referenceIndex = @variable.getRealType().toMetadata(references, ignoreAlteration)
		}
		else if @type.isAlien() && @type.isPredefined() {
			return super.toMetadata(references, ignoreAlteration)
		}
		else {
			const reference = @variable.getRealType().toReference(references, ignoreAlteration)

			@referenceIndex = references.length

			references.push(reference)
		}

		return @referenceIndex
	} // }}}
	toQuote() => `'\(@name)'`
	toReference(references, ignoreAlteration) { // {{{
		this.resolveType()

		if @predefined {
			return this.export(references, ignoreAlteration)
		}
		else if !@variable.getDeclaredType().isClass() {
			return super.toReference(references, ignoreAlteration)
		}
		else if @type.isExplicitlyExported() {
			if ignoreAlteration && @type.isAlteration() {
				return this.export(references, ignoreAlteration, @type.toAlterationReference(references, ignoreAlteration))
			}
			else {
				return this.export(references, ignoreAlteration, @type.toReference(references, ignoreAlteration))
			}
		}
		else if this.isNative() {
			return this.export(references, ignoreAlteration)
		}
		else {
			return this.export(references, ignoreAlteration, @type.toReference(references, ignoreAlteration))
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
				fragments.code(`\($runtime.type(node)).is(`).compile(node).code(`, `)

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