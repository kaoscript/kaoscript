class UntilStatement extends Statement {
	private late {
		_bindingScope: Scope
		_body
		_bodyScope: Scope
		_condition
	}
	analyse() { # {{{
		@bindingScope = this.newScope(@scope, ScopeType::Hollow)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@condition = $compile.expression(@data.condition, this, @bindingScope)
		@condition.analyse()


		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target) { # {{{
		@condition.prepare(@scope.reference('Boolean'))

		unless @condition.type().canBeBoolean() {
			TypeException.throwInvalidCondition(@condition, this)
		}

		this.assignTempVariables(@scope)

		@scope.line(@data.body.start.line)

		@body.prepare(target)

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
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
			.code('while(!')
			.wrapBoolean(@condition)
			.code(')')
			.step()
			.compile(@body)
			.done()
	} # }}}
}
