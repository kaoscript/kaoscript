class TypeAliasDeclaration extends Statement {
	private {
		_name: String
	}
	analyse() { // {{{
		@name = @data.name.name
		
		@scope.define(@name, true, new AliasType(Type.fromAST(@data.type, this)), this)
	} // }}}
	prepare()
	translate()
	name() => @name
	toStatementFragments(fragments, mode)
}