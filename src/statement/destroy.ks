class DestroyStatement extends Statement {
	private {
		_expression
		_variable
	}
	analyse() { // {{{
		@expression = $compile.expression(@data.variable, this)
		
		@expression.analyse()
		
		if @data.variable.kind == NodeKind::Identifier {
			@variable = @scope.getVariable(@data.variable.name)
			
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
		if @variable?.type? && (type ?= $variable.fromType(@variable.type, this)) && type.destructors > 0 {
			fragments.newLine().code(type.name.name, '.__ks_destroy(').compile(@expression).code(')').done()
		}
		
		if @expression is IdentifierLiteral {
			fragments.newLine().compile(@expression).code(' = undefined').done()
		}
		else {
			fragments.newLine().code('delete ').compile(@expression).done()
		}
	} // }}}
}