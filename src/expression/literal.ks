const $predefined = { // {{{
	__false(scope) => scope.reference('Boolean')
	__null(scope) => Type.Any
	__true(scope) => scope.reference('Boolean')
	__Error(scope) => scope.reference('Error')
	__Function(scope) => scope.reference('Function')
	__Infinity(scope) => scope.reference('Number')
	__Math(scope) => scope.reference('Object')
	__Number(scope) => scope.reference('Number')
	__NaN(scope) => scope.reference('Number')
	__Object(scope) => scope.reference('Object')
	__String(scope) => scope.reference('String')
	__RegExp(scope) => scope.reference('RegExp')
} // }}}

class Literal extends Expression {
	private {
		_value
	}
	constructor(@value, @parent) { // {{{
		super(false, parent)
	} // }}}
	constructor(data, parent, scope, @value) { // {{{
		super(data, parent, scope)
	} // }}}
	analyse()
	prepare()
	translate()
	hasExceptions() => false
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
	value() => @value
}

class IdentifierLiteral extends Literal {
	private {
		_isVariable: Boolean	= false
		_variable: Variable
		_type: Type
	}
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.name)
	} // }}}
	analyse() { // {{{
		if @variable ?= @scope.getVariable(@value) {
			@isVariable = true
		}
		else if $predefined[`__\(@value)`] is Function {
			@type = $predefined[`__\(@value)`](@scope)
		}
		else if $runtime.isDefined(@value, @parent) {
			@type = Type.Any
		}
		else {
			ReferenceException.throwNotDefined(@value, this)
		}
	} // }}}
	prepare() { // {{{
		if @isVariable {
			@type = @variable.type()
		}
	} // }}}
	name() => @value
	toFragments(fragments, mode) { // {{{
		fragments.code(@scope.getRenamedVariable(@value), @data)
	} // }}}
	type() => @type
	walk(fn) { // {{{
		if @isVariable {
			fn(@value, @type)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
}

class NumberLiteral extends Literal { // {{{
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.value)
	} // }}}
	type() => @scope.reference('Number')
} // }}}

class StringLiteral extends Literal { // {{{
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
	type() => @scope.reference('String')
} // }}}