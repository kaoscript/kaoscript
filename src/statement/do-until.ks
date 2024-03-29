class DoUntilStatement extends Statement {
	private late {
		@body: Block
		@bodyScope: Scope
		@condition
	}
	analyse() { # {{{
		@bodyScope = @newScope(@scope!?, ScopeType.InlineBlock)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		@condition = $compile.expression(@data.condition, this, @scope)
		@condition.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@body.prepare(target)

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, true, this)
			}
		}

		@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		@assignTempVariables(@scope!?)
	} # }}}
	translate() { # {{{
		@condition.translate()
		@body.translate()
	} # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => @condition.isUsingVariable(name) || @body.isUsingVariable()
	toStatementFragments(fragments, mode) { # {{{
		fragments
			.newControl()
			.code('do')
			.step()
			.compile(@body)
			.step()
			.code('while(!(')
			.compileCondition(@condition)
			.code('))')
			.done()
	} # }}}

	proxy @body {
		isExit
	}
}
