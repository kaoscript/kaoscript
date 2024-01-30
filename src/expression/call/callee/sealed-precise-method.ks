class SealedPreciseMethodCallee extends MethodCallee {
	private {
		@object
		@objectType: ReferenceType
		@property: String
		@standardLibrary: Boolean		= false
	}
	constructor(@data, @object, @objectType, @property, assessment, match: CallMatch, @node) { # {{{
		super(data, MemberExpression.new(data.callee, node, node.scope(), object), false, assessment, match, node)

		if @function.isStandardLibrary() {
			@standardLibrary = true

			@node.module().flagLibSTDUsage(@objectType.name())
		}
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			match node._data.scope.kind {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					if @function.isInstance() {
						fragments.code(`\(@objectType.getSealedPath(@standardLibrary)).__ks_func_\(@property)_\(@function.index()).call(`)

						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, null, fragments, mode)
					}
					else {
						fragments.code(`\(@objectType.getSealedPath(@standardLibrary)).__ks_sttc_\(@property)_\(@function.index()).apply(null, `)

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, null, fragments, mode)
					}
				}
			}
		}
		else {
			match @scope {
				ScopeKind.Argument {
					throw NotImplementedException.new(node)
				}
				ScopeKind.This {
					if @function.isAlien() {
						throw NotImplementedException.new(node)
					}
					else if @function.isInstance() {
						fragments.code(`\(@objectType.getSealedPath(@standardLibrary)).__ks_func_\(@property)_\(@function.index()).call(`)

						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, true, fragments, mode)
					}
					else {
						fragments.code(`\(@objectType.getSealedPath(@standardLibrary)).__ks_sttc_\(@property)_\(@function.index())(`)

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, true, fragments, mode)
					}
				}
			}
		}
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@objectType.toPositiveTestFragments(fragments, @object)
	} # }}}
	private {
		getContextSubstitute(expression) { # {{{
			if expression is IdentifierLiteral {
				var variable = expression.variable()

				if var substitute ?= variable.replaceContext?() {
					return substitute
				}
			}

			return null
		} # }}}
	}
}
