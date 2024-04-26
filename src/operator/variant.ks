class AssignmentOperatorVariantCoalescing extends AssignmentOperatorExpression {
	private late {
		@assert: Boolean		= false
		@name: String
	}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		var type = @left.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@left, this)
		}

		unless type.isVariant() {
			TypeException.throwNotBooleanVariant(@left, this)
		}

		var root = type.discard()
		var variant = root.getVariantType()

		unless variant.hasManyValues(type) {
			TypeException.throwUnnecessaryVariantChecking(@left, type, this)
		}

		unless variant.canBeBoolean() {
			TypeException.throwNotBooleanVariant(@left, this)
		}

		var leftType = @left.getDeclaredType().discardValue()
		var rightType = @right.type()

		if !@isMisfit() && @parent is not BinaryOperatorTypeEquality | BinaryOperatorTypeInequality && !rightType.isDeferred() && !rightType.isFunction() && !rightType.isAssignableToVariable(leftType, false, false, false) {
			@assert = true
		}

		@name = root.getVariantName()

		if @assert {
			@right.acquireReusable(true)
			@right.releaseReusable()
		}
	} # }}}
	inferTypes(inferables) { # {{{
		@left.inferTypes(inferables)

		if @left.isInferable() {
			var type = Type.union(@scope, Type.setTrueSubtype(@left.type().setNullable(false), @scope, this), @right.type())

			inferables[@left.path()] = {
				isVariable: @left.isVariable()
				type
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments.code(' && ').compile(@left).code(`.\(@name)`)
		}
		else {
			fragments.compile(@left).code(`.\(@name)`)
		}

		if @assert {
			fragments.code(' && (')

			@left.getDeclaredType().setNullable(false).toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}

		fragments
			.code(' ? null : ')
			.compile(@left)
			.code($equals)
			.compileReusable(@right)
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments.code(' && ').compile(@left).code(`.\(@name))`)
		}
		else {
			fragments.compile(@left).code(`.\(@name)`)
		}

		if @assert {
			fragments.code(' && (')

			@left.getDeclaredType().setNullable(false).toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}

		fragments
			.code(' ? false : (')
			.compile(@left)
			.code($equals)
			.compileReusable(@right)
			.code(', true)')
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl()

		ctrl
			.code('if(!')

		if @left.isNullable() {
			ctrl.code('(')

			@left.toNullableFragments(ctrl)

			ctrl.code(' && ').compile(@left).code(`.\(@name))`)
		}
		else {
			ctrl.compile(@left).code(`.\(@name)`)
		}

		if @assert {
			ctrl.code(' && (')

			@left.getDeclaredType().setNullable(false).toPositiveTestFragments(ctrl, @right)

			ctrl.code(')')
		}

		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(@left)
			.code($equals)
			.compileReusable(@right)
			.done()

		ctrl.done()
	} # }}}
	toQuote() => `\(@left.toQuote()) ?]]= \(@right.toQuote())`
	type() => @scope.reference('Boolean')
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
		SyntaxException.throwNoReturn(this) unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement

		super(AnyType.NullableUnexplicit)

		@right.acquireReusable(true)
		@right.releaseReusable()

		var rightType = @right.type()

		if rightType.isInoperative() {
			TypeException.throwUnexpectedInoperative(rightType, this)
		}

		unless rightType.isVariant() {
			TypeException.throwNotBooleanVariant(@right, this)
		}

		var root = rightType.discard()
		var variant = root.getVariantType()

		unless variant.canBeBoolean() {
			TypeException.throwNotBooleanVariant(@right, this)
		}

		unless variant.hasManyValues(rightType) {
			TypeException.throwUnnecessaryVariantChecking(@right, rightType, this)
		}

		@name = root.getVariantName()
		@type = Type.setTrueSubtype(rightType, @scope, this)

		if @left.isVariable() {
			if @condition && @lateinit {
				@statement.initializeLateVariable(@left.name(), @type, true)
			}
			else {
				@left.initializeVariables(@type, this)
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
				type: @type
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
		if @right.isReusingName() && !@right.isReusable() {
			fragments.code('(').wrapReusable(@right).code(')')
		}
		else {
			fragments.compile(@right)
		}

		fragments.code(`.\(@name) ? (`)

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
		@names: String[]		= []
		@nullables: Boolean[]	= []
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = @operands.length - 1

		for var operand, index in @operands {
			operand.prepare()

			var mut type = operand.type()

			if type.isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			if index < last {
				unless type.isVariant() {
					TypeException.throwNotBooleanVariant(operand, this)
				}

				var root = type.discard()
				var variant = root.getVariantType()

				unless variant.canBeBoolean() {
					TypeException.throwNotBooleanVariant(operand, this)
				}

				unless variant.hasManyValues(type) {
					TypeException.throwUnnecessaryVariantChecking(operand, type, this)
				}

				@names.push(root.getVariantName())
				@nullables.push(type.isNullable())

				operand.acquireReusable(true)
				operand.releaseReusable()

				type = Type.setTrueSubtype(type, @scope, this)

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
			else {
				types.push(type)
			}
		}

		if #types == 1 {
			@type = types[0]
		}
		else {
			@type = Type.union(@scope, ...types)
		}
	} # }}}
	operator() => Operator.VariantCoalescing
	symbol() => '?]]'
	toFragments(fragments, mode) { # {{{
		var last = @operands.length - 1

		for var operand, index in @operands to~ -1 {
			if @nullables[index] {
				fragments
					.code(`(\($runtime.type(this)).isValue(`)
					.compileReusable(operand)
					.code(') && ')
					.compile(operand)
					.code(`.\(@names[index])) ? `)
					.compile(operand)
					.code(' : ')
			}
			else {
				fragments
					.compileReusable(operand)
					.code(`.\(@names[index]) ? `)
					.compile(operand)
					.code(' : ')
			}
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
		@trueType: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		var type = @argument.type()

		if type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		unless type.isVariant() {
			TypeException.throwNotBooleanVariant(@argument, this)
		}

		var root = type.discard()
		var variant = root.getVariantType()

		unless variant.canBeBoolean() {
			TypeException.throwNotBooleanVariant(@argument, this)
		}

		unless variant.hasManyValues(type) {
			TypeException.throwUnnecessaryVariantChecking(@argument, type, this)
		}

		@trueType = Type.setTrueSubtype(type, @scope, this)
		@name = root.getVariantName()
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		@argument.inferTypes(inferables)

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument.isVariable()
				type: @trueType
			}
		}

		return inferables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@argument).code(`.\(@name)`)
	} # }}}
	type() => @scope.reference('Boolean')
}
