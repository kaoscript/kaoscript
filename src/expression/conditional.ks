class ConditionalExpression extends Expression {
	private late {
		@condition
		@whenFalseExpression
		@whenFalseScope: Scope
		@whenTrueExpression
		@whenTrueScope: Scope
		@type: Type
	}
	analyse() { # {{{
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()

		@whenTrueScope = @newScope(@scope, ScopeType.InlineBlock)
		@whenTrueExpression = $compile.expression(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		@whenFalseScope = @newScope(@scope, ScopeType.InlineBlock)
		@whenFalseExpression = $compile.expression(@data.whenFalse, this, @whenFalseScope)
		@whenFalseExpression.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		for var data, name of @condition.inferWhenTrueTypes({}) {
			@whenTrueScope.updateInferable(name, data, this)
		}

		for var data, name of @condition.inferWhenFalseTypes({}) {
			@whenFalseScope.updateInferable(name, data, this)
		}

		@whenTrueExpression.prepare(target, targetMode)
		@whenFalseExpression.prepare(target, targetMode)

		var t = @whenTrueExpression.type().discardValue()
		var f = @whenFalseExpression.type().discardValue()

		@type = Type.union(@scope, t, f)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@whenTrueExpression.translate()
		@whenFalseExpression.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		@condition.acquireReusable(false)
		@whenTrueExpression.acquireReusable(false)
		@whenFalseExpression.acquireReusable(false)
	} # }}}
	releaseReusable() { # {{{
		@condition.releaseReusable()
		@whenTrueExpression.releaseReusable()
		@whenFalseExpression.releaseReusable()
	} # }}}
	isComputed() => true
	isInverted() => @condition.isInverted() || @whenTrueExpression.isInverted() || @whenFalseExpression.isInverted()
	isUsingVariable(name) => @condition.isUsingVariable(name) || @whenTrueExpression.isUsingVariable(name) || @whenFalseExpression.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition.listNonLocalVariables(scope, variables)
		@whenTrueExpression.listNonLocalVariables(scope, variables)
		@whenFalseExpression.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments
			.wrapCondition(@condition)
			.code(' ? ')
			.compile(@whenTrueExpression)
			.code(' : ')
			.compile(@whenFalseExpression)
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		if @condition.isInverted() {
			@condition.toInvertedFragments(fragments, callback)
		}
		else if @whenTrueExpression.isInverted() {
			@whenTrueExpression.toInvertedFragments(fragments, callback)
		}
		else {
			@whenFalseExpression.toInvertedFragments(fragments, callback)
		}
	} # }}}
	toQuote() => `\(@condition.toQuote()) ? \(@whenTrueExpression.toQuote()) : \(@whenFalseExpression.toQuote())`
	type() => @type
}
