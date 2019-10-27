class BreakStatement extends Statement {
	analyse() { // {{{
		let parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('break', this)
		}

		while !parent.isLoop() {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('break', this)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('break', this._data)
	} // }}}
}