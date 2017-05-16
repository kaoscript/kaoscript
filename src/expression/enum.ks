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
		
		const enum = @enum.type()
		if !enum.hasElement(@data.member.name) {
			ReferenceException.throwNotDefinedEnumElement(@data.member.name, enum.name(), this)
		}
		
		@type = enum.type()
	} // }}}
	translate() { // {{{
		@enum.translate()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@enum).code('.', @data.member.name)
	} // }}}
	type() => @type
}