class AssignmentOperatorEmptyCoalescing extends AssignmentOperatorExpression {
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		unless type.isIterable() || @isMisfit() || @left is MemberExpression {
			TypeException.throwNotIterable(@left, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isNotEmpty(')
				.compile(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isNotEmpty(')
				.compile(@left)
				.code(')')
		}

		fragments
			.code(' ? null : ')
			.compile(@left)
			.code($equals)
			.compile(@right)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl.code('if(!')

		if @left.isNullable() {
			ctrl.code('(')

			@left.toNullableFragments(ctrl)

			ctrl
				.code(' && ' + $runtime.type(this) + '.isNotEmpty(')
				.compile(@left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isNotEmpty(')
				.compile(@left)
				.code(')')
		}

		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} # }}}
	toQuote() => `\(@left.toQuote()) ?##= \(@right.toQuote())`
}

class AssignmentOperatorNonEmpty extends AssignmentOperatorExpression {
	private {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement

		super(AnyType.NullableUnexplicit)

		@right.acquireReusable(true)
		@right.releaseReusable()

		var type = @right.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}

		unless type.isIterable() || @right.isLateInit() || @isMisfit() || @right is MemberExpression {
			TypeException.throwNotIterable(@right, this)
		}

		if @left is IdentifierLiteral {
			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), type, true)
				}
				else {
					@left.type(type, @scope, this)
				}
			}
			else {
				@left.type(type, @scope, this)
			}
		}
	} # }}}
	defineVariables(left) { # {{{
		return if @declaration

		if @condition {
			var names = []

			for var { name } in left.listAssignments([]) {
				if var variable ?= @scope.getVariable(name) {
					if variable.isLateInit() {
						@statement.addInitializableVariable(variable, true, this)
						@lateinit = true
					}
					else if variable.isImmutable() {
						ReferenceException.throwImmutable(name, this)
					}
				}
				else {
					names.push(name)
				}
			}

			if names.length > 0 {
				@statement.defineVariables(left, names, @scope, @leftMost, @leftMost == this)
			}
		}
		else {
			@statement.defineVariables(left, @scope, @leftMost, @leftMost == this)
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left.isVariable()
				type: @right.type()
			}
		}

		return inferables
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}
		else {
			fragments
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}

		fragments.code(' ? ')

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}
		else {
			fragments
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}

		fragments.code(' ? (')

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) ?#= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorEmpty extends AssignmentOperatorNonEmpty {
	toConditionFragments(fragments, mode, junction) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}
		else {
			fragments
				.code(`\($runtime.type(this)).isNotEmpty(`)
				.compileReusable(@right)
				.code(')')
		}

		fragments.code(' ? (')

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', false) : true')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) !?#= \(@right.toQuote())`
	} # }}}
}

class PolyadicOperatorEmptyCoalescing extends PolyadicOperatorExpression {
	private late {
		@spread: Boolean
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = @operands.length - 1

		for var operand, index in @operands {
			operand
				..flagNotNull(@symbol()) if index < last
				..prepare()

			@spread ||= operand.isSpread()

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if index < last {
				unless type.isIterable() || operand.isLateInit() || @isMisfit() || operand is MemberExpression {
					TypeException.throwNotIterable(operand, this)
				}

				operand.acquireReusable(true)
				operand.releaseReusable()
			}

			var mut ne = true

			for var tt in types while ne {
				if tt.equals(type) {
					ne = false
				}
			}

			if ne {
				types.push(type)
			}
		}

		if types.length == 1 {
			@type = types[0]
		}
		else {
			@type = Type.union(@scope, ...types)
		}
	} # }}}
	isSpread() => @spread
	override isSpreadable() => false
	operator() => Operator.EmptyCoalescing
	symbol() => '?##'
	toFragments(fragments, mode) { # {{{
		var last = @operands.length - 1

		if @spread {
			var spreads = []

			with var mut spread = false {
				for var operand in @operands down {
					spread ||= operand.isSpread()

					spreads.unshift(spread)
				}
			}

			var mut opened = false

			for var mut operand, index in @operands {
				var spread = operand.isSpread()

				if spread {
					operand = operand.argument()

					if opened {
						fragments.code(']')

						opened = false
					}
				}
				else if spreads[index] {
					if opened {
						fragments.code(']')

						opened = false
					}
				}
				else {
					if !opened {
						fragments.code('[')

						opened = true
					}
				}

				if index != last {
					fragments
						.code($runtime.type(this) + '.isNotEmpty(')
						.compileReusable(operand)
						.code(') ? ')
				}

				if !spread && !opened {
					fragments.code('[').compile(operand).code(']')
				}
				else {
					fragments.compile(operand)
				}

				fragments.code(' : ') if index != last
			}

			fragments.code(']') if opened
		}
		else {
			for var operand in @operands to~ -1 {
				fragments
					.code($runtime.type(this) + '.isNotEmpty(')
					.compileReusable(operand)
					.code(') ? ')
					.compile(operand)
					.code(' : ')
			}

			fragments.compile(@operands[last])
		}
	} # }}}
	type() => @type
}

class BinaryOperatorEmptyCoalescing extends PolyadicOperatorEmptyCoalescing {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class UnaryOperatorEmpty extends UnaryOperatorExpression {
	private {
		@mode: Number		= 0
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		unless type.isIterable() || @argument.isLateInit() || @isMisfit() || @argument is MemberExpression {
			TypeException.throwNotIterable(@argument, this)
		}

		if !type.isNullable() {
			if type.isBroadArray() || type.isString() {
				@mode = 1
			}
			else if type.isBroadObject() {
				@mode = 2
			}
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.code(`\($runtime.type(this)).isNotEmpty(`)
			.compile(@argument)
			.code(`, \(@mode))`)
	} # }}}
	type() => @scope.reference('Boolean')
}

class UnaryOperatorNonEmpty extends UnaryOperatorExpression {
	private late {
		@mode: Number		= 0
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		unless type.isIterable() || @argument.isLateInit() || @isMisfit() || @argument is MemberExpression {
			TypeException.throwNotIterable(@argument, this)
		}

		if !type.isNullable() && !@argument.isLateInit() {
			if type.isBroadArray() || type.isString() {
				@mode = 1
			}
			else if type.isBroadObject() {
				@mode = 2
			}
		}

		@type = type.setNullable(false)
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		@argument.inferTypes(inferables)

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument.isVariable()
				type: @type
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.code(`\($runtime.type(this)).isNotEmpty(`)
			.compile(@argument)
			.code(`, \(@mode))`)
	} # }}}
	type() => @scope.reference('Boolean')
}
