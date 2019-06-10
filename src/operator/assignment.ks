class AssignmentOperatorExpression extends Expression {
	private {
		_await: Boolean				= false
		_left						= null
		_right						= null
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)

		if this.isDeclararing() {
			@left.setAssignment(AssignmentType::Expression)
		}

		@left.analyse()

		@right = $compile.expression(@data.right, this)

		if @right.isAssignable() {
			@right.setAssignment(AssignmentType::Expression)
		}

		@right.analyse()

		@await = @right.isAwait()

		if this.isDeclararing() {
			this.defineVariables(@left)
		}
		else {
			if @left is IdentifierLiteral {
				if const variable = @scope.getVariable(@left.name()) {
					if variable.isImmutable() {
						ReferenceException.throwImmutable(@left.name(), this)
					}
				}
			}
		}
	} // }}}
	prepare() { // {{{
		@left.prepare()
		@right.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	defineVariables(left) { // {{{
		let leftMost = true
		let expression = this

		while expression.parent() is not Statement {
			expression = expression.parent()
			leftMost = false
		}

		expression.parent().defineVariables(left, @scope, expression, leftMost)
	} // }}}
	isAwait() => @await
	isAwaiting() => @right.isAwaiting()
	isComputed() => true
	isDeclararing() => false
	isDeclararingVariable(name: String) => this.isDeclararing() && @left.isDeclararingVariable(name)
	isNullable() => @right.isNullable()
	isUsingVariable(name) => @left.isUsingVariable(name) || @right.isUsingVariable(name)
	listAssignments(array) => @left.listAssignments(@right.listAssignments(array))
	setAssignment(assignment)
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(@right)
	} // }}}
	type() => @left.type()
	variable() => @left.variable()
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' += ').compile(@right)
	} // }}}
}

class AssignmentOperatorBitwiseAnd extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' &= ').compile(@right)
	} // }}}
}

class AssignmentOperatorBitwiseLeftShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' <<= ').compile(@right)
	} // }}}
}

class AssignmentOperatorBitwiseOr extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' |= ').compile(@right)
	} // }}}
}

class AssignmentOperatorBitwiseRightShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' >>= ').compile(@right)
	} // }}}
}

class AssignmentOperatorBitwiseXor extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' ^= ').compile(@right)
	} // }}}
}

class AssignmentOperatorDivision extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' /= ').compile(@right)
	} // }}}
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	prepare() { // {{{
		super.prepare()

		if @left is IdentifierLiteral {
			@left.type(@right.type(), @scope, this)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@right.acquireReusable(@left.isSplitAssignment())
	} // }}}
	hasExceptions() => @right.isAwaiting() && @right.hasExceptions()
	isAssignable() => @left == null || @left.isAssignable()
	isDeclararing() => true
	releaseReusable() { // {{{
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @right.isAwaiting() {
			return @right.toFragments(fragments, mode)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).compile(@right)
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		fragments.compile(@left).code($equals).wrap(@right)
	} // }}}
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	prepare() { // {{{
		@left.prepare()
		@right.prepare()

		@right.acquireReusable(true)
		@right.releaseReusable()

		if @left is IdentifierLiteral {
			@left.type(@right.type(), @scope, this)
		}
	} // }}}
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
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

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(' : undefined')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
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

		if @left.toAssignmentFragments? {
			@left.toAssignmentFragments(fragments, @right)
		}
		else {
			fragments.compile(@left).code($equals).wrap(@right)
		}

		fragments.code(', true) : false')
	} // }}}
}

class AssignmentOperatorModulo extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' %= ').compile(@right)
	} // }}}
}

class AssignmentOperatorMultiplication extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' *= ').compile(@right)
	} // }}}
}

class AssignmentOperatorNonExistential extends AssignmentOperatorExpression {
	prepare() { // {{{
		@left.prepare()
		@right.prepare()

		@right.acquireReusable(true)
		@right.releaseReusable()
	} // }}}
	isDeclararing() => true
	toFragments(fragments, mode) { // {{{
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
			.code(' : undefined')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
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
	} // }}}
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
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
			.code(' ? undefined : ')
			.compile(@left)
			.code($equals)
			.compile(@right)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()

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
	} // }}}
}

class AssignmentOperatorQuotient extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.compile(@left)
			.code($equals)
			.code('Number.parseInt(').compile(@left).code(' / ').compile(@right).code(')')
	} // }}}
}

class AssignmentOperatorSubtraction extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' -= ').compile(@right)
	} // }}}
}