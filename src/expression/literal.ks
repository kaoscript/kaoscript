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
} // }}}

abstract class Literal extends Expression {
	private {
		_value
	}
	constructor(data, parent, scope, @value) { // {{{
		super(data, parent, scope)
	} // }}}
	analyse()
	prepare()
	translate()
	isComposite() => false
	isEntangled() => false
	toFragments(fragments, mode) { // {{{
		if @data {
			fragments.code(@value, @data)
		}
		else {
			fragments.code(@value)
		}
	} // }}}
}

class IdentifierLiteral extends Literal {
	private {
		_isVariable = false
		_variable
	}
	constructor(data, parent, scope = parent.scope(), variable = true) { // {{{
		super(data, parent, scope, data.name)
		
		if variable && !($predefined[data.name] == true || $runtime.isDefined(data.name, parent)) {
			if parent is MemberExpression {
				if parent._data.object == data {
					@isVariable = true
				}
				else if parent._data.computed && parent._data.property == data {
					@isVariable = true
				}
			}
			else {
				@isVariable = true
			}
		}
		
		if @isVariable && (@variable !?= @scope.getVariable(data.name)) {
			ReferenceException.throwNotDefined(data.name, this)
		}
	} // }}}
	name() => @value
	toFragments(fragments, mode) { // {{{
		if @isVariable {
			fragments.code(@scope.getRenamedVariable(@value), @data)
		}
		else {
			fragments.code(@value, @data)
		}
	} // }}}
	type() => @variable.type()
}

class NumberLiteral extends Literal { // {{{
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.value)
	} // }}}
	type() => Type.Number
} // }}}

class StringLiteral extends Literal { // {{{
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
	type() => Type.String
} // }}}