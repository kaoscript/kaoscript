const $predefined = { // {{{
	false: true
	null: true
	string: true
	true: true
	Error: true
	Function: true
	Infinity: true
	Math: true
	NaN: true
	Object: true
	String: true
	Type: true
} // }}}

class Literal extends Expression {
	private {
		_value
	}
	$create(data, parent, scope, @value) { // {{{
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
	$create(data, parent, scope = parent.scope(), variable = true) { // {{{
		super(data, parent, scope, data.name)
		
		if variable && $predefined[data.name] != true {
			if parent is MemberExpression {
				if parent._data.object == data {
					this._isVariable = true
				}
				else if parent._data.computed && parent._data.property == data {
					this._isVariable = true
				}
			}
			else {
				this._isVariable = true
			}
		}
		
		if this._isVariable && !this._scope.hasVariable(data.name) {
			$throw(`Undefined variable '\(data.name)' at line \(data.start.line)`, this)
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
	$create(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.value)
	} // }}}
} // }}}

class StringLiteral extends Literal { // {{{
	$create(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
} // }}}