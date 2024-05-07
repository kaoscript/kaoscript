export class Module {
	private {
		@aliens							= {}
		@arguments: Array				= []
		@binary: Boolean				= false
		@body
		@compiler: Compiler
		@data
		@directory
		@exports						= {}
		@exported: Boolean				= false
		@exportedMacros					= {}
		@file
		@flags							= {}
		@hashes							= {}
		@imports						= {}
		@includeModules					= {}
		@includePaths					= {}
		@libSTDType: Boolean			= false
		@libSTDUsages: String[]			= []
		@metaExports					= {
			exports: []
			references: []
			macros: []
		}
		@metaRequirements?				= null
		@options
		@output
		@register						= false
		@requirements					= []
		@requirementByNames				= {}
		@rewire
		@standardLibrary: Boolean		= false
		@variationId
	}
	constructor(data, @compiler, @file) { # {{{
		@data = @parse(data, file)

		@directory = $path.dirname(file)
		@options = Attribute.configure(@data, @compiler._options, AttributeTarget.Global, file, true)
		@standardLibrary = @options.libstd.current

		for var attr in @data.attributes {
			if attr.declaration.kind == NodeKind.Identifier &&	attr.declaration.name == 'bin' {
				@binary = true
			}
		}

		if @compiler._options.output is String {
			@output = @compiler._options.output

			if @compiler._options.rewire is Array {
				@rewire = @compiler._options.rewire
			}
			else {
				@rewire = []
			}
		}
		else {
			@output = null
		}

		@hashes['.'] = @compiler.sha256(file, data)
	} # }}}
	addAlien(name: String, type: Type): valueof this { # {{{
		@aliens[name] = type

		return this
	} # }}}
	addHash(file, hash) { # {{{
		@hashes[$path.relative(@directory, file)] = hash
	} # }}}
	addHashes(file, hashes) { # {{{
		var mut root = $path.dirname(file)

		for var hash, name of hashes {
			if name == '.' {
				@hashes[$path.relative(@directory, file)] = hash
			}
			else {
				@hashes[$path.relative(@directory, $path.join(root, name))] = hash
			}
		}
	} # }}}
	addInclude(path) { # {{{
		if @includePaths[path] is not String {
			@includePaths[path] = true
		}
	} # }}}
	addInclude(path, moduleName, modulePath, moduleVersion) { # {{{
		if @includePaths[path] == true || @includePaths[path] is not String {
			@includePaths[path] = modulePath
		}

		if ?@includeModules[moduleName] {
			@includeModules[moduleName].paths:!!!(Array).pushUniq(path)
			@includeModules[moduleName].versions:!!!(Array).pushUniq(moduleVersion)
		}
		else {
			@includeModules[moduleName] = {
				paths: [path]
				versions: [moduleVersion]
			}
		}

		if moduleName != modulePath {
			if ?@includeModules[modulePath] {
				@includeModules[modulePath].paths:!!!(Array).pushUniq(path)
				@includeModules[modulePath].versions:!!!(Array).pushUniq(moduleVersion)
			}
			else {
				@includeModules[modulePath] = {
					paths: [path]
					versions: [moduleVersion]
				}
			}
		}
	} # }}}
	addRequirement(requirement: Requirement) { # {{{
		if ?@requirementByNames[requirement.name()] {
			return this
		}

		requirement.index(@requirements.length)

		@requirements.push(requirement)
		@requirementByNames[requirement.name()] = requirement

		requirement.type().flagRequirement()

		return this
	} # }}}
	authority() => @body
	compile() { # {{{
		@initiate()

		@finish()
	} # }}}
	compiler() => @compiler
	directory() => @directory
	export(name: String, identifier: IdentifierLiteral) { # {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		var type = identifier.getDeclaredType()

		@exports[name] = {
			type
			variable: identifier
		}

		type.flagExported(true).flagReferenced()
	} # }}}
	export(name: String, expression: Expression | ExportProperty) { # {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		var type = expression.type()

		@exports[name] = {
			type
			variable: expression
		}

		type.flagExported(true).flagReferenced()
	} # }}}
	export(name: String, variable: Variable) { # {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		var type = variable.getDeclaredType()

		@exports[name] = {
			type
			variable
		}

		type.flagExported(false).flagReferenced()
	} # }}}
	exportMacro(name: String, data: String) { # {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		if @exportedMacros[name] is Array {
			@exportedMacros[name].push(data)
		}
		else {
			@exportedMacros[name] = [data]
		}
	} # }}}
	exportMacro(name: String, macro: MacroDeclaration) { # {{{
		@body.exportMacro(name, macro)
	} # }}}
	file() => @file
	finish() { # {{{
		@body.analyse()

		@body.enhance()

		@body.prepare(@binary ? Type.Void : AnyType.NullableUnexplicit)

		@body.translate()

		for var export, name of @exports {
			unless export.type.isExportable(this) {
				ReferenceException.throwNotExportable(name, @body)
			}
		}
	} # }}}
	flag(name) { # {{{
		@flags[name] = true
	} # }}}
	flagBinary() { # {{{
		@binary = true
	} # }}}
	flagRegister() { # {{{
		@register = true
	} # }}}
	flagLibSTDType() { # {{{
		@libSTDType = true
	} # }}}
	flagLibSTDUsage(name: String) { # {{{
		@libSTDUsages.pushUniq(name)
	} # }}}
	getAlien(name: String) => @aliens[name]
	getArgument(index: Number) => @arguments[index]
	getRequirement(name: String) => @requirementByNames[name]
	hasInclude(path) { # {{{
		return @includePaths[path] == true || @includePaths[path] is String
	} # }}}
	import(name: String) { # {{{
		@imports[name] = true
	} # }}}
	initiate() { # {{{
		@body = ModuleBlock.new(@data, this)

		@body.initiate()
	} # }}}
	isBinary() => @binary
	isStandardLibrary(): Boolean => @standardLibrary
	isUpToDate(file: String, source: String) { # {{{
		var late data
		try {
			data = JSON.parse($fs.readFile(getHashPath(file)))
		}
		catch {
			return null
		}

		var mut root = $path.dirname(file)

		for var hash, name of data.hashes {
			if name == '.' {
				return null if @compiler.sha256(file, source) != hash
			}
			else {
				return null if @compiler.sha256($path.join(root, name)) != hash
			}
		}

		return data
	} # }}}
	isUpToDate(hashes): Boolean { # {{{
		for var hash, name of @hashes {
			var h = hashes[name]
			if ?h {
				if h != hash {
					return false
				}
			}
			else {
				return false
			}
		}

		return true
	} # }}}
	listIncludeVersions(path, moduleName, modulePath) { # {{{
		if ?@includeModules[modulePath] {
			return @includeModules[modulePath].versions
		}
		else if ?@includeModules[moduleName] {
			return @includeModules[moduleName].versions
		}
		else if @includePaths[path] {
			return ['']
		}
		else {
			return null
		}
	} # }}}
	parse(data, file) { # {{{
		try {
			return SyntaxAnalysis.parse(data)
		}
		catch error {
			error.fileName = file
			error.message += ` (\(error.fileName):\(error.lineNumber):\(error.columnNumber))`

			throw error
		}
	} # }}}
	path(filename: String? = null, name: String): String { # {{{
		unless ?filename && ?@output {
			return name
		}

		var mut output: String? = null

		for var rewire in @rewire {
			if rewire.input == filename {
				output = $path.relative(@output, rewire.output)
				break
			}
		}

		if !?output {
			output = $path.relative(@output, filename)
		}

		if output[0] != '.' {
			output = './' + output
		}

		return output!?
	} # }}}
	scope() => @body.scope()
	setArguments(arguments: Array, module: String = $path.basename(@file), node: AbstractNode = @body) { # {{{
		var scope = @body.scope()

		if ?#arguments {
			var references = {}
			var queue = []
			var alterations = {}
			var resets = []
			var metadata = []

			for var requirement, index in @requirements {
				if arguments[index] is Boolean {
					if requirement.isRequired() {
						SyntaxException.throwMissingRequirement(requirement.name(), module, node)
					}
					else {
						@arguments.push(false)
					}
				}
				else if var { name, type } ?= arguments[index] {
					if type.isSubsetOf(requirement.type(), MatchingMode.Signature) {
						if !requirement.type().isSubsetOf(type, MatchingMode.Signature) {
							var refIndex = type.toMetadata(metadata, 0, ExportMode.Requirement, this)
							var newType = Type.toNamedType(requirement.name(), references[refIndex] ?? Type.import(refIndex, metadata, references, alterations, queue, scope, @body))

							references[refIndex] = newType

							if requirement.type().isExtendable() {
								newType.originals(requirement.type().type())
							}

							newType.flagRequirement()

							var variable = scope.getVariable(requirement.name())

							variable.setDeclaredType(newType)

							resets.pushUniq(type, type.scope())
						}
					}
					else {
						TypeException.throwNotCompatibleArgument(name, requirement.name(), module, node)
					}

					@arguments.push(type)
				}
				else {
					if requirement.isRequired() {
						SyntaxException.throwMissingRequirement(requirement.name(), module, node)
					}
					else {
						@arguments.push(null)
					}
				}
			}

			while #queue > 0 {
				queue.shift()()
			}

			for var reset in resets {
				reset.resetReferences()
			}
		}
	} # }}}
	toHashes() => @hashes
	toFragments() { # {{{
		var fragments = FragmentBuilder.new(0)

		if @options.header {
			fragments.comment(`// Generated by kaoscript \($metadata.version)`)
		}

		if @register && @compiler._options.register {
			fragments.line('require("kaoscript/register")')
		}

		var mark = fragments.mark()

		if @binary {
			@body.toFragments(fragments)
		}
		else {
			var line = fragments.newLine().code('module.exports = function(')

			var mut comma = false

			for var requirement in @requirements {
				comma = requirement.toParameterFragments(line, comma)
			}

			line.code(')')

			var block = line.newBlock()

			for var requirement in @requirements {
				requirement.toFragments(block)
			}

			@body.toFragments(block)

			var mut exportingFragments = {}
			var mut exportingTypes = []

			if @standardLibrary {
				for var export, name of @exports {
					if export.type.isExportingFragment() {
						if export.type.isStandardLibrary(LibSTDMode.Yes) || export.type.hasAuxiliary() {
							exportingFragments[name] = export
						}
					}
					else if export.type.isExportingType() {
						exportingTypes.push(export)
					}
				}
			}
			else {
				for var export, name of @exports {
					if export.type.isExportingFragment() {
						exportingFragments[name] = export
					}
					else if export.type.isExportingType() {
						exportingTypes.push(export)
					}
				}
			}

			if ?#exportingFragments || ?#exportingTypes {
				var returnLine = block.newLine().code('return ')
				var object = returnLine.newObject()

				for var export, name of exportingFragments {
					export.type.toExportFragment(object, name, export.variable, this)
				}

				if ?#exportingTypes {
					var typesLine = object.newLine().code(`\(@standardLibrary ? '__ksStd_types' : '__ksType'): [`)

					for var { type }, index in exportingTypes {
						typesLine
							..code($comma) if index > 0
							..code(type.getTestName())

						type.setTestIndex(index)
					}

					typesLine.code(']').done()
				}

				object.done()
				returnLine.done()
			}

			block.done()
			line.done()
		}

		var helper = $runtime.helper(this)
		var initFlag = $runtime.initFlag(this)
		var object = $runtime.object(this)
		var operator = $runtime.operator(this)
		var type = $runtime.type(this)

		var mut hasHelper = @flags.Helper == true && !@imports[helper]
		var mut hasInitFlag = @flags.initFlag == true
		var mut hasObject = @flags.Object == true && !@imports[object]
		var mut hasOperator = @flags.Operator == true && !@imports[operator]
		var mut hasType = @flags.Type == true && !@imports[type]

		if hasHelper || hasType {
			for var requirement in @requirements {
				if requirement.name() == helper {
					hasHelper = false
				}
				else if requirement.name() == type {
					hasType = false
				}
			}
		}

		var packages = {}
		if hasHelper {
			packages[@options.runtime.helper.package] ??= []

			packages[@options.runtime.helper.package].push({
				name: helper
				options: @options.runtime.helper
			})
		}
		if hasInitFlag {
			packages[@options.runtime.initFlag.package] ??= []

			packages[@options.runtime.initFlag.package].push({
				name: initFlag
				options: @options.runtime.initFlag
			})
		}
		if hasObject {
			packages[@options.runtime.object.package] ??= []

			packages[@options.runtime.object.package].push({
				name: object
				options: @options.runtime.object
			})
		}
		if hasOperator {
			packages[@options.runtime.operator.package] ??= []

			packages[@options.runtime.operator.package].push({
				name: operator
				options: @options.runtime.operator
			})
		}
		if hasType {
			packages[@options.runtime.type.package] ??= []

			packages[@options.runtime.type.package].push({
				name: type
				options: @options.runtime.type
			})
		}

		for var package, name of packages {
			var line = mark.newLine().code('const {')

			for var item, index in package {
				line.code(', ') if index != 0

				if item.name == item.options.member {
					line.code(item.name)
				}
				else {
					line.code(`\(item.options.member): \(item.name)`)
				}
			}

			line.code(`} = require("\(name)")`)

			line.done()
		}

		if @libSTDType || ?#@libSTDUsages {
			@body._statements[0]._declarators[0].toLibSTDFragments(@libSTDType, @libSTDUsages, mark)
		}

		return fragments.toArray()
	} # }}}
	toExports() { # {{{
		@metaRequirements ??= @toRequirements()

		if !@exported {
			var delta = @metaRequirements.references.length

			for var { variable }, name of @exports {
				var type = if variable is IdentifierLiteral | Variable {
					set variable.getDeclaredType()
				}
				else {
					set variable.type()
				}

				@metaExports.exports.push(type.toMetadata(@metaExports.references, delta, ExportMode.Export, this), name)
			}

			for var datas, name of @exportedMacros {
				@metaExports.macros.push(name, datas)
			}

			@exported = true
		}

		return @metaExports
	} # }}}
	toRequirements() { # {{{
		if !?@metaRequirements {
			@metaRequirements = {
				aliens: []
				requirements: []
				references: []
			}

			for var type, name of @aliens {
				@metaRequirements.aliens.push(
					type.toMetadata(@metaRequirements.references, 0, ExportMode.Alien, this)
					name,
					null
				)
			}

			for var requirement in @requirements {
				@metaRequirements.requirements.push(
					requirement.type().toMetadata(@metaRequirements.references, 0, ExportMode.Requirement, this)
					requirement.name()
					requirement.toRequiredMetadata()
				)
			}

			var mut index = 2
			for var type, name of @aliens {
				@metaRequirements.aliens[index] = type.toRequiredMetadata(@requirements)

				index += 3
			}
		}

		return @metaRequirements
	} # }}}
	toVariationId() { # {{{
		if !?@variationId {
			var variations = [@options.target.name, @options.target.version]

			if ?@arguments {
				for var type in @arguments {
					if type is Boolean {
						variations.push(false)
					}
					else if ?type {
						type.toVariations(variations)
					}
					else {
						variations.push(null)
					}
				}
			}

			@variationId = $fs.djb2a(variations.join())
		}

		return @variationId
	} # }}}
}

