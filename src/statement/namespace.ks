class NamespaceDeclaration extends Statement {
	private {
		_exports: Array			= []
		_name: String
		_statements: Array
		_type: NamespaceType
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@type = new NamespaceType(@name, @scope)
		
		@scope.parent().define(@name, true, @type, this)
		
		@statements = []
		for statement in @data.statements {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
			
			if statement is ExportDeclaration {
				statement.walk((name, type) => @type.addProperty(name, type))
			}
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	export(name: String, alias: String?, node) { // {{{
		let variable: Variable
		
		if variable !?= @scope.getVariable(name) {
			ReferenceException.throwNotDefined(name, node)
		}
		
		if variable.type() is not AliasType {
			@exports.push(`\(alias ?? name): \(name)`)
			
			const type = variable.type().unalias()
			if type.isSealed() {
				@exports.push(`__ks_\(alias ?? name): \(type.sealName())`)
			}
		}
	} // }}}
	name() => @name
	recipient() => this
	toExportFragements(fragments) { // {{{
		const line = fragments.newLine().code('return ')
		const object = line.newObject()
		
		for export in @exports {
			object.line(export)
		}
		
		object.done()
		line.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code($runtime.scope(this), @name, ' = (function()')
		const block = line.newBlock()
		
		for statement in @statements {
			block.compile(statement)
		}
		
		this.toExportFragements(block)
		
		block.done()
		line.code(')()').done()
	} // }}}
	type() => @type
}