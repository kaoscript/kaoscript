class Variable {
	private late {
		// true: can be altered by `impl` declaration
		@altereable: Boolean		= false
		@class: Boolean				= false
		@complete: Boolean			= false
		@declaration: Statement?	= null
		@declaredType: Type			= AnyType.NullableUnexplicit
		// true: the type can't be changed
		@definitive: Boolean		= false
		// true: the value can be set only once
		@immutable: Boolean			= true
		@initialized: Boolean		= false
		@module: Boolean			= false
		@name: String
		@new: Boolean				= true
		@lateInit: Boolean			= false
		@predefined: Boolean		= false
		@realType: Type				= Type.Null
		@secureName: String
	}
	static {
		createPredefinedClass(name: String, features: ClassFeature? = null, scope: Scope): Variable { # {{{
			type = ClassType.new(scope)
			type.flagAlien()
			type.flagComplete()
			type.flagPredefined()
			type.flagSystem()

			if ?features {
				type.features(features)
			}

			return Variable.new(name, true, true, type)
		} # }}}
		fromAST(data, scope) { # {{{
			match data.kind {
				NodeKind.Identifier {
					return scope.getVariable(data.name)
				}
				else {
					console.error(data)
					throw NotImplementedException.new()
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
		var clone = Variable.new()

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
	flagMutating() { # {{{
		if @declaredType.hasMutableAccess() {
			@realType = @declaredType
		}
	} # }}}
	getDeclaredType() => @declaredType
	getRealType() => @realType
	getSecureName() => @secureName
	hasDeclaration() => ?@declaration
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
