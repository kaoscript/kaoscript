class BlockStatement extends Statement {
	private late {
		@body					= null
		@bodyScope: Scope
		@continuous: Boolean	= false
		@name: String
	}
	analyse() { # {{{
		@name = @data.label.name

		@bodyScope = @newScope(@scope!?, ScopeType.InlineBlock)

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
	flagContinuous() { # {{{
		@continuous = true
	} # }}}
	isJumpable() => true
	isUsingVariable(name) { # {{{
		return @body.isUsingVariable(name)
	} # }}}
	name() => @name
	toFragments(fragments, mode) { # {{{
		if @continuous {
			var loop = fragments
				.newControl()
				.code('while(true)')
				.step()

			loop
				.newControl()
				.code(`\(@name):`)
				.step()
				.compile(@body)
				.line('break')
				.done()

			loop.done()
		}
		else {
			fragments
				.newControl()
				.code(`\(@name):`)
				.step()
				.compile(@body)
				.done()
		}
	} # }}}
}
