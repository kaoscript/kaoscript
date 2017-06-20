class PolyadicOperatorExpression extends Expression {
	private {
		_operands
		_tested = false
	}
	analyse() { // {{{
		@operands = []
		for operand in @data.operands {
			@operands.push(operand = $compile.expression(operand, this))
			
			operand.analyse()
		}
	} // }}}
	prepare() { // {{{
		for operand in @operands {
			operand.prepare()
		}
	} // }}}
	translate() { // {{{
		for operand in @operands {
			operand.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		for i from 0 til @operands.length {
			@operands[i].acquireReusable(false)
			@operands[i].releaseReusable()
		}
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	hasExceptions() => false
	isComputed() => true
	isNullable() { // {{{
		for operand in @operands {
			if operand.isNullable() {
				return true
			}
		}
		
		return false
	} // }}}
	isUsingVariable(name) { // {{{
		for operand in @operands {
			if operand.isUsingVariable(name) {
				return true
			}
		}
		
		return false
	} // }}}
	toFragments(fragments, mode) { // {{{
		let test = this.isNullable() && !@tested
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
		if !@tested {
			let nf = false
			for operand in @operands {
				if operand.isNullable() {
					if nf {
						fragments.code(' && ')
					}
					else {
						nf = true
					}
					
					fragments.compileNullable(operand)
				}
			}
			
			@tested = true
		}
	} // }}}
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('+', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type(): Type { // {{{
		if @operands[0].type().isNumber() || @operands[0].type().isString() {
			return @operands[0].type()
		}
		else {
			return new UnionType([@scope.reference('Number'), @scope.reference('String')])
		}
	} // }}}
}

class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	toFragments(fragments, mode) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('&&', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorBitwiseAnd extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('&', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorBitwiseLeftShift extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('<<', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorBitwiseOr extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('|', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorBitwiseRightShift extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('>>', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorBitwiseXor extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('^', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorDivision extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('/', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorEquality extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let l = @operands.length - 1
		
		for i from 0 til l {
			fragments.code(' && ') if i
			
			fragments
				.compile(@operands[i])
				.code(' === ')
				.compile(@operands[i + 1])
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorGreaterThan extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til @operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(@operands[i])
				.code($space)
				.code('>', @data.operator)
				.code($space)
				.wrap(@operands[i + 1])
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorGreaterThanOrEqual extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til @operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(@operands[i])
				.code($space)
				.code('>=', @data.operator)
				.code($space)
				.wrap(@operands[i + 1])
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorLessThan extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til @operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(@operands[i])
				.code($space)
				.code('<', @data.operator)
				.code($space)
				.wrap(@operands[i + 1])
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorLessThanOrEqual extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til @operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(@operands[i])
				.code($space)
				.code('<=', @data.operator)
				.code($space)
				.wrap(@operands[i + 1])
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorMultiplication extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('*', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorModulo extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('%', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	private {
		_type: Type
	}
	constructor(@data, @parent, @scope = new Scope(parent.scope())) { // {{{
		super(data, parent, scope)
	} // }}}
	analyse() { // {{{
		@operands = []
		for operand in @data.operands {
			@operands.push(operand = $compile.expression(operand, this, this.newScope()))
			
			operand.analyse()
		}
	} // }}}
	prepare() { // {{{
		const types = []
		
		let operandType, type, ne
		for operand in @operands {
			operand.prepare()
			
			operand.acquireReusable(true)
			operand.releaseReusable()
			
			operandType = operand.type()
			ne = true
			
			for type in types while ne {
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
			@type = new UnionType(types)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		for i from 0 to @operands.length - 2 {
			@operands[i].acquireReusable(true)
			@operands[i].releaseReusable()
		}
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Type')
		
		let l = @operands.length - 1
		
		let operand
		for i from 0 til l {
			operand = @operands[i]
			
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
	} // }}}
	type() => @type
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	toFragments(fragments, mode) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('||', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
	type() => @scope.reference('Boolean')
}

class PolyadicOperatorSubtraction extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in @operands {
			if nf {
				fragments
					.code($space)
					.code('-', @data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
	type() => @scope.reference('Number')
}