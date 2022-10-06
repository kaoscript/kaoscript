class SealedPreciseMethodCallee extends MethodCallee {
	private {
		@object
		@property: String
		@variable: NamedType<ClassType>
	}
	constructor(@data, @object, @property, assessment, match: CallMatch, @variable, @node) { # {{{
		super(data, new MemberExpression(data.callee, node, node.scope(), object), false, assessment, match, node)
	} # }}}
	override buildHashCode() => null
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isInstance() {
						fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
					else {
						fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index()).apply(null, `)

						Router.Argument.toFlatFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
					}
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @function.isAlien() {
						throw new NotImplementedException(node)
					}
					else {
						if @function.isInstance() {
							fragments.code(`\(@variable.getSealedPath()).__ks_func_\(@property)_\(@function.index()).call(`)

							if var substitute ?= @getContextSubstitute(@object) {
								substitute(fragments)
							}
							else {
								fragments.compile(@object)
							}

							Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, true, fragments, mode)
						}
						else {
							fragments.code(`\(@variable.getSealedPath()).__ks_sttc_\(@property)_\(@function.index())(`)

							Router.Argument.toFragments(@positions, null, node.arguments(), @function, false, false, fragments, mode)
						}
					}
				}
			}
		}
	} # }}}
	toPositiveTestFragments(fragments, node) { # {{{
		@node.scope().reference(@variable).toPositiveTestFragments(fragments, @object)
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
