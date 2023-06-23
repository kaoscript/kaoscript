class TypeAliasDeclaration extends Statement {
	private late {
		@name: String
		@variable: Variable
		@type: AliasType
	}
	override initiate() { # {{{
		@name = @data.name.name

		@type = AliasType.new(@scope)
		@variable = @scope.define(@name, true, @type, this)
	} # }}}
	postInitiate() { # {{{
		@type
			..type(Type.fromAST(@data.type, this))
			..flagComplete()
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		if @type.isComplex() {
			var authority = @recipient().authority()
			authority.addTypeTest(@name, @type)

			// @type.setTestName(test)
		}
	} # }}}
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode)
}
