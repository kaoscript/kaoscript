class RepeatIteration extends IterationNode {
	private late {
		@indexName
		@to
		@toName
	}
	override analyse() { # {{{
		@bindingScope = @newScope(@scope!?, ScopeType.InlineBlock)

		@to = $compile.expression(@data.expression, this, @scope)
		@to.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@to.prepare(@scope.reference('Number'))

		@indexName = @bindingScope.acquireTempName()
		@toName = @bindingScope.acquireTempName() if @to.isComposite()
	} # }}}
	override translate() { # {{{
		@to.translate()
	} # }}}
	isUsingVariable(name) { # {{{
		return @to.isUsingVariable(name)
	} # }}}
	override releaseVariables() { # {{{
		@bindingScope.releaseTempName(@indexName) if ?@indexName
		@bindingScope.releaseTempName(@toName) if ?@toName
	} # }}}
	override toIterationFragments(fragments) { # {{{
		var ctrl = fragments.newControl().code(`for(\(@indexName) = 0`)

		if ?@toName {
			ctrl.code(`, \(@toName) = `).compile(@to)
		}

		ctrl.code(`; \(@indexName) < `).compile(@toName ?? @to).code(`; ++\(@indexName))`).step()

		return {
			fragments: ctrl
			close: () => {
				ctrl.done()
			}
		}
	} # }}}
}
