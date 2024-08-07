abstract class Expression extends AbstractNode {
	private {
		@leftMost: Expression?		= null
		@statement: Statement?		= null
	}
	acquireReusable(acquire)
	argument() => this
	canBeNull(): Boolean => @type().isNullable()
	flagAssignable() { # {{{
		if !@isAssignable() {
			ReferenceException.throwInvalidAssignment(this)
		}
	} # }}}
	flagNewExpression()
	flagNotNull(operator: String)
	getDeclaredType() => @type()
	getDefaultValue(): String => 'null'
	getReuseName(): String? => null
	getTestedType(): Type => @type()
	getUnpreparedType() => AnyType.NullableUnexplicit
	// if the expression can throw an expception
	hasExceptions(): Boolean => true
	inferProperty(property: Type, inferables) => inferables
	// types after of the expression block
	inferTypes(inferables) => inferables
	// types if the condition is true
	inferWhenTrueTypes(inferables) => @inferTypes(inferables)
	// types if the condition is false
	inferWhenFalseTypes(inferables) => @inferTypes(inferables)
	initializeVariable(variable: VariableBrief, expression: Expression)
	isAccessibleAliasType(value: IdentifierLiteral): Boolean => false
	// if the expression can be an assignment
	isAssignable(): Boolean => false
	isAssignedInLoop(value: Expression): Boolean => false
	assist isAssignedInLoop(value: IdentifierLiteral) { # {{{
		var name = value.name()

		var mut current = @statement()
		var mut previous = current

		repeat {
			var loop = current.getLoopAncestorWithoutNew(name, previous)

			return false if !?loop

			return true if loop.isInitializingVariableAfter(name, previous)

			previous = current
			current = loop.parent()
		}

		return false
	} # }}}
	// if the expression is an `await` expression
	isAwait(): Boolean => false
	// if the expression is awaiting to be resolved
	isAwaiting(): Boolean => false
	// if the generated code, to cast the expression has a boolean, requires to be wrapped inside parentheses
	isBooleanComputed(): Boolean => @isComputed() || !@type().isBoolean() || @type().isNullable()
	isBooleanComputed(junction: Junction): Boolean => @isBooleanComputed()
	// if the expression contains a call
	isCallable(): Boolean => false
	// if the expression needs to be assign to a temp variable to be reused
	isComposite(): Boolean => true
	// if parentheses are required around the expression to be wrapped
	isComputed(): Boolean => false
	isComputedMember(): Boolean => false
	// if the expression can be an assignment and be transformed as a declaration
	isDeclarable(): Boolean => false
	// if the expression can have several values
	isDerivative(): Boolean => false
	isDisrupted(): Boolean => false
	// if the expression is exiting
	isExit(mode: ExitMode): Boolean => false
	// if the expression can be an assignment and the variable has a defined type
	isExpectingType(): Boolean => false
	isFitting(): Boolean => false
	// if the expression can be ignored (like a variable casting)
	isIgnorable(): Boolean => false
	isImmutableValue(): Boolean => false
	// if the expression is a variable and needs to be initialized
	isInitializable(): Boolean => false
	// if the expression is initializing the given instance variable
	isInitializingInstanceVariable(name: String): Boolean => false
	isInitializingVariable(name: String): Boolean => false
	// if the associated type can be updated (it's a chunck or a variable)
	isInferable(): Boolean => false
	// if the expression is an inline statement which use directly the defined variable
	isInSituStatement(): Boolean => false
	// if the access member has been inverted with the forward pipeline
	isInverted(): Boolean => false
	// if the expression is a lateinit field
	isLateInit(): Boolean => false
	// if the expression can be freely assigned
	isLiberal(): Boolean => false
	// if the expression needs to be assign to a temp variable to be reused, expect for simple member expression
	isLooseComposite(): Boolean => @isComposite()
	// if the type is matching the given type
	isMatchingType(type: Type): Boolean => @type().matchContentOf(type)
	// if the expression isn't empty
	isNotEmpty(): Boolean => false
	// if the expression is nullable
	isNullable(): Boolean => false
	// if the generated code, to test if the expression is null, requires to be wrapped inside parentheses
	isNullableComputed(): Boolean => @isComputed()
	isReferenced(): Boolean => false
	// if the expression's type can refined
	isRefinable(): Boolean => false
	isReusable(): Boolean => false
	isReusingName(): Boolean => false
	// if the expression should be skipped or not
	isSkippable(): Boolean => false
	isSpread(): Boolean => false
	isSpreadable(): Boolean => true
	isUndisruptivelyNullable(): Boolean => @isNullable() && !@isDisrupted()
	// if the expression is the given instance variable
	isUsingInstanceVariable(name): Boolean => false
	// if the expression is using any non-local vraiables
	isUsingNonLocalVariables(scope: Scope): Boolean => false
	// if the expression needs to use a setter function to assign a value
	isUsingSetter(): Boolean => false
	// if the expression is the given static variable
	isUsingStaticVariable(class, varname): Boolean => false
	// if the expression is the given variable
	isUsingVariable(name): Boolean => false
	isUsingVariableBefore(name: String, statement: Statement = @statement!?): Boolean => @statement?.isUsingVariableBefore(name, statement) ?? false
	isVariable(): Boolean => false
	// if the expression generates multiple assignments
	isSplitAssignment(): Boolean => false
	listLocalVariables(scope: Scope, variables: Array): Array => variables
	listNonLocalVariables(scope: Scope, variables: Array): Array => variables
	makeCallee(generics: Generic[]?, node: CallExpression) { # {{{
		NotSupportedException.throw(node)
	} # }}}
	makeMemberCallee(property: String, testing: Boolean, generics: Generic[]?, node: CallExpression) { # {{{
		if var callback ?= @type().makeMemberCallee(property, null, generics, node) {
			callback()
		}
	} # }}}
	path(): String? => null
	releaseReusable()
	setAssignment(assignment: AssignmentType)
	setAttributes(data) { # {{{
		@options = Attribute.configure({ attributes: data }, @parent._options, AttributeTarget.Statement, @file())
	} # }}}
	setReuseName(name: String)
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
	toArgumentFragments(fragments, mode: Mode = Mode.None) { # {{{
		@toFragments(fragments, mode)
	} # }}}
	toArgumentFragments(fragments, member: Number, mode: Mode = Mode.None) { # {{{
		@toArgumentFragments(fragments, mode)

		fragments.code(`[\(member)]`)
	} # }}}
	toArgumentFragments(fragments, property: String, mode: Mode = Mode.None) { # {{{
		@toArgumentFragments(fragments, mode)

		if $isVarname(property) {
			fragments.code(`.\(property)`)
		}
		else {
			fragments.code(`[\($quote(property))]`)
		}
	} # }}}
	toArgumentFragments(fragments, type: Type, mode: Mode = Mode.None) { # {{{
		@toArgumentFragments(fragments, mode)
	} # }}}
	toConditionFragments(fragments, mode: Mode = Mode.None, junction: Junction = Junction.NONE) { # {{{
		@toFragments(fragments, mode)

		if !@type().isBoolean() || @type().isNullable() {
			fragments.code(' === true')
		}
	} # }}}
	toFlatArgumentFragments(nullTested: Boolean, fragments, mode: Mode = Mode.None) { # {{{
		@toArgumentFragments(fragments, mode)
	} # }}}
	toFragments(fragments, mode)
	toNullableFragments(fragments) => @toFragments(fragments, Mode.None)
	toOperandFragments(fragments, operator, type) => @toFragments(fragments, Mode.None)
	toParameterFragments(fragments) { # {{{
		@toFragments(fragments)
	} # }}}
	toQuote(): String { # {{{
		throw NotSupportedException.new()
	} # }}}
	toQuote(double: Boolean): String { # {{{
		return if double set `"\(@toQuote())"` else `'\(@toQuote())'`
	} # }}}
	toReusableFragments(fragments) => @toFragments(fragments, Mode.None)
	toTypeQuote() => @type().toTypeQuote()
	toTypeQuote(double: Boolean): String { # {{{
		return if double set `"\(@toTypeQuote())"` else `'\(@toTypeQuote())'`
	} # }}}
	type() => AnyType.NullableUnexplicit
	unflagAssertable()
	unflagExpectingBitmask()
	unspecify()
	validateType(type: Type)
	variable() => null
}

include {
	'../expression/literal.ks'
	'../expression/array.ks'
	'../expression/array-comprehension.ks'
	'../expression/await.ks'
	'../expression/binding/index.ks'
	'../expression/call/index.ks'
	'../expression/curry.ks'
	'../expression/disruptive.ks'
	'../expression/function.ks'
	'../expression/if.ks'
	'../expression/match.ks'
	'../expression/member.ks'
	'../expression/object.ks'
	'../expression/object-comprehension.ks'
	'../expression/omitted.ks'
	'../expression/reference.ks'
	'../expression/regex.ks'
	'../expression/restrictive.ks'
	'../expression/rolling.ks'
	'../expression/sequence.ks'
	'../expression/template.ks'
	'../expression/this.ks'
	'../expression/try.ks'
	'../expression/typed.ks'

	'../expression/misc.ks'
}
