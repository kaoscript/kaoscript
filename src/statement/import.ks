extern process, require

const $nodeModules = { // {{{
	assert: true
	buffer: true
	child_process: true
	cluster: true
	constants: true
	crypto: true
	dgram: true
	dns: true
	domain: true
	events: true
	fs: true
	http: true
	https: true
	module: true
	net: true
	os: true
	path: true
	punycode: true
	querystring: true
	readline: true
	repl: true
	stream: true
	string_decoder: true
	tls: true
	tty: true
	url: true
	util: true
	v8: true
	vm: true
	zlib: true
} // }}}

func $nodeModulesPaths(start) { // {{{
	start = fs.resolve(start)

	let prefix = '/'
	if /^([A-Za-z]:)/.test(start) {
		prefix = ''
	}
	else if /^\\\\/.test(start) {
		prefix = '\\\\'
	}

	let splitRe = process.platform == 'win32' ? /[\/\\]/ : /\/+/

	let parts = start.split(splitRe)

	let dirs = []
	for i from parts.length - 1 to 0 by -1 {
		if parts[i] == 'node_modules' {
			continue
		}

		dirs.push(prefix + path.join(path.join(...parts.slice(0, i + 1)), 'node_modules'))
	}

	if process.platform == 'win32' {
		dirs[dirs.length - 1] = dirs[dirs.length - 1].replace(':', ':\\')
	}

	return dirs
} // }}}

