class Variable {
	private {
		// true: can be altered by `impl` declaration
		_altereable: Boolean	= false
		// true: the value can be set only once
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_predefined: Boolean	= false
		_required: Boolean		= false
		_type: Type				= Type.Any
	}
	static {
		createPredefinedClass(name, scope) { // {{{
			const fn = new ClassConstructorType()
			fn.addParameter(Type.Any, 0, Infinity)

			type = new ClassType(name, scope)
			type.alienize()
			type.seal()
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
	constructor(@name, @immutable, @type = Type.Any)
	constructor(@name, @immutable, @predefined, @type)
	isImmutable() => @immutable
	isPredefined() => @predefined
	isRequired() => @required
	name() => @name
	prepareAlteration() { // {{{
		if @required && !@altereable {
			@type = @type.replicate(@name)
			@altereable = true
		}
	} // }}}
	require() { // {{{
		@required = true
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(@name)
	} // }}}
	type() => @type
	type(@type) => this
}