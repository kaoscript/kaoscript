class NamespaceDeclaration extends Statement {
	private late {
		@anonymousIndex: Number						= -1
		@anonymousTypes: ReferenceType{}			= {}
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
	} # }}}
	postInitiate() { # {{{
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
	addAnonymousType(type: Type): ReferenceType { # {{{
		var hash = type.hashCode()

		if var reference ?= @anonymousTypes[hash] {
			return reference
		}

		@anonymousIndex += 1

		var name = `\(@anonymousIndex)`
		var alias = AliasType.new(@scope, type)
			..flagComplete()
		var named = NamedType.new(name, alias)
			..setPrettyName(type.toQuote())

		@scope.define(name, true, named, this)

		@addTypeTest(name, named)

		var reference = @scope.reference(name)

		@anonymousTypes[hash] = reference

		return reference
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
		@parent.registerSyntimeFunction(`\(@name).\(name)`, macro)
		@parent.exportMacro(`\(@name).\(name)`, macro)
	} # }}}
	getTypeTestVariable() => @parent.recipient().authority().getTypeTestVariable()
	includePath() => null
	initializeVariable({name, type}: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		if var variable ?= @scope.getDefinedVariable(name) {
			variable.setDeclaredType(type)

			return variable.getRealType()
		}
	} # }}}
	name() => @name
	recipient() => this
	registerSyntimeFunction(name, macro) { # {{{
		@scope.addSyntimeFunction(name, macro)
	} # }}}
	toExportFragments(fragments) { # {{{
		var module = @module()
		var line = fragments.newLine().code('return ')
		var object = line.newObject()

		for var variable, name of @exports {
			var type = variable.getDeclaredType()

			type.toExportFragment(object, name, variable, module)
		}

		if @testIndex > 0 {
			var typesLine = object.newLine().code(`__ksType: [`)
			var mut index = 0

			for var variable, name of @exports {
				var type = variable.getDeclaredType()

				if type.hasTest() {
					typesLine.code($comma) if index > 0

					typesLine.code(type.getTestName())

					index += 1
				}
			}

			typesLine.code(']').done()
		}

		object.done()
		line.done()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.namespace(function()')
		var block = line.newBlock()

		if ?#@tests {
			var testsLine = block.newLine().code(`\($runtime.immutableScope(this))\(@testVariable) = `)
			var object = testsLine.newObject()

			for var { type, name } in @tests {
				with var funcLine = object.newLine() {
					var funcName = `is\(name)`

					funcLine.code(`\(funcName): `)

					type.toBlindTestFunctionFragments(funcName, 'value', false, true, null, funcLine, this)

					funcLine.done()
				}

				if type.isVariant() && type.canBeDeferred() {
					var generics = type.generics()

					for var { type % subtype }, index in type.discard().getVariantType().getFields() {
						var funcName = `is\(name)__\(index)`
						var funcLine = object.newLine().code(`\(funcName): `)

						subtype.toBlindTestFunctionFragments(funcName, 'value', false, false, generics, funcLine, this)

						funcLine.done()
					}
				}
			}

			object.done()
			testsLine.done()
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
