class ContinueStatement extends Statement {
	ContinueStatement(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments.line('continue', this._data)
	} // }}}
}