class NamespaceDeclaration extends Statement {
	private late {
		@exports									= {}
		@name: String
		@statements: Array
		@topNodes: Array							= []
		@type: NamedContainerType<NamespaceType>
		@variable: Variable
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, new NamespaceScope(scope))
	} # }}}
	initiate() { # {{{
		@name = @data.name.name
		@type = new NamedContainerType(@name, new NamespaceType(@scope!?))

		@variable = @scope.parent().define(@name, true, @type, this)

		@statements = []
		for var data in @data.statements {
			@scope.line(data.start.line)

			var statement = $compile.statement(data, this)

			statement.initiate()

			@statements.push(statement)
		}
	} # }}}
	analyse() { # {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}
	} # }}}
	enhance() { # {{{
		for var statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		for var statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(this, true)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var statement in @statements {
			@scope.line(statement.line())

			statement.prepare(Type.Void)
		}

		for var statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(this, false)
		}

		@type.flagComplete()
	} # }}}
	translate() { # {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} # }}}
	addInitializableVariable(variable, node)
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	export(name: String, variable) { # {{{
		@type.addProperty(name, variable.getDeclaredType())

		@exports[name] = variable
	} # }}}
	exportMacro(name, macro) { # {{{
		@parent.registerMacro(`\(@name).\(name)`, macro)
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} # }}}
	includePath() => null
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		if var var ?= @scope.getDefinedVariable(variable.name) {
			var.setDeclaredType(variable.type)
		}
	} # }}}
	name() => @name
	recipient() => this
	registerMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)
	} # }}}
	toExportFragements(fragments) { # {{{
		var line = fragments.newLine().code('return ')
		var object = line.newObject()

		for var variable, name of @exports {
			variable.getDeclaredType().toExportFragment(object, name, variable)
		}

		object.done()
		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.namespace(function()')
		var block = line.newBlock()

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		for statement in @statements {
			block.compile(statement)
		}

		@toExportFragements(block)

		block.done()
		line.code(')').done()
	} # }}}
	type() => @type
}
