class Variable {
	private {
		// true: can be altered by `impl` declaration
		_altereable: Boolean	= false
		_declaredType: Type		= Type.Any
		// true: the type can't be changed
		_definitive: Boolean	= false
		// true: the value can be set only once
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_predefined: Boolean	= false
		_realType: Type			= Type.Null
	}
	static {
		createPredefinedClass(name, scope) { // {{{
			const fn = new ClassConstructorType(scope)
			fn.addParameter(Type.Any, 0, Infinity)

			type = new ClassType(scope)
			type.flagAlien()
			type.flagPredefined()
			type.flagSealed()
			type.addConstructor(fn)

			return new Variable(name, true, true, type)
		} // }}}
		fromAST(data, scope) { // {{{
			switch data.kind {
				NodeKind::Identifier => {
					return scope.getVariable(data.name)
				}
				=> {
					console.error(data)
					throw new NotImplementedException()
				}
			}
		} // }}}
	}
	constructor()
	constructor(@name, @immutable, @predefined, declaredType = null) { // {{{
		if declaredType == null {
			@declaredType = Type.toNamedType(@name, Type.Any)
			@realType = Type.Null
		}
		else {
			@declaredType = Type.toNamedType(@name, declaredType)
			@realType = @declaredType
		}

		@definitive = @immutable
	} // }}}
	clone() { // {{{
		const clone = new Variable()

		clone._name = @name
		clone._immutable = @immutable
		clone._predefined = @predefined
		clone._declaredType = @declaredType
		clone._realType = @realType
		clone._definitive = @definitive

		return clone
	} // }}}
	flagDefinitive() { // {{{
		@definitive = true

		return this
	} // }}}
	getDeclaredType() => @declaredType
	getRealType() => @realType
	isDefinitive() => @definitive
	isImmutable() => @immutable
	isPredefined() => @predefined
	name() => @name
	prepareAlteration() { // {{{
		if (@declaredType.isRequired() || @declaredType.isAlien()) && !@altereable {
			@declaredType = @declaredType.clone()
			@realType = @declaredType
			@altereable = true
		}
	} // }}}
	setDeclaredType(@declaredType) { // {{{
		@declaredType = Type.toNamedType(@name, declaredType)

		@realType = @declaredType

		return this
	} // }}}
	setRealType(type: Type) { // {{{
		if type.isMorePreciseThan(@declaredType) {
			@realType = type
		}
		else {
			@realType = @declaredType
		}

		return this
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(@name)
	} // }}}
}