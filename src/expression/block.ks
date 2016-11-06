class BlockExpression extends Expression {
	private {
		_body = []
	}
	analyse() { // {{{
		if this._data.statements {
			for statement in this._data.statements {
				this._body.push(statement = $compile.statement(statement, this))
				
				statement.analyse()
			}
		}
	} // }}}
	fuse() { // {{{
		for statement in this._body {
			statement.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in this._body {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}