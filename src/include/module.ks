export class Module {
	private {
		_aliens					= {}
		_binary: Boolean		= false
		_body
		_compiler: Compiler
		_data
		_directory
		_dynamicRequirements	= []
		_exports				= {}
		_exportedMacros			= {}
		_file
		_flags					= {}
		_hashes					= {}
		_imports				= {}
		_includeModules			= {}
		_includePaths			= {}
		_metadata				= null
		_options
		_output
		_references				= {}
		_register				= false
		_requirements			= []
		_requirementByNames		= {}
		_rewire
	}
	constructor(data, @compiler, @file) { // {{{
		@data = this.parse(data, file)

		@directory = path.dirname(file)
		@options = Attribute.configure(@data, @compiler._options.config, true, AttributeTarget::Global)

		for attr in @data.attributes {
			if attr.declaration.kind == NodeKind::Identifier &&	attr.declaration.name == 'bin' {
				@binary = true
			}
		}

		if @compiler._options.output {
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
	} // }}}
	addAlien(name: String, type: Type) { // {{{
		@aliens[name] = type
	} // }}}
	addHash(file, hash) { // {{{
		@hashes[path.relative(@directory, file)] = hash
	} // }}}
	addHashes(file, hashes) { // {{{
		let root = path.dirname(file)

		for name, hash of hashes {
			if name == '.' {
				@hashes[path.relative(@directory, file)] = hash
			}
			else {
				@hashes[path.relative(@directory, path.join(root, name))] = hash
			}
		}
	} // }}}
	addInclude(path) { // {{{
		if @includePaths[path] is not String {
			@includePaths[path] = true
		}
	} // }}}
	addInclude(path, modulePath, moduleVersion) { // {{{
		if @includePaths[path] == true || @includePaths[path] is not String {
			@includePaths[path] = modulePath
		}

		if @includeModules[modulePath] is Object {
			@includeModules[modulePath].paths:Array.pushUniq(path)
			@includeModules[modulePath].versions:Array.pushUniq(moduleVersion)
		}
		else {
			@includeModules[modulePath] = {
				paths: [path]
				versions: [moduleVersion]
			}
		}
	} // }}}
	addReference(key, code) { // {{{
		if @references[key] {
			@references[key].push(code)
		}
		else {
			@references[key] = [code]
		}

		return this
	} // }}}
	addRequirement(requirement: Requirement) { // {{{
		@requirements.push(requirement)
		@requirementByNames[requirement.name()] = requirement

		if requirement is DynamicRequirement {
			@dynamicRequirements.push(requirement)
		}

		if requirement.isAlien() {
			this.addAlien(requirement.name(), requirement.type())
		}
	} // }}}
	compile() { // {{{
		@body = new ModuleBlock(@data, this)

		@body.analyse()

		@body.prepare()

		@body.translate()
	} // }}}
	compiler() => @compiler
	directory() => @directory
	export(name: String, variable) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		@exports[name] = variable

		variable.type().flagExported().flagReferenced()
	} // }}}
	exportMacro(name: String, data: String) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		if @exportedMacros[name]? {
			@exportedMacros[name].push(data)
		}
		else {
			@exportedMacros[name] = [data]
		}
	} // }}}
	file() => @file
	flag(name) { // {{{
		@flags[name] = true
	} // }}}
	flagRegister() { // {{{
		@register = true
	} // }}}
	getRequirement(name: String) => @requirementByNames[name]
	hasInclude(path) { // {{{
		return @includePaths[path] == true || @includePaths[path] is String
	} // }}}
	import(name: String) { // {{{
		@imports[name] = true
	} // }}}
	isBinary() => @binary
	isUpToDate(file, target, data) { // {{{
		let hashes
		try {
			hashes = JSON.parse(fs.readFile(getHashPath(file, target)))
		}
		catch {
			return null
		}

		let root = path.dirname(file)

		for name, hash of hashes {
			if name == '.' {
				return null if @compiler.sha256(file, data) != hash
			}
			else {
				return null if @compiler.sha256(path.join(root, name)) != hash
			}
		}

		return hashes
	} // }}}
	listIncludeVersions(path, modulePath) { // {{{
		if @includeModules[modulePath] is Object {
			return @includeModules[modulePath].versions
		}
		else if @includePaths[path] == true {
			return ['']
		}
		else {
			return null
		}
	} // }}}
	listReferences(key) { // {{{
		if @references[key] {
			let references = @references[key]

			@references[key] = null

			return references
		}
		else {
			return null
		}
	} // }}}
	parse(data, file) { // {{{
		try {
			return Parser.parse(data)
		}
		catch error {
			error.message += ` (file "\(file)")`
			error.fileName = file

			throw error
		}
	} // }}}
	path(x = null, name) { // {{{
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
	} // }}}
	scope() => @body.scope()
	toHashes() => @hashes
	toFragments() { // {{{
		let fragments = new FragmentBuilder(0)

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
			if @dynamicRequirements.length > 0 {
				const ctrl = fragments.newControl().code('function __ks_require(')

				for requirement, index in @dynamicRequirements {
					if index != 0 {
						ctrl.code($comma)
					}

					requirement.toParameterFragments(ctrl)
				}

				ctrl.code(')').step()

				if @dynamicRequirements.length == 1 {
					@dynamicRequirements[0].toLoneAltFragments(ctrl)
				}
				else {
					ctrl.line('var req = []')

					for requirement in @dynamicRequirements {
						requirement.toManyAltFragments(ctrl)
					}

					ctrl.line('return req')
				}

				ctrl.done()
			}

			const line = fragments.newLine().code('module.exports = function(')

			for requirement, index in @requirements {
				if index != 0 {
					line.code($comma)
				}

				requirement.toParameterFragments(line)
			}

			line.code(')')

			const block = line.newBlock()

			if @dynamicRequirements.length > 0 {
				if @options.format.destructuring == 'es5' {
					let line = block.newLine().code('var __ks__ = __ks_require(')

					for requirement, index in @dynamicRequirements {
						if index != 0 {
							line.code($comma)
						}

						requirement.toParameterFragments(line)
					}

					line.code(')').done()

					line = block.newLine().code('var ')

					let i = -1
					for requirement, index in @dynamicRequirements {
						if index != 0 {
							line.code($comma)
						}

						i = requirement.toAssignmentFragments(line, i)
					}

					line.done()
				}
				else {
					const line = block.newLine().code('var [')

					for requirement, index in @dynamicRequirements {
						if index != 0 {
							line.code($comma)
						}

						requirement.toNameFragments(line)
					}

					line.code('] = __ks_require(')

					for requirement, index in @dynamicRequirements {
						if index != 0 {
							line.code($comma)
						}

						requirement.toParameterFragments(line)
					}

					line.code(')').done()
				}
			}

			@body.toFragments(block)

			let export = 0
			for :variable of @exports {
				if !variable.type().isAlias() {
					++export
				}
			}

			if export != 0 {
				const line = block.newLine().code('return ')
				const object = line.newObject()

				let type
				for name, variable of @exports {
					type = variable.type()

					if !type.isAlias() {
						object.newLine().code(`\(name): `).compile(variable).done()

						if type is not ReferenceType {
							if type.isSealed() && type.isExtendable() {
								object.line(`__ks_\(name): \(type.getSealedName())`)
							}
						}
					}
				}

				object.done()
				line.done()
			}

			block.done()
			line.done()
		}

		let helper = $runtime.helper(this)
		let type = $runtime.type(this)

		let hasHelper = !@flags.Helper || @imports[helper] == true
		let hasType = !@flags.Type || @imports[type] == true

		if !hasHelper || !hasType {
			for requirement in @requirements {
				if requirement.name() == helper {
					hasHelper = true
				}
				else if requirement.name() == type {
					hasType = true
				}
			}
		}

		if !hasHelper || !hasType {
			if hasHelper {
				mark.line(`var \(type) = require("\(@options.runtime.type.package)").\(@options.runtime.type.member)`)
			}
			else if hasType {
				mark.line(`var \(helper) = require("\(@options.runtime.helper.package)").\(@options.runtime.helper.member)`)
			}
			else if @options.runtime.helper.package == @options.runtime.type.package {
				if @options.format.destructuring == 'es5' {
					mark
						.line(`var __ks__ = require("\(@options.runtime.helper.package)")`)
						.line(`var \(helper) = __ks__.\(@options.runtime.helper.member), \(type) = __ks__.\(@options.runtime.type.member)`)
				}
				else {
					helper = `\(@options.runtime.helper.member): \(helper)` unless helper == @options.runtime.helper.member
					type = `\(@options.runtime.type.member): \(type)` unless type == @options.runtime.type.member

					mark.line(`var {\(helper), \(type)} = require("\(@options.runtime.helper.package)")`)
				}
			}
			else {
				mark
					.line(`var \(helper) = require("\(@options.runtime.helper.package)").\(@options.runtime.helper.member)`)
					.line(`var \(type) = require("\(@options.runtime.type.package)").\(@options.runtime.type.member)`)
			}
		}

		return fragments.toArray()
	} // }}}
	toMetadata() { // {{{
		if @metadata == null {
			@metadata = {
				aliens: []
				requirements: []
				exports: []
				references: []
				macros: []
			}

			for name, type of @aliens {
				@metadata.aliens.push(type.toMetadata(@metadata.references), name)
			}

			for requirement in @requirements {
				requirement.toMetadata(@metadata)
			}

			for name, variable of @exports {
				@metadata.exports.push(variable.type().toMetadata(@metadata.references), name)
			}

			for name, datas of @exportedMacros {
				@metadata.macros.push(name, datas)
			}
		}

		return @metadata
	} // }}}
}

class ModuleBlock extends AbstractNode {
	private {
		_module
		_statements: Array		= []
	}
	constructor(@data, @module) { // {{{
		super()

		@options = module._options
		@scope = new ModuleScope()
	} // }}}
	analyse() { // {{{
		for statement in @data.body {
			if statement ?= $compile.statement(statement, this) {
				@statements.push(statement)

				statement.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
		}

		const recipient = this.recipient()
		for statement in @statements when statement.isExportable() {
			statement.export(recipient)
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	directory() => @module.directory()
	file() => @module.file()
	isConsumedError(error): Boolean => @module.isBinary()
	includePath() => null
	module() => @module
	recipient() => @module
	toFragments(fragments) { // {{{
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
	} // }}}
}