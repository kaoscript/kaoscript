class ArrayExpression extends Expression {
	private {
		_flatten: Boolean	= false
		_values
	}
	analyse() { // {{{
		const es5 = @options.format.spreads == 'es5'

		@values = []
		for value in @data.values {
			@values.push(value = $compile.expression(value, this))

			value.analyse()

			if es5 && value is UnaryOperatorSpread {
				@flatten = true
			}
		}
	} // }}}
	prepare() { // {{{
		for value in @values {
			value.prepare()
		}
	} // }}}
	translate() { // {{{
		for value in @values {
			value.translate()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @flatten {
			CallExpression.toFlattenArgumentsFragments(fragments, @values)
		}
		else {
			fragments.code('[')

			for value, index in @values {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(value)
			}

			fragments.code(']')
		}
	} // }}}
	type() => @scope.reference('Array')
}

class ArrayRange extends Expression {
	private {
		_by				= null
		_from
		_to
		_type: Type
	}
	analyse() { // {{{
		@from = $compile.expression(@data.from ?? @data.then, this)
		@from.analyse()

		@to = $compile.expression(@data.to ?? @data.til, this)
		@to.analyse()

		if @data.by? {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
		}

	} // }}}
	prepare() { // {{{
		@type = Type.arrayOf(@scope.reference('Number'), @scope)

		@from.prepare()
		@to.prepare()
		@by.prepare() if @by?
	} // }}}
	translate() { // {{{
		@from.translate()
		@to.translate()

		if @by != null {
			@by.translate()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')

		fragments
			.code($runtime.helper(this), '.newArrayRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if @by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code(', ').compile(@by)
		}

		fragments.code($comma, @data.from?, $comma, @data.to?, ')')
	} // }}}
	type() => @type
}