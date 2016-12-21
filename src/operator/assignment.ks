class AssignmentOperatorExpression extends Expression {
	private {
		_left
		_right
	}
	isAssignable() => true
	isComputed() => true
	isNullable() => this._right.isNullable()
	analyse() { // {{{
		let data = this._data
		
		this.assignment(data)
		
		this._left = $compile.expression(data.left, this)
		this._right = $compile.expression(data.right, this)
	} // }}}
	assignment(data) { // {{{
		let expression = this
		while !(expression._parent is Statement) {
			expression = expression._parent
		}
		
		expression._parent.assignment(data, expression)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toNullableFragments(fragments) { // {{{
		fragments.compileNullable(this._right)
	} // }}}
}

class AssignmentOperatorAddition extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' += ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseAnd extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' &= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseLeftShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' <<= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseOr extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' |= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseRightShift extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' >>= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorBitwiseXor extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' ^= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorEquality extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code($equals).compile(this._right)
	} // }}}
	toAssignmentFragments(fragments) { // {{{
		if this._left.toAssignmentFragments? {
			this._left.toAssignmentFragments(fragments)
			
			fragments.code($equals).compile(this._right)
		}
		else {
			fragments.compile(this._left).code($equals).compile(this._right)
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code($equals).wrap(this._right)
	} // }}}
}

class AssignmentOperatorExistential extends AssignmentOperatorExpression {
	acquireReusable(acquire) { // {{{
		this._right.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		this._right.releaseReusable()
	} // }}}
	isAssignable() => false
	toFragments(fragments, mode) { // {{{
		if this._right.isNullable() {
			fragments
				.wrapNullable(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		
		fragments
			.code(' ? ')
			.compile(this._left)
			.code($equals)
			.wrap(this._right)
			.code(' : undefined')
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if this._right.isNullable() {
			fragments
				.wrapNullable(this._right)
				.code(' && ')
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(', this._data.operator)
				.compileReusable(this._right)
				.code(')', this._data.operator)
		}
		
		fragments
			.code(' ? (')
			.compile(this._left)
			.code($equals)
			.wrap(this._right)
			.code(', true) : false')
	} // }}}
}

class AssignmentOperatorModulo extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' %= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorMultiplication extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' *= ').compile(this._right)
	} // }}}
}

class AssignmentOperatorNullCoalescing extends AssignmentOperatorExpression {
	isAssignable() => false
	toFragments(fragments, mode) { // {{{
		if this._left.isNullable() {
			fragments.code('(')
			
			this._left.toNullableFragments(fragments)
			
			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code(')')
		}
		
		fragments
			.code(' ? undefined : ')
			.compile(this._left)
			.code($equals)
			.compile(this._right)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(!')
		
		if this._left.isNullable() {
			ctrl.code('(')
			
			this._left.toNullableFragments(ctrl)
			
			ctrl
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code('))')
		}
		else {
			ctrl
				.code($runtime.type(this) + '.isValue(')
				.compile(this._left)
				.code(')')
		}
		
		ctrl
			.code(')')
			.step()
			.newLine()
			.compile(this._left)
			.code($equals)
			.compile(this._right)
			.done()
		
		ctrl.done()
	} // }}}
}

class AssignmentOperatorSubtraction extends AssignmentOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left).code(' -= ').compile(this._right)
	} // }}}
}