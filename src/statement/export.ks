class ExportDeclaration extends Statement {
	private {
		_declarations	= []
	}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		let statement
		for declaration in data.declarations {
			switch declaration.kind {
				NodeKind::ClassDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				NodeKind::ExportAlias => {
					module.export(declaration.name, declaration.alias)
				}
				NodeKind::EnumDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				NodeKind::FunctionDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					module.export(declaration.name)
				}
				NodeKind::Identifier => {
					module.export(declaration)
				}
				NodeKind::TypeAliasDeclaration => {
					$variable.define(this, this._scope, declaration.name, VariableKind::TypeAlias, declaration.type)
					
					module.export(declaration.name)
				}
				NodeKind::VariableDeclaration => {
					this._declarations.push(statement = $compile.statement(declaration, this))
					
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
	fuse() { // {{{
		for declaration in this._declarations {
			declaration.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declaration in this._declarations {
			declaration.toFragments(fragments, Mode::None)
		}
	} // }}}
}