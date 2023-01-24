class BlockStatement extends Statement {
	private late {
		@body				= null
		@bodyScope: Scope
		@label: String
	}
	analyse() { # {{{
		@label = @data.label.name

		@bodyScope = @newScope(@scope!?, ScopeType::InlineBlock)

		@scope.line(@data.body.start.line)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.line(@data.body.start.line)

		@body.prepare(target)
	} # }}}
	translate() { # {{{
		@body.translate()
	} # }}}
	isJumpable() => true
	isUsingVariable(name) { # {{{
		return @body.isUsingVariable(name)
	} # }}}
	toFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl().code(`\(@label):`).step().compile(@body).done()
	} # }}}
}
