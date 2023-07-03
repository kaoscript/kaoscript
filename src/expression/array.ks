class ArrayExpression extends Expression {
	private late {
		@flatten: Boolean	= false
		@type: Type
		@values: Array		= []
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
	override prepare(target, targetMode) { # {{{
		var subtarget = target.isArray() ? target.parameter() : AnyType.NullableUnexplicit

		var mut spread = false

		for var value in @values {
			value.prepare(subtarget)

			spread ||= value.type().isSpread()
		}

		if spread {
			var mut type = @values[0].type().discardSpread()

			for var value in @values from 1 {
				if !type.equals(value.type().discardSpread()) {
					type = null

					break
				}
			}

			if ?type {
				@type = Type.arrayOf(type, @scope)
			}
			else {
				@type = @scope.reference('Array')
			}
		}
		else {
			@type = ArrayType.new(@scope)

			for var value in @values {
				@type.addProperty(value.type())
			}
		}
	} # }}}
	translate() { # {{{
		for var value in @values {
			value.translate()
		}
	} # }}}
	isInverted() { # {{{
		for var value in @values {
			if value.isInverted() {
				return true
			}
		}

		return false
	} # }}}
	isMatchingType(type: Type) { # {{{
		if @values.length == 0 {
			return type.isAny() || type.isArray()
		}
		else {
			return @type.matchContentOf(type)
		}
	} # }}}
	isNotEmpty() => @values.length > 0
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

			for var value, index in @values {
				if index != 0 {
					fragments.code($comma)
				}

				fragments.compile(value)
			}

			fragments.code(']')
		}
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		for var value in @values {
			if value.isInverted() {
				return value.toInvertedFragments(fragments, callback)
			}
		}
	} # }}}
	toQuote() { # {{{
		var mut fragments = '['

		for var value, index in @values {
				if index != 0 {
					fragments += ', '
				}

				fragments += value.toQuote()
			}

		fragments += ']'

		return fragments
	} # }}}
	type() => @type
	validateType(type: ArrayType) { # {{{
		for var value, index in @values {
			if var propertyType ?= type.getProperty(index) {
				value.validateType(propertyType)
			}
		}
	} # }}}
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
		@by				= null
		@from
		@to
		@type: Type
	}
	analyse() { # {{{
		@from = $compile.expression(@data.from ?? @data.then, this)
		@from.analyse()

		@to = $compile.expression(@data.to ?? @data.til, this)
		@to.analyse()

		if ?@data.by {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
		}

	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = Type.arrayOf(@scope.reference('Number'), @scope)

		@from.prepare(@scope.reference('Number'))
		@to.prepare(@scope.reference('Number'))
		@by.prepare(@scope.reference('Number')) if ?@by
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
		@module().flag('Helper')

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

		fragments.code($comma, ?@data.from, $comma, ?@data.to, ')')
	} # }}}
	type() => @type
}
