class DestroyStatement extends Statement {
	private {
		_expression
		_variable
	}
	analyse() { // {{{
		this._expression = $compile.expression(this._data.variable, this)
		
		if this._data.variable.kind == Kind::Identifier {
			this._variable = this._scope.getVariable(this._data.variable.name)
			
			this._scope.removeVariable(this._data.variable.name)
		}
	} // }}}
	fuse() { // {{{
		this._expression.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._variable?.type? && (type ?= $variable.fromType(this._variable.type, this)) && type.destructors > 0 {
			fragments.newLine().code(type.name.name, '.__ks_destroy(').compile(this._expression).code(')').done()
		}
		
		if this._expression is IdentifierLiteral {
			fragments.newLine().compile(this._expression).code(' = undefined').done()
		}
		else {
			fragments.newLine().code('delete ').compile(this._expression).done()
		}
	} // }}}
}