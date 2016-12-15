class TypeAliasDeclaration extends Statement {
	TypeAliasDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		$variable.define(this, this._scope, this._data.name, VariableKind::TypeAlias, this._data.type)
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}