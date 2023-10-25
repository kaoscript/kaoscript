class BreakStatement extends Statement {
	private {
		@name: String?	= null
	}
	analyse() { # {{{
		@name = @data.label?.name

		var mut parent = @parent

		unless parent.isJumpable() {
			SyntaxException.throwIllegalStatement('break', this)
		}

		if ?@name {
			while parent is not BlockStatement || parent.name() != @name {
				parent = parent.parent()

				unless parent?.isJumpable() {
					SyntaxException.throwIllegalStatement('break', this)
				}
			}
		}
		else {
			while !parent.isLoop() {
				parent = parent.parent()

				unless parent?.isJumpable() {
					SyntaxException.throwIllegalStatement('break', this)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	isExit() => !?@name
	toStatementFragments(fragments, mode) { # {{{
		if ?@name {
			fragments.line(`break \(@name)`)
		}
		else {
			fragments.line('break', this._data)
		}
	} # }}}
}