class ModuleBlock extends AbstractNode {
	private {
		@anonymousIndex: Number				= -1
		@anonymousTypes: ReferenceType{}	= {}
		@attributeDatas						= {}
		@length: Number						= 0
		@module: Module
		@statements: Array					= []
		@topNodes: Array					= []
		@typeTests							= []
		@typeTestVarCount: Number			= -1
	}
	constructor(@data, @module) { # {{{
		super()

		@options = module._options
		@scope = ModuleScope.new(@module.isStandardLibrary())
	} # }}}
	initiate() { # {{{
		return unless @data.body.length > 0

		var mut start = 0

		if @data.body[0].kind == NodeKind.ShebangDeclaration {
			@module.flagBinary()

			start = 1
		}

		if @options.libstd.enable {
			var statement = $compile.statement({
				kind: NodeKind.ImportDeclaration
				declarations: [{
					kind: NodeKind.ImportDeclarator
					source: {
						value: @options.libstd.package
					}
					attributes: []
					modifiers: []
					specifiers: []
					start: { line: 1 }
					end: { line: 1 }
				}]
				attributes: []
				start: { line: 1 }
				end: { line: 1 }
			}, this)

			@statements.push(statement)

			statement
				..flagStandardLibrary()
				..initiate()
		}

		for var data in @data.body from start {
			@scope.line(data.start.line)

			if var statement ?= $compile.statement(data, this) {
				@statements.push(statement)

				statement.initiate()
			}
		}

		for var statement in @statements {
			statement.postInitiate()
		}

		@length = @data.body.length
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

		var recipient = @recipient()
		for var statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient, true)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var statement, index in @statements {
			@scope.line(statement.line())

			if statement is ReturnStatement {
				statement.prepare(target, index, @length)
			}
			else {
				statement.prepare(Type.Void, index, @length)
			}
		}

