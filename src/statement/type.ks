class TypeAliasDeclaration extends Statement {
	private late {
		@alias: AliasType
		@name: String
		@generics: Generic[]		= []
		@type: Type
		@variable: Variable
	}
	override initiate() { # {{{
		@name = @data.name.name

		@alias = AliasType.new(@scope)
		@variable = @scope.define(@name, true, @alias, this)
	} # }}}
	override postInitiate() { # {{{
		if #@data.typeParameters {
			for var parameter in @data.typeParameters {
				var generic = Type.toGeneric(parameter, this)

				@alias.addGeneric(generic)

				@generics.push(generic)
			}
		}

		@type = Type.fromAST(@data.type, @generics, this)

		@alias.type(@type)
	} # }}}
	override analyse() { # {{{
		@type.finalize(@data.type, @generics, this)

		@alias.flagComplete()
	} # }}}
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
