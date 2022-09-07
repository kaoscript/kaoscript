class Variable {
	private late {
		// true: can be altered by `impl` declaration
		_altereable: Boolean		= false
		_class: Boolean				= false
		_complete: Boolean			= false
		_declaration: Statement?	= null
		_declaredType: Type			= AnyType.NullableUnexplicit
		// true: the type can't be changed
		_definitive: Boolean		= false
		// true: the value can be set only once
		_immutable: Boolean			= true
		_initialized: Boolean		= false
		_module: Boolean			= false
		_name: String
		_new: Boolean				= true
		_lateInit: Boolean			= false
		_predefined: Boolean		= false
		_realType: Type				= Type.Null
		_secureName: String
	}
	static {
		createPredefinedClass(name, scope) { # {{{
			type = new ClassType(scope)
			type.flagAlien()
			type.flagPredefined()
			type.flagSystem()

			return new Variable(name, true, true, type)
		} # }}}
		fromAST(data, scope) { # {{{
			switch data.kind {
				NodeKind::Identifier => {
					return scope.getVariable(data.name)
				}
				=> {
					console.error(data)
					throw new NotImplementedException()
				}
			}
		} # }}}
	}
	constructor()
	constructor(@name, @immutable, @predefined, declaredType: Type? = null, initialized: Boolean = false) { # {{{
		if declaredType == null {
			if initialized {
				@realType = @declaredType
			}
		}
		else {
			@declaredType = Type.toNamedType(@name, declaredType)

			if @predefined || initialized || !declaredType.isReference() {
				@realType = @declaredType
			}
		}

		@definitive = @immutable
		@secureName = @name
		@module = @predefined
	} # }}}
	clone() { # {{{
		var clone = new Variable()

		clone._name = @name
		clone._secureName = @secureName
		clone._immutable = @immutable
		clone._predefined = @predefined
		clone._declaredType = @declaredType
		clone._realType = @realType
		clone._definitive = @definitive
		clone._initialized = @initialized
		clone._lateInit = @lateInit

		return clone
	} # }}}
	declaration() => @declaration
	declaration(@declaration) => this
	flagClassStatement() { # {{{
		@class = true

		return this
	} # }}}
	flagDefinitive() { # {{{
		@definitive = true

		return this
	} # }}}
	flagLateInit() { # {{{
		@lateInit = true
		@initialized = false
		@definitive = false

		return this
	} # }}}
	flagModule() { # {{{
		@module = true

		return this
	} # }}}
	getDeclaredType() => @declaredType
	getRealType() => @realType
	getSecureName() => @secureName
	isAltereable() => @altereable
	isClassStatement() => @class
	isComplete() => @complete
	isDefinitive() => @definitive
	isImmutable() => @immutable
	isInitialized() => @initialized
	isLateInit() => @lateInit
	isModule() => @module
	isPredefined() => @predefined
	isRenamed() => @name != @secureName
	name() => @name
	prepareAlteration() { # {{{
		if (@declaredType.isRequired() || @declaredType.isAlien()) && !@altereable {
			@declaredType = @declaredType.clone()
			@realType = @declaredType
			@altereable = true
		}
	} # }}}
	renameAs(@secureName)
	setComplete(@complete) => this
	setDeclaredType(@declaredType, initialize: Boolean = true) { # {{{
		@declaredType = Type.toNamedType(@name, declaredType)

		if initialize {
			@initialized = true

			@realType = @declaredType
		}

		return this
	} # }}}
	setDefinitive(@definitive) => this
	setRealType(type: Type) { # {{{
		@initialized = true

		if type.isMorePreciseThan(@declaredType) {
			@realType = type
		}
		else {
			@realType = @declaredType
		}

		return this
	} # }}}
	setRealType(type: Type, absolute: Boolean, scope: Scope) { # {{{
		if absolute {
			@initialized = true

			if type.isMorePreciseThan(@declaredType) {
				@realType = type
			}
			else {
				@realType = @declaredType
			}
		}
		else {
			if @realType.isNull() {
				@realType = type.setNullable(true)
			}
			else if @realType.isMorePreciseThan(type) {
				@realType = Type.union(scope, type, @realType)
			}
			else {
				@realType = @declaredType
			}
		}

		return this
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.code(@secureName)
	} # }}}
}
