class ExportDeclaration extends Statement {
	private {
		_declarations	= []
		_statements		= []
	}
	analyse() { // {{{
		let statement

		if @parent.includePath() == null {
			for declaration in @data.declarations {
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

				statement.analyse()

				@statements.push(statement)
				@declarations.push(statement)
			}
		}
		else {
			for declaration in @data.declarations when declaration.kind == NodeKind::ExportDeclarationSpecifier {
				@statements.push(statement = $compile.statement(declaration.declaration, this))

				statement.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	export(recipient) { // {{{
		for declaration in @declarations {
			declaration.export(recipient)
		}
	} // }}}
	isExportable() => true
	exportMacro(name, macro) { // {{{
		@parent.exportMacro(name, macro)
	} // }}}
	registerMacro(name, macro) { // {{{
		@parent.publishMacro(name, macro)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
	walk(fn) { // {{{
		for statement in @statements {
			statement.walk(fn)
		}
	} // }}}
}

class ExportExclusionSpecifier extends AbstractNode {
	private {
		_expression
	}
	analyse()
	prepare()
	translate()
	export(recipient) { // {{{
		const exclusions = [exclusion.name for exclusion in @data.exclusions]

		for const variable in @parent.parent().scope().listDefinedVariables() when exclusions.indexOf(variable.name()) == -1 {
			recipient.export(variable.name(), variable)
		}
	} // }}}
	toFragments(fragments, mode)
}

class ExportNamedSpecifier extends AbstractNode {
	private {
		_expression
	}
	analyse()
	prepare() { // {{{
		@expression = $compile.expression(@data.local, @parent)
		@expression.analyse()

		if @expression.isMacro() {
			for const macro in @scope.listMacros(@expression.name()) {
				@parent.registerMacro(@data.exported.name, macro)
			}
		}
	} // }}}
	translate()
	export(recipient) { // {{{
		@expression.prepare()

		if @expression.isMacro() {
			for macro in @scope.listMacros(@expression.name()) {
				macro.export(recipient, @data.exported.name)
			}
		}
		else {
			recipient.export(@data.exported.name, @expression)
		}
	} // }}}
	toFragments(fragments, mode)
	walk(fn) { // {{{
		if !@expression.isMacro() {
			fn(@data.exported.name, @expression.type())
		}
	} // }}}
}

class ExportPropertiesSpecifier extends AbstractNode {
	private {
		_object
	}
	analyse()
	prepare() { // {{{
		@object = $compile.expression(@data.object, @parent)
		@object.analyse()
	} // }}}
	translate()
	export(recipient) { // {{{
		@object.prepare()

		for property in @data.properties {
			recipient.export(property.exported.name, new ExportProperty(@object, property.local.name))
		}
	} // }}}
	toFragments(fragments, mode)
}

class ExportWildcardSpecifier extends AbstractNode {
	private {
		_expression
	}
	analyse()
	prepare() { // {{{
		@expression = $compile.expression(@data.local, @parent)
		@expression.analyse()
	} // }}}
	translate()
	export(recipient) { // {{{
		@expression.prepare()

		@expression.type().walk((name,) => {
			recipient.export(name, new ExportProperty(@expression, name))
		})
	} // }}}
	toFragments(fragments, mode)
}

class ExportProperty {
	private {
		_object
		_property: String
	}
	constructor(@object, @property)
	toFragments(fragments, mode) { // {{{
		fragments.compile(@object).code(`.\(@property)`)
	} // }}}
	type() => @object.type().getProperty(@property)
}