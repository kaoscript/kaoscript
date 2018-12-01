class Variable {
	private {
		// true: can be altered by `impl` declaration
		_altereable: Boolean	= false
		// true: the value can be set only once
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_predefined: Boolean	= false
		_type: Type				= Type.Any
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
	constructor(@name, @immutable, @predefined, @type = Type.Any) { // {{{
		if type is AliasType || type is ClassType || type is EnumType || type is NamespaceType {
			@type = new NamedType(@name, type)
		}
		else {
			@type = type
		}
	} // }}}
	isImmutable() => @immutable
	isPredefined() => @predefined
	name() => @name
	prepareAlteration() { // {{{
		if (@type.isRequired() || @type.isAlien()) && !@altereable {
			@type = @type.clone()
			@altereable = true
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(@name)
	} // }}}
	type() => @type
	type(@type) { // {{{
		if type is AliasType || type is ClassType || type is EnumType || type is NamespaceType {
			@type = new NamedType(@name, type)
		}
		else {
			@type = type
		}

		return this
	} // }}}
}