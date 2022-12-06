class TypeAliasDeclaration extends Statement {
	private late {
		@name: String
		@variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		@variable = @scope.define(@name, true, new AliasType(@scope, Type.fromAST(@data.type, this)), this)
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode)
}
