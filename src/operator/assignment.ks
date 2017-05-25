class AssignmentOperatorExpression extends Expression {
	private {
		_await: Boolean				= false
		_left
		_right
		_variables: Array<String>	= []
	}
	analyse() { // {{{
		let variables = this.assignment(@data)
		
		@left = $compile.expression(@data.left, this)
		@left.analyse()
		
		if variables? {
			@variables = variables
		}
		
		@right = $compile.expression(@data.right, this)
		@right.analyse()
		
		@await = @right.isAwait()
	} // }}}
	prepare() { // {{{
		@left.prepare()
		@right.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	assignment(data) { // {{{
		let expression = this
		while expression._parent is not Statement {
			expression = expression._parent
		}
		
		return expression._parent.assignment(data, expression)
	} // }}}
	isAssignable() => true
	isAwait() => @await
	isAwaiting() => @right.isAwaiting()
	isComputed() => true
	isDeclararingVariable(name: String) => @variables.contains(name)
	isNullable() => @right.isNullable()
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

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	hasExceptions() => @right.isAwaiting() && @right.hasExceptions()
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
	} // }}}
	acquireReusable(acquire) { // {{{
		@right.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		@right.releaseReusable()
	} // }}}
	isAssignable() => false
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
			.code(', true) : false')
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
	acquireReusable(acquire) { // {{{
		@right.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		@right.releaseReusable()
	} // }}}
	isAssignable() => false
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
	isAssignable() => false
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

class AssignmentOperatorSubtraction extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left).code(' -= ').compile(@right)
	} // }}}
}