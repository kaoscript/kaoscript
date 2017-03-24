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
					
					module.export(declaration.name)
				}
				NodeKind::ExportAlias => {
					module.export(declaration.name, declaration.alias)
				}
				NodeKind::EnumDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				NodeKind::FunctionDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				NodeKind::Identifier => {
					module.export(declaration)
				}
				NodeKind::TypeAliasDeclaration => {
					$variable.define(this, @scope, declaration.name, true, VariableKind::TypeAlias, declaration.type)
					
					module.export(declaration.name)
				}
				NodeKind::VariableDeclaration => {
					@declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					for j from 0 til declaration.declarations.length {
						module.export(declaration.declarations[j].name)
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