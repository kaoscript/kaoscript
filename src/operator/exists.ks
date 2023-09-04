class AssignmentOperatorExistential extends AssignmentOperatorExpression {
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

		if @left is IdentifierLiteral {
			var type = @right.type().setNullable(false)

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
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
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
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
		}

		fragments.code(' ? (')

		if ?@left.toAssignmentFragments {
			if @left is ArrayBinding | ObjectBinding {
				@left.toAssertFragments(fragments, @right, true)
			}

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

		if @left is IdentifierLiteral {
			var type = @right.type().setNullable(false)

			if @condition {
				if @lateinit {
					@statement.initializeLateVariable(@left.name(), type, false)
				}
				else if var scope ?= @statement.getWhenFalseScope() {
					@left.type(type, scope, this)
				}
			}
			else {
				@left.type(type, @scope, this)
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
				isVariable: @left is IdentifierLiteral
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
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
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
				.code($runtime.type(this) + '.isValue(', @data.operator)
				.compileReusable(@right)
				.code(')', @data.operator)
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
				isVariable: @left is IdentifierLiteral
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
	toQuote() => `\(@left.toQuote()) ??= \(@right.toQuote())`
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		super(target, TargetMode.Permissive)

		@left.acquireReusable(true)
		@left.releaseReusable()

		var leftType = @left.type().setNullable(false)

		if leftType.equals(@right.type()) {
			@type = leftType
		}
		else {
			@type = Type.union(@scope, leftType, @right.type())
		}
	} # }}}
	inferTypes(inferables) => @left.inferTypes(inferables)
	toFragments(fragments, mode) { # {{{
		if @left.isNullable() {
			fragments.code('(')

			@left.toNullableFragments(fragments)

			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compileReusable(@left)
				.code(')')
		}

		fragments
			.code(' ? ')
			.compile(@left)
			.code(' : ')
			.compile(@right)
	} # }}}}
	type() => @type
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		var types = []
		var last = @operands.length - 1

		for var operand, index in @operands {
			operand.prepare(target, TargetMode.Permissive)

			if operand.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(operand, this)
			}

			var late operandType

			if index < last {
				operand.acquireReusable(true)
				operand.releaseReusable()

				if operand.type().isNull() {
					operandType = operand.getDeclaredType().setNullable(false)
				}
				else {
					operandType = operand.type().setNullable(false)
				}
			}
			else {
				operandType = operand.type()
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

		if types.length == 1 {
			@type = types[0]
		}
		else {
			@type = Type.union(@scope, ...types)
		}
	} # }}}
	operator() => Operator.NullCoalescing
	symbol() => '??'
	toFragments(fragments, mode) { # {{{
		@module().flag('Type')

		var mut l = @operands.length - 1

		for var i from 0 to~ l {
			var operand = @operands[i]

			if operand.isNullable() {
				fragments.code('(')

				operand.toNullableFragments(fragments)

				fragments
					.code(' && ' + $runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code('))')
			}
			else {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(operand)
					.code(')')
			}

			fragments
				.code(' ? ')
				.compile(operand)
				.code(' : ')
		}

		fragments.compile(@operands[l])
	} # }}}
	type() => @type
}


class UnaryOperatorExistential extends UnaryOperatorExpression {
	private late {
		@type: Type
	}
	override prepare(target, targetMode) { # {{{
		@argument.prepare()

		unless @argument.type().isNullable() || @argument.isLateInit() || @options.rules.ignoreMisfit || @argument is MemberExpression {
			TypeException.throwNotNullableExistential(@argument, this)
		}

		@type = @argument.type().setNullable(false)
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