class Importer extends Statement {
	private {
		_alias: String				= null
		_arguments					= {}
		_count: Number				= 0
		_imports					= {}
		_isKSFile: Boolean
		_localToModuleArguments		= {}
		_metadata
		_moduleToLocalArguments		= {}
		_moduleName: String
		_sealedVariables			= {}
		_seepedArguments			= {}
		_variables					= {}
		_worker: ImportWorker
	}
	analyse() { // {{{
		let x = @data.source.value
		let y = this.directory()

		let metadata
		if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x) {
			x = fs.resolve(y, x)

			if !(this.loadFile(x, null) || this.loadDirectory(x, null)) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
		else {
			if !(this.loadNodeModule(x, y) || this.loadCoreModule(x)) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
	} // }}}
	prepare() { // {{{
		if @isKSFile {
			for name, argument of @arguments {
				argument.name = @moduleToLocalArguments[name]

				if @seepedArguments[name] == true {
					argument.seeped = true
				}
				else {
					argument.seeped = false
					argument.type = @scope.getVariable(@moduleToLocalArguments[name]).type()
				}
			}

			@worker.prepare(@arguments)

			const module = this.module()

			for name of @seepedArguments {
				module.addRequirement(new SeepedRequirement(@arguments[name].name, @arguments[name].type))
			}

			const matchables = []

			for name, def of @imports {
				const variable = @scope.getVariable(def.local)

				if def.isAlias {
					const type = new NamedContainerType(def.local, new NamespaceType(@scope))

					for i from 1 til @metadata.exports.length by 2 {
						const name = @metadata.exports[i]

						type.addProperty(name, @worker.getType(name))
					}

					variable.type(type)
				}
				else {
					if !@worker.hasType(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					const type = @worker.getType(name)

					if def.type != null && !type.matchSignatureOf(def.type, matchables) {
						TypeException.throwNotCompatibleDefinition(def.local, name, @data.source.value, this)
					}

					if def.newVariable {
						variable.type(def.type ?? type)
					}
					else if !variable.isPredefined() && @localToModuleArguments[def.local] is not String {
						ReferenceException.throwNotPassed(def.local, @data.source.value, this)
					}
					else if type.matchSignatureOf(variable.type(), matchables) {
						const alien = variable.type().isAlien()

						variable.type(def.type ?? type)

						if alien {
							variable.type().flagAlien()
						}
					}
					else {
						console.log(type)
						console.log(variable.type())
						TypeException.throwNotCompatibleArgument(def.local, name, @data.source.value, this)
					}

					if type.isNamed() {
						type.name(def.local)

						type.scope().reassignReference(name, def.local, @scope)
					}

					if !type.isAlias() {
						@variables[name] = def.local
						++@count

						if type.isSealed() {
							@sealedVariables[name] = true
							++@count
						}
					}
				}
			}

			if @data.arguments?.length != 0 || @count != 0 || @alias? {
				this.module().flagRegister()
			}
		}
	} // }}}
	translate()
	addArgument(data) { // {{{
		if data.seeped {
			if (variable ?= @scope.getVariable(data.local.name)) && !variable.type().isPredefined()  {
				ReferenceException.throwDefined(data.local.name, this)
			}

			@seepedArguments[data.imported.name] = true
		}
		else {
			unless @scope.hasVariable(data.local.name) {
				ReferenceException.throwNotDefined(data.local.name, this)
			}
		}

		@localToModuleArguments[data.local.name] = data.imported.name
		@moduleToLocalArguments[data.imported.name] = data.local.name
	} // }}}
	addImport(imported: String, local: String, isAlias: Boolean, type: Type = null) { // {{{
		const newVariable = (variable !?= @scope.getVariable(local)) || variable.isPredefined()

		if newVariable {
			@scope.define(local, true, null, this)
		}
		else if @parent.includePath() != null {
			return
		}
		else if isAlias {
			SyntaxException.throwAlreadyDeclared(local, this)
		}

		this.module().import(local)

		@imports[imported] = {
			local
			isAlias
			newVariable
			type
		}
	} // }}}
	addVariable(imported: String, local: String, isVariable: Boolean, type: Type?) { // {{{
		if (variable ?= @scope.getVariable(local)) && !variable.isPredefined() {
			if @parent.includePath() != null {
				// TODO: check & merge type
				return
			}
			else if isVariable {
				if @localToModuleArguments[local] is not String {
					ReferenceException.throwNotPassed(local, @data.source.value, this)
				}
				else if variable.type().isMergeable(type) {
					variable.type().merge(type, this)
				}
				else {
					ReferenceException.throwNotMergeable(local, @data.source.value, this)
				}
			}
			else {
				SyntaxException.throwAlreadyDeclared(local, this)
			}
		}
		else {
			@scope.define(local, true, type, this)
		}

		this.module().import(local)

		if isVariable && type is not AliasType {
			@variables[imported] = local
			++@count
		}
	} // }}}
	loadCoreModule(x) { // {{{
		if $nodeModules[x] == true {
			return this.loadNodeFile(null, x)
		}

		return false
	} // }}}
	loadDirectory(x, moduleName = null) { // {{{
		let pkgfile = path.join(x, 'package.json')
		if fs.isFile(pkgfile) {
			let pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}

			if pkg? {
				let metadata

				if pkg.kaoscript? {
					const metadata = pkg.kaoscript.metadata? ? path.join(x, pkg.kaoscript.metadata) : null

					if pkg.kaoscript.main? {
						if this.loadKSFile(path.join(x, pkg.kaoscript.main), moduleName, metadata) {
							return true
						}
					}
					else if metadata? {
						if this.loadKSFile(null, moduleName ?? x, metadata) {
							return true
						}
					}
				}

				if	pkg.main &&
						(
							this.loadFile(path.join(x, pkg.main), moduleName) ||
							this.loadDirectory(path.join(x, pkg.main), moduleName)
						)
				{
					return true
				}
			}
		}

		return this.loadFile(path.join(x, 'index'), moduleName)
	} // }}}
	loadFile(x, moduleName = null) { // {{{
		if fs.isFile(x) {
			if x.endsWith($extensions.source) {
				return this.loadKSFile(x, moduleName)
			}
			else {
				return this.loadNodeFile(x, moduleName)
			}
		}

		if fs.isFile(x + $extensions.source) {
			return this.loadKSFile(x + $extensions.source, moduleName)
		}
		else {
			for ext of require.extensions {
				if fs.isFile(x + ext) {
					return this.loadNodeFile(x, moduleName)
				}
			}
		}

		return false
	} // }}}
	loadKSFile(x: String?, moduleName = null, metadataPath = null) { // {{{
		const module = this.module()

		if moduleName == null {
			moduleName = module.path(x, @data.source.value)

			if moduleName.slice(-$extensions.source.length).toLowerCase() != $extensions.source && path.basename(x) == path.basename(moduleName + $extensions.source) {
				moduleName += $extensions.source
			}
		}

		let name, alias, variable, hashes

		if ?metadataPath && fs.isFile(metadataPath) && (@metadata ?= this.readMetadata(metadataPath)) {
		}
		else {
			let source = fs.readFile(x)
			let target = @options.target

			if fs.isFile(getMetadataPath(x, target)) && fs.isFile(getHashPath(x, target)) && (hashes ?= module.isUpToDate(x, target, source)) && (@metadata ?= this.readMetadata(getMetadataPath(x, target))) {
				module.addHashes(x, hashes)
			}
			else {
				let compiler = module.compiler().createServant(x)

				compiler.compile(source)

				compiler.writeFiles()

				@metadata = compiler.toMetadata()

				hashes = compiler.toHashes()

				module.addHashes(x, hashes)
			}
		}

		@isKSFile = true
		@moduleName = moduleName

		@worker = new ImportWorker(@metadata, this)

		if @data.arguments?.length != 0 {
			for argument in @data.arguments {
				this.addArgument(argument)
			}

			let name
			for i from 0 til @metadata.requirements.length by 3 {
				name = @metadata.requirements[i + 1]

				if @moduleToLocalArguments[name] is String {
					@arguments[name] = {
						index: Math.floor(i / 3) + 1
						data: @metadata.references[@metadata.requirements[i]]
					}
				}
				else if @metadata.requirements[i + 2] {
					SyntaxException.throwMissingRequirement(name, this)
				}
			}
		}
		else {
			for i from 1 til @metadata.requirements.length by 3 {
				if @metadata.requirements[i + 1] {
					SyntaxException.throwMissingRequirement(@metadata.requirements[i], this)
				}
			}
		}

		const macros = {}
		for i from 0 til @metadata.macros.length by 2 {
			macros[@metadata.macros[i]] = [JSON.parse(Buffer.from(data, 'base64').toString('utf8')) for data in @metadata.macros[i + 1]]
		}

		if @data.specifiers.length == 0 {
			for i from 1 til @metadata.exports.length by 2 {
				name = @metadata.exports[i]

				this.addImport(name, name, false)
			}

			for name, datas of macros {
				for data in datas {
					new MacroDeclaration(data, this, null, name)
				}
			}
		}
		else {
			let name, type
			for specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.local.name
				}
				else {
					switch specifier.imported.kind {
						NodeKind::ClassDeclaration => {
							name = specifier.imported.name.name
							type = Type.fromAST(specifier.imported, this)
						}
						NodeKind::Identifier => {
							name = specifier.imported.name
							type = null
						}
						NodeKind::VariableDeclarator => {
							name = specifier.imported.name.name
							type = specifier.imported.type ? Type.fromAST(specifier.imported.type, this) : null
						}
						=> {
							console.log(specifier.imported)
							throw new NotImplementedException()
						}
					}

					if macros[name]? {
						for data in macros[name] {
							new MacroDeclaration(data, this, null, specifier.local.name)
						}
					}
					else {
						this.addImport(name, specifier.local.name, false, type)
					}
				}
			}

			if @alias != null {
				this.addImport(@alias, @alias, true)
			}
		}

