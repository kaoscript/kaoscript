class DestructurableObjectType extends ReferenceType {
	constructor() { # {{{
		super(null, '__ks_DestructurableObject')
	} # }}}
	isDictionary() => false
	isExplicit() => true
	isNullable() => false
	isObject() => true
	isUnion() => false
	toTestFunctionFragments(fragments, node) { # {{{
		fragments.code(`\($runtime.type(node)).isDestructurableObject`)
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code(`\($runtime.type(node)).isDestructurableObject`)
	} # }}}
}
