abstract class Expression extends AbstractNode {
	private {
		_castingEnum: Boolean		= false
	}
	acquireReusable(acquire)
	checkIfAssignable() { // {{{
		if !this.isAssignable() {
			ReferenceException.throwInvalidAssignment(this)
		}
	} // }}}
	getDeclaredType() => this.type()
	getUnpreparedType() => AnyType.NullableUnexplicit
	// if the expression can throw an expception
	hasExceptions() => true
	// types after of the expression block
	inferTypes(inferables) => inferables
	// types if the condition is true
	inferWhenTrueTypes(inferables) => this.inferTypes(inferables)
	// types if the condition is false
	inferWhenFalseTypes(inferables) => this.inferTypes(inferables)
	initializeVariable(variable: VariableBrief, expression: Expression)
	// if the expression can be an assignment
	isAssignable() => false
	// if the expression is an `await` expression
	isAwait() => false
	// if the expression is awaiting to be resolved
	isAwaiting() => false
	// if the generated code, to cast the expression has a boolean, requires to be wrapped inside parentheses
	isBooleanComputed() => this.isComputed() || !this.type().isBoolean() || this.type().isNullable()
	// if the expression contains a call
	isCallable() => false
	// if the expression needs to be assign to a temp variable to be reused
	isComposite() => true
	// if parentheses are required around the expression to be wrapped
	isComputed() => false
	// if the expression can be an assignment and be transformed as a declaration
	isDeclarable() => false
	// if the expression is always exiting
	isExit() => false
	// if the expression can be an assignment and the variable has a defined type
	isExpectingType() => false
	// if the expression can be ignored (like a variable casting)
	isIgnorable() => false
	// if the expression is a variable and needs to be initialized
	isInitializable() => false
	// if the expression is initializing the given instance variable
	isInitializingInstanceVariable(name: String): Boolean => false
	// if the associated type can be updated (it's a chunck or a variable)
	isInferable() => false
	// if the expression is a lateinit field
	isLateInit() => false
	// if the expression needs to be assign to a temp variable to be reused, expect for simple member expression
	isLooseComposite() => this.isComposite()
	// if the type is matching the given type
	isMatchingType(type: Type) => this.type().matchContentOf(type)
	// if the expression is nullable
	isNullable() => false
	// if the generated code, to test if the expression is null, requires to be wrapped inside parentheses
	isNullableComputed() => this.isComputed()
	// if the expression is the given instance variable
	isUsingInstanceVariable(name) => false
	// if the expression needs to use a setter function to assign a value
	isUsingSetter() => false
	// if the expression is the given static variable
	isUsingStaticVariable(class, varname) => false
	// if the expression is the given variable
	isUsingVariable(name) => false
	// if the expression generates multiple assignments
	isSplitAssignment() => false
	releaseReusable()
	setAssignment(type: AssignmentType)
	setCastingEnum(@castingEnum)
	setExpectedType(type: Type): Void
	statement(data) { // {{{
		let expression = this

		while expression._parent is not Statement {
			expression = expression._parent
		}

		return expression._parent
	} // }}}
	toArgumentFragments(fragments, mode = Mode::None) { // {{{
		this.toFragments(fragments, mode)

		if @castingEnum {
			fragments.code('.value')
		}
	} // }}}
	toBooleanFragments(fragments, mode = Mode::None) { // {{{
		this.toFragments(fragments, mode)

		if !this.type().isBoolean() || this.type().isNullable() {
			fragments.code(' === true')
		}
	} // }}}
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toOperandFragments(fragments, operator, type) => this.toFragments(fragments, Mode::None)
	toQuote(): String { // {{{
		throw new NotSupportedException()
	} // }}}
	toQuote(double: Boolean): String { // {{{
		if double {
			return `"\(this.toQuote())"`
		}
		else {
			return `'\(this.toQuote())'`
		}
	} // }}}
	toReusableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toStringFragments(fragments) { // {{{
		const type = this.type()
		if type.isReference() && type.type().isEnum() {
			fragments.compile(this).code('.value')
		}
		else {
			fragments.wrap(this)
		}
	} // }}}
	type() => AnyType.NullableUnexplicit
	variable() => null
}

include {
	'../expression/literal'
	'../expression/array'
	'../expression/array-comprehension'
	'../expression/await'
	'../expression/binding'
	'../expression/call'
	'../expression/conditional'
	'../expression/create'
	'../expression/curry'
	'../expression/dictionary'
	'../expression/enum'
	'../expression/function'
	'../expression/if'
	'../expression/if-variable'
	'../expression/member'
	'../expression/omitted'
	'../expression/regex'
	'../expression/sequence'
	'../expression/template'
	'../expression/this'
	'../expression/try'
	'../expression/unless'

	'../expression/misc'
}