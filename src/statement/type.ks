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
		var generics = []

		if #@data.generics {
			for var generic in @data.generics {
				@type.addGeneric(generic.name)

				generics.push(generic.name)
			}
		}

		var type = Type.fromAST(@data.type, generics, this)

		@type.type(type)

		type.finalize(@data.type, generics, this)

		@type.flagComplete()
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		if @type.isComplex() {
			var authority = @recipient().authority()

			authority.addTypeTest(@name, @type)
		}
	} # }}}
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode)
}
