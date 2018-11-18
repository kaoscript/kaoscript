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
	isUsingVariable(name) => false
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
		_assignenement			= null
		_isMacro: Boolean		= false
		_isVariable: Boolean	= false
		_variable: Variable
		_type: Type
	}
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.name)
		
		const statement = parent.statement()
		while parent != statement {
			if parent is AssignmentOperatorExpression {
				@assignenement = parent
				break
			}
			
			parent = parent.parent()
		}
		
		if @assignenement == null && statement is VariableDeclaration {
			@assignenement = statement
		}
	} // }}}
	analyse() { // {{{
		if @assignenement != null && @assignenement.isDeclararingVariable(@name) {
			ReferenceException.throwSelfDefinedVariable(@value, this)
		}
		else if @variable ?= @scope.getVariable(@value) {
			@isVariable = true
		}
		else if $runtime.isDefined(@value, @parent) {
			@type = Type.Any
		}
		else if @scope.hasMacro(@value) {
			@isMacro = true
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
	isMacro() => @isMacro
	isUsingVariable(name) => @value == name
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
	isUsingVariable(name) => false
	type() => @scope.reference('Number')
} // }}}

class StringLiteral extends Literal { // {{{
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
	type() => @scope.reference('String')
} // }}}