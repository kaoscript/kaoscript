class Expression extends AbstractNode {
	acquireReusable(acquire) { // {{{
	} // }}}
	releaseReusable() { // {{{
	} // }}}
	isAssignable() => false
	isBooleanComputed() => this.isComputed()
	isCallable() => false
	isComposite() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isEntangled() => true
	isNullable() => false
	isNullableComputed() => this.isComputed()
	toBooleanFragments(fragments, mode = Mode::None) => this.toFragments(fragments, mode)
	toNullableFragments(fragments) => this.toFragments(fragments, Mode::None)
	toReusableFragments(fragments) => this.toFragments(fragments, Mode::None)
}

include {
	../expression/literal
	../expression/array
	../expression/array-comprehension
	../expression/binding
	../expression/block
	../expression/call
	../expression/create
	../expression/curry
	../expression/enum
	../expression/function
	../expression/if
	../expression/member
	../expression/object
	../expression/omitted
	../expression/regex
	../expression/ternary
	../expression/template
	../expression/unless
}