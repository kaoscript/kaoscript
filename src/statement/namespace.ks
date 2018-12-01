class NamespaceDeclaration extends Statement {
	private {
		_exports				= {}
		_name: String
		_statements: Array
		_type: NamedContainerType<NamespaceType>
		_variable: Variable
	}
	constructor(data, parent) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@type = new NamedContainerType(@name, new NamespaceType(@scope))

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
		}

		for statement in @statements when statement.isExportable() {
			statement.export(this)
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
		@type.addProperty(name, variable.type())

		@exports[name] = variable
	} // }}}
	includePath() => null
	name() => @name
	recipient() => this
	toExportFragements(fragments) { // {{{
		const line = fragments.newLine().code('return ')
		const object = line.newObject()

		let type
		for name, variable of @exports {
			type = variable.type()

			if type is not AliasType {
				object.newLine().code(`\(name): `).compile(variable).done()

				if type is not ReferenceType {

					if type.isSealed() {
						object.line(`__ks_\(name): \(type.sealName())`)
					}
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