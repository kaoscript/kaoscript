class Variable {
	private {
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
	require() { // {{{
		@required = true
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code(@name)
	} // }}}
	type() => @type
	type(@type) => this
}