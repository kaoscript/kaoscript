class ContinueStatement extends Statement {
	analyse() { # {{{
		var mut parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('continue', this)
		}

		while !parent.isLoop() {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('continue', this)
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		fragments.line('continue', this._data)
	} # }}}
}
