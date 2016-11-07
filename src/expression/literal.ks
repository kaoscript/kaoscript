class Literal extends Expression {
	private {
		_value
	}
	Literal(data, parent, scope, @value) { // {{{
		super(data, parent, scope)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	isComposite() => false
	isEntangled() => false
	toFragments(fragments, mode) { // {{{
		if this._data {
			fragments.code(this._value, this._data)
		}
		else {
			fragments.code(this._value)
		}
	} // }}}
}

class IdentifierLiteral extends Literal {
	private {
		_isVariable = false
	}
	IdentifierLiteral(data, parent, scope = parent.scope(), variable = true) { // {{{
		super(data, parent, scope, data.name)
		
		if variable && !((parent is MemberExpression && parent._data.object != data) || $predefined[data.name]) {
			this._isVariable = true
			
			if !this._scope.hasVariable(data.name) {
				throw new Error(`Undefined variable '\(data.name)' at line \(data.start.line)`)
			}
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._isVariable {
			fragments.code(this._scope.getRenamedVariable(this._value), this._data)
		}
		else {
			fragments.code(this._value, this._data)
		}
	} // }}}
}

class NumberLiteral extends Literal { // {{{
	NumberLiteral(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.value)
	} // }}}
} // }}}

class StringLiteral extends Literal { // {{{
	StringLiteral(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
} // }}}