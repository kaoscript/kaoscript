class NamespaceDeclaration extends Statement {
	private {
		_exports				= {}
		_name: String
		_statements: Array
		_type: NamedContainerType<NamespaceType>
		_variable: Variable
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope, ScopeType::Block)
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@type = new NamedContainerType(@name, new NamespaceType(@scope:Scope))

		@variable = @scope.parent().define(@name, true, @type, this)

		@statements = []
		for statement in @data.statements {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		for statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(this)
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	export(name: String, variable) { // {{{
		@type.addProperty(name, variable.getDeclaredType())

		@exports[name] = variable
	} // }}}
	exportMacro(name, macro) { // {{{
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} // }}}
	includePath() => null
	name() => @name
	publishMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)

		@parent.registerMacro(`\(@name).\(name)`, macro)
	} // }}}
	recipient() => this
	registerMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)
	} // }}}
	toExportFragements(fragments) { // {{{
		const line = fragments.newLine().code('return ')
		const object = line.newObject()

		let type
		for const variable, name of @exports {
			type = variable.getDeclaredType()

			if type is not AliasType {
				object.newLine().code(`\(name): `).compile(variable).done()

				if type is not ReferenceType && type.isSealed() {
					object.line(`__ks_\(name): \(type.getSealedName())`)
				}
			}
		}

		object.done()
		line.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.namespace(function()')
		const block = line.newBlock()

		for statement in @statements {
			block.compile(statement)
		}

		this.toExportFragements(block)

		block.done()
		line.code(')').done()
	} // }}}
	type() => @type
}