class NamespaceDeclaration extends Statement {
	private lateinit {
		_exports									= {}
		_name: String
		_statements: Array
		_topNodes: Array							= []
		_type: NamedContainerType<NamespaceType>
		_variable: Variable
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new NamespaceScope(scope))
	} // }}}
	initiate() { // {{{
		@name = @data.name.name
		@type = new NamedContainerType(@name, new NamespaceType(@scope!?))

		@variable = @scope.parent().define(@name, true, @type, this)

		@statements = []
		for statement in @data.statements {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.initiate()
		}
	} // }}}
	analyse() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}
	} // }}}
	enhance() { // {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		for const statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(this, true)
		}
	} // }}}
	prepare() { // {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		for const statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(this, false)
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} // }}}
	addInitializableVariable(variable, node)
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
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
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { // {{{
		if const var = @scope.getDefinedVariable(variable.name) {
			var.setDeclaredType(variable.type)
		}
	} // }}}
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

		for const variable, name of @exports {
			variable.getDeclaredType().toExportFragment(object, name, variable)
		}

		object.done()
		line.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.namespace(function()')
		const block = line.newBlock()

		for const node in @topNodes {
			node.toAuthorityFragments(block)
		}

		for statement in @statements {
			block.compile(statement)
		}

		this.toExportFragements(block)

		block.done()
		line.code(')').done()
	} // }}}
	type() => @type
}
