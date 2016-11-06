class Expression extends AbstractNode {
	isAssignable() => false
	isCallable() => false
	isComposite() => true
	isComputed() => false
	isConditional() => this.isNullable()
	isEntangled() => true
	isNullable() => false
	toBooleanFragments(fragments) => this.toFragments(fragments, Mode::None)
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