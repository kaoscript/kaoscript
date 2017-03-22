class TypeAliasDeclaration extends Statement {
	analyse() { // {{{
		$variable.define(this, @scope, @data.name, VariableKind::TypeAlias, @data.type)
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}