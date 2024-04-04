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
	expression() => @argument
	hasExceptions() => false
	inferTypes(inferables) => @argument.inferTypes(inferables)
	isUsingVariable(name) => @argument.isUsingVariable(name)
	listAssignments(array: Array) => @argument.listAssignments(array)
}

class UnaryOperatorSpread extends UnaryOperatorExpression {
	private late {
		@canBeNullable: Boolean		= false
		@fitting: Boolean			= false
		@helper: Boolean			= false
		@notNull: Boolean			= false
		@notNullOperator: String?
		@nullable: Boolean			= false
		@object: Boolean			= false
		@reusable: Boolean			= false
		@reuseName: String?			= null
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

		if @argument is UnaryOperatorTypeFitting && @argument.isForced() {
			var type = @argument.argument().type()

			if type.isArray() {
				@type = type.flagSpread().setNullable(false)
			}
			else if type.isObject() {
				@type = type.flagSpread().setNullable(false)
				@object = true
			}
			else if type.canBeArray() {
				@type = @scope.reference('Array').flagSpread()
			}
			else {
				TypeException.throwInvalidSpread(this)
			}

			@fitting = true

			return
		}

		var type = @argument.type()

		@nullable = !@notNull && type.isNullable()

		if !@canBeNullable && @nullable {
			TypeException.throwNotNullableOperand(@argument, @operator(), this)
		}
		else if @canBeNullable && !@nullable {
			if @notNull {
				TypeException.throwNeverNullableOperand(@argument, @notNullOperator, @operator(), this)
			}
			else {
				TypeException.throwNullableOperand(@argument, @operator(), this)
			}
		}
		else if type.isArray() {
			@type = type.flagSpread().setNullable(false)
			@helper = @nullable && @parent is ArrayExpression
		}
		else if type.isObject() {
			@type = type.flagSpread().setNullable(false)
			@object = true
		}
		else if type.canBeArray() {
			@type = @scope.reference('Array').flagSpread()
			@helper = true
		}
		else {
			TypeException.throwInvalidSpread(this)
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire && !@helper && @argument.isComposite() {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	amendTarget(target: Type): Type { # {{{
		var type = @parent is ArrayExpression ? Type.arrayOf(target, @scope) : target

		return @canBeNullable ? type.setNullable(true) : type
	} # }}}
	override flagNotNull(operator) { # {{{
		@notNull = true
		@notNullOperator = operator
	} # }}}
	isExpectingType() => true
	override isFitting() => @fitting
	isSpread() => true
	operator() => @canBeNullable ? '...?' : '...'
	releaseReusable() { # {{{
		@scope.releaseTempName(@reuseName) if ?@reuseName
	} # }}}
	override toArgumentFragments(fragments, mode) { # {{{
		if @object {
			NotSupportedException.throw(this)
		}
		else if @nullable {
			fragments
				.code(`...\($runtime.helper(this)).toArray(`)
				.compileReusable(this)
				.code(`, \(@helper ? '1' : '0'))`)
		}
		else if @helper {
			fragments
				.code(`...\($runtime.helper(this)).checkArray(`)
				.compileReusable(this)
				.code(`)`)
		}
		else {
			fragments.code('...').wrapReusable(this)
		}
	} # }}}
	override toArgumentFragments(fragments, property, mode) { # {{{
		NotSupportedException.throw(this) unless @object

		@toReusableFragments(fragments)

		if $isVarname(property) {
			fragments.code(`.\(property)`)
		}
		else {
			fragments.code(`[\($quote(property))]`)
		}
	} # }}}
	override toArgumentFragments(fragments, member, mode) { # {{{
		@toReusableFragments(fragments)

		fragments.code(`[\(member)]`)
	} # }}}
	toArgumentFragments(fragments, from: Number, to: Number?, mode: Mode?) { # {{{
		@toReusableFragments(fragments)

		fragments
			..code(`.slice(\(from)`)
			..code(`, \(to + 1)`) if ?to
			..code(')')
	} # }}}
	// TODO! when removed, method should not be hidden
	override toArgumentFragments(fragments, type, mode) { # {{{
		@toArgumentFragments(fragments, mode)
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
		if ?@reuseName {
			fragments.code(`...\(@reuseName)`)
		}
		else if @nullable {
			NotSupportedException.throw(this)
		}
		else {
			fragments.code('...').wrap(@argument)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if ?@reuseName {
			if @reusable {
				fragments.code(`\(@reuseName)`)
			}
			else {
				fragments.code(`(\(@reuseName) = `).compile(@argument).code(`)`)

				@reusable = true
			}
		}
		else {
			fragments.compile(@argument)
		}
	} # }}}
	toTypeQuote() { # {{{
		return `\(@operator())\(@type.toQuote())`
	} # }}}
	type() => @type
	useHelper() => @helper
}
