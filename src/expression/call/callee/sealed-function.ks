class SealedFunctionCallee extends Callee {
	private {
		_function
		_object
		_property: String
		_type: Type
		_variable: NamedType<NamespaceType>
	}
	constructor(@data, @variable, @function, @type, node) { # {{{
		super(data)

		@object = node._object
		@property = node._property

		@nullableProperty = node._object.isNullable()

		this.validate(function, node)
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean => @function.isInitializingInstanceVariable(name)
	toFragments(fragments, mode, node) { # {{{
		if node._flatten {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					throw new NotImplementedException(node)
				}
			}
		}
		else {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					fragments.code(`\(@variable.getSealedName()).\(@property)(`)

					for var argument, index in node._arguments {
						if index != 0 {
							fragments.code($comma)
						}

						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@type.toPositiveTestFragments(fragments, @object)
	} # }}}
	translate() { # {{{
		@object.translate()
	} # }}}
	type() => @type
}
