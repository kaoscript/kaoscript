extern process, require

const $importExts = { // {{{
	data: {
		json: true
	}
	source: {
		coffee: true
		js: true
		ks: true
		ts: true
	}
} // }}}

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
		_alias: String?				= null
		_arguments: Array			= []
		_argumentNames				= {}
		_argumentValues				= {}
		_count: Number				= 0
		_hasArguments: Boolean		= true
		_imports					= {}
		_isKSFile: Boolean
		_metadata
		_moduleName: String
		_reusable: Boolean			= false
		_reuseName: String
		_sealedVariables			= {}
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
			const module = this.module()

			const arguments = {}

			for const argument in @arguments {
				argument.value.prepare()
				argument.type = argument.value.type()

				arguments[argument.name] = argument
			}

			@worker.prepare(arguments)

			for const argument in @arguments when argument.required {
				module.addRequirement(new ImportingRequirement(argument.name, argument.type, this))
			}

			const matchables = []

			for const def, name of @imports {
				const variable = @scope.getVariable(def.local)

				if def.isAlias {
					const type = new NamedContainerType(def.local, new NamespaceType(@scope:Scope))

					for i from 1 til @metadata.exports.length by 2 {
						const name = @metadata.exports[i]

						type.addProperty(name, @worker.getType(name))
					}

					variable.setDeclaredType(type)
				}
				else {
					if !@worker.hasType(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					const type = @worker.getType(name)

					if def.type != null && !type.isMatching(def.type, MatchingMode::Signature) {
						TypeException.throwNotCompatibleDefinition(def.local, name, @data.source.value, this)
					}

					if def.newVariable {
						variable.setDeclaredType(def.type ?? type)
					}
					else if !variable.isPredefined() && @argumentValues[def.local] is not Number {
						ReferenceException.throwNotPassed(def.local, @data.source.value, this)
					}
					else if type.isMatching(variable.getDeclaredType(), MatchingMode::Signature) {
						const alien = variable.getDeclaredType().isAlien()

						variable.setDeclaredType(def.type ?? type)

						if alien {
							variable.getDeclaredType().flagAlien()
						}
					}
					else {
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

			if @count != 0 || @alias != null {
				this.module().flagRegister()
			}
		}
		else {
			for const argument in @arguments {
				argument.value.prepare()
				argument.type = argument.value.type()
			}
		}

		if @count != 0 {
			if @alias == null {
				if @count > 1 {
					@reuseName = @scope.acquireTempName(false)
					@scope.releaseTempName(@reuseName)
				}
			}
			else {
				@reuseName = @alias
			}
		}
	} // }}}
	translate() { // {{{
		for const argument in @arguments {
			argument.value.translate()
		}
	} // }}}
	addArgument(data) { // {{{
		const argument = {
			index: @isKSFile ? null : 0
			isIdentifier: false
			isNamed: false
			required: false
			value: $compile.expression(data.value, this)
		}

		for const modifer in data.modifiers {
			if modifer.kind == ModifierKind::Required {
				argument.required = true

				break
			}
		}

		if argument.required {
			if (variable ?= @scope.getVariable(data.value.name)) && !variable.getDeclaredType().isPredefined()  {
				ReferenceException.throwDefined(data.value.name, this)
			}

			argument.isNamed = true
			argument.name = data.name?.name ?? data.value.name

			argument.isIdentifier = true
			argument.identifier = data.value.name

			@argumentNames[argument.name] = @arguments.length
			@argumentValues[data.value.name] = @arguments.length
		}
		else if data.value.kind == NodeKind::Identifier {
			argument.isNamed = true
			argument.name = data.name?.name ?? data.value.name

			argument.isIdentifier = true
			argument.identifier = data.value.name

			@argumentNames[argument.name] = @arguments.length
			@argumentValues[data.value.name] = @arguments.length
		}
		else if data.name? {
			argument.isNamed = true
			argument.name = data.name.name

			@argumentNames[argument.name] = @arguments.length
		}

		argument.value.analyse()

		@arguments.push(argument)
	} // }}}
	addImport(imported: String, local: String, isAlias: Boolean, type: Type = null) { // {{{
		const newVariable = (variable !?= @scope.getVariable(local)) || variable.isPredefined()

		if newVariable {
			@scope.define(local, true, null, true, this)
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
				if @argumentValues[local] is not Number {
					ReferenceException.throwNotPassed(local, @data.source.value, this)
				}
				else if variable.getDeclared().isMergeable(type) {
					variable.getDeclared().merge(type, this)
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
			@scope.define(local, true, type, true, this)
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

				if pkg.main is String && (this.loadFile(path.join(x, pkg.main), moduleName) || this.loadDirectory(path.join(x, pkg.main), moduleName)) {
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
			for const _, ext of require.extensions {
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

			x = x as String

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

		let autofill = false

		for const modifer in @data.modifiers {
			if modifer.kind == ModifierKind::Autofill {
				autofill = true
			}
		}

		@worker = new ImportWorker(@metadata, this)

		if @data.arguments?.length != 0 {
			for const argument in @data.arguments {
				this.addArgument(argument)
			}

			if autofill {
				for const i from 0 til @metadata.requirements.length by 3 {
					const name = @metadata.requirements[i + 1]

					if !?@argumentNames[name] {
						if @scope.hasVariable(name) {
							this.addArgument({
								modifiers: []
								value: {
									kind: NodeKind::Identifier
									name: name
								}
							})
						}
						else if @metadata.requirements[i + 2] {
							SyntaxException.throwMissingRequirement(name, this)
						}
					}
				}
			}
		}
		else if autofill {
			for const i from 0 til @metadata.requirements.length by 3 {
				const name = @metadata.requirements[i + 1]

				if @scope.hasVariable(name) {
					this.addArgument({
						modifiers: []
						value: {
							kind: NodeKind::Identifier
							name: name
						}
					})
				}
				else if @metadata.requirements[i + 2] {
					SyntaxException.throwMissingRequirement(name, this)
				}
			}
		}
		else {
			for const i from 1 til @metadata.requirements.length by 3 {
				if @metadata.requirements[i + 1] {
					SyntaxException.throwMissingRequirement(@metadata.requirements[i], this)
				}
			}
		}

		if @arguments.length != 0 {
			const requirements = []

			for const i from 0 til @metadata.requirements.length by 3 {
				const name = @metadata.requirements[i + 1]

				if @argumentNames[name] is Number {
					@arguments[@argumentNames[name]].index = @metadata.requirements[i]
				}
				else {
					requirements.push(@metadata.requirements.slice(i, i + 3))
				}
			}

			const len = @arguments.length
			let nextArgument = 0
			for const requirement in requirements {
				while nextArgument < len && @arguments[nextArgument].index != null {
					++nextArgument
				}

				if nextArgument == len {
					if requirement[2] {
						SyntaxException.throwMissingRequirement(requirement[1], this)
					}
				}
				else {
					@arguments[nextArgument].index = requirement[0]
					@arguments[nextArgument].name = requirement[1]
				}
			}

			@arguments.sort((a, b) => a.index - b.index)
		}

		const macros = {}
		for const i from 0 til @metadata.macros.length by 2 {
			macros[@metadata.macros[i]] = [JSON.parse(Buffer.from(data, 'base64').toString('utf8')) for data in @metadata.macros[i + 1]]
		}

		if @data.specifiers.length == 0 {
			for const i from 1 til @metadata.exports.length by 2 {
				name = @metadata.exports[i]

				this.addImport(name, name, false)
			}

			for const datas, name of macros {
				for data in datas {
					new MacroDeclaration(data, this, null, name)
				}
			}
		}
		else {
			let name, type
			for const specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportExclusionSpecifier {
					const exclusions = [exclusion.name for exclusion in specifier.exclusions]

					for const i from 1 til @metadata.exports.length by 2 when exclusions.indexOf(@metadata.exports[i]) == -1 {
						name = @metadata.exports[i]

						this.addImport(name, name, false)
					}

					for const datas, name of macros when exclusions.indexOf(name) == -1 {
						for data in datas {
							new MacroDeclaration(data, this, null, name)
						}
					}
				}
				else if specifier.kind == NodeKind::ImportNamespaceSpecifier {
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
							type = specifier.imported.type? ? Type.fromAST(specifier.imported.type, this) : null
						}
						=> {
							console.info(specifier.imported)
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

		if @data.arguments? {
			for const argument in @data.arguments {
				if argument.name? {
					SyntaxException.throwInvalidImportAliasArgument(this)
				}
				else {
					this.addArgument(argument)
				}
			}
		}
		else {
			@hasArguments = false
		}

		@isKSFile = false
		@moduleName = moduleName

		if @data.specifiers.length == 0 {
			const parts = @data.source.value.split('/')

			for const part in parts desc while @alias == null when !/(?:^\.+$|^@)/.test(part) {
				const dots = part.split('.')
				const last = dots.length - 1

				if last == 0 {
					@alias = dots[0].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
				}
				else if $importExts.data[dots[last]] == true {
					@alias = dots.slice(0, last).join('.').replace(/[-_.]+(.)/g, (m, l) => l.toUpperCase())
				}
				else if $importExts.source[dots[last]] == true {
					@alias = dots[last - 1].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
				}
				else {
					@alias = dots[last].replace(/[-_]+(.)/g, (m, l) => l.toUpperCase())
				}
			}

			if @alias == null {
				SyntaxException.throwUnnamedWildcardImport(this)
			}

			this.addVariable(@alias, @alias, false, null)
		}
		else {
			let type
			for const specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportExclusionSpecifier {
					NotSupportedException.throw(`JavaScript import doesn't support exclusions`, this)
				}
				else if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.local.name

					if specifier.specifiers?.length != 0 {
						type = new NamespaceType(@scope:Scope)

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
	toImportFragments(fragments, aliases = null) { // {{{
		if @isKSFile {
			this.toKSFileFragments(fragments, aliases)
		}
		else {
			this.toNodeFileFragments(fragments)
		}
	} // }}}
	toKSFileFragments(fragments, aliases: Dictionary?) { // {{{
		if @count == 0 {
			if @alias != null {
				const line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				this.toRequireFragments(line)

				line.done()
			}
			else if @arguments.length != 0 {
				const line = fragments.newLine()

				this.toRequireFragments(line)

				line.done()
			}
		}
		else {
			if @alias != null {
				const line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				this.toRequireFragments(line)

				line.done()
			}

			if @count == 1 {
				let alias, name

				for alias, name of @variables {
				}

				const line = fragments
					.newLine()
					.code(`var \(alias) = `)

				this.toRequireFragments(line)

				line.code(`.\(name)`).done()
			}
			else {
				if @options.format.destructuring == 'es5' {
					let variable

					if @reusable {
						variable = @reuseName
					}
					else {
						const line = fragments
							.newLine()
							.code('var __ks__ = ')

						this.toRequireFragments(line)

						line.done()

						variable = '__ks__'
					}

					if !?aliases {
						let line = fragments.newLine().code('var ')

						let nf = false
						for const alias, name of @variables {
							if nf {
								line.code(', ')
							}
							else {
								nf = true
							}

							if alias == name && $virtuals[name] {
								line.code(`__ks_\(alias) = \(variable).__ks_\(name)`)
							}
							else {
								line.code(`\(alias) = \(variable).\(name)`)

								if @sealedVariables[name] == true {
									line.code(`, __ks_\(alias) = \(variable).__ks_\(name)`)
								}
							}
						}

						line.done()
					}
				}
				else {
					aliases ??= {}

					let line = fragments.newLine().code('var {')

					let nf = false
					for const alias, name of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						if alias == name {
							if $virtuals[name] {
								line.code(`__ks_\(name)`)
							}
							else {
								if const ralias = aliases[name] {
									line.code(ralias)

									if @sealedVariables[name] == true {
										line.code(`, __ks_\(ralias)`)
									}
								}
								else {
									line.code(name)

									if @sealedVariables[name] == true {
										line.code(`, __ks_\(name)`)
									}
								}
							}
						}
						else {
							line.code(`\(name): \(alias)`)

							if @sealedVariables[name] == true {
								line.code(`, __ks_\(name): __ks_\(alias)`)
							}
						}
					}

					line.code('} = ')

					this.toRequireFragments(line)

					line.done()
				}
			}
		}
	} // }}}
	toNodeFileFragments(fragments) { // {{{
		if @count == 0 {
			if @alias != null {
				const line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				this.toRequireFragments(line)

				line.done()
			}
		}
		else {
			if @alias != null {
				const line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				this.toRequireFragments(line)

				line.done()
			}

			let name, alias
			if @count == 1 {
				let alias, name

				for alias, name of @variables {
				}

				const line = fragments
					.newLine()
					.code(`var \(alias) = `)

				this.toRequireFragments(line)

				line.code(`.\(name)`).done()
			}
			else if @count > 0 {
				if @options.format.destructuring == 'es5' {
					let line = fragments
						.newLine()
						.code(`var __ks__ = `)

					this.toRequireFragments(line)

					line.done()

					line = fragments.newLine().code('var ')

					let nf = false
					for const alias, name of @variables {
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
					for const alias, name of @variables {
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

					line.code(`} = `)

					this.toRequireFragments(line)

					line.done()
				}
			}
		}
	} // }}}
	toRequireFragments(fragments) { // {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			const modulePath = @isKSFile && $localFileRegex.test(@moduleName) && @parent.includePath() != null ? path.join(path.dirname(@parent.includePath()), @moduleName) : @moduleName

			fragments.code(`require(\($quote(modulePath)))`)

			if @hasArguments {
				fragments.code(`(`)

				let nf = false

				for const argument in @arguments when argument.index != null {
					if nf {
						fragments.code($comma)
					}
					else {
						nf = true
					}

					fragments.compile(argument.value)

					if argument.isIdentifier && argument.type.isSealed() {
						fragments.code(`, __ks_\(argument.identifier)`)
					}
				}

				fragments.code(`)`)
			}

			@reusable = true
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
	getType(name: String) => @scope.getDefinedVariable(name).getDeclaredType()
	prepare(arguments) { // {{{
		const references = []
		const queue = []

		let index, name, type, argument

		if @metadata.requirements.length > 0 {
			const reqReferences = []
			const alterations = {}

			for const i from 0 til @metadata.requirements.length by 3 {
				index = @metadata.requirements[i]
				type = Type.import(index, @metadata, reqReferences, alterations, queue, @scope, @node)

				reqReferences[index] = Type.toNamedType(@metadata.requirements[i + 1], type)
			}

			while queue.length > 0 {
				queue.shift()()
			}

			const matchables = []

			for const i from 0 til @metadata.requirements.length by 3 {
				name = @metadata.requirements[i + 1]

				if (argument ?= arguments[name]) && !argument.required && !reqReferences[@metadata.requirements[i]].isAny() && !argument.type.isMatching(reqReferences[@metadata.requirements[i]], MatchingMode::Signature) {
					TypeException.throwNotCompatibleArgument(argument.name, name, @node.data().source.value, @node)
				}
			}

			for const i from 0 til @metadata.requirements.length by 3 {
				if argument ?= arguments[@metadata.requirements[i + 1]] {
					if argument.required {
						argument.type = reqReferences[@metadata.requirements[i]]
					}

					references[@metadata.requirements[i]] = argument.type
				}
			}
		}

		const alterations = {}

		for const i from 0 til @metadata.aliens.length by 2 {
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

		for const i from 0 til @metadata.requirements.length by 3 {
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

		for const i from 0 til @metadata.exports.length by 2 {
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

		for const i from 0 til @metadata.aliens.length by 2 {
			index = @metadata.aliens[i]
			name = @metadata.aliens[i + 1]

			if !@scope.hasVariable(name) {
				@scope.addVariable(name, new Variable(name, false, false, references[index]), @node)
			}
		}

		for const _, index in @metadata.references {
			if !?references[index] {
				let type = Type.import(index, @metadata, references, alterations, queue, @scope, @node)

				if type is AliasType || type is ClassType || type is EnumType {
					type = new NamedType(@scope.acquireTempName(), type)

					@scope.define(type.name(), true, type, @node)
				}
				else if type is NamespaceType {
					type = new NamedContainerType(@scope.acquireTempName(), type)

					@scope.define(type.name(), true, type, @node)
				}

				references[index] = type
			}
		}

		while queue.length > 0 {
			queue.shift()()
		}
	} // }}}
	scope() => @scope
}