enum VariableKind {
}

class Variable {
	private {
		_immutable: Boolean		= true
		_name: String
		_new: Boolean			= true
		_required: Boolean		= false
		_type: Type				= Type.Any
	}
	static {
		import(name: String, data, node) => new Variable(name, true, Type.import(name, data, node))
	}
	constructor()
	constructor(@name, @immutable, @type = Type.Any)
	export() => @type.export()
	isImmutable() => @immutable
	name() => @name
	require() { // {{{
		@required = true
	} // }}}
	type() => @type
	type(@type) => this
}