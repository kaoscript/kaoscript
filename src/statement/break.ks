class BreakStatement extends Statement {
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('break', this._data)
	} // }}}
}