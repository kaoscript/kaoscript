class TypeAliasDeclaration extends Statement {
	private lateinit {
		_name: String
		_variable: Variable
	}
	analyse() { // {{{
		@name = @data.name.name

		@variable = @scope.define(@name, true, new AliasType(@scope, Type.fromAST(@data.type, this)), this)
	} // }}}
	prepare()
	translate()
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	name() => @name
	toStatementFragments(fragments, mode)
}