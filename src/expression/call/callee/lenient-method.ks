class LenientMethodCallee extends LenientFunctionCallee {
	private {
		@instance: Boolean
		@object
		@objectType: ReferenceType
		@property: String
		@sealed: Boolean					= false
	}
	constructor(@data, @object, @objectType, @property, assessment: Router.Assessment, @result, @node) { # {{{
		this(data, object, objectType, property, assessment, result.possibilities, node)
	} # }}}
	constructor(@data, @object, @objectType, @property, assessment: Router.Assessment, @functions, @node) { # {{{
		super(data, assessment, functions, node)

		@instance = @function.isInstance()

		for var function in @functions {
			if function.isSealed() {
				@sealed = true

				break
			}
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		@object.acquireReusable(acquire)
	} # }}}
	releaseReusable() { # {{{
		@object.releaseReusable()
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			if @sealed {
				if @instance {
					fragments.code(`\(@objectType.getSealedPath())._im_\(@property)`)
				}
				else {
					fragments.code(`\(@objectType.getSealedPath())._sm_\(@property)`)
				}
				
				fragments.code('.apply(null')
				
				Router.Argument.toFlatFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, @object, fragments, mode)
			}
			else {
				fragments.compileReusable(@object).code(`.\(@property)`)
				
				if @scope == ScopeKind.Argument {
					fragments.code('.apply(').compile(node.getCallScope(), mode)
				}
				else {
					fragments.code('.apply(').compile(@object, mode)
				}
				
				Router.Argument.toFlatFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, null, fragments, mode)
			}
		}
		else {
			if @sealed {
				if @instance {
					fragments.code(`\(@objectType.getSealedPath())._im_\(@property)`)
				}
				else {
					fragments.code(`\(@objectType.getSealedPath())._sm_\(@property)`)
				}
			}
			else {
				fragments.wrap(@object).code(`.\(@property)`)
			}

			match @scope {
				ScopeKind.Argument {
					fragments.code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, false, fragments, mode)
				}
				ScopeKind.This {
					fragments.code('(')

					if @sealed && @instance {
						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, false, fragments, mode)
					}
					else {
						Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, false, false, fragments, mode)
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
