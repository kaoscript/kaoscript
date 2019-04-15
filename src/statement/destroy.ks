class DestroyStatement extends Statement {
	private {
		_expression
		_hasVariable: Boolean	= false
		_type: Type
		_variable: Variable
	}
	analyse() { // {{{
		@expression = $compile.expression(@data.variable, this)

		@expression.analyse()

		if @data.variable.kind == NodeKind::Identifier {
			@hasVariable = true

			@variable = @scope.getVariable(@data.variable.name)

			@scope.removeVariable(@data.variable.name)
		}
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		if @hasVariable {
			@type = @variable.getRealType()
		}
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @hasVariable && (type = @type.discardReference()).isClass() && type.type().hasDestructors() {
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