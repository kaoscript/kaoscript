class ArrayExpression extends Expression {
	private late {
		_flatten: Boolean	= false
		_type: Type
		_values: Array		= []
	}
	analyse() { # {{{
		var es5 = @options.format.spreads == 'es5'

		for var data in @data.values {
			var value = $compile.expression(data, this)

			value.analyse()

			if es5 && value is UnaryOperatorSpread {
				@flatten = true
			}

			@values.push(value)
		}
	} # }}}
	prepare() { # {{{
		var dyn type = null

		for var value, index in @values {
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
	} # }}}
	translate() { # {{{
		for value in @values {
			value.translate()
		}
	} # }}}
	isMatchingType(type: Type) { # {{{
		if @values.length == 0 {
			return type.isAny() || type.isArray()
		}
		else {
			return @type.matchContentOf(type)
		}
	} # }}}
	isUsingVariable(name) { # {{{
		for var value in @values {
			if value.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		for var value in @values {
			value.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
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
	} # }}}
	type() => @type
	validateType(type: ReferenceType) { # {{{
		if type.hasParameters() {
			var parameter = type.parameter(0)

			for var value in @values {
				value.validateType(parameter)
			}
		}
	} # }}}
}

class ArrayRange extends Expression {
	private late {
		_by				= null
		_from
		_to
		_type: Type
	}
	analyse() { # {{{
		@from = $compile.expression(@data.from ?? @data.then, this)
		@from.analyse()

		@to = $compile.expression(@data.to ?? @data.til, this)
		@to.analyse()

		if @data.by? {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
		}

	} # }}}
	prepare() { # {{{
		@type = Type.arrayOf(@scope.reference('Number'), @scope)

		@from.prepare()
		@to.prepare()
		@by.prepare() if @by?
	} # }}}
	translate() { # {{{
		@from.translate()
		@to.translate()

		if @by != null {
			@by.translate()
		}
	} # }}}
	isUsingVariable(name) => @from.isUsingVariable(name) || @to.isUsingVariable(name) || @by?.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@from.listNonLocalVariables(scope, variables)
		@to.listNonLocalVariables(scope, variables)
		@by?.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
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
	} # }}}
	type() => @type
}
