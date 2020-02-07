class EnumExpression extends Expression {
	private lateinit {
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
		if !named.type().isEnum() {
			TypeException.throwNotEnum(@data.enum.name, this)
		}
		else if !named.type().hasElement(@data.member.name) {
			ReferenceException.throwNotDefinedEnumElement(@data.member.name, named.name(), this)
		}

		@type = named.reference(@scope)
	} // }}}
	translate() { // {{{
		@enum.translate()
	} // }}}
	isUsingVariable(name) => false
	toFragments(fragments, mode) { // {{{
		fragments.compile(@enum).code('.', @data.member.name)
	} // }}}
	toQuote() => `\(@enum.toQuote())::\(@data.member.name)`
	type() => @type
}