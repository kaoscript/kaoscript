class ConditionalExpression extends Expression {
	private late {
		@condition
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
		@condition.acquireReusable(false)
		@whenTrue.acquireReusable(false)
		@whenFalse.acquireReusable(false)
	} # }}}
	releaseReusable() { # {{{
		@condition.releaseReusable()
		@whenTrue.releaseReusable()
		@whenFalse.releaseReusable()
	} # }}}
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
		fragments
			.wrapCondition(@condition)
			.code(' ? ')
			.compile(@whenTrue)
			.code(' : ')
			.compile(@whenFalse)
	} # }}}
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
