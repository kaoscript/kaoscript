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
	listAssignments(array) => array
	override listNonLocalVariables(scope, variables) => variables
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
	private lateinit {
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

			if @scope.hasDeclaredVariable(@value) && !@scope.hasDefinedVariable(@value, @line) && !variable.isPredefined() {
				@scope.renameNext(@value, @line)
			}

			if @assignment == AssignmentType::Neither && variable.isLateInit() && !variable.isInitialized() {
				SyntaxException.throwNotInitializedVariable(@value, this)
			}

			@declaredType = variable.getDeclaredType()
			@realType = variable.getRealType()
		}
	} // }}}
	checkIfAssignable() { // {{{
		if @isVariable {
			if const variable = @scope.getVariable(@value, @line) {
				if variable.isImmutable() {
					if variable.isLateInit() {
						if variable.isInitialized() {
							ReferenceException.throwImmutable(@value, this)
						}
					}
					else {
						ReferenceException.throwImmutable(@value, this)
					}
				}
			}
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@value, this)
	} // }}}
	getVariableDeclaration(class) { // {{{
		return class.getInstanceVariable(@value)
	} // }}}
	getDeclaredType() => @declaredType
	getUnpreparedType() { // {{{
		if @isVariable {
			return @scope.getVariable(@value, @line).getRealType()
		}
		else {
			return @realType
		}
	} // }}}
	initializeVariables(type: Type, node: Expression) { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			if variable.isLateInit() {
				node.initializeVariable(VariableBrief(
					name: @value
					type
					immutable: true
					lateInit: true
				))
			}
		}
	} // }}}
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
	override isUsingNonLocalVariables(scope) { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isPredefined() && !scope.hasDeclaredVariable(@value) {
				return true
			}
		}

		return false
	} // }}}
	isUsingVariable(name) => @value == name
	listAssignments(array) { // {{{
		array.push(@name)

		return array
	} // }}}
	override listLocalVariables(scope, variables) { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isPredefined() && scope.hasDeclaredVariable(@value) {
				variables.pushUniq(variable)
			}
		}

		return variables
	} // }}}
	override listNonLocalVariables(scope, variables) { // {{{
		if @isVariable {
			const variable = @scope.getVariable(@value, @line)

			if @value != 'this' && !variable.isModule() && !scope.hasDeclaredVariable(@value) {
				variables.pushUniq(variable)
			}
		}

		return variables
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
	getUnpreparedType() => this.type()
	type() => @scope.reference('Number')
}

class StringLiteral extends Literal {
	constructor(data, parent, scope = parent.scope()) { // {{{
		super(data, parent, scope, $quote(data.value))
	} // }}}
	getUnpreparedType() => this.type()
	type() => @scope.reference('String')
}