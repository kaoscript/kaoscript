class SealedMethodCallee extends Callee {
	private {
		@instance: Boolean
		@node
		@object
		@objectType: ReferenceType
		@property: String
	}
	constructor(@data, @object, @objectType, @property, @instance, @node) { # {{{
		super(data)

		@nullableProperty = data.callee.modifiers?.some(modifier => modifier.kind == ModifierKind.Nullable) ?? false
	} # }}}
	translate() { # {{{
		@object.translate()
	} # }}}
	override hashCode() => null
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		var mut class = @objectType.discard()

		if @instance {
			while true {
				if var methods ?= class.listInstanceMethods(@property) {
					for var method in methods {
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
				if var methods ?= class.listStaticMethods(@property) {
					for var method in methods {
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
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					if @instance {
						fragments.code(`\(@objectType.getAuxiliaryPath())._im_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node.arguments(), @object)
					}
					else {
						fragments.code(`\(@objectType.getAuxiliaryPath())._sm_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node.arguments())
					}
				}
			}
		}
		else {
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					if @instance {
						fragments
							.code(`\(@objectType.getAuxiliaryPath())._im_\(@property)(`)
							.compile(@object)

						for var argument in node.arguments() {
							fragments.code($comma)

							argument.toArgumentFragments(fragments, mode)
						}
					}
					else {
						fragments.code(`\(@objectType.getAuxiliaryPath())._sm_\(@property)(`)

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
		@objectType.toPositiveTestFragments(fragments, @object)
	} # }}}
	type() => AnyType.NullableUnexplicit
}
