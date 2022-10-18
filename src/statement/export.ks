class ExportDeclaration extends Statement {
	private {
		@declarations	= []
		@statements		= []
	}
	override initiate() { # {{{
		if @parent.includePath() == null {
			for var declaration in @data.declarations {
				var late statement

				switch declaration.kind {
					NodeKind::ExportDeclarationSpecifier => {
						statement = $compile.statement(declaration.declaration, this)
					}
					NodeKind::ExportExclusionSpecifier => {
						statement = new ExportExclusionSpecifier(declaration, this)
					}
					NodeKind::ExportNamedSpecifier => {
						statement = new ExportNamedSpecifier(declaration, this)
					}
					NodeKind::ExportPropertiesSpecifier => {
						statement = new ExportPropertiesSpecifier(declaration, this)
					}
					NodeKind::ExportWildcardSpecifier => {
						statement = new ExportWildcardSpecifier(declaration, this)
					}
					=> {
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
			for var declaration in @data.declarations when declaration.kind == NodeKind::ExportDeclarationSpecifier {
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
	override prepare(target) { # {{{
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
		@parent.publishMacro(name, macro)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for statement in @statements {
			statement.toFragments(fragments, Mode::None)
		}
	} # }}}
	override walkVariable(fn) { # {{{
		for var statement in @statements {
			statement.walkVariable(fn)
		}
	} # }}}
}

class ExportExclusionSpecifier extends AbstractNode {
	private {
		@expression
	}
	analyse()
	override prepare(target)
	translate()
	export(recipient) { # {{{
		var exclusions = [exclusion.name for exclusion in @data.exclusions]

		for var variable in @parent.parent().scope().listDefinedVariables() when exclusions.indexOf(variable.name()) == -1 {
			recipient.export(variable.name(), variable)
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
}

class ExportNamedSpecifier extends AbstractNode {
	private {
		@expression
	}
	analyse()
	override prepare(target) { # {{{
		@expression = $compile.expression(@data.internal, @parent)
		@expression.analyse()

		if @expression.isMacro() {
			for var macro in @scope.listMacros(@expression.name()) {
				@parent.registerMacro(@data.external.name, macro)
			}
		}
	} # }}}
	translate()
	export(recipient) { # {{{
		@expression.prepare()

		if @expression.isMacro() {
			for var macro in @scope.listMacros(@expression.name()) {
				macro.export(recipient, @data.external.name)
			}
		}
		else {
			recipient.export(@data.external.name, @expression)

			var type = @expression.type()

			if type.isClass() || type.isNamespace() {
				var regex = new RegExp(`^\(@expression.name())`)

				for var macro in @scope.listCompositeMacros(@expression.name()) {
					macro.export(recipient, macro.name().replace(regex, @data.external.name))
				}
			}
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
	override walkVariable(fn) { # {{{
		if !@expression.isMacro() {
			fn(@data.external.name, @expression.type())
		}
	} # }}}
}

class ExportPropertiesSpecifier extends AbstractNode {
	private {
		@object
	}
	analyse()
	override prepare(target) { # {{{
		@object = $compile.expression(@data.object, @parent)
		@object.analyse()
	} # }}}
	translate()
	export(recipient) { # {{{
		@object.prepare()

		for property in @data.properties {
			recipient.export(property.external.name, new ExportProperty(@object, property.internal.name))
		}
	} # }}}
	isEnhancementExport() => false
	toFragments(fragments, mode)
}

class ExportWildcardSpecifier extends AbstractNode {
	private {
		@expression
	}
	analyse()
	override prepare(target) { # {{{
		@expression = $compile.expression(@data.internal, @parent)
		@expression.analyse()
	} # }}}
	translate()
	export(recipient) { # {{{
		@expression.prepare()

		@expression.type().walk((name, _) => {
			recipient.export(name, new ExportProperty(@expression, name))
		})
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
