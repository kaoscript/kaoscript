class TypeAliasDeclaration extends Statement {
	private late {
		@alias: AliasType
		@name: String
		@generics: String[]		= []
		@type: Type
		@variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		@alias = AliasType.new(@scope)
		@variable = @scope.define(@name, true, @alias, this)
	} # }}}
	override postInitiate() { # {{{
		if #@data.generics {
			for var generic in @data.generics {
				@alias.addGeneric(generic.name)

				@generics.push(generic.name)
			}
		}

		@type = Type.fromAST(@data.type, @generics, this)

		@alias.type(@type)
	} # }}}
	override analyse() {
		@type.finalize(@data.type, @generics, this)

		@alias.flagComplete()
	}
	override prepare(target, targetMode) { # {{{
		if @alias.isComplex() {
			var authority = @recipient().authority()

			authority.addTypeTest(@name, @alias)
		}
	} # }}}
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode)
}
