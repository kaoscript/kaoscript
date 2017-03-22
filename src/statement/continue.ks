class ContinueStatement extends Statement {
	analyse()
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('continue', this._data)
	} // }}}
}