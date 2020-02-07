class NamespaceDeclaration extends Statement {
	private lateinit {
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
	addInitializableVariable(variable, node)
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

		for statement in @statements {
			block.compile(statement)
		}

		this.toExportFragements(block)

		block.done()
		line.code(')').done()
	} // }}}
	type() => @type
}