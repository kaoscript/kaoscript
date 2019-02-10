class ReferenceType extends Type {
	private {
		_name: String
		_nullable: Boolean = false
		_parameters: Array<Type>
		_predefined: Boolean = false
		_type: Type
		_variable: Variable
	}
	constructor(@scope, name: String, @nullable = false, @parameters = []) { // {{{
		super(scope)

		@name = $types[name] ?? name
	} // }}}
	discardAlias() { // {{{
		if @name == 'Any' {
			return Type.Any
		}
		else if (variable ?= @scope.getVariable(@name)) && (variable.type() is not ReferenceType || variable.name() != @name || variable.scope() != @scope) {
			return variable.type().discardAlias()
		}
		else {
			return this
		}
	} // }}}
	discardReference() { // {{{
		if @name == 'Any' {
			return Type.Any
		}
		else if (variable ?= @scope.getVariable(@name)) && (variable.type() is not ReferenceType || variable.name() != @name || variable.scope() != @scope) {
			return variable.type().discardReference()
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
	export(references, ignoreAlteration) { // {{{
		if @nullable {
			return {
				nullable: @nullable
				name: @name
			}
		}
		else {
			return @name
		}

	} // }}}
	flagExported() { // {{{
		if !this.isAny() && !this.isEnum() && !this.isVoid() {
			this.type().flagReferenced()
		}

		return super.flagExported()
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
	isAny() => @name == 'Any' || @name == 'any'
	isArray() => @name == 'Array' || @name == 'array'
	isAsync() => false
	isClass() => @name == 'Class' || @name == 'class'
	isEnum() => @name == 'Enum' || @name == 'enum'
	isFunction() => @name == 'Function' || @name == 'function'
	isInstanceOf(target: AnyType) => true
	isInstanceOf(target: ReferenceType) { // {{{
		if @name == target.name() || target.isAny() {
			return true
		}

		if (thisClass ?= this.discardAlias()) && thisClass is ClassType && (targetClass ?= target.discardAlias()) && targetClass is ClassType {
			return thisClass.isInstanceOf(targetClass)
		}

		return false
	} // }}}
	isNullable() => @nullable
	isNumber() => @name == 'Number' || @name == 'number'
	isObject() => @name == 'Object' || @name == 'object'
	isString() => @name == 'String' || @name == 'string'
	isVoid() => @name == 'Void' || @name == 'void'
	matchContentOf(b) { // {{{
		if this.isAny() {
			return b.isAny()
		}
		else if this.isEnum() {
			return b.isEnum()
		}
		else if this.isFunction() {
			return b.isFunction()
		}
		else {
			a = this.discardReference()
			b = b.discardReference()

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
	matchContentTo(b) { // {{{
		if this.isAny() {
			return b.isAny()
		}
		else if this.isEnum() {
			return b.isEnum()
		}
		else if this.isFunction() {
			return b.isFunction()
		}
		else {
			a = this.discardReference()
			b = b.discardReference()

			if a is ReferenceType {
				if b is ReferenceType {
					return a._name == b._name
				}
				else {
					return false
				}
			}
			else {
				return a.matchContentTo(b)
			}
		}
	} // }}}
	matchSignatureOf(value) { // {{{
		if value is ReferenceType {
			if this.isEnum() {
				return value.discardReference() is EnumType
			}
			else if value.isEnum() {
				return this.discardReference() is EnumType
			}
			else {
				return this.discardReference().matchSignatureOf(value.discardReference())
			}
		}
		else {
			return false
		}
	} // }}}
	name() => @name
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
		if !?@type {
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
			else if @variable ?= @scope.getVariable(@name) {
				@type = @variable.type()
				@predefined = @type.isPredefined()

				if @type is AliasType {
					@type = @type.type()
				}
				if @type is ReferenceType {
					@type = @type.type()
				}
			}
			else {
				console.log(this)
				throw new NotImplementedException()
			}
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		fragments.code(@name)
	} // }}}
	toMetadata(references, ignoreAlteration) { // {{{
		this.resolveType()

		if @predefined {
			return super.toMetadata(references, ignoreAlteration)
		}
		else if !@variable.type().isClass() {
			@referenceIndex = @variable.type().toMetadata(references, ignoreAlteration)
		}
		else if @type.isExported() {
			@referenceIndex = @variable.type().toMetadata(references, ignoreAlteration)
		}
		else if @type.isAlien() {
			return super.toMetadata(references, ignoreAlteration)
		}
		else {
			console.log(this)
			throw new NotImplementedException()
		}

		return @referenceIndex
	} // }}}
	toQuote() => `'\(@name)'`
	toReference(references, ignoreAlteration) { // {{{
		this.resolveType()

		if @predefined {
			return this.export(references, ignoreAlteration)
		}
		else if !@variable.type().isClass() {
			return super.toReference(references, ignoreAlteration)
		}
		else if @type.isExported() {
			if ignoreAlteration && @type.type().isAlteration() {
				return @type.type().toAlterationReference()
			}
			else {
				return super.toReference(references, ignoreAlteration)
			}
		}
		else if @type.isAlien() {
			return this.export(references, ignoreAlteration)
		}
		else {
			return this.export(references, ignoreAlteration)
		}
	} // }}}
	toTestFragments(fragments, node) { // {{{
		this.resolveType()

		if @variable.type().isAlias() {
			@variable.type().toTestFragments(fragments, node)
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