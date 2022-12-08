class DestructurableObjectType extends ReferenceType {
	private {
		@properties: Object			= {}
	}
	constructor(@scope) { # {{{
		super(scope, '__ks_DestructurableObject')

		@type = scope.reference('Object')
	} # }}}
	addProperty(name: String, type: Type) { # {{{
		@properties[name] = type
	} # }}}
	isComplete() => true
	isExplicit() => true
	isFunction() => false
	isNullable() => false
	isObject() => true
	isUnion() => false
	matchContentOf(value) => false
	properties() => @properties
	override resolve()
	toQuote() { # {{{
		var mut str = '{'
		var mut first = true

		for var property, name of @properties {
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
