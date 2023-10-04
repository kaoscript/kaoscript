class UnaryOperatorExpression extends Expression {
	private {
		@argument
	}
	analyse() { # {{{
		@argument = $compile.expression(@data.argument, this)
		@argument.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@argument.prepare(target, targetMode)

		if @argument.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}
	} # }}}
	translate() { # {{{
		@argument.translate()
	} # }}}
	argument() => @argument
	hasExceptions() => false
	inferTypes(inferables) => @argument.inferTypes(inferables)
	isUsingVariable(name) => @argument.isUsingVariable(name)
	listAssignments(array: Array) => @argument.listAssignments(array)
}

class UnaryOperatorDefault extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		var type = @argument.type()

		unless type.isNullable() {
			NotImplementedException.throw(this)
		}

		if type.isEnum() {
			var enum = type.discard()

			unless enum.hasDefaultVariable() {
				NotImplementedException.throw(this)
			}

			@type = type.setNullable(false)
		}
		else if type.isNumber() || type.isString() {
			@type = type.setNullable(false)
		}
		else {
			NotImplementedException.throw(this)
		}
	} # }}}
	isComputed() => true
	toFragments(fragments, mode) { # {{{
		fragments
			.code($runtime.type(this) + '.isValue(')
			.compileReusable(@argument)
			.code(') ? ')
			.compile(@argument)
			.code(' : ')

		if @type.isEnum() {
			var enum = @type.discardReference()
			var default = enum.type().getDefaultVariable()

			fragments.code(`\(enum.name()).\(default)`)
		}
		else if @type.isNumber() {
			fragments.code('0')
		}
		else if @type.isString() {
			fragments.code('""')
		}
	} # }}}
	type(): valueof @type
}

class UnaryOperatorSpread extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		if @parent is ArrayExpression {
			var targetArray = Type.arrayOf(target, @scope)

			super(targetArray, targetMode)

			var type = @argument.type()

			if type.isArray() {
				@type = type.flagSpread()
			}
			else {
				@type = targetArray.flagSpread()
			}
		}
		else {
			super(target, targetMode)

			var type = @argument.type()

			if type.isArray() {
				@type = type.flagSpread()
			}
			else if type.isAny() {
				@type = @scope.reference('Array').flagSpread()
			}
			else {
				TypeException.throwInvalidSpread(this)
			}
		}
	} # }}}
	isExpectingType() => true
	isSpread() => true
	toFragments(fragments, mode) { # {{{
		if @options.format.spreads == 'es5' {
			throw NotSupportedException.new(this)
		}

		fragments
			.code('...', @data.operator)
			.wrap(@argument)
	} # }}}
	toTypeQuote() { # {{{
		var type = @type.parameter(0)

		return `...\(type.toQuote())`
	} # }}}
	type() => @type
}
