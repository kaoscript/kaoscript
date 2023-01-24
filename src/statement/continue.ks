class ContinueStatement extends Statement {
	private {
		@name: String?	= null
	}
	analyse() { # {{{
		@name = @data.label?.name

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
		if ?@name {
			fragments.line(`continue \(@name)`)
		}
		else {
			fragments.line('continue', this._data)
		}
	} # }}}
}
