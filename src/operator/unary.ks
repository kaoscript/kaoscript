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

class UnaryOperatorSpread extends UnaryOperatorExpression {
	private late {
		@canBeNullable: Boolean	= false
		@helper: Boolean	= false
		@nullable: Boolean	= false
		@type: Type
	}
	override analyse() { # {{{
		super()

		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.Nullable {
					@canBeNullable = true
				}
			}
		}
	} # }}}
	override prepare(mut target, targetMode) { # {{{
		target = @amendTarget(target)

		super(target, targetMode)

		var type = @argument.type()

		@nullable = type.isNullable()

		if !@canBeNullable && @nullable {
			TypeException.throwNotNullableOperand(@argument, @operator(), this)
		}
		else if type.isArray() {
			@type = type.flagSpread()
			@helper = @nullable && @parent is ArrayExpression
		}
		else if type.canBeArray() {
			@type = @scope.reference('Array').flagSpread()
			@helper = true
		}
		else {
			TypeException.throwInvalidSpread(this)
		}
	} # }}}
	amendTarget(target: Type): Type {
		var type = @parent is ArrayExpression ? Type.arrayOf(target, @scope) : target

		return @canBeNullable ? type.setNullable(true) : type
	}
	isExpectingType() => true
	isSpread() => true
	operator() => @canBeNullable ? '...?' : '...'
	override toArgumentFragments(fragments, mode) { # {{{
		if @nullable {
			fragments
				.code(`...\($runtime.helper(this)).toArray(`)
				.compile(@argument)
				.code(`, \(@helper ? '1' : '0'))`)
		}
		else if @helper {
			fragments
				.code(`...\($runtime.helper(this)).checkArray(`)
				.compile(@argument)
				.code(`)`)
		}
		else {
			fragments.code('...').wrap(@argument)
		}
	} # }}}
	override toFlatArgumentFragments(nullTested, fragments, _) { # {{{
		if !nullTested && @nullable {
			fragments
				.code(`\($runtime.helper(this)).toArray(`)
				.compile(@argument)
				.code(`, \(@helper ? '1' : '0'))`)
		}
		else if @helper {
			fragments
				.code(`\($runtime.helper(this)).checkArray(`)
				.compile(@argument)
				.code(`)`)
		}
		else {
			fragments.compile(@argument)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @nullable {
			NotSupportedException.throw(this)
		}
		else {
			fragments.code('...').wrap(@argument)
		}
	} # }}}
	toTypeQuote() { # {{{
		var type = @type.parameter(0)

		return `\(@operator())\(type.toQuote())`
	} # }}}
	type() => @type
	useHelper() => @helper
}
