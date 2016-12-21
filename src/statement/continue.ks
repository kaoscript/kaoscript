class ContinueStatement extends Statement {
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('continue', this._data)
	} // }}}
}