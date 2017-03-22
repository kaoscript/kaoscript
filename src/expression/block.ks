class BlockExpression extends Expression {
	private {
		_body = []
	}
	analyse() { // {{{
		if @data.statements {
			for statement in @data.statements {
				@body.push(statement = $compile.statement(statement, this))
				
				statement.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @body {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @body {
			statement.translate()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in @body {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}