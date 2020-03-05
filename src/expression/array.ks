class ArrayExpression extends Expression {
	private lateinit {
		_flatten: Boolean	= false
		_type: Type
		_values: Array		= []
	}
	analyse() { // {{{
		const es5 = @options.format.spreads == 'es5'

		for const data in @data.values {
			const value = $compile.expression(data, this)

			value.analyse()

			if es5 && value is UnaryOperatorSpread {
				@flatten = true
			}

			@values.push(value)
		}
	} // }}}
	prepare() { // {{{
		let type = null

		for const value, index in @values {
			value.prepare()

			if index == 0 {
				type = value.type().discardSpread()
			}
			else if type != null {
				if !type.equals(value.type().discardSpread()) {
					type = null
				}
			}
		}

		if type == null {
			@type = @scope.reference('Array')
		}
		else {
			@type = Type.arrayOf(type, @scope)
		}
	} // }}}
	translate() { // {{{
		for value in @values {
			value.translate()
		}
	} // }}}
	isMatchingType(type: Type) { // {{{
		if @values.length == 0 {
			return type.isAny() || type.isArray()
		}
		else {
			return @type.matchContentOf(type)
		}
	} // }}}
	isUsingVariable(name) { // {{{
		for const value in @values {
			if value.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	override listUsedVariables(scope, variables) { // {{{
		for const value in @values {
			value.listUsedVariables(scope, variables)
		}

		return variables
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @flatten {
			if @values.length == 1 {
				fragments.code('[].concat(').compile(@values[0].argument()).code(')')
			}
			else {
				CallExpression.toFlattenArgumentsFragments(fragments, @values)
			}
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
	type() => @type
}

class ArrayRange extends Expression {
	private lateinit {
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
	isUsingVariable(name) => @from.isUsingVariable(name) || @to.isUsingVariable(name) || @by?.isUsingVariable(name)
	override listUsedVariables(scope, variables) { // {{{
		@from.listUsedVariables(scope, variables)
		@to.listUsedVariables(scope, variables)
		@by?.listUsedVariables(scope, variables)

		return variables
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