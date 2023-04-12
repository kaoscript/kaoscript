class SealedFunctionCallee extends Callee {
	private {
		@function
		@object
		@property: String
		@type: Type
		@variable: NamedType<NamespaceType>
	}
	constructor(@data, @variable, @function, @type, node) { # {{{
		super(data)

		@object = node._object
		@property = node._property

		@nullableProperty = node._object.isNullable()

		@validate(function, node)
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean => @function.isInitializingInstanceVariable(name)
	toFragments(fragments, mode, node) { # {{{
		if node._flatten {
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					throw NotImplementedException.new(node)
				}
			}
		}
		else {
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					fragments.code(`\(@variable.getSealedName()).\(@property)(`)

					for var argument, index in node.arguments() {
						if index != 0 {
							fragments.code($comma)
						}

						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@type.toPositiveTestFragments(fragments, @object)
	} # }}}
	translate() { # {{{
		@object.translate()
	} # }}}
	type() => @type
}
