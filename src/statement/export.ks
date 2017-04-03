class ExportDeclaration extends Statement {
	private {
		_declarations	= []
	}
	analyse() { // {{{
		let module = this.module()
		
		let statement
		for declaration in @data.declarations {
			switch declaration.kind {
				NodeKind::ClassDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name.name, null, this)
				}
				NodeKind::ExportAlias => {
					module.export(declaration.name.name, declaration.alias.name, this)
				}
				NodeKind::EnumDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name.name, null, this)
				}
				NodeKind::FunctionDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name.name, null, this)
				}
				NodeKind::Identifier => {
					module.export(declaration.name, null, this)
				}
				NodeKind::TypeAliasDeclaration => {
					statement = $compile.statement(declaration, this)
					
					statement.analyse()
					
					module.export(statement.name(), null, this)
				}
				NodeKind::VariableDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					for i from 0 til declaration.declarations.length {
						module.export(declaration.declarations[i].name.name, null, this)
					}
				}
				=> {
					throw new NotImplementedException(this)
				}
			}
		}
	} // }}}
	prepare() { // {{{
		for declaration in @declarations {
			declaration.prepare()
		}
	} // }}}
	translate() { // {{{
		for declaration in @declarations {
			declaration.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declaration in @declarations {
			declaration.toFragments(fragments, Mode::None)
		}
	} // }}}
}