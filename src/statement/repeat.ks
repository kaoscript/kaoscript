class RepeatStatement extends Statement {
	private late {
		@body
		@bodyScope: Scope
		@indexName: String
		@to
		@toAssert: Boolean					= false
		@toName: String
	}
	analyse() { # {{{
		@bodyScope = @newScope(@scope!?, ScopeType::InlineBlock)

		if ?@data.expression {
			@to = $compile.expression(@data.expression, this, @scope)
			@to.analyse()
		}

		@scope.line(@data.body.start.line)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?@to {
			@to.prepare(@scope.reference('Number'))

			@indexName = @scope.acquireTempName()
			@toName = @scope.acquireTempName() if @to.isComposite()

			if !@to.type().isNumber() {
				@toAssert = true
			}
		}

		@assignTempVariables(@scope!?)

		@scope.line(@data.body.start.line)

		@body.prepare(target)

		@scope.releaseTempName(@indexName) if ?@indexName
		@scope.releaseTempName(@toName) if ?@toName
	} # }}}
	translate() { # {{{
		@to?.translate()
		@body.translate()
	} # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) { # {{{
		return @to?.isUsingVariable(name) || @body.isUsingVariable(name)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if ?@indexName {
			fragments.line(`\(@indexName) = -1`)
		}
		if ?@toName {
			fragments.newLine().code(@toName, $equals).compile(@to).done()
		}

		if @toAssert {
			fragments
				.newLine()
				.code(`\($runtime.helper(this)).assertNumber(\(@to.toQuote(true)), `)
				.compile(@toName ?? @to)
				.code(`, 3)`)
				.done()
		}

		var ctrl = fragments.newControl().code('while(')

		if ?@to {
			ctrl.code(`++\(@indexName) < `).compile(@toName ?? @to)
		}
		else {
			ctrl.code('true')
		}

		ctrl.code(')').step()

		ctrl.compile(@body)

		ctrl.done()
	} # }}}
}
