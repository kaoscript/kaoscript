class LenientMethodCallee extends LenientFunctionCallee {
	private {
		@auxiliary: Boolean				= false
		@generics: AltType[]
		@instance: Boolean
		@misfit: Boolean
		@object
		@objectType: ReferenceType
		@property: String
		@standardLibrary: Boolean		= false
	}
	constructor(@data, @object, @objectType, @generics, @property, assessment: Router.Assessment, @result, @node) { # {{{
		this(data, object, objectType, generics, property, assessment, result.possibilities, node)
	} # }}}
	constructor(@data, @object, @objectType, @generics, @property, assessment: Router.Assessment, @functions, @node) { # {{{
		super(data, assessment, functions, node)

		@instance = @function.isInstance()
		@misfit = @functions.every((function, ...) => @node.isMisfit() && !function.isSealed())

		for var function in @functions {
			if function.isUsingAuxiliary() && !@misfit {
				@auxiliary = true
			}

			if @auxiliary && function.isStandardLibrary(.Yes) {
				@standardLibrary = true

				@node.module().flagLibSTDUsage(@objectType.name())
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
		var root = @objectType.discard()
		var generic = !@misfit && root.isGenericInstanceMethod(@property)

		if @flatten {
			if @auxiliary {
				if @instance {
					fragments.code(`\(@objectType.getSealedPath(@standardLibrary))._im_\(@property)`)
				}
				else {
					fragments.code(`\(@objectType.getSealedPath(@standardLibrary))._sm_\(@property)`)
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
			if @auxiliary {
				if @instance {
					fragments.code(`\(@objectType.getSealedPath(@standardLibrary))._im_\(@property)`)
				}
				else {
					fragments.code(`\(@objectType.getSealedPath(@standardLibrary))._sm_\(@property)`)
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

					if @auxiliary && @instance {
						if var substitute ?= @getContextSubstitute(@object) {
							substitute(fragments)
						}
						else {
							fragments.compile(@object)
						}

						if generic {
							if @node.isMisfit() {
								fragments.code(`, null`)
							}
							else {
								fragments.code(`, {`)

								for var { name, type }, index in @generics {
									fragments
										..code(`, `) if index > 0
										..code(`\(name): `)

									type.toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)
								}

								fragments.code(`}`)
							}
						}

						Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, true, false, fragments, mode)
					}
					else {
						if generic {
							if @node.isMisfit() {
								fragments.code(`null`)
							}
							else {
								fragments.code(`{`)

								for var { name, type }, index in @generics {
									fragments
										..code(`, `) if index > 0
										..code(`\(name): `)

									type.toAwareTestFunctionFragments('value', false, false, false, false, null, null, fragments, node)
								}

								fragments.code(`}`)
							}
						}

						Router.Argument.toFragments(@result?.positions, @result?.labels, node.arguments(), @function, @labelable, generic, false, fragments, mode)
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
