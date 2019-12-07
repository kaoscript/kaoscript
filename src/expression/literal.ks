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
	isUsingVariable(name) => false
	listAssignments(array) => array
	toFragments(fragments, mode) { // {{{
		if @data {
			fragments.code(@value, @data)
		}
		else {
			fragments.code(@value)
		}
	} // }}}
	toQuote() => @value
	value() => @value
}

class IdentifierLiteral extends Literal {
	private {
		_assignment: AssignmentType		= AssignmentType::Neither
		_declaredType: Type
		_isMacro: Boolean				= false
		_isVariable: Boolean			= false
		_line: Number
		_realType: Type
	}
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.name)
	} // }}}
	analyse() { // {{{
		if @assignment == AssignmentType::Neither {
			if @scope.hasVariable(@value) {
				@isVariable = true
				@line = @scope.line()

				if @value == 'Dictionary' {
					this.module().flag('Dictionary')
				}
			}
			else if @scope.hasMacro(@value) {
				@isMacro = true
			}
			else if const name = $runtime.getVariable(@value, @parent) {
				@value = name
				@realType = @declaredType = Type.Any
			}
			else {
				ReferenceException.throwNotDefined(@value, this)
			}
		}
		else {
			@isVariable = true
			@line = @scope.line()
		}
	} // }}}
	prepare() { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			if @scope.hasDeclaredVariable(@value) && !@scope.hasDefinedVariable(@value, @line) {
				@scope.renameNext(@value, @line)
			}

			if @assignment == AssignmentType::Neither && variable.isLateInit() && variable.isImmutable() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedVariable(@value, this)
			}

			@declaredType = variable.getDeclaredType()
			@realType = variable.getRealType()
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@value, this)
	} // }}}
	getDeclaredType() => @declaredType
	isAssignable() => true
	isDeclarable() => true
	isDeclararingVariable(name: String) => @value == name
	isExpectingType() { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			return variable.isDefinitive()
		}
		else {
			return false
		}
	} // }}}
	isMacro() => @isMacro
	isRedeclared() => @scope.isRedeclaredVariable(@value)
	isRenamed() => @scope.isRenamedVariable(@value)
	isInferable() => true
	isUsingVariable(name) => @value == name
	listAssignments(array) { // {{{
		array.push(@name)

		return array
	} // }}}
	name() => @value
	path() => @value
	setAssignment(@assignment)
	toFragments(fragments, mode) { // {{{
		if @isVariable {
			fragments.compile(@scope.getVariable(@value, @line))
		}
		else {
			fragments.code(@value, @data)
		}
	} // }}}
	type() => @realType
	type(type: Type, scope: Scope, node) { // {{{
		if @isVariable {
			@realType = scope.replaceVariable(@name, type, node).getRealType()
		}
	} // }}}
	variable() => @scope.getVariable(@value, @line)
	walk(fn) { // {{{
		if @isVariable {
			fn(@value, @realType)
		}
		else {
			throw new NotSupportedException()
		}
	} // }}}
}

class NumberLiteral extends Literal {
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, data.value)
	} // }}}
	isUsingVariable(name) => false
	type() => @scope.reference('Number')
}

class StringLiteral extends Literal {
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
	type() => @scope.reference('String')
}