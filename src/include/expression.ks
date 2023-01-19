abstract class Expression extends AbstractNode {
	private {
		@leftMost: Expression?		= null
		@statement: Statement?		= null
	}
	acquireReusable(acquire)
	flagAssignable() { # {{{
		if !@isAssignable() {
			ReferenceException.throwInvalidAssignment(this)
		}
	} # }}}
	getDeclaredType() => @type()
	getDefaultValue(): String => 'null'
	getUnpreparedType() => AnyType.NullableUnexplicit
	// if the expression can throw an expception
	hasExceptions() => true
	// types after of the expression block
	inferTypes(inferables) => inferables
	// types if the condition is true
	inferWhenTrueTypes(inferables) => @inferTypes(inferables)
	// types if the condition is false
	inferWhenFalseTypes(inferables) => @inferTypes(inferables)
	initializeVariable(variable: VariableBrief, expression: Expression)
	// if the expression can be an assignment
	isAssignable() => false
	// if the expression is an `await` expression
	isAwait() => false
	// if the expression is awaiting to be resolved
	isAwaiting() => false
	// if the generated code, to cast the expression has a boolean, requires to be wrapped inside parentheses
	isBooleanComputed() => @isComputed() || !@type().isBoolean() || @type().isNullable()
	isBooleanComputed(junction: Junction) => @isBooleanComputed()
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
	// if the expression can be freely assigned
	isLiberal() => false
	// if the expression needs to be assign to a temp variable to be reused, expect for simple member expression
	isLooseComposite() => @isComposite()
	// if the type is matching the given type
	isMatchingType(type: Type) => @type().matchContentOf(type)
	// if the expression isn't empty
	isNotEmpty() => false
	// if the expression is nullable
	isNullable() => false
	// if the generated code, to test if the expression is null, requires to be wrapped inside parentheses
	isNullableComputed() => @isComputed()
	// if the expression's type can refined
	isRefinable() => false
	// if the expression should be skipped or not
	isSkippable() => false
	// if the expression is the given instance variable
	isUsingInstanceVariable(name) => false
	// if the expression is using any non-local vraiables
	isUsingNonLocalVariables(scope: Scope): Boolean => false
	// if the expression needs to use a setter function to assign a value
	isUsingSetter() => false
	// if the expression is the given static variable
	isUsingStaticVariable(class, varname) => false
	// if the expression is the given variable
	isUsingVariable(name) => false
	// if the expression generates multiple assignments
	isSplitAssignment() => false
	listLocalVariables(scope: Scope, variables: Array): Array => variables
	listNonLocalVariables(scope: Scope, variables: Array): Array => variables
	releaseReusable()
	setAssignment(assignment: AssignmentType)
	statement() { # {{{
		if !?@statement {
			@leftMost = this

			while @leftMost._parent is not Statement {
				@leftMost = @leftMost._parent!!
			}

			@statement = @leftMost._parent!!
		}

		return @statement
	} # }}}
	toArgumentFragments(fragments, mode = Mode::None) { # {{{
		this.toFragments(fragments, mode)
	} # }}}
	toArgumentFragments(fragments, type: Type, mode = Mode::None) { # {{{
		@toArgumentFragments(fragments, mode)
	} # }}}
	toCastingFragments(fragments, mode) { # {{{
		fragments.code($runtime.helper(this), '.valueOf(')

		this.toFragments(fragments, mode)

		fragments.code(')')
	} # }}}
	toConditionFragments(fragments, mode = Mode::None, junction = Junction::NONE) { # {{{
		this.toFragments(fragments, mode)

		if !@type().isBoolean() || @type().isNullable() {
			fragments.code(' === true')
		}
	} # }}}
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toOperandFragments(fragments, operator, type) => this.toFragments(fragments, Mode::None)
	toQuote(): String { # {{{
		throw new NotSupportedException()
	} # }}}
	toQuote(double: Boolean): String { # {{{
		return double ? `"\(@toQuote())"` : `'\(@toQuote())'`
	} # }}}
	toReusableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toStringFragments(fragments) { # {{{
		var type = @type()
		if type.isReference() && type.type().isEnum() {
			fragments.compile(this).code('.value')
		}
		else {
			fragments.wrap(this)
		}
	} # }}}
	toTypeQuote() => @type().toQuote()
	type() => AnyType.NullableUnexplicit
	unflagExpectingEnum()
	validateType(type: Type)
	variable() => null
}

include {
	'../expression/literal'
	'../expression/array'
	'../expression/array-comprehension'
	'../expression/await'
	'../expression/binding'
	'../expression/call/index'
	'../expression/conditional'
	'../expression/create'
	'../expression/curry'
	'../expression/enum'
	'../expression/function'
	'../expression/if'
	'../expression/if-variable'
	'../expression/member'
	'../expression/object'
	'../expression/omitted'
	'../expression/regex'
	'../expression/sequence'
	'../expression/template'
	'../expression/this'
	'../expression/try'
	'../expression/unless'

	'../expression/misc'
}
