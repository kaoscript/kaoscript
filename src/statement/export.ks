class ExportDeclaration extends Statement {
	private {
		_declarations	= []
		_statements		= []
	}
	analyse() { // {{{
		const recipient = @parent.recipient()
		
		let statement
		for declaration in @data.declarations {
			switch declaration.kind {
				NodeKind::ClassDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::ExportAlias => {
					statement = new AliasDeclarator(declaration, this)
					
					statement.analyse()
					
					recipient.export(declaration.name.name, declaration.alias.name, this)
				}
				NodeKind::EnumDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::FunctionDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::Identifier => {
					statement = new IdentifierLiteral(declaration, this)
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::NamespaceDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::TypeAliasDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					recipient.export(statement.name(), null, this)
				}
				NodeKind::VariableDeclaration => {
					@statements.push(statement = $compile.statement(declaration, this))
					
					statement.analyse()
					
					statement.walk((name,) => recipient.export(name, null, this))
				}
				=> {
					throw new NotImplementedException(this)
				}
			}
			
			@declarations.push(statement)
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

class AliasDeclarator extends AbstractNode {
	private {
		_name: String
		_variable: Variable
		_type: Type
	}
	analyse() { // {{{
		@name = @data.alias.name
		
		if @variable !?= @scope.getVariable(@data.name.name) {
			ReferenceException.throwNotDefined(@data.name.name, this)
		}
	} // }}}
	prepare() { // {{{
		@type = @variable.type()
	} // }}}
	translate()
	name() => @name
	walk(fn) { // {{{
		fn(@name, @type)
	} // }}}
	type() => @type
}