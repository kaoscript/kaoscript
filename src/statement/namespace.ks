class NamespaceDeclaration extends Statement {
	private late {
		@exports									= {}
		@name: String
		@statements: Array
		@topNodes: Array							= []
		@type: NamedContainerType<NamespaceType>
		@variable: Variable
		@typeTests									= []
		@typeTestVariable: String
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, NamespaceScope.new(scope))
	} # }}}
	initiate() { # {{{
		@name = @data.name.name
		@type = NamedContainerType.new(@name, NamespaceType.new(@scope!?))

		@variable = @scope.parent().define(@name, true, @type, this)

		@statements = []
		for var data in @data.statements {
			@scope.line(data.start.line)

			var statement = $compile.statement(data, this)

			statement.initiate()

			@statements.push(statement)
		}

		for var statement in @statements {
			statement.postInitiate()
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
	addTypeTest(name: String, type: Type): String { # {{{
		@typeTestVariable ??= @getTypeTestVariable()

		@typeTests.push({ name, type })

		return `\(@typeTestVariable).is\(name)`
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
	getTypeTestVariable() => @parent.recipient().authority().getTypeTestVariable()
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

		if #@typeTests {
			var line = block.newLine().code(`\($runtime.immutableScope(this))\(@typeTestVariable) = `)
			var object = line.newObject()

			for var { type, name } in @typeTests {
				var line = object.newLine().code(`is\(name): `)

				type.toTestFunctionFragments(line, this, TestFunctionMode.DEFINE)

				line.done()
			}

			object.done()
			line.done()
		}

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
