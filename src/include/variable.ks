class Variable {
	private {
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_required: Boolean		= false
		_type: Type				= Type.Any
	}
	constructor()
	constructor(@name, @immutable, @type = Type.Any)
	isImmutable() => @immutable
	name() => @name
	require() { // {{{
		@required = true
	} // }}}
	type() => @type
	type(@type) => this
}