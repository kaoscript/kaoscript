class BinaryOperatorExpression extends Expression {
	private {
		_left
		_right
		_tested = false
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
		
		@right = $compile.expression(@data.right, this)
		@right.analyse()
	} // }}}
	prepare() { // {{{
		@left.prepare()
		@right.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
		@right.translate()
	} // }}}
	isComputed() => true
	isNullable() => @left.isNullable() || @right.isNullable()
	isNullableComputed() => (@left.isNullable() && @right.isNullable()) || @left.isNullableComputed() || @right.isNullableComputed()
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(false)
		@right.acquireReusable(false)
	} // }}}
	releaseReusable() { // {{{
		@left.releaseReusable()
		@right.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			fragments
				.wrapNullable(this)
				.code(' ? ')
			
			this.toOperatorFragments(fragments)
			
			fragments.code(' : false')
		}
		else {
			this.toOperatorFragments(fragments)
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			if @left.isNullable() {
				fragments.compileNullable(@left)
				
				if @right.isNullable() {
					fragments.code(' && ').compileNullable(@right)
				}
			}
			else {
				fragments.compileNullable(@right)
			}
			
			@tested = true
		}
	} // }}}
}

class BinaryOperatorAddition extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('+', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type(): Type { // {{{
		if @left.type().isNumber() || @left.type().isString() {
			return @left.type()
		}
		else {
			return new UnionType([@scope.reference('Number'), @scope.reference('String')])
		}
	} // }}}
}

class BinaryOperatorAnd extends BinaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@left)
			.code($space)
			.code('&&', @data.operator)
			.code($space)
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorBitwiseAnd extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('&', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseLeftShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('<<', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseOr extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('|', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseRightShift extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('>>', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorBitwiseXor extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('^', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorDivision extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('/', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorEquality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('===', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorGreaterThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('>', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorGreaterThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('>=', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorInequality extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('!==', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorLessThan extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('<', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorLessThanOrEqual extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('<=', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorModulo extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('%', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorMultiplication extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space)
			.code('*', @data.operator)
			.code($space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorNullCoalescing extends BinaryOperatorExpression {
	private {
		_type: Type
	}
	prepare() { // {{{
		super.prepare()
		
		@left.acquireReusable(true)
		@left.releaseReusable()
		
		if @left.type().equals(@right.type()) {
			@type = @left.type()
		}
		else {
			@type = new UnionType([@left.type(), @right.type()])
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@left.acquireReusable(true)
	} // }}}
	releaseReusable() { // {{{
		@left.releaseReusable()
	} // }}}
	toFragments(fragments, mode) { // {{{
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
			.wrap(@right)
	} // }}}}
	type() => @type
}

class BinaryOperatorOr extends BinaryOperatorExpression {
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(@left)
			.code($space)
			.code('||', @data.operator)
			.code($space)
			.wrapBoolean(@right)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorSubtraction extends BinaryOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		fragments
			.wrap(@left)
			.code($space, '-', @data.operator, $space)
			.wrap(@right)
	} // }}}
	type() => @scope.reference('Number')
}

class BinaryOperatorTypeCasting extends Expression {
	private {
		_left
		_type: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
		
		@type = Type.fromAST(@data.right, this)
	} // }}}
	prepare() { // {{{
		@left.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	isComputed() => false
	isNullable() => @left.isNullable()
	toFragments(fragments, mode) { // {{{
		fragments.compile(@left)
	} // }}}
	type() => @type
}

class BinaryOperatorTypeEquality extends Expression {
	private {
		_left
		_type: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
		
		@type = Type.fromAST(@data.right, this)
	} // }}}
	prepare() { // {{{
		@left.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	isComputed() => false
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		@type.toTestFragments(fragments, @left)
	} // }}}
	type() => @scope.reference('Boolean')
}

class BinaryOperatorTypeInequality extends Expression {
	private {
		_left
		_type: Type
	}
	analyse() { // {{{
		@left = $compile.expression(@data.left, this)
		@left.analyse()
		
		@type = Type.fromAST(@data.right, this)
	} // }}}
	prepare() { // {{{
		@left.prepare()
	} // }}}
	translate() { // {{{
		@left.translate()
	} // }}}
	isComputed() => false
	isNullable() => false
	toFragments(fragments, mode) { // {{{
		if @data.right.kind == NodeKind::TypeReference {
			fragments.code('!')
			
			@type.toTestFragments(fragments, @left)
		}
		else if @data.right.types? {
			fragments.code('!(')
			
			@type.toTestFragments(fragments, @left)
			
			fragments.code(')')
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}