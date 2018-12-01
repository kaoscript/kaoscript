class DestroyStatement extends Statement {
	private {
		_expression
		_hasVariable: Boolean	= false
		_variable: Variable
	}
	analyse() { // {{{
		@expression = $compile.expression(@data.variable, this)

		@expression.analyse()

		if @data.variable.kind == NodeKind::Identifier {
			@variable = @scope.getVariable(@data.variable.name)
			@hasVariable = true

			@scope.removeVariable(@data.variable.name)
		}
	} // }}}
	prepare() { // {{{
		@expression.prepare()
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @hasVariable && (type = @variable.type().discardReference()).isClass() && type.type().hasDestructors() {
			fragments.newLine().code(type.path(), '.__ks_destroy(').compile(@expression).code(')').done()
		}

		if @expression is IdentifierLiteral {
			fragments.newLine().compile(@expression).code(' = undefined').done()
		}
		else {
			fragments.newLine().code('delete ').compile(@expression).done()
		}
	} // }}}
}