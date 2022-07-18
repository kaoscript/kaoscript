class FallthroughStatement extends Statement {
	private lateinit {
		_switch: SwitchStatement
	}
	analyse() { # {{{
		let parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('fallthrough', this)
		}

		while parent is not SwitchStatement {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('fallthrough', this)
			}
		}

		@switch = parent!!

		@switch.flagUsingFallthrough()
	} # }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { # {{{
		@switch.toFallthroughFragments(fragments)
	} # }}}
}
