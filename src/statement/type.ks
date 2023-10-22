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

		if type is ObjectType && type.isVariant() {
			var variant = type.getVariantType()

			for var { kind, type } in @data.type.properties when kind == NodeKind.PropertyType && type.kind == NodeKind.VariantType {
				for var property in type.properties {
					if property.kind == NodeKind.VariantField && ?property.type {
						var names = [name for var { name } in property.names]

						variant.addField(names, Type.fromAST(property.type, @scope, false, generics, this))
					}
				}

				break
			}

			type.setDeferrable(variant.canBeDeferred())
		}

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
