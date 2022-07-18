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
		let root = path.dirname(file)

		for const hash, name of hashes {
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

		const type = identifier.getDeclaredType()

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

		const type = expression.type()

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

		const type = variable.getDeclaredType()

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

		for const export, name of @exports {
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
		let data
		try {
			data = JSON.parse(fs.readFile(getHashPath(file)))
		}
		catch {
			return null
		}

		let root = path.dirname(file)

		for const hash, name of data.hashes {
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
		for const hash, name of @hashes {
			const h = hashes[name]
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
			error.message += ` (file "\(file)")`
			error.fileName = file

			throw error
		}
	} # }}}
	path(x = null, name) { # {{{
		if !?x || !?@output {
			return name
		}

		let output = null
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
		const scope = @body.scope()

		if arguments.length != 0 {
			const references = {}
			const queue = []
			const alterations = {}
			const resets = []
			const metadata = []

			for const requirement, index in @requirements {
				if arguments[index] is Boolean {
					if requirement.isRequired() {
						SyntaxException.throwMissingRequirement(requirement.name(), module, node)
					}
					else {
						@arguments.push(false)
					}
				}
				else if const { name, type } = arguments[index] {
					if type.isSubsetOf(requirement.type(), MatchingMode::Signature) {
						if !requirement.type().isSubsetOf(type, MatchingMode::Signature) {
							const index = type.toMetadata(metadata, 0, ExportMode::Requirement, this)
							const newType = Type.toNamedType(requirement.name(), references[index] ?? Type.import(index, metadata, references, alterations, queue, scope, @body))

							references[index] = newType

							if requirement.type().isExtendable() {
								newType.originals(requirement.type().type())
							}

							newType.flagRequirement()

							const variable = scope.getVariable(requirement.name())

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

			for const reset in resets {
				reset.resetReferences()
			}
		}
	} # }}}
	toHashes() => @hashes
	toFragments() { # {{{
		const fragments = new FragmentBuilder(0)

		if @options.header {
			fragments.comment(`// Generated by kaoscript \(metadata.version)`)
		}

		if @register && @compiler._options.register {
			fragments.line('require("kaoscript/register")')
		}

		const mark = fragments.mark()

		if @binary {
			@body.toFragments(fragments)
		}
		else {
			const line = fragments.newLine().code('module.exports = function(')

			let comma = false

			for const requirement in @requirements {
				comma = requirement.toParameterFragments(line, comma)
			}

			line.code(')')

			const block = line.newBlock()

			for const requirement in @requirements {
				requirement.toFragments(block)
			}

			@body.toFragments(block)

			let exportable = false
			for const export of @exports {
				if export.type.isExportingFragment() {
					exportable = true

					break
				}
			}

			if exportable {
				const line = block.newLine().code('return ')
				const object = line.newObject()

				for const export, name of @exports {
					export.type.toExportFragment(object, name, export.variable)
				}

				object.done()
				line.done()
			}

			block.done()
			line.done()
		}

		const dictionary = $runtime.dictionary(this)
		const helper = $runtime.helper(this)
		const initFlag = $runtime.initFlag(this)
		const operator = $runtime.operator(this)
		const type = $runtime.type(this)

		let hasDictionary = @flags.Dictionary == true && !@imports[dictionary]
		let hasHelper = @flags.Helper == true && !@imports[helper]
		let hasInitFlag = @flags.initFlag == true
		let hasOperator = @flags.Operator == true && !@imports[operator]
		let hasType = @flags.Type == true && !@imports[type]

		if hasHelper || hasType {
			for const requirement in @requirements {
				if requirement.name() == helper {
					hasHelper = false
				}
				else if requirement.name() == type {
					hasType = false
				}
			}
		}

		const packages = {}
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

		for const package, name of packages {
			const line = mark.newLine().code('const {')

			for const item, index in package {
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

			const delta = @metaRequirements.references.length

			for const { variable }, name of @exports {
				let type

				if variable is IdentifierLiteral | Variable {
					type = variable.getDeclaredType()
				}
				else {
					type = variable.type()
				}

				@metaExports.exports.push(type.toMetadata(@metaExports.references, delta, ExportMode::Export, this), name)
			}

			for const datas, name of @exportedMacros {
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
			for const type, name of @aliens {
				@metaRequirements.aliens.push(
					type.toMetadata(@metaRequirements.references, 0, ExportMode::Alien, this)
					name,
					null
				)
			}

			for const requirement in @requirements {
				@metaRequirements.requirements.push(
					requirement.type().toMetadata(@metaRequirements.references, 0, ExportMode::Requirement, this)
					requirement.name()
					requirement.toRequiredMetadata()
				)
			}

			let index = 2
			for const type, name of @aliens {
				@metaRequirements.aliens[index] = type.toRequiredMetadata(@requirements)

				index += 3
			}
		}

		return @metaRequirements
	} # }}}
	toVariationId() { # {{{
		if !?@variationId {
			const variations = [@options.target.name, @options.target.version]

			if @arguments? {
				for const type in @arguments {
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
		for const statement in @data.body {
			@scope.line(statement.start.line)

			if const statement = $compile.statement(statement, this) {
				@statements.push(statement)

				statement.initiate()
			}
		}
	} # }}}
	analyse() { # {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}
	} # }}}
	enhance() { # {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		const recipient = this.recipient()
		for const statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient, true)
		}
	} # }}}
	prepare() { # {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		const recipient = this.recipient()
		for const statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient, false)
		}

		let type: Type
		for const data, name of @module._exports {
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
		for const statement in @statements {
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
			const class = @scope.getVariable(variable.class).declaration()

			if const var = class.getClassVariable(variable.name) {
				var.initialize(variable.type, expression)
			}
		}
		else if const var = @scope.getDefinedVariable(variable.name) {
			var.setDeclaredType(variable.type)
		}
	} # }}}
	isConsumedError(error): Boolean => @module.isBinary()
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { # {{{
		const line = stmt.line()

		for const statement in @statements while statement.line() < line && statement != stmt {
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
		for const node in @topNodes {
			node.toAuthorityFragments(fragments)
		}

		let index = -1
		let item

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
