class NamespaceDeclaration extends Statement {
	private late {
		@exports									= {}
		@name: String
		@statements: Array
		@topNodes: Array							= []
		@type: NamedContainerType<NamespaceType>
		@variable: Variable
		@tests										= []
		@testIndex: Number							= 0
		@testVariable: String
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
		for var statement in @statements {
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
		for var statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} # }}}
	addInitializableVariable(variable, node)
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	addTypeTest(name: String, type: Type): Void { # {{{
		@testVariable ??= @getTypeTestVariable()

		@tests.push({ name, type })

		type.setTestName(`\(@testVariable).is\(name)`)
	} # }}}
	authority() => this
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	export(name: String, variable) { # {{{
		var type = variable.getDeclaredType()

		if type.hasTest() {
			var clone = type.clone()

			clone.setTestName(`\(@name).__ksType[\(@testIndex)]`)
			clone.setTestIndex(@testIndex)

			@testIndex += 1

			@type.addProperty(name, clone)
		}
		else {
			@type.addProperty(name, type)
		}

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
	toExportFragments(fragments) { # {{{
		var line = fragments.newLine().code('return ')
		var object = line.newObject()

		for var variable, name of @exports {
			var type = variable.getDeclaredType()

			type.toExportFragment(object, name, variable)
		}

		if @testIndex > 0 {
			var line = object.newLine().code(`__ksType: [`)
			var mut index = 0

			for var variable, name of @exports {
				var type = variable.getDeclaredType()

				if type.hasTest() {
					line.code($comma) if index > 0

					line.code(type.getTestName())

					index += 1
				}
			}

			line.code(']').done()
		}

		object.done()
		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.namespace(function()')
		var block = line.newBlock()

		if #@tests {
			var line = block.newLine().code(`\($runtime.immutableScope(this))\(@testVariable) = `)
			var object = line.newObject()

			for var { type, name } in @tests {
				var funcname = `is\(name)`
				var line = object.newLine().code(`\(funcname): `)

				type.toBlindTestFunctionFragments(funcname, 'value', true, null, line, this)

				line.done()

				if type.isVariant() && type.canBeDeferred() {
					var generics = type.generics()

					for var { type % subtype }, index in type.discard().getVariantType().getFields() {
						var funcname = `is\(name)__\(index)`
						var line = object.newLine().code(`\(funcname): `)

						subtype.toBlindTestFunctionFragments(funcname, 'value', false, generics, line, this)

						line.done()
					}
				}
			}

			object.done()
			line.done()
		}

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		for var statement in @statements {
			block.compile(statement)
		}

		@toExportFragments(block)

		block.done()
		line.code(')').done()
	} # }}}
	type() => @type
}
