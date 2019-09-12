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

		const named = @enum.type()
		if !named.type().hasElement(@data.member.name) {
			ReferenceException.throwNotDefinedEnumElement(@data.member.name, named.name(), this)
		}

		@type = named.type().type()
	} // }}}
	translate() { // {{{
		@enum.translate()
	} // }}}
	isUsingVariable(name) => false
	toFragments(fragments, mode) { // {{{
		fragments.compile(@enum).code('.', @data.member.name)
	} // }}}
	toQuote() => `\(@enum.toQuote())::\(@data.member.name))`
	type() => @type
}