class DestructurableObjectType extends ReferenceType {
	private {
		_properties: Dictionary			= {}
	}
	constructor() { # {{{
		super(null, '__ks_DestructurableObject')
	} # }}}
	addProperty(name: String, type: Type) { # {{{
		@properties[name] = type
	} # }}}
	isDictionary() => false
	isExplicit() => true
	isFunction() => false
	isNullable() => false
	isObject() => true
	isUnion() => false
	matchContentOf(value) => false
	properties() => @properties
	toQuote() { # {{{
		auto str = '{'

		let first = true
		for const property, name of @properties {
			if first {
				first = false
			}
			else {
				str += ', '
			}

			str += `\(name): \(property.toQuote())`
		}

		return str + '}'
	} # }}}
	toTestFunctionFragments(fragments, node) { # {{{
		fragments.code(`\($runtime.type(node)).isDestructurableObject`)
	} # }}}
	toTestFunctionFragments(fragments, node, junction) { # {{{
		fragments.code(`\($runtime.type(node)).isDestructurableObject`)
	} # }}}
}
