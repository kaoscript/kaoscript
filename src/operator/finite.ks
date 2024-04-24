class AssignmentOperatorFinite extends AssignmentOperatorExpression {
	private {
		@assert: Boolean		= true
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

		if type.isNumber() {
			@assert = type.isNullable()
		}
		else if !type.canBeNumber() {
			TypeException.throwNotNumber(@right, this)
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
		fragments
			.code(`\($runtime.type(this)).isFinite(`)
			.compileReusable(@right)
			.code(`, \(@assert ? '1' : '0')) ? `)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments
			.code(`\($runtime.type(this)).isFinite(`)
			.compileReusable(@right)
			.code(`, \(@assert ? '1' : '0')) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) ?+= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorNonFinite extends AssignmentOperatorFinite {
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments
			.code(`\($runtime.type(this)).isFinite(`)
			.compileReusable(@right)
			.code(`, \(@assert ? '1' : '0')) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', false) : true')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) !?+= \(@right.toQuote())`
	} # }}}
}

class AssignmentOperatorNonFiniteCoalescing extends AssignmentOperatorExpression {
	private {
		@assert: Boolean		= true
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if type.isNumber() {
			@assert = type.isNullable()
		}
		else if !type.canBeNumber() {
			TypeException.throwNotNumber(@left, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.code(`\($runtime.type(this)).isFinite(`)
			.compile(@left)
			.code(`, \(@assert ? '1' : '0')) ? null : `)
			.compile(@left)
			.code($equals)
			.compile(@right)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl
			.code('if(!')
			.code(`\($runtime.type(this)).isFinite(`)
			.compile(@left)
			.code(`, \(@assert ? '1' : '0')))`)
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} # }}}
	toQuote() => `\(@left.toQuote()) ?++= \(@right.toQuote())`
}

class PolyadicOperatorNonFiniteCoalescing extends PolyadicOperatorExpression {
	private late {
		@asserts: Boolean[]		= []
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = @operands.length - 1

		for var operand, index in @operands {
			operand.prepare()

			var type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if index < last {
				if type.isNumber() {
					@asserts.push(type.isNullable())
				}
				else if type.canBeNumber() {
					@asserts.push(true)
				}
				else {
					TypeException.throwNotNumber(@argument, this)
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
	operator() => Operator.NonFiniteCoalescing
	symbol() => '?++'
	toFragments(fragments, mode) { # {{{
		var last = @operands.length - 1

		for var operand, index in @operands to~ -1 {
			fragments
				.code(`\($runtime.type(this)).isFinite(`)
				.compileReusable(operand)
				.code(`, \(@asserts[index] ? '1' : '0')) ? `)
				.compile(operand)
				.code(' : ')
		}

		fragments.compile(@operands[last])
	} # }}}
	type() => @type
}

class BinaryOperatorNonFiniteCoalescing extends PolyadicOperatorNonFiniteCoalescing {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class UnaryOperatorFinite extends UnaryOperatorExpression {
	private late {
		@assert: Boolean		= true
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		if type.isNumber() {
			@assert = type.isNullable()
		}
		else if !type.canBeNumber() {
			TypeException.throwNotNumber(@argument, this)
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
			.code(`\($runtime.type(this)).isFinite(`)
			.compile(@argument)
			.code(`, \(@assert ? '1' : '0'))`)
	} # }}}
	type() => @scope.reference('Boolean')
}
