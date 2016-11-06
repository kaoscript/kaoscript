class BreakStatement extends Statement {
	BreakStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('break', this._data)
	} // }}}
}