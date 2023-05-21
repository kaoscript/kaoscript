class ConditionalExpression extends Expression {
	private late {
		@condition
		// @reusable: Boolean			= false
		// @reuseName: String?			= null
		@whenFalse
		@whenTrue
		@type: Type
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenTrue = $compile.expression(@data.whenTrue, this)
		@whenTrue.analyse()

		@whenFalse = $compile.expression(@data.whenFalse, this)
		@whenFalse.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		for var data, name of @condition.inferTypes({}) {
			@scope.updateInferable(name, data, this)
		}

		@whenTrue.prepare(target, targetMode)
		@whenFalse.prepare(target, targetMode)

		var t = @whenTrue.type()
		var f = @whenFalse.type()

		@type = Type.union(@scope, t, f)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		// if acquire {
		// 	@reuseName = @scope.acquireTempName()

		// 	@condition.acquireReusable(true)
		// 	@whenTrue.acquireReusable(true)
		// 	@whenFalse.acquireReusable(true)
		// }
		@condition.acquireReusable(false)
		@whenTrue.acquireReusable(false)
		@whenFalse.acquireReusable(false)
	} # }}}
	releaseReusable() { # {{{
		// if ?@reuseName {
		// 	@scope.releaseTempName(@reuseName)

		// 	@condition.releaseReusable()
		// 	@whenTrue.releaseReusable()
		// 	@whenFalse.releaseReusable()
		// }
		@condition.releaseReusable()
		@whenTrue.releaseReusable()
		@whenFalse.releaseReusable()
	} # }}}
	// isComposite() => true
	isComputed() => true
	isInverted() => @condition.isInverted() || @whenTrue.isInverted() || @whenFalse.isInverted()
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenTrue.isUsingVariable(name) || @whenFalse.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition.listNonLocalVariables(scope, variables)
		@whenTrue.listNonLocalVariables(scope, variables)
		@whenFalse.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		// if @reusable {
		// 	fragments.code(@reuseName)
		// }
		// else {
			fragments
				.wrapCondition(@condition)
				.code(' ? ')
				.compile(@whenTrue)
				.code(' : ')
				.compile(@whenFalse)
		// }
	} # }}}
	// toReusableFragments(fragments) { # {{{
	// 	if !@reusable && ?@reuseName {
	// 		fragments.code(@reuseName, $equals).compile(this)

	// 		@reusable = true
	// 	}
	// 	else {
	// 		fragments.compile(this)
	// 	}
	// } # }}}
	toInvertedFragments(fragments, callback) { # {{{
		if @condition.isInverted() {
			@condition.toInvertedFragments(fragments, callback)
		}
		else if @whenTrue.isInverted() {
			@whenTrue.toInvertedFragments(fragments, callback)
		}
		else {
			@whenFalse.toInvertedFragments(fragments, callback)
		}
	} # }}}
	toQuote() => `\(@condition.toQuote()) ? \(@whenTrue.toQuote()) : \(@whenFalse.toQuote())`
	type() => @type
}
