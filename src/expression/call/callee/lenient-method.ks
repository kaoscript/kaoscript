class LenientMethodCallee extends LenientFunctionCallee {
	private {
		@instance: Boolean
		@object
		@property: String
		@sealed: Boolean					= false
		@variable: NamedType<ClassType>
	}
	// TODO
	// constructor(@data, @object, @property, assessment: Router.Assessment, result: LenientCallMatchResult, @variable, @node) { # {{{
	constructor(@data, @object, @property, assessment, result: LenientCallMatchResult, @variable, @node) { # {{{
		super(data, assessment, result, node)

		@instance = @function.isInstance()

		for var function in @functions {
			if function.isSealed() {
				@sealed = true

				break
			}
		}
	} # }}}
	toFragments(fragments, mode, node) { # {{{
		if @flatten {
			fragments.compileReusable(@object).code(`.\(@property)`)

			if @scope == ScopeKind::Argument {
				fragments.code('.apply(').compile(node.getCallScope(), mode)
			}
			else if @scope == ScopeKind::Null || @expression is not MemberExpression {
				fragments.code('.apply(null')
			}
			else {
				fragments.code('.apply(').compile(@object, mode)
			}

			Router.Argument.toFlatFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
		}
		else {
			if @sealed {
				if @instance {
					fragments.code(`\(@variable.getSealedPath())._im_\(@property)`)
				}
				else {
					fragments.code(`\(@variable.getSealedPath())._sm_\(@property)`)
				}
			}
			else {
				fragments.wrap(@object).code(`.\(@property)`)
			}

			switch @scope {
				ScopeKind::Argument => {
					fragments.code('.call(').compile(node.getCallScope(), mode)

					Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
				}
				ScopeKind::Null => {
					fragments.code('.call(null')

					Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
				}
				ScopeKind::This => {
					fragments.code('(')

					if @sealed && @instance {
						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, true, fragments, mode)
					}
					else {
						Router.Argument.toFragments(@positions, @labels, node.arguments(), @function, @labelable, false, fragments, mode)
					}
				}
			}
		}
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