		return true
	} // }}}
	loadNodeFile(x = null, moduleName = null) { // {{{
		const module = this.module()

		let file = null
		if moduleName == null {
			file = moduleName = module.path(x, @data.source.value)
		}

		if @data.arguments?.length != 0 {
			for argument in @data.arguments {
				if argument.local == argument.imported {
					this.addArgument(argument)
				}
				else {
					SyntaxException.throwInvalidImportAliasArgument(this)
				}
			}
		}

		@isKSFile = false
		@moduleName = moduleName

		if @data.specifiers.length == 0 {
			const parts = @data.source.value.split('/')
			for const i from 0 til parts.length while @alias == null {
				if !/(?:^\.+$|^@)/.test(parts[i]) {
					const dots = parts[i].split('.')
					const last = dots.length - 1

					if last == 0 {
						@alias = dots[0].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
					}
					else if dots[last].length <= 3 {
						@alias = dots[last - 1].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
					}
					else {
						@alias = dots[last].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
					}
				}
			}

			if @alias == null {
				SyntaxException.throwUnnamedWildcardImport(this)
			}

			this.addVariable(@alias, @alias, false, null)
		}
		else {
			let type
			for specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.local.name

					if specifier.specifiers?.length != 0 {
						type = new NamespaceType(@scope)

						for s in specifier.specifiers {
							if s.imported.kind == NodeKind::Identifier {
								type.addProperty(s.local.name, Type.Any)
							}
							else {
								type.addProperty(s.local.name, Type.fromAST(s.imported, this).flagAlien())
							}
						}

						this.addVariable(@alias, @alias, false, type)
					}
					else {
						this.addVariable(@alias, @alias, false, null)
					}
				}
				else {
					if specifier.imported.kind == NodeKind::Identifier {
						this.addVariable(specifier.imported.name, specifier.local.name, true, null)
					}
					else {
						type = Type.fromAST(specifier.imported, this).flagAlien()

						this.addVariable(specifier.imported.name.name, specifier.local.name, true, type)
					}
				}
			}
		}

		return true
	} // }}}
	loadNodeModule(x, start) { // {{{
		let dirs = $nodeModulesPaths(start)

		let file, metadata
		for dir in dirs {
			file = path.join(dir, x)

			if this.loadFile(file, x) || this.loadDirectory(file, x) {
				return true
			}
		}

		return false
	} // }}}
	readMetadata(file) { // {{{
		try {
			return JSON.parse(fs.readFile(file), func(key, value) => key == 'max' && value == 'Infinity' ? Infinity : value)
		}
		catch {
			return null
		}
	} // }}}
	registerMacro(name, macro) { // {{{
		@parent.registerMacro(name, macro)
	} // }}}
	toImportFragments(fragments) { // {{{
		if @isKSFile {
			this.toKSFileFragments(fragments)
		}
		else {
			this.toNodeFileFragments(fragments)
		}
	} // }}}
	toKSFileFragments(fragments) { // {{{
		const modulePath = $localFileRegex.test(@moduleName) && @parent.includePath() != null ? path.join(path.dirname(@parent.includePath()), @moduleName) : @moduleName

		let importCode = `require(\($quote(modulePath)))(`
		let importCodeVariable = false
		let name, alias, variable

		const hasArguments = @data.arguments?.length != 0

		if hasArguments {
			let nf = false

			for name of @arguments {
				if nf {
					importCode += ', '
				}
				else {
					nf = true
				}

				if @moduleToLocalArguments[name] is String {
					importCode += @moduleToLocalArguments[name]

					if @arguments[name].type.isSealed() {
						importCode += `, __ks_\(@moduleToLocalArguments[name])`
					}
				}
				else {
					importCode += 'null'
				}
			}
		}

		importCode += ')'

		if @count == 0 {
			if @alias != null {
				fragments.newLine().code('var ', @alias, ' = ', importCode).done()
			}
			else if hasArguments {
				fragments.newLine().code(importCode).done()
			}
		}
		else {
			if @alias != null {
				const variable = @scope.acquireTempName()

				fragments.line(`var \(variable) = \(importCode)`)

				importCode = variable
				importCodeVariable = true
			}

			if @count == 1 {
				for name, alias of @variables {
				}

				fragments.newLine().code(`var \(alias) = \(importCode).\(name)`).done()
			}
			else {
				if @options.format.destructuring == 'es5' {
					let variable = importCode

					if !importCodeVariable {
						fragments.line(`var __ks__ = \(importCode)`)

						variable = '__ks__'
					}

					let line = fragments.newLine().code('var ')

					let nf = false
					for name, alias of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						line.code(`\(alias) = \(variable).\(name)`)

						if @sealedVariables[name] == true {
							line.code(`, __ks_\(alias) = \(variable).__ks_\(name)`)
						}
					}

					line.done()
				}
				else {
					let line = fragments.newLine().code('var {')

					let nf = false
					for name, alias of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						if alias == name {
							line.code(name)

							if @sealedVariables[name] == true {
								line.code(`, __ks_\(name)`)
							}
						}
						else {
							line.code(`\(name): \(alias)`)

							if @sealedVariables[name] == true {
								line.code(`, __ks_\(name): __ks_\(alias)`)
							}
						}
					}

					line.code('} = ', importCode).done()
				}
			}

			if @alias != null {
				fragments.newLine().code('var ', @alias, ' = ', importCode).done()
			}
		}

		if Scope.isTempName(importCode) {
			@scope.releaseTempName(importCode)
		}
	} // }}}
	toNodeFileFragments(fragments) { // {{{
		if @alias != null {
			const line = fragments
				.newLine()
				.code(`var \(@alias) = require(\($quote(@moduleName)))`)

			if @data.arguments? {
				line.code('(')

				for argument, index in @data.arguments {
					if index != 0 {
						line.code(', ')
					}

					line.code(argument.local.name)
				}

				line.code(')')
			}

			line.done()
		}

		let name, alias
		if @count == 1 {
			for name, alias of @variables {
			}

			const line = fragments
				.newLine()
				.code(`var \(alias) = require(\($quote(@moduleName)))`)

			if @data.arguments? {
				line.code('(')

				for argument, index in @data.arguments {
					if index != 0 {
						line.code(', ')
					}

					line.code(argument.local.name)
				}

				line.code(')')
			}

			line.code(`.\(alias)`).done()
		}
		else if @count > 0 {
			if @options.format.destructuring == 'es5' {
				let line = fragments
					.newLine()
					.code(`var __ks__ = require(\($quote(@moduleName)))`)

				if @data.arguments? {
					line.code('(')

					for argument, index in @data.arguments {
						if index != 0 {
							line.code(', ')
						}

						line.code(argument.local.name)
					}

					line.code(')')
				}

				line.done()

				line = fragments.newLine().code('var ')

				let nf = false
				for name, alias of @variables {
					if nf {
						line.code(', ')
					}
					else {
						nf = true
					}

					line.code(`\(alias) = __ks__.\(name)`)
				}

				line.done()
			}
			else {
				let line = fragments.newLine().code('var {')

				let nf = false
				for name, alias of @variables {
					if nf {
						line.code(', ')
					}
					else {
						nf = true
					}

					if alias == name {
						line.code(name)
					}
					else {
						line.code(name, ': ', alias)
					}
				}

				line.code(`} = require(\($quote(@moduleName)))`)

				if @data.arguments? {
					line.code('(')

					for argument, index in @data.arguments {
						if index != 0 {
							line.code(', ')
						}

						line.code(argument.local.name)
					}

					line.code(')')
				}

				line.done()
			}
		}
	} // }}}
}

class ImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		for declarator in @data.declarations {
			@declarators.push(declarator = new ImportDeclarator(declarator, this))

			declarator.analyse()
		}
	} // }}}
	prepare() { // {{{
		for declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate()
	registerMacro(name, macro) { // {{{
		@parent.registerMacro(name, macro)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} // }}}
}

class ImportDeclarator extends Importer {
	toStatementFragments(fragments, mode) { // {{{
		this.toImportFragments(fragments)
	} // }}}
}

class ImportWorker {
	private {
		_metadata
		_node
		_scope: Scope
	}
	constructor(@metadata, @node) { // {{{
		@scope = new ImportScope(node.scope())
	} // }}}
	hasType(name: String) => @scope.hasDefinedVariable(name)
	getType(name: String) => @scope.getDefinedVariable(name).type()
	prepare(arguments) { // {{{
		const references = []
		const queue = []

		let index, name, type, argument

		if @metadata.requirements.length > 0 {
			const reqReferences = []
			const alterations = {}

			for i from 0 til @metadata.requirements.length by 3 {
				index = @metadata.requirements[i]
				type = Type.import(index, @metadata, reqReferences, alterations, queue, @scope, @node)

				reqReferences[index] = Type.toNamedType(@metadata.requirements[i + 1], type)
			}

			while queue.length > 0 {
				queue.shift()()
			}

			const matchables = []

			for i from 0 til @metadata.requirements.length by 3 {
				name = @metadata.requirements[i + 1]

				if (argument ?= arguments[name]) && !argument.seeped && !argument.type.matchSignatureOf(reqReferences[@metadata.requirements[i]], matchables) {
					TypeException.throwNotCompatibleArgument(argument.name, name, @node.data().source.value, @node)
				}
			}

			for i from 0 til @metadata.requirements.length by 3 {
				if argument ?= arguments[@metadata.requirements[i + 1]] {
					if argument.seeped {
						argument.type = reqReferences[@metadata.requirements[i]]
					}

					references[@metadata.requirements[i]] = argument.type
				}
			}
		}

		const alterations = {}

		for i from 0 til @metadata.aliens.length by 2 {
			index = @metadata.aliens[i]
			name = @metadata.aliens[i + 1]

			if !?references[index] {
				type = Type.import(index, @metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			type = references[index] = Type.toNamedType(name, type)
		}

		for i from 0 til @metadata.requirements.length by 3 {
			index = @metadata.requirements[i]
			name = @metadata.requirements[i + 1]

			if !?references[index] {
				type = Type.import(index, @metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			references[index] = Type.toNamedType(name, type)
		}

		for i from 0 til @metadata.exports.length by 2 {
			index = @metadata.exports[i]
			name = @metadata.exports[i + 1]

			if !?references[index] {
				type = Type.import(index, @metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			type = references[index] = Type.toNamedType(name, type)

			@scope.addVariable(name, new Variable(name, false, false, type), @node)
		}

		for i from 0 til @metadata.aliens.length by 2 {
			index = @metadata.aliens[i]
			name = @metadata.aliens[i + 1]

			if !@scope.hasVariable(name) {
				@scope.addVariable(name, new Variable(name, false, false, references[index]), @node)
			}
		}

		for :index in @metadata.references {
			if !?references[index] {
				references[index] = Type.import(index, @metadata, references, alterations, queue, @scope, @node)
			}
		}

		while queue.length > 0 {
			queue.shift()()
		}
	} // }}}
	scope() => @scope
}