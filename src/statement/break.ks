class BreakStatement extends Statement {
	analyse() { # {{{
		var mut parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('break', this)
		}

		while !parent.isLoop() {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('break', this)
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		fragments.line('break', this._data)
	} # }}}
}
