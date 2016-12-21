class TypeAliasDeclaration extends Statement {
	analyse() { // {{{
		$variable.define(this, this._scope, this._data.name, VariableKind::TypeAlias, this._data.type)
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}