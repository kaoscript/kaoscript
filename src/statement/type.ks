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
		if ?#@data.typeParameters {
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
		// if @alias.isComplex() {
		// 	var authority = @recipient().authority()

		// 	authority.addTypeTest(@name, @alias)
		// }
		// @alias.setTestName(`\(@name).is`)
		@alias.setTestName(@name)
	} # }}}
	translate()
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine()

		line.code($runtime.immutableScope(this), @name, $equals, $runtime.helper(this), '.alias(')

		// @type.toBlindTestFunctionFragments(`\(@name).is`, 'value', false, true, null, line, this)
		@type.toBlindTestFunctionFragments(@name, 'value', false, true, null, line, this)

		line.code(')').done()

		if @type.isVariant() && @type.canBeDeferred() {
			var variant = @alias.discard().getVariantType()
			var generics = @alias.generics()

			for var { names, type } in variant.getFields() {
				var funcName = `is\(names[0]:!!(String).capitalize())`
				var funcLine = fragments.newLine().code(`\(@name).\(funcName) = `)

				type.toBlindTestFunctionFragments(@name, 'value', false, false, generics, funcLine, this)

				funcLine.done()
			}
		}
	} # }}}
}
