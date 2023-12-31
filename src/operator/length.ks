class UnaryOperatorLength extends UnaryOperatorExpression {
	private late {
		@native: Boolean	= false
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		if type.isAny() {
			@native = false
		}
		else if type.isArray() || type.isString() {
			@native = !type.isNullable()
		}
		else if type.canBeArray() || type.canBeString() || type.canBeObject() {
			@native = false
		}
		else {
			TypeException.throwNotIterable(@argument, this)
		}

		@type = @scope.reference('Number')

		if type.isObject() {
			pass
		}
		else if !@native {
			@type = @type.setNullable(true)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @native {
			fragments.compile(@argument).code(`.length`)
		}
		else {
			fragments
				.code(`\($runtime.helper(this)).length(`)
				.compile(@argument)
				.code(`)`)
		}
	} # }}}
	type() => @type
}
