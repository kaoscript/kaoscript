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
		_assignment: AssignmentType		= AssignmentType::Neither
		_declaredType: Type
		_isMacro: Boolean				= false
		_isVariable: Boolean			= false
		_realType: Type
	}
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.name)
	} // }}}
	analyse() { // {{{
		if @assignment == AssignmentType::Neither {
			if @scope.hasVariable(@value) {
				@isVariable = true
			}
			else if $runtime.isDefined(@value, @parent) {
				@realType = @declaredType = Type.Any
			}
			else if @scope.hasMacro(@value) {
				@isMacro = true
			}
			else {
				ReferenceException.throwNotDefined(@value, this)
			}
		}
		else {
			@isVariable = true
		}
	} // }}}
	prepare() { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value)

			@declaredType = variable.getDeclaredType()
			@realType = variable.getRealType()
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@value, this)
	} // }}}
	getDeclaredType() => @declaredType
	isAssignable() => true
	isDeclararingVariable(name: String) => @value == name
	isMacro() => @isMacro
	isRedeclared() => @scope.isRedeclaredVariable(@value)
	isRenamed() => @scope.isRenamedVariable(@value)
	isUsingVariable(name) => @value == name
	listAssignments(array) { // {{{
		array.push(@name)

		return array
	} // }}}
	name() => @value
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		fragments.code(@scope.getRenamedVariable(@value), @data)
	} // }}}
	type() => @realType
	type(type: Type, scope: Scope, node) { // {{{
		if @isVariable {
			@realType = scope.replaceVariable(@name, type, node).getRealType()
		}
	} // }}}
	variable() => @scope.getVariable(@value)
	walk(fn) { // {{{
		if @isVariable {
			fn(@value, @realType)
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