class FallthroughStatement extends Statement {
	private late {
		@switch: SwitchStatement
	}
	analyse() { # {{{
		var mut parent = @parent

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
	override prepare(target)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		@switch.toFallthroughFragments(fragments)
	} # }}}
}
