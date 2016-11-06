class BinaryOperatorExpression extends Expression {
	private {
		_left
		_right
		_tested = false
	}
	isComputed() => true
	isNullable() => this._left.isNullable() || this._right.isNullable()
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
		this._right = $compile.expression(this._data.right, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
		this._right.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		let test = this.isNullable() && !this._tested
		if test {
			fragments
				.compileNullable(this)
				.code(' ? ')
		}
		
		this.toOperatorFragments(fragments)
		
		if test {
			fragments.code(' : false')
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			if this._left.isNullable() {
				fragments.compileNullable(this._left)
				
				if this._right.isNullable() {
					fragments.code(' && ').compileNullable(this._right)
				}
			}
			else {
				fragments.compileNullable(this._right)
			}
			
			this._tested = true
		}
	} // }}}
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('+', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrapBoolean(this._left)
			.code($space)
			.code('&&', this._data.operator)
			.code($space)
			.wrapBoolean(this._right)
	} // }}}
}

class BinaryOperatorBitwiseAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('&', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseLeftShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<<', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('|', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseRightShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>>', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorBitwiseXor extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('^', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorDivision extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('/', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorEquality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('===', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorGreaterThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorGreaterThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('>=', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorInequality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('!==', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorLessThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorLessThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('<=', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('%', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space)
			.code('*', this._data.operator)
			.code($space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	analyse() { // {{{
		super.analyse()
		
		if this._data.left != Kind::Identifier {
			this._left.analyseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._left.isNullable() {
			fragments.code('(')
			
			this._left.toNullableFragments(fragments)
			
			fragments
				.code(' && ' + $runtime.type(this) + '.isValue(')
				.compileReusable(this._left)
				.code('))')
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compileReusable(this._left)
				.code(')')
		}
		
		fragments
			.code(' ? ')
			.compile(this._left)
			.code(' : ')
			.wrap(this._right)
	} // }}}}
}

class BinaryOperatorOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrapBoolean(this._left)
			.code($space)
			.code('||', this._data.operator)
			.code($space)
			.wrapBoolean(this._right)
	} // }}}
}

class BinaryOperatorSubtraction extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(this._left)
			.code($space, '-', this._data.operator, $space)
			.wrap(this._right)
	} // }}}
}

class BinaryOperatorTypeCast extends Expression {
	private {
		_left
	}
	isComputed() => false
	isNullable() => this._left.isNullable()
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.compile(this._left)
	} // }}}
}

class BinaryOperatorTypeCheck extends Expression {
	isComputed() => false
	isNullable() => false
	analyse() { // {{{
		this._left = $compile.expression(this._data.left, this)
	} // }}}
	fuse() { // {{{
		this._left.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		$type.check(this, fragments, this._left, this._data.right)
	} // }}}
}