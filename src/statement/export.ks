class ExportDeclaration extends Statement {
	private {
		@declarations	= []
		@statements		= []
	}
	override initiate() { # {{{
		if @parent.includePath() == null {
			for var declaration in @data.declarations {
				var late statement

				match declaration.kind {
					NodeKind.DeclarationSpecifier {
						statement = $compile.statement(declaration.declaration, this)
					}
					NodeKind.GroupSpecifier {
						statement = new ExportGroupSpecifier(declaration, this)
					}
					NodeKind.NamedSpecifier {
						statement = new ExportNamedSpecifier(declaration, this)
					}
					NodeKind.PropertiesSpecifier {
						statement = new ExportPropertiesSpecifier(declaration, this)
					}
					else {
						console.info(declaration)
						throw new NotImplementedException(this)
					}
				}

				statement.initiate()

				@statements.push(statement)
				@declarations.push(statement)
			}
		}
		else {
			for var declaration in @data.declarations when declaration.kind == NodeKind.DeclarationSpecifier {
				var statement = $compile.statement(declaration.declaration, this)

				statement.initiate()

				@statements.push(statement)
			}
		}
	} # }}}
	analyse() { # {{{
		for var statement in @statements {
			statement.analyse()
		}
	} # }}}
	enhance() { # {{{
		for var statement in @statements {
			statement.enhance()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var statement in @statements {
			statement.prepare()
		}
	} # }}}
	translate() { # {{{
		for var statement in @statements {
			statement.translate()
		}
	} # }}}
	export(recipient, enhancement: Boolean = false) { # {{{
		if enhancement {
			for var declaration in @declarations when declaration.isEnhancementExport() {
				declaration.export(recipient)
			}
		}
		else {
			for var declaration in @declarations when !declaration.isEnhancementExport() {
				declaration.export(recipient)
			}
		}
	} # }}}
	isExportable() => true
	exportMacro(name, macro) { # {{{
		@parent.exportMacro(name, macro)
	} # }}}
	registerMacro(name, macro) { # {{{
		@parent.registerMacro(name, macro)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for statement in @statements {
			statement.toFragments(fragments, Mode.None)
		}
	} # }}}
	override walkVariable(fn) { # {{{
		for var statement in @statements {
			statement.walkVariable(fn)
		}
	} # }}}
}

class ExportGroupSpecifier extends AbstractNode {
	private {
		@elements: Array			= []
		@exclusion: Boolean		= false
		@wildcard: Boolean		= false
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Exclusion {
				@exclusion = true
			}
			else if modifier.kind == ModifierKind.Wildcard {
				@wildcard = true
			}
		}
	} # }}}
	override prepare(target, targetMode) {
		if @exclusion {
			for var element in @data.elements {
				@elements.push(element.internal.name)
			}
		}
	}
	translate()
	export(recipient) { # {{{
		if @exclusion {
			for var variable in @parent.parent().scope().listDefinedVariables() when @elements.indexOf(variable.name()) == -1 {
				recipient.export(variable.name(), variable)
			}
		}
		else if @wildcard {
			for var variable in @parent.parent().scope().listDefinedVariables() {
				recipient.export(variable.name(), variable)
			}
		}
		else {
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
}

class ExportNamedSpecifier extends AbstractNode {
	private {
		@expression
		@externalName: String?
		@wildcard: Boolean		= false
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Wildcard {
				@wildcard = true
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression = $compile.expression(@data.internal, @parent)
		@expression.analyse()

		if !@wildcard {
			@externalName = ?@data.external ? @data.external.name : @expression.name()
		}
	} # }}}
	translate()
	export(recipient) { # {{{
		@expression.prepare()

		if @expression.isMacro() {
			for var macro in @scope.listMacros(@expression.name()) {
				macro.export(recipient, @externalName)
			}
		}
		else if @wildcard {
			@expression.type().walk((name, _) => {
				recipient.export(name, new ExportProperty(@expression, name))
			})
		}
		else {
			recipient.export(@externalName, @expression)

			var type = @expression.type()

			if type.isClass() || type.isNamespace() {
				var regex = new RegExp(`^\(@expression.name())`)

				for var macro in @scope.listCompositeMacros(@expression.name()) {
					macro.export(recipient, macro.name().replace(regex, @externalName))
				}
			}
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
	override walkVariable(fn) { # {{{
		if !@expression.isMacro() {
			fn(@externalName, @expression.type())
		}
	} # }}}
}

class ExportPropertiesSpecifier extends AbstractNode {
	private {
		@object
	}
	analyse()
	override prepare(target, targetMode) { # {{{
		@object = $compile.expression(@data.object, @parent)
		@object.analyse()
	} # }}}
	translate()
	export(recipient) { # {{{
		@object.prepare()

		for var property in @data.properties {
			if ?property.external {
				recipient.export(property.external.name, new ExportProperty(@object, property.internal.name))
			}
			else {
				recipient.export(property.internal.name, new ExportProperty(@object, property.internal.name))
			}
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
}

class ExportProperty {
	private {
		@object
		@property: String
	}
	constructor(@object, @property)
	toFragments(fragments, mode) { # {{{
		fragments.compile(@object).code(`.\(@property)`)
	} # }}}
	type() => @object.type().getProperty(@property)
}
