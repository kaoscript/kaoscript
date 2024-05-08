class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	private {
		@assert: Boolean		= false
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement | WhileStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement {
			SyntaxException.throwNoReturn(this)
		}

		super(AnyType.NullableUnexplicit, TargetMode.Permissive)

		unless @right.isComputedMember() || @right.canBeNull() {
			TypeException.throwNullableOperand(@right, '?=', this)
		}

		@right.acquireReusable(true)
		@right.releaseReusable()

		var leftType = @left.getDeclaredType().discardValue()
		var rightType = @right.type().setNullable(false)
		var forcedFitting = @right is UnaryOperatorTypeFitting && @right.isForced()

		if @left.isVariable() {
			if @condition && @lateinit {
				@statement.initializeLateVariable(@left.name(), rightType, true)
			}
			else if !forcedFitting {
				@left.initializeVariables(rightType, this)
			}
		}

		if @isInDestructor() {
			@type = NullType.Explicit
		}
		else if forcedFitting {
			@type = leftType.setNullable(false)
		}
		else {
			unless rightType.isAssignableToVariable(leftType, true, false, false) {
				TypeException.throwInvalidAssignment(@left, leftType, rightType, this)
			}

			if !@isMisfit() && @parent is not BinaryOperatorTypeEquality | BinaryOperatorTypeInequality && !rightType.isDeferred() && !rightType.isFunction() && !rightType.isAssignableToVariable(leftType, false, false, false) {
				@assert = true
			}

			if @left.isInferable() {
				@type = leftType.tryCastingTo(rightType)
			}
			else {
				@type = rightType
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
	initializeVariable(variable: VariableBrief) { # {{{
		return @parent.initializeVariable(variable, this)
	} # }}}
	isAssigningBinding() => true
	isDeclararing() => true
	toFragments(fragments, mode) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
		}

		if @assert {
			fragments.code('(')

			@type.toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
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
		}

		if @assert {
			fragments.code('(')

			@type.toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
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
		return `\(@left.toQuote()) ?= \(@right.toQuote())`
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorNonExistential extends AssignmentOperatorExpression {
	private {
		@assert: Boolean		= false
		@condition: Boolean		= false
		@lateinit: Boolean		= false
	}
	analyse() { # {{{
		@condition = @statement() is IfStatement

		super()
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement {
			SyntaxException.throwNoReturn(this)
		}

		super(AnyType.NullableUnexplicit, TargetMode.Permissive)

		unless @right.isComputedMember() || @right.type().isNullable() {
			TypeException.throwNullableOperand(@right, '!?=', this)
		}

		@right.acquireReusable(true)
		@right.releaseReusable()

		var leftType = @left.getDeclaredType().discardValue()
		var rightType = @right.type().setNullable(false)
		var forcedFitting = @right is UnaryOperatorTypeFitting && @right.isForced()

		if @left.isVariable() {
			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), rightType, false)
				}
				else if var scope ?= @statement.getWhenFalseScope() {
					@left.type(rightType, scope, this)
				}
			}
			else if !forcedFitting {
				@left.initializeVariables(rightType, this)
			}
		}

		if @isInDestructor() {
			@type = NullType.Explicit
		}
		else if forcedFitting {
			@type = leftType.setNullable(false)
		}
		else {
			unless rightType.isAssignableToVariable(leftType, true, false, false) {
				TypeException.throwInvalidAssignment(@left, leftType, rightType, this)
			}

			if !@isMisfit() && @parent is not BinaryOperatorTypeEquality | BinaryOperatorTypeInequality && !rightType.isDeferred() && !rightType.isFunction() && !rightType.isAssignableToVariable(leftType, false, false, false) {
				@assert = true
			}

			if @left.isInferable() {
				@type = leftType.tryCastingTo(rightType)
			}
			else {
				@type = rightType
			}
		}
	} # }}}
	defineVariables(left) { # {{{
		if @condition {
			var scope = @statement.scope()
			var names = []

			for var { name } in left.listAssignments([]) {
				if var variable ?= scope.getVariable(name) {
					if variable.isLateInit() {
						if @parent == @statement {
							@statement.addInitializableVariable(variable, false, this)
						}
						else {
							throw NotImplementedException.new(this)
						}

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
	inferWhenFalseTypes(inferables) { # {{{
		if @left.isInferable() {
			inferables[@left.path()] = {
				isVariable: @left.isVariable()
				type: @right.type().setNullable(false)
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
		}

		if @assert {
			fragments.code('(')

			@type.toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(' : null')
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @right.isNullable() {
			fragments
				.wrapNullable(@right)
				.code(' && ')
		}

		if @assert {
			fragments.code('(')

			@type.toPositiveTestFragments(fragments, @right)

			fragments.code(')')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments
			.code(' ? (')
			.compile(@left)
			.code($equals)
			.wrap(@right)
			.code(', false) : true')
	} # }}}
	type() => @scope.reference('Boolean')
	override validate(target)
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	private {
		@assert: Boolean		= false
	}
	override prepare(target, targetMode) { # {{{
		SyntaxException.throwNoReturn(this) unless target.isVoid() || target.canBeBoolean() || @parent is ExpressionStatement

		super(AnyType.NullableUnexplicit)

		var leftType = @left.getDeclaredType().discardValue()
		var rightType = @right.type()

		if !@isMisfit() && @parent is not BinaryOperatorTypeEquality | BinaryOperatorTypeInequality && !rightType.isDeferred() && !rightType.isFunction() && !rightType.isAssignableToVariable(leftType, false, false, false) {
			@assert = true
		}

		if @assert {
			@right.acquireReusable(true)
			@right.releaseReusable()
		}
	} # }}}
	inferTypes(inferables) { # {{{
		@left.inferTypes(inferables)

		if @left.isInferable() {
			var leftType = @left.type().setNullable(false)

			var type = if leftType.equals(@right.type()) {
				set leftType
			}
			else {
				set Type.union(@scope, leftType, @right.type())
			}

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

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
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

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
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

		ctrl.code('if(!')

		if @left.isNullable() {
			ctrl.code('(')

			@left.toNullableFragments(ctrl)

			ctrl
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(@left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isValue(')
				.compile(@left)
				.code(')')
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
	toQuote() => `\(@left.toQuote()) ??= \(@right.toQuote())`
	type() => @scope.reference('Boolean')
	override validate(target)
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	private late {
		@asserting: Boolean					= false
		@assertable: Boolean				= true
		@spread: Boolean
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = #@operands - 1

		for var operand, index in @operands {
			if index < last {
				if operand is UnaryOperatorSpread {
					operand
						..flagNotNull(@symbol())
						..prepare(target, TargetMode.Permissive)

					unless operand.argument().type().isNullable() {
						TypeException.throwNullableOperand(operand, '??', this)
					}
				}
				else {
					operand.prepare(target, TargetMode.Permissive)

					unless operand.isComputedMember() || operand.canBeNull() {
						TypeException.throwNullableOperand(operand, '??', this)
					}
				}
			}
			else {
				operand.prepare(target, TargetMode.Permissive)
			}


			@spread ||= operand.isSpread()

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			var late operandType

			if index < last {
				operand
					..acquireReusable(operand.getTestedType().isNullable())
					..releaseReusable()

				if operand.type().isNull() {
					operandType = operand.getDeclaredType().setNullable(false)
				}
				else {
					operandType = operand.type().setNullable(false)
				}

				if @assertable {
					@asserting ||= !operandType.isAssignableToVariable(target, false, false, false)
				}
			}
			else {
				operandType = operand.type()

				if @assertable {
					@asserting &&= operandType.isAssignableToVariable(target, false, false, false)
				}
			}

			var mut ne = true

			for var type in types while ne {
				if type.equals(operandType) {
					ne = false
				}
			}

			if ne {
				types.push(operandType)
			}
		}

		var union = Type.union(@scope, ...types)

		if @assertable {
			unless union.isAssignableToVariable(target, true, false, false) {
				TypeException.throwInvalidExpression(this, union, target, this)
			}

			if @asserting {
				@type = target
			}
			else {
				@type = union
			}
		}
		else {
			@type = union
		}
	} # }}}
	isSpread() => @spread
	override isSpreadable() => false
	operator() => Operator.NullCoalescing
	symbol() => '??'
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
					if operand.isNullable() {
						fragments.code('(')

						operand.toNullableFragments(fragments)

						fragments
							.code(' && ' + $runtime.type(this) + '.isValue(')
							.compileReusable(if spread set operand.argument() else operand)
							.code('))')
					}
					else {
						fragments
							.code($runtime.type(this) + '.isValue(')
							.compileReusable(if spread set operand.argument() else operand)
							.code(')')
					}

					fragments.code(' ? ')
				}

				if spread {
					operand.toFlatArgumentFragments(true, fragments, Mode.None)
				}
				else if !opened {
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
			for var operand, index in @operands to~ last {
				if operand.isNullable() {
					fragments.code('(')

					operand.toNullableFragments(fragments)

					if operand.getTestedType().isNullable() {
						fragments
							.code(' && ' + $runtime.type(this) + '.isValue(')
							.compileReusable(operand)
							.code(')')
					}

					fragments.code(')')
				}
				else {
					fragments
						.code($runtime.type(this) + '.isValue(')
						.compileReusable(operand)
						.code(')')
				}

				fragments.code(' ? ')

				if @asserting && index == 0 {
					@type.toAssertFunctionFragments(operand, false, fragments, this)
				}
				else {
					fragments.compile(operand)
				}

				fragments.code(' : ')
			}

			fragments.compile(@operands[last])
		}
	} # }}}
	type() => @type
	unflagAssertable() { # {{{
		@assertable = false
	} # }}}
}

class BinaryOperatorNullCoalescing extends PolyadicOperatorNullCoalescing {
	analyse() { # {{{
		for var data in [@data.left, @data.right] {
			var operand = $compile.expression(data, this)

			operand.analyse()

			@operands.push(operand)
		}
	} # }}}
}

class UnaryOperatorExistential extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		unless @argument.type().isNullable() || @argument.isLateInit() || @isMisfit() || @argument is MemberExpression {
			TypeException.throwNotNullableExistential(@argument, this)
		}

		@type = @argument.type().setNullable(false)
	} # }}}
	inferWhenTrueTypes(inferables) { # {{{
		@argument.inferWhenTrueTypes(inferables)

		if @argument.isInferable() {
			inferables[@argument.path()] = {
				isVariable: @argument.isVariable()
				type: @type
			}
		}

		return inferables
	} # }}}
	isComputed() => @argument.isNullable()
	toFragments(fragments, mode) { # {{{
		if @argument.isNullable() {
			fragments
				.wrapNullable(@argument)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compile(@argument)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compile(@argument)
				.code(')', @data.operator)
		}
	} # }}}
	type() => @scope.reference('Boolean')
}
