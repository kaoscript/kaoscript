class ContinueStatement extends Statement {
	analyse() { // {{{
		let parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('continue', this)
		}

		while !parent.isLoop() {
			parent = parent.parent()

			unless parent?.isJumpable() {
				SyntaxException.throwIllegalStatement('continue', this)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('continue', this._data)
	} // }}}
}