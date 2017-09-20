class Variable {
	private {
		_altereable: Boolean	= false
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_required: Boolean		= false
		_type: Type				= Type.Any
	}
	static {
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
	isImmutable() => @immutable
	name() => @name
	prepareAlteration() { // {{{
		if @required && !@altereable {
			@type = @type.replicate()
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