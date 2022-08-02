class TypeAliasDeclaration extends Statement {
	private late {
		_name: String
		_variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		@variable = @scope.define(@name, true, new AliasType(@scope, Type.fromAST(@data.type, this)), this)
	} # }}}
	analyse()
	prepare()
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode)
}
