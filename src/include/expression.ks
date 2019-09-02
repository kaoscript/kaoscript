abstract class Expression extends AbstractNode {
	acquireReusable(acquire)
	// if the expression can throw an expception
	hasExceptions() => true
	inferTypes() => {}
	inferContraryTypes() => {}
	// if the expression can be an assignment
	isAssignable() => false
	// if the expression is an `await` expression
	isAwait() => false
	// if the expression is awaiting to be resolved
	isAwaiting() => false
	// if the generated code, to cast the expression has a boolean, requires to be wrapped inside parentheses
	isBooleanComputed() => this.isComputed()
	// if the expression contains a call
	isCallable() => false
	// if the expression needs to be assign to a temp variable to be reused
	isComposite() => true
	// if parentheses are required around the expression to be wrapped
	isComputed() => false
	// if the expression can be an assignment and be transformed as a declaration
	isDeclarable() => false
	// if the expression can be ignored (like a variable casting)
	isIgnorable() => false
	// if the associated type can be updated (it's a chunck or a variable)
	isInferable() => false
	// if the expression needs to be assign to a temp variable to be reused, expect for simple member expression
	isLooseComposite() => this.isComposite()
	// if the type is matching the given type
	isMatchingType(type: Type) => this.type().matchContentOf(type)
	// if the expression is nullable
	isNullable() => false
	// if the generated code, to test if the expression is null, requires to be wrapped inside parentheses
	isNullableComputed() => this.isComputed()
	// if the expression generates multiple assignments
	isSplitAssignment() => false
	releaseReusable()
	setAssignment(type: AssignmentType)
	statement(data) { // {{{
		let expression = this

		while expression._parent is not Statement {
			expression = expression._parent
		}

		return expression._parent
	} // }}}
	toBooleanFragments(fragments, mode = Mode::None) => this.toFragments(fragments, mode)
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
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
}

include {
	'../expression/literal'
	'../expression/array'
	'../expression/array-comprehension'
	'../expression/await'
	'../expression/binding'
	'../expression/call'
	'../expression/comparison'
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
	'../expression/this'
	'../expression/template'
	'../expression/unless'

	'../expression/misc'
}