class PolyadicOperatorExpression extends Expression {
	private {
		_operands
		_tested = false
	}
	isComputed() => true
	isNullable() { // {{{
		for operand in this._operands {
			return true if operand.isNullable()
		}
		
		return false
	} // }}}
	analyse() { // {{{
		this._operands = [$compile.expression(operand, this) for operand in this._data.operands]
	} // }}}
	fuse() { // {{{
		for operand in this._operands {
			operand.fuse()
		}
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
			let nf = false
			for operand in this._operands {
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
			
			this._tested = true
		}
	} // }}}
}

class PolyadicOperatorAddition extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('+', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
}

class PolyadicOperatorAnd extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('&&', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
}

class PolyadicOperatorLessThanOrEqual extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		for i from 0 til this._operands.length - 1 {
			fragments.code(' && ') if i
			
			fragments
				.wrap(this._operands[i])
				.code($space)
				.code('<=', this._data.operator)
				.code($space)
				.wrap(this._operands[i + 1])
		}
	} // }}}
}

class PolyadicOperatorMultiplication extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('*', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrap(operand)
		}
	} // }}}
}

class PolyadicOperatorNullCoalescing extends PolyadicOperatorExpression {
	PolyadicOperatorNullCoalescing(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._operands = [$compile.expression(operand, this, this.newScope()) for operand in this._data.operands]
	} // }}}
	acquireReusable(acquire) { // {{{
		for i from 0 to this._operands.length - 2 {
			this._operands[i].acquireReusable(true)
			this._operands[i].releaseReusable()
		}
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Type')
		
		let l = this._operands.length - 1
		
		let operand
		for i from 0 til l {
			operand = this._operands[i]
			
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
		
		fragments.compile(this._operands[l])
	} // }}}
}

class PolyadicOperatorOr extends PolyadicOperatorExpression {
	toOperatorFragments(fragments) { // {{{
		let nf = false
		for operand in this._operands {
			if nf {
				fragments
					.code($space)
					.code('||', this._data.operator)
					.code($space)
			}
			else {
				nf = true
			}
			
			fragments.wrapBoolean(operand)
		}
	} // }}}
}