class EnumExpression extends Expression {
	private {
		_enum
		_type: Type
	}
	analyse() { // {{{
		@enum = $compile.expression(@data.enum, this)
		@enum.analyse()
	} // }}}
	prepare() { // {{{
		@enum.prepare()
		
		@type = @enum.type().type()
	} // }}}
	translate() { // {{{
		@enum.translate()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@enum).code('.', @data.member.name)
	} // }}}
	type() => @type
}