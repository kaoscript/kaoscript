abstract class Expression extends AbstractNode {
	acquireReusable(acquire) { // {{{
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	hasExceptions() => true
	isAssignable() => false
	isAwait() => false
	isAwaiting() => false
	isBooleanComputed() => this.isComputed()
	isCallable() => false
	isComposite() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isEntangled() => true
	isNullable() => false
	isNullableComputed() => this.isComputed()
	reduceTypes() => {}
	statement(data) { // {{{
		let expression = this

		while expression._parent is not Statement {
			expression = expression._parent
		}

		return expression._parent
	} // }}}
	toBooleanFragments(fragments, mode = Mode::None) => this.toFragments(fragments, mode)
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toReusableFragments(fragments) => this.toFragments(fragments, Mode::None)
}

include {
	'../expression/literal'
	'../expression/array'
	'../expression/array-comprehension'
	'../expression/await'
	'../expression/binding'
	'../expression/block'
	'../expression/call'
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
}