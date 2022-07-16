class EnumExpression extends Expression {
	private lateinit {
		_enum
		_enumCasting: Boolean	= false
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
		else if !named.type().hasVariable(@data.member.name) {
			ReferenceException.throwNotDefinedEnumElement(@data.member.name, named.name(), this)
		}

		@type = named.reference(@scope)
	} // }}}
	translate() { // {{{
		@enum.translate()
	} // }}}
	isUsingVariable(name) => false
	toArgumentFragments(fragments, type: Type, mode: Mode) { // {{{
		this.toFragments(fragments, mode)

		if !(type.isAny() || type.isEnum()) {
			fragments.code('.value')
		}
	} // }}}
	toCastingFragments(fragments, mode) { // {{{
		this.toFragments(fragments, mode)

		fragments.code('.value')
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(@enum).code('.', @data.member.name)

		if @enumCasting {
			fragments.code('.value')
		}
	} // }}}
	toQuote() => `\(@enum.toQuote())::\(@data.member.name)`
	type() => @type
	validateType(type: Type) { // {{{
		if !type.isAny() && !type.isEnum() {
			@enumCasting = true
		}
	} // }}}
}
