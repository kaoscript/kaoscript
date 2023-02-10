class SealedCallee extends Callee {
	private {
		@flatten: Boolean
		@instance: Boolean
		@methods: Array<FunctionType>
		@node: CallExpression
		@object
		@property: String
		@scope: ScopeKind
		@type: Type
		@variable: NamedType<ClassType>
	}
	constructor(@data, @variable, @instance, @methods, @node) { # {{{
		super(data)

		@object = node._object
		@property = node._property
		@flatten = node._flatten
		@nullableProperty = data.callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind.Nullable)
		@scope = data.scope.kind

		var union = new UnionType(node.scope())

		for var method in methods {
			@validate(method, node)

			union.addType(method.getReturnType())
		}

		@type = union.type()
	} # }}}
	override hashCode() => `sealed`
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		for var method in @methods {
			if !method.isInitializingInstanceVariable(name) {
				return false
			}
		}

		return true
	} # }}}
	mergeWith(that: Callee) { # {{{
		@type = Type.union(@node.scope(), @type, that.type())
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind.Null {
					throw new NotImplementedException(node)
				}
				ScopeKind.This {
					if @instance {
						fragments.code(`\(@variable.getSealedPath())._im_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node.arguments(), @object)
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._sm_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node.arguments())
					}
				}
			}
		}
		else {
			match @scope {
				ScopeKind.Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind.Null {
					throw new NotImplementedException(node)
				}
				ScopeKind.This {
					if @instance {
						fragments
							.code(`\(@variable.getSealedPath())._im_\(@property)(`)
							.compile(@object)

						for var argument in node.arguments() {
							fragments.code($comma)

							argument.toArgumentFragments(fragments, mode)
						}
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._sm_\(@property)(`)

						for var argument, index in node.arguments() {
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
	translate()
	type() => @type
	type(@type) => this
}
