class SealedPreciseMethodCallee extends MethodCallee {
	private {
		@object
		@objectType: ReferenceType
		@property: String
	}
	constructor(@data, @object, @objectType, @property, assessment, match: CallMatch, @node) { # {{{
		super(data, new MemberExpression(data.callee, node, node.scope(), object), false, assessment, match, node)
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			match node._data.scope.kind {
				ScopeKind::Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null {
					throw new NotImplementedException(node)
				}
				ScopeKind::This {
					if @function.isInstance() {
						fragments.code(`\(@objectType.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
					else {
						fragments.code(`\(@objectType.getSealedPath()).__ks_sttc_\(@property)_\(@function.index()).apply(null, `)

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
				}
			}
		}
		else {
			match @scope {
				ScopeKind::Argument {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null {
					throw new NotImplementedException(node)
				}
				ScopeKind::This {
					if @function.isAlien() {
						throw new NotImplementedException(node)
					}
					else if @function.isInstance() {
						fragments.code(`\(@objectType.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
					else {
						fragments.code(`\(@objectType.getSealedPath()).__ks_sttc_\(@property)_\(@function.index())(`)

						Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
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
