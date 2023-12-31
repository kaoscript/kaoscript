class AssignmentOperatorVariantCoalescing extends AssignmentOperatorExpression {
	private late {
		@name: String
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		if type.isVariant() {
			var root = type.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@name = root.getVariantName()
			}
			else {
				TypeException.throwNotBooleanVariant(@left, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@left, this)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.compile(@left)
			.code(`.\(@name) ? null : `)
			.compile(@left)
			.code($equals)
			.compile(@right)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl
			.code('if(!')
			.compile(@left)
			.code(`.\(@name))`)
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compile(@right)
			.done()

		ctrl.done()
	} # }}}
	toQuote() => `\(@left.toQuote()) ?||= \(@right.toQuote())`
}

class AssignmentOperatorVariantYes extends AssignmentOperatorExpression {
	private late {
		@condition: Boolean		= false
		@lateinit: Boolean		= false
		@name: String
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || target.isBoolean() || @parent is ExpressionStatement

		super(AnyType.NullableUnexplicit)

		@right.acquireReusable(true)
		@right.releaseReusable()

		var type = @right.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@right, this)
		}

		if type.isVariant() {
			var root = type.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@name = root.getVariantName()
			}
			else {
				TypeException.throwNotBooleanVariant(@right, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@right, this)
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
				isVariable: @left is IdentifierLiteral
				type: @right.type()
			}
		}

		return inferables
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		fragments.wrapReusable(@right).code(`.\(@name) ? `)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : null')
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments.wrapReusable(@right).code(`.\(@name) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) ?|= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorVariantNo extends AssignmentOperatorVariantYes {
	toConditionFragments(fragments, mode, junction) { # {{{
		fragments.wrapReusable(@right).code(`.\(@name) ? (`)

		if ?@left.toAssignmentFragments {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', false) : true')
	} # }}}
	toQuote() { # {{{
		return `\(@left.toQuote()) !?|= \(@right.toQuote())`
	} # }}}
}

class PolyadicOperatorVariantCoalescing extends PolyadicOperatorExpression {
	private late {
		@names: String[]	= []
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
				if type.isVariant() {
					var root = type.discard()
					var variant = root.getVariantType()

					unless variant.canBeBoolean() {
						TypeException.throwNotBooleanVariant(operand, this)
					}

					@names.push(root.getVariantName())
				}
				else {
					TypeException.throwNotBooleanVariant(operand, this)
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
	operator() => Operator.VariantCoalescing
	symbol() => '?||'
	toFragments(fragments, mode) { # {{{
		var last = @operands.length - 1

		for var operand, index in @operands to~ -1 {
			fragments
				.compileReusable(operand)
				.code(`.\(@names[index]) ? `)
				.compile(operand)
				.code(' : ')
		}

		fragments.compile(@operands[last])
	} # }}}
	type() => @type
}

class BinaryOperatorVariantCoalescing extends PolyadicOperatorVariantCoalescing {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class UnaryOperatorVariant extends UnaryOperatorExpression {
	private late {
		@name: String
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		if type.isVariant() {
			var root = type.discard()
			var variant = root.getVariantType()

			if variant.canBeBoolean() {
				@type = type
				@name = root.getVariantName()
			}
			else {
				TypeException.throwNotBooleanVariant(@argument, this)
			}
		}
		else {
			TypeException.throwNotBooleanVariant(@argument, this)
		}
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		@argument.inferTypes(inferables)

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument is IdentifierLiteral
				type: @type
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument).code(`.\(@name)`)
	} # }}}
	type() => @scope.reference('Boolean')
}
