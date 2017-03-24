class TypeAliasDeclaration extends Statement {
	analyse() { // {{{
		$variable.define(this, @scope, @data.name, true, VariableKind::TypeAlias, @data.type)
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}