		var recipient = @recipient()
		for var statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient, false)
		}

		var mut type: Type
		for var data, name of @module._exports {
			if data.variable is Variable {
				type = data.variable.getRealType()
			}
			else {
				type = data.variable.type()
			}

			if type.isNull() && !data.type.isNullable() {
				TypeException.throwUnexpectedExportType(name, data.type, type, this)
			}
		}
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
		@typeTests.push({ name, type })

		type.setTestName(`__ksType.is\(name)`)
	} # }}}
	authority() => this
	directory() => @module.directory()
	exportMacro(name, macro) { # {{{
		@module.exportMacro(name, macro.toMetadata())
	} # }}}
	file() => @module.file()
	override getASTReference(name) => null
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	getLoopAncestorWithoutNew(name: String, before: Statement): Statement? => null
	getTypeTestVariable(): String { # {{{
		@typeTestVarCount += 1

		return `__ksType\(@typeTestVarCount)`
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		if variable.static {
			var class = @scope.getVariable(variable.class).declaration()

			if var var ?= class.getStaticVariable(variable.name) {
				var.initialize(variable.type, expression)
			}
		}
		else if var var ?= @scope.getDefinedVariable(variable.name) {
			var.setDeclaredType(variable.type)

			return var.getRealType()
		}
	} # }}}
	isConsumedError(error): Boolean => @module.isBinary()
	isUsingStaticVariableBefore(class: String, varname: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariableBefore(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	includePath() => null
	module() => @module
	registerMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)
	} # }}}
	recipient() => @module
	setAttributeData(key: AttributeData, data) { # {{{
		@attributeDatas[key] = data
	} # }}}
	target() => @options.target
	toFragments(fragments) { # {{{
		if ?#@typeTests {
			var line = fragments.newLine().code(`\($runtime.immutableScope(this))__ksType = `)
			var object = line.newObject()
			var variants = []

			for var { type, name } in @typeTests {
				var funcName = `is\(name)`
				var funcLine = object.newLine().code(`\(funcName): `)

				type.toBlindTestFunctionFragments(funcName, 'value', false, true, null, funcLine, this)

				funcLine.done()

				if type.isVariant() && type.canBeDeferred() {
					variants.push({
						name
						variant: type.discard().getVariantType()
						generics: type.generics()
					})
				}
			}

			object.done()
			line.done()

			if ?#variants {
				for var { name, variant, generics } in variants {
					for var { type }, index in variant.getFields() {
						var funcName = `is\(name).__\(index)`
						var funcLine = fragments.newLine().code(`__ksType.\(funcName) = `)

						type.toBlindTestFunctionFragments(funcName, 'value', false, false, generics, funcLine, this)

						funcLine.done()
					}
				}
			}
		}

		for var node in @topNodes {
			node.toAuthorityFragments(fragments)
		}

		var mut index = -1
		var mut item = null

		for var statement, i in @statements while index == -1 {
			if item ?= statement.toFragments(fragments, Mode.None) {
				index = i
			}
		}

		if index != -1 {
			item(@statements.slice(index + 1))
		}
	} # }}}
}
