export class Module {
	private {
		_aliens							= {}
		_arguments: Array				= []
		_binary: Boolean				= false
		_body
		_compiler: Compiler
		_data
		_directory
		_exports						= {}
		_exportedMacros					= {}
		_file
		_flags							= {}
		_hashes							= {}
		_imports						= {}
		_includeModules					= {}
		_includePaths					= {}
		_metaExports					= null
		_metaRequirements				= null
		_options
		_output
		_register						= false
		_requirements					= []
		_requirementByNames				= {}
		_rewire
		_shebang: String?				= null
		_variationId
	}
	constructor(data, @compiler, @file) { # {{{
		@data = this.parse(data, file)

		@directory = path.dirname(file)
		@options = Attribute.configure(@data, @compiler._options, AttributeTarget::Global, file, true)

		for attr in @data.attributes {
			if attr.declaration.kind == NodeKind::Identifier &&	attr.declaration.name == 'bin' {
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
	addAlien(name: String, type: Type): this { # {{{
		@aliens[name] = type

		return this
	} # }}}
	addHash(file, hash) { # {{{
		@hashes[path.relative(@directory, file)] = hash
	} # }}}
	addHashes(file, hashes) { # {{{
		var mut root = path.dirname(file)

		for var hash, name of hashes {
			if name == '.' {
				@hashes[path.relative(@directory, file)] = hash
			}
			else {
				@hashes[path.relative(@directory, path.join(root, name))] = hash
			}
		}
	} # }}}
	addInclude(path) { # {{{
		if @includePaths[path] is not String {
			@includePaths[path] = true
		}
	} # }}}
	addInclude(path, modulePath, moduleVersion) { # {{{
		if @includePaths[path] == true || @includePaths[path] is not String {
			@includePaths[path] = modulePath
		}

		if @includeModules[modulePath] is Dictionary {
			@includeModules[modulePath].paths:Array.pushUniq(path)
			@includeModules[modulePath].versions:Array.pushUniq(moduleVersion)
		}
		else {
			@includeModules[modulePath] = {
				paths: [path]
				versions: [moduleVersion]
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
	compile() { # {{{
		this.initiate()

		this.finish()
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

		@body.prepare()

		@body.translate()

		for var export, name of @exports {
			if !export.type.isExportable() {
				ReferenceException.throwNotExportable(name, @body)
			}
		}
	} # }}}
	flag(name) { # {{{
		@flags[name] = true
	} # }}}
	flagRegister() { # {{{
		@register = true
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
		@body = new ModuleBlock(@data, this)

		@body.initiate()
	} # }}}
	isBinary() => @binary
	isUpToDate(file: String, source: String) { # {{{
		var mut data
		try {
			data = JSON.parse(fs.readFile(getHashPath(file)))
		}
		catch {
			return null
		}

		var mut root = path.dirname(file)

		for var hash, name of data.hashes {
			if name == '.' {
				return null if @compiler.sha256(file, source) != hash
			}
			else {
				return null if @compiler.sha256(path.join(root, name)) != hash
			}
		}

		return data
	} # }}}
	isUpToDate(hashes): Boolean { # {{{
		for var hash, name of @hashes {
			var h = hashes[name]
			if h? {
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
	listIncludeVersions(path, modulePath) { # {{{
		if @includeModules[modulePath] is Dictionary {
			return @includeModules[modulePath].versions
		}
		else if @includePaths[path] == true {
			return ['']
		}
		else {
			return null
		}
	} # }}}
	parse(data, file) { # {{{
		try {
			return Parser.parse(data)
		}
		catch error {
			error.fileName = file
			error.message += ` (\(error.fileName):\(error.lineNumber):\(error.columnNumber))`

			throw error
		}
	} # }}}
	path(x = null, name) { # {{{
		if !?x || !?@output {
			return name
		}

		var mut output = null
		for rewire in @rewire {
			if rewire.input == x {
				output = path.relative(@output, rewire.output)
				break
			}
		}

		if !?output {
			output = path.relative(@output, x)
		}

		if output[0] != '.' {
			output = './' + output
		}

		return output
	} # }}}
	scope() => @body.scope()
	setArguments(arguments: Array, module: String = path.basename(@file), node: AbstractNode = @body) { # {{{
		var scope = @body.scope()

		if arguments.length != 0 {
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
				else if var { name, type } = arguments[index] {
					if type.isSubsetOf(requirement.type(), MatchingMode::Signature) {
						if !requirement.type().isSubsetOf(type, MatchingMode::Signature) {
							var index = type.toMetadata(metadata, 0, ExportMode::Requirement, this)
							var newType = Type.toNamedType(requirement.name(), references[index] ?? Type.import(index, metadata, references, alterations, queue, scope, @body))

							references[index] = newType

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

			while queue.length > 0 {
				queue.shift()()
			}

			for var reset in resets {
				reset.resetReferences()
			}
		}
	} # }}}
	setShebang(@shebang) { # {{{
		@binary = true
	} # }}}
	toHashes() => @hashes
	toFragments() { # {{{
		var fragments = new FragmentBuilder(0)
		
		if ?@shebang {
			fragments.newLine(terminator: false).code(`#!\(@shebang)\n`).done()
		}

		if @options.header {
			fragments.comment(`// Generated by kaoscript \(metadata.version)`)
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

			var mut exportable = false
			for var export of @exports {
				if export.type.isExportingFragment() {
					exportable = true

					break
				}
			}

			if exportable {
				var line = block.newLine().code('return ')
				var object = line.newObject()

				for var export, name of @exports {
					export.type.toExportFragment(object, name, export.variable)
				}

				object.done()
				line.done()
			}

			block.done()
			line.done()
		}

		var dictionary = $runtime.dictionary(this)
		var helper = $runtime.helper(this)
		var initFlag = $runtime.initFlag(this)
		var operator = $runtime.operator(this)
		var type = $runtime.type(this)

		var mut hasDictionary = @flags.Dictionary == true && !@imports[dictionary]
		var mut hasHelper = @flags.Helper == true && !@imports[helper]
		var mut hasInitFlag = @flags.initFlag == true
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
		if hasDictionary {
			packages[@options.runtime.dictionary.package] ??= []

			packages[@options.runtime.dictionary.package].push({
				name: dictionary
				options: @options.runtime.dictionary
			})
		}
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

		return fragments.toArray()
	} # }}}
	toExports() { # {{{
		if @metaRequirements == null {
			this.toRequirements()
		}

		if @metaExports == null {
			@metaExports = {
				exports: []
				references: []
				macros: []
			}

			var delta = @metaRequirements.references.length

			for var { variable }, name of @exports {
				var mut type

				if variable is IdentifierLiteral | Variable {
					type = variable.getDeclaredType()
				}
				else {
					type = variable.type()
				}

				@metaExports.exports.push(type.toMetadata(@metaExports.references, delta, ExportMode::Export, this), name)
			}

			for var datas, name of @exportedMacros {
				@metaExports.macros.push(name, datas)
			}
		}

		return @metaExports
	} # }}}
	toRequirements() { # {{{
		if @metaRequirements == null {
			@metaRequirements = {
				aliens: []
				requirements: []
				references: []
			}
			for var type, name of @aliens {
				@metaRequirements.aliens.push(
					type.toMetadata(@metaRequirements.references, 0, ExportMode::Alien, this)
					name,
					null
				)
			}

			for var requirement in @requirements {
				@metaRequirements.requirements.push(
					requirement.type().toMetadata(@metaRequirements.references, 0, ExportMode::Requirement, this)
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

			if @arguments? {
				for var type in @arguments {
					if type is Boolean {
						variations.push(false)
					}
					else if type? {
						type.toVariations(variations)
					}
					else {
						variations.push(null)
					}
				}
			}

			@variationId = fs.djb2a(variations.join())
		}

		return @variationId
	} # }}}
}

class ModuleBlock extends AbstractNode {
	private {
		_attributeDatas			= {}
		_module
		_statements: Array		= []
		_topNodes: Array		= []
	}
	constructor(@data, @module) { # {{{
		super()

		@options = module._options
		@scope = new ModuleScope()
	} # }}}
	initiate() { # {{{
		return unless @data.body.length > 0
		
		var mut start = 0
		
		if @data.body[0].kind == NodeKind::ShebangDeclaration {
			@module.setShebang(@data.body[0].command)
			
			start = 1
		}
	
		for var statement in @data.body from start {
			@scope.line(statement.start.line)

			if var statement = $compile.statement(statement, this) {
				@statements.push(statement)

				statement.initiate()
			}
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

		var recipient = this.recipient()
		for var statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient, true)
		}
	} # }}}
	prepare() { # {{{
		for var statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		var recipient = this.recipient()
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
	addInitializableVariable(variable, node)
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	directory() => @module.directory()
	exportMacro(name, macro) { # {{{
		@module.exportMacro(name, macro.toMetadata())
	} # }}}
	file() => @module.file()
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		if variable.static {
			var class = @scope.getVariable(variable.class).declaration()

			if var var = class.getClassVariable(variable.name) {
				var.initialize(variable.type, expression)
			}
		}
		else if var var = @scope.getDefinedVariable(variable.name) {
			var.setDeclaredType(variable.type)
		}
	} # }}}
	isConsumedError(error): Boolean => @module.isBinary()
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { # {{{
		var line = stmt.line()

		for var statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	includePath() => null
	module() => @module
	publishMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)
	} # }}}
	registerMacro(name, macro) { # {{{
		@scope.addMacro(name, macro)
	} # }}}
	recipient() => @module
	setAttributeData(key: AttributeData, data) { # {{{
		@attributeDatas[key] = data
	} # }}}
	target() => @options.target
	toFragments(fragments) { # {{{
		for var node in @topNodes {
			node.toAuthorityFragments(fragments)
		}

		var mut index = -1
		var mut item

		for statement, i in @statements while index == -1 {
			if item ?= statement.toFragments(fragments, Mode::None) {
				index = i
			}
		}

		if index != -1 {
			item(@statements.slice(index + 1))
		}
	} # }}}
}
