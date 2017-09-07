class ExportDeclaration extends Statement {
	private {
		_declarations	= []
		_statements		= []
	}
	analyse() { // {{{
		let statement
		for declaration in @data.declarations {
			switch declaration.kind {
				NodeKind::ExportDeclarationSpecifier => {
					@statements.push(statement = $compile.statement(declaration.declaration, this))
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
					console.log(declaration)
					throw new NotImplementedException(this)
				}
			}
			
			statement.analyse()
			
			@declarations.push(statement)
		}
	} // }}}
	prepare() { // {{{
		const recipient = @parent.recipient()
		
		for declaration in @declarations {
			declaration.prepare()
			
			declaration.export(recipient)
		}
	} // }}}
	translate() { // {{{
		for declaration in @declarations {
			declaration.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declaration in @statements {
			declaration.toFragments(fragments, Mode::None)
		}
	} // }}}
	walk(fn) { // {{{
		for declaration in @declarations {
			declaration.walk(fn)
		}
	} // }}}
}

class ExportNamedSpecifier extends AbstractNode {
	private {
		_expression
	}
	analyse() { // {{{
		@expression = $compile.expression(@data.local, @parent)
		@expression.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()
	} // }}}
	translate()
	export(recipient) { // {{{
		recipient.export(@data.exported.name, @expression)
	} // }}}
	walk(fn) { // {{{
		fn(@data.exported.name, @expression.type())
	} // }}}
}

class ExportPropertiesSpecifier extends AbstractNode {
	private {
		_object
	}
	analyse() { // {{{
		@object = $compile.expression(@data.object, @parent)
		@object.analyse()
	} // }}}
	prepare() { // {{{
		@object.prepare()
	} // }}}
	translate()
	export(recipient) { // {{{
		for property in @data.properties {
			recipient.export(property.exported.name, new ExportProperty(@object, property.local.name))
		}
	} // }}}
}

class ExportWildcardSpecifier extends AbstractNode {
	private {
		_expression
	}
	analyse() { // {{{
		@expression = $compile.expression(@data.local, @parent)
		@expression.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()
	} // }}}
	translate()
	export(recipient) { // {{{
		@expression.type().walk((name,) => {
			recipient.export(name, new ExportProperty(@expression, name))
		})
	} // }}}
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