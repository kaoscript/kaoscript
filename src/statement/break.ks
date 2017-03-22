class BreakStatement extends Statement {
	analyse()
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('break', this._data)
	} // }}}
}