class NamespaceDeclaration extends Statement {
	private {
		_exports				= {}
		_name: String
		_statements: Array
		_type: NamespaceType
		_variable: Variable
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@type = new NamespaceType(@name, @scope)
		
		@variable = @scope.parent().define(@name, true, @type, this)
		
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
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	export(name: String, variable) { // {{{
		@exports[name] = variable
	} // }}}
	includePath() => null
	name() => @name
	recipient() => this
	toExportFragements(fragments) { // {{{
		const line = fragments.newLine().code('return ')
		const object = line.newObject()
		
		for name, variable of @exports {
			if variable.type() is not AliasType {
				object.newLine().code(`\(name): `).compile(variable).done()
				
				const type = variable.type().unalias()
				if type.isSealed() {
					object.line(`__ks_\(name): \(type.sealName())`)
				}
			}
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