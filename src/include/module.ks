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
		@options = Attribute.configure(@data, @compiler._options, AttributeTarget::Global, true)

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
	} // }}}
	addAlien(name: String, type: Type) { // {{{
		@aliens[name] = type
	} // }}}
	addHash(file, hash) { // {{{
		@hashes[path.relative(@directory, file)] = hash
	} // }}}
	addHashes(file, hashes) { // {{{
		let root = path.dirname(file)

		for const hash, name of hashes {
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

		for const export, name of @exports {
			if !export.type.isExportable() {
				ReferenceException.throwNotExportable(name, @body)
			}
		}
	} // }}}
	compiler() => @compiler
	directory() => @directory
	export(name: String, identifier: IdentifierLiteral) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		const type = identifier.getDeclaredType()

		@exports[name] = {
			type
			variable: identifier
		}

		type.flagExported(true).flagReferenced()
	} // }}}
	export(name: String, expression: Expression | ExportProperty) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		const type = expression.type()

		@exports[name] = {
			type
			variable: expression
		}

		type.flagExported(true).flagReferenced()
	} // }}}
	export(name: String, variable: Variable) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		const type = variable.getDeclaredType()

		@exports[name] = {
			type
			variable
		}

		type.flagExported(false).flagReferenced()
	} // }}}
	exportMacro(name: String, data: String) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}

		if @exportedMacros[name] is Array {
			@exportedMacros[name].push(data)
		}
		else {
			@exportedMacros[name] = [data]
		}
	} // }}}
	exportMacro(name: String, macro: MacroDeclaration) { // {{{
		@body.exportMacro(name, macro)
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

		for const hash, name of hashes {
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
		if @includeModules[modulePath] is Dictionary {
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

				ctrl.line('var req = []')

				for requirement in @dynamicRequirements {
					requirement.toAltFragments(ctrl)
				}

				ctrl.line('return req')

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

			let exportCount = 0
			for const export of @exports {
				if !export.type.isAlias() {
					++exportCount
				}
			}

			if exportCount != 0 {
				const line = block.newLine().code('return ')
				const object = line.newObject()

				let type
				for const export, name of @exports {
					type = export.type

					if !type.isAlias() {
						if !type.isVirtual() {
							object.newLine().code(`\(name): `).compile(export.variable).done()
						}

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

		const dictionary = $runtime.dictionary(this)
		const helper = $runtime.helper(this)
		const operator = $runtime.operator(this)
		const type = $runtime.type(this)

		let hasDictionary = @flags.Dictionary == true && !@imports[dictionary]
		let hasHelper = @flags.Helper == true && !@imports[helper]
		let hasOperator = @flags.Operator == true && !@imports[operator]
		let hasType = @flags.Type == true && !@imports[type]

		if hasDictionary || hasHelper || hasType {
			for const requirement in @requirements {
				if requirement.name() == dictionary {
					hasDictionary = false
				}
				else if requirement.name() == helper {
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
			if package.length == 1 {
				mark.line(`var \(package[0].name) = require("\(package[0].options.package)").\(package[0].options.member)`)
			}
			else if @options.format.destructuring == 'es5' {
				mark.line(`var __ks__ = require("\(name)")`)

				const line = mark.newLine().code('var ')

				for const item, index in package {
					line.code(', ') if index != 0

					line.code(`\(item.name) = __ks__.\(item.options.member)`)
				}

				line.done()
			}
			else {
				const line = mark.newLine().code('var {')

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

			for requirement in @requirements {
				@metadata.requirements.push(
					requirement.type().toMetadata(@metadata.references, ExportMode::IgnoreAlteration)
					requirement.name()
					requirement.isRequired()
				)
			}

			for const type, name of @aliens {
				@metadata.aliens.push(type.toMetadata(@metadata.references, ExportMode::IgnoreAlteration), name)
			}

			for const export, name of @exports {
				@metadata.exports.push(export.type.toMetadata(@metadata.references, ExportMode::Default), name)
			}

			for const datas, name of @exportedMacros {
				@metadata.macros.push(name, datas)
			}
		}

		return @metadata
	} // }}}
}

class ModuleBlock extends AbstractNode {
	private {
		_attributeDatas			= {}
		_module
		_statements: Array		= []
	}
	constructor(@data, @module) { // {{{
		super()

		@options = module._options
		@scope = new ModuleScope()
	} // }}}
	analyse() { // {{{
		for const statement in @data.body {
			@scope.line(statement.start.line)

			if const statement = $compile.statement(statement, this) {
				@statements.push(statement)

				statement.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		const recipient = this.recipient()
		for const statement in @statements when statement.isExportable() {
			@scope.line(statement.line())

			statement.export(recipient)
		}
	} // }}}
	translate() { // {{{
		for const statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} // }}}
	directory() => @module.directory()
	exportMacro(name, macro) { // {{{
		@module.exportMacro(name, macro.toMetadata())
	} // }}}
	file() => @module.file()
	getAttributeData(key: AttributeData) => @attributeDatas[key]
	isConsumedError(error): Boolean => @module.isBinary()
	includePath() => null
	module() => @module
	publishMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)
	} // }}}
	registerMacro(name, macro) { // {{{
		@scope.addMacro(name, macro)
	} // }}}
	recipient() => @module
	setAttributeData(key: AttributeData, data) { // {{{
		@attributeDatas[key] = data
	} // }}}
	target() => @options.target
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