class FallthroughStatement extends Statement {
	private late {
		@match: MatchStatement
	}
	analyse() { # {{{
		var mut parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('fallthrough', this)
		}

		while parent is not MatchStatement {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('fallthrough', this)
			}
		}

		@match = parent!!

		@match.flagUsingFallthrough()
	} # }}}
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		@match.toFallthroughFragments(fragments)
	} # }}}
}
