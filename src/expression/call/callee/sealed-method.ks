class SealedMethodCallee extends Callee {
	private {
		_instance: Boolean
		_node
		_object
		_property: String
		_variable: NamedType<ClassType>
	}
	constructor(@data, @variable, @instance, @node) { # {{{
		super(data)

		@object = node._object
		@property = node._property

		@nullableProperty = data.callee.modifiers.some(modifier => modifier.kind == ModifierKind::Nullable)
	} # }}}
	translate() { # {{{
		@object.translate()
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		let class = @variable.type()

		if @instance {
			while true {
				if const methods = class.listInstanceMethods(@property) {
					for const method in methods {
						if !method.isInitializingInstanceVariable(name) {
							return false
						}
					}
				}

				if class.isExtending() {
					class = class.extends().type()
				}
				else {
					break
				}
			}
		}
		else {
			while true {
				if const methods = class.listClassMethods(@property) {
					for const method in methods {
						if !method.isInitializingInstanceVariable(name) {
							return false
						}
					}
				}

				if class.isExtending() {
					class = class.extends().type()
				}
				else {
					break
				}
			}
		}

		return true
	} # }}}
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
					if @instance {
						fragments.code(`\(@variable.getSealedPath())._im_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments, @object)
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._sm_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments)
					}
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
					if @instance {
						fragments
							.code(`\(@variable.getSealedPath())._im_\(@property)(`)
							.compile(@object)

						for const argument in node._arguments {
							fragments.code($comma)

							argument.toArgumentFragments(fragments, mode)
						}
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._sm_\(@property)(`)

						for const argument, index in node._arguments {
							if index != 0 {
								fragments.code($comma)
							}

							argument.toArgumentFragments(fragments, mode)
						}
					}
				}
			}
		}
	} # }}}
	toNullableFragments(fragments, node) { # {{{
		fragments
			.code($runtime.type(node) + '.isValue(')
			.compile(@object)
			.code(')')
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@node.scope().reference(@variable).toPositiveTestFragments(fragments, @object)
	} # }}}
	type() => AnyType.NullableUnexplicit
}
