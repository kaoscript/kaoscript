extern process, require

const $importExts = { # {{{
	data: {
		json: true
	}
	source: {
		coffee: true
		js: true
		ks: true
		ts: true
	}
} # }}}

const $nodeModules = { # {{{
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
} # }}}

func $nodeModulesPaths(start) { # {{{
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
} # }}}

struct ImportedVariable {
	name: String
	sealed: Boolean		= false
	systemic: Boolean	= false
}

struct Arguments {
	values: Array					= []
	fromLocal: Dictionary			= {}
	toImport: Dictionary			= {}
}

enum ImportMode {
	Default

	Import
	ExternOrImport
	RequireOrImport
}

abstract class Importer extends Statement {
	private lateinit {
		_alias: String?								= null
		_arguments: Arguments						= Arguments()
		_autofill: Boolean							= false
		_count: Number								= 0
		_extAddendum: String						= ''
		_filename: String							= null
		_hasArguments: Boolean						= true
		_imports									= {}
		_isKSFile: Boolean							= false
		_metaExports
		_metaRequirements
		_moduleName: String
		_pathAddendum: String						= ''
		_reusable: Boolean							= false
		_reuseName: String
		_variables: Dictionary<ImportedVariable>	= {}
		_variationId: String
		_worker: ImportWorker
	}
	abstract mode(): ImportMode
	initiate() { # {{{
		let x = @data.source.value
		let y = this.directory()

		let metadata
		if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x) {
			x = fs.resolve(y, x)

			if !(this.loadFile(x, '', null) || this.loadDirectory(x, null)) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
		else {
			if !(this.loadNodeModule(x, y) || this.loadCoreModule(x)) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}

		const module = this.module()

		if @isKSFile {
			@worker.prepare(@arguments)

			@scope.line(this.line())

			for const argument in @arguments.values when argument.required {
				module.addRequirement(new ImportingRequirement(argument.name, argument.type, this))

				if const variable = @scope.getVariable(argument.name) {
					variable.setDeclaredType(argument.type)
				}
				else {
					@scope.define(argument.name, true, argument.type, true, this)
				}
			}

			const matchables = []
			const workerScope = @worker.scope()

			for const def, name of @imports {
				workerScope.rename(name, def.local, @scope)
			}

			for const def, name of @imports {
				const variable = @scope.getVariable(def.local)

				if def.isAlias {
					const type = new NamedContainerType(def.local, new NamespaceType(@scope:Scope))

					for i from 1 til @metaExports.exports.length by 2 {
						const name = @metaExports.exports[i]

						type.addProperty(name, @worker.getType(name))
					}

					variable.setDeclaredType(type)
				}
				else {
					if !@worker.hasType(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					const type = @worker.getType(name)
					if def.type != null && !type.isSubsetOf(def.type, MatchingMode::Signature) {
						TypeException.throwNotCompatibleDefinition(def.local, name, @data.source.value, this)
					}

					if def.newVariable {
						variable.setDeclaredType(type ?? def.type)
					}
					else if !variable.isPredefined() && @arguments.fromLocal[def.local] is not Number {
						ReferenceException.throwNotPassed(def.local, @data.source.value, this)
					}
					else if type.isSubsetOf(variable.getDeclaredType(), MatchingMode::Signature + MatchingMode::Renamed) {
						const alien = variable.getDeclaredType().isAlien()

						variable.setDeclaredType(type ?? def.type)

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
						const var = ImportedVariable(
							name: def.local
							sealed: type.isSealed() && !type.isSystemic()
							systemic: type.isSystemic()
						)

						@variables[name] = var

						if var.sealed {
							@count += 2
						}
						else {
							@count += 1
						}

						if type.isSystemic() && def.local == 'Dictionary' {
							module.flag('Dictionary')
						}
						else {
							module.import(def.local)
						}
					}
				}

				variable.setComplete(true)
			}

			if @count != 0 || @alias != null {
				module.flagRegister()
			}
		}
		else {
			for const import of @imports {
				module.import(import.local)
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
	} # }}}
	analyse() { # {{{
		for const argument in @arguments.values when !argument.required {
			const variable = @scope.getVariable(argument.identifier)

			if !variable.isImmutable() || !variable.isComplete() {
				SyntaxException.throwOnlyStaticImport(variable.name(), @data.source.value, this)
			}
		}
	} # }}}
	prepare()
	translate()
	addArgument(data, autofill, arguments) { # {{{
		const argument = {
			index: @isKSFile ? null : 0
			isApproved: true
			isAutofill: autofill
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

			arguments.fromLocal[data.value.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else if data.value.kind == NodeKind::Identifier {

			argument.isNamed = true
			argument.name = data.name?.name ?? data.value.name

			argument.isIdentifier = true
			argument.identifier = data.value.name

			arguments.fromLocal[data.value.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else if data.name? {
			argument.isNamed = true
			argument.name = data.name.name
			argument.identifier = data.name.name

			arguments.fromLocal[argument.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else {
			SyntaxException.throwOnlyStaticImport(@data.source.value, this)
		}

		arguments.values.push(argument)
	} # }}}
	addImport(imported: String, local: String, isAlias: Boolean, type: Type = null) { # {{{
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

		@imports[imported] = {
			local
			isAlias
			newVariable
			type
		}
	} # }}}
	addVariable(imported: String, local: String, isVariable: Boolean, type: Type?) { # {{{
		if (variable ?= @scope.getVariable(local)) && !variable.isPredefined() {
			if @parent.includePath() != null {
				// TODO: check & merge type
				return
			}
			else if isVariable {
				if @arguments.fromLocal[local] is not Number {
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
			@variables[imported] = ImportedVariable(local)
			++@count
		}
	} # }}}
	buildArguments(metadata, arguments: Arguments = Arguments()): Arguments { # {{{
		@scope.line(this.line() - 1)

		if @data.arguments?.length != 0 {
			for const argument in @data.arguments {
				this.addArgument(argument, false, arguments)
			}

			if @autofill {
				for const i from 0 til metadata.requirements.length by 3 {
					const name = metadata.requirements[i + 1]

					if !?arguments.toImport[name] {
						if @scope.hasVariable(name) {
							this.addArgument({
								modifiers: []
								value: {
									kind: NodeKind::Identifier
									name: name
								}
							}, true, arguments)
						}
						else {
							this.validateRequirement(metadata.requirements[i + 2], name, metadata)
						}
					}
				}
			}
		}
		else if @autofill {
			for const i from 0 til metadata.requirements.length by 3 {
				const name = metadata.requirements[i + 1]

				if @scope.hasVariable(name) {
					this.addArgument({
						modifiers: []
						value: {
							kind: NodeKind::Identifier
							name: name
						}
					}, true, arguments)
				}
				else {
					this.validateRequirement(metadata.requirements[i + 2], name, metadata)
				}
			}
		}
		else {
			for const i from 0 til metadata.requirements.length by 3 {
				this.validateRequirement(metadata.requirements[i + 2], metadata.requirements[i + 1], metadata)
			}
		}

		if arguments.values.length != 0 {
			const unmatchedArguments = [0..<arguments.values.length]
			const requirements = []
			const queue = []

			const reqReferences = {}
			const alterations = {}

			for const i from 0 til metadata.aliens.length by 3 {
				const index = metadata.aliens[i]
				const name = metadata.aliens[i + 1]
				lateinit const type

				if !?reqReferences[index] {
					type = Type.import(index, metadata.references, reqReferences, alterations, queue, @scope, this)
				}
				else {
					type = reqReferences[index]
				}

				reqReferences[index] = Type.toNamedType(name, type)
			}

			for const i from 0 til metadata.requirements.length by 3 {
				const index = metadata.requirements[i]
				const name = metadata.requirements[i + 1]

				if arguments.toImport[name] is Number {
					const argument = arguments.values[arguments.toImport[name]]

					argument.index = i / 3

					argument.type = Type.import(index, metadata.references, reqReferences, alterations, queue, @scope, this)

					reqReferences[index] = Type.toNamedType(name, argument.type)

					unmatchedArguments.remove(arguments.toImport[name])
				}
				else {
					requirements.push(metadata.requirements.slice(i, i + 3))
				}
			}

			while queue.length > 0 {
				queue.shift()()
			}

			const len = arguments.values.length
			let nextArgument = 0
			for const requirement in requirements {
				while nextArgument < len && arguments.values[nextArgument].index != null {
					++nextArgument
				}

				if nextArgument == len {
					if requirement[2] {
						SyntaxException.throwMissingRequirement(requirement[1], this)
					}
				}
				else {
					arguments.values[nextArgument].index = requirement[0]
					arguments.values[nextArgument].name = requirement[1]

					unmatchedArguments.remove(nextArgument)
				}
			}

			if unmatchedArguments.length != 0 {
				SyntaxException.throwUnmatchedImportArguments([arguments.values[i].name for const i in unmatchedArguments], this)
			}
		}

		for const argument, index in [...arguments.values] when !argument.required {
			const variable = @scope.getVariable(argument.identifier)

			if variable.getRealType().isSubsetOf(argument.type, MatchingMode::Signature) {
				argument.type = variable.getRealType()
			}
			else if argument.isAutofill {
				arguments.values.splice(index, 1)

				delete arguments.fromLocal[argument.identifier]
				delete arguments.toImport[argument.name]
			}
			else {
				TypeException.throwNotCompatibleArgument(argument.identifier, argument.name, @data.source.value, this)
			}
		}

		return arguments
	} # }}}
	getModuleName() => @moduleName
	loadCoreModule(moduleName) { # {{{
		if $nodeModules[moduleName] == true {
			return this.loadNodeFile(null, moduleName)
		}

		return false
	} # }}}
	loadDirectory(dir, moduleName = null) { # {{{
		let pkgfile = path.join(dir, 'package.json')
		if fs.isFile(pkgfile) {
			let pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}

			if pkg? {
				let metadata

				if pkg.kaoscript? {
					const metadata = pkg.kaoscript.metadata? ? path.join(dir, pkg.kaoscript.metadata) : null

					if pkg.kaoscript.main? {
						if this.loadKSFile(path.join(dir, pkg.kaoscript.main), pkg.kaoscript.main, null, moduleName, metadata) {
							return true
						}
					}
					else if metadata? {
						if this.loadKSFile(null, null, null, moduleName ?? dir, metadata) {
							return true
						}
					}
				}

				if pkg.main is String && (this.loadFile(path.join(dir, pkg.main), pkg.main, moduleName) || this.loadDirectory(path.join(dir, pkg.main), moduleName)) {
					return true
				}
			}
		}

		return this.loadFile(path.join(dir, 'index'), 'index', moduleName)
	} # }}}
	loadFile(filename, pathAddendum, moduleName = null) { # {{{
		if fs.isFile(filename) {
			if filename.endsWith($extensions.source) {
				return this.loadKSFile(filename, pathAddendum, null, moduleName)
			}
			else {
				return this.loadNodeFile(filename, moduleName)
			}
		}

		if fs.isFile(filename + $extensions.source) {
			return this.loadKSFile(filename + $extensions.source, pathAddendum, $extensions.source, moduleName)
		}
		else {
			for const _, ext of require.extensions {
				if fs.isFile(filename + ext) {
					return this.loadNodeFile(filename, moduleName)
				}
			}
		}

		return false
	} # }}}
	loadKSFile(filename: String?, pathAddendum: String = '', extAddendum: String = '', moduleName = null, metadataPath = null) { # {{{
		const module = this.module()

		if moduleName == null {
			moduleName = module.path(filename, @data.source.value)

			if moduleName.slice(-$extensions.source.length).toLowerCase() != $extensions.source && path.basename(filename) == path.basename(moduleName + $extensions.source) {
				moduleName += $extensions.source
			}
		}

		if module.compiler().isInHierarchy(filename) {
			SyntaxException.throwLoopingImport(@data.source.value, this)
		}

		@isKSFile = true
		@filename = filename
		@pathAddendum = pathAddendum
		@extAddendum = extAddendum
		@moduleName = moduleName

		for const modifer in @data.modifiers until @autofill {
			if modifer.kind == ModifierKind::Autofill {
				@autofill = true
			}
		}

		this.loadMetadata()

		@worker = new ImportWorker(@metaRequirements, @metaExports, this)

		const macros = {}
		for const i from 0 til @metaExports.macros.length by 2 {
			macros[@metaExports.macros[i]] = [JSON.parse(Buffer.from(data, 'base64').toString('utf8')) for data in @metaExports.macros[i + 1]]
		}

		@scope.line(this.line())

		if @data.specifiers.length == 0 {
			for const i from 1 til @metaExports.exports.length by 2 {
				name = @metaExports.exports[i]

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

					for const i from 1 til @metaExports.exports.length by 2 when exclusions.indexOf(@metaExports.exports[i]) == -1 {
						name = @metaExports.exports[i]

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

		@scope.line(this.line() - 1)

		return true
	} # }}}
	loadMetadata() { # {{{
		const module = this.module()
		const source = fs.readFile(@filename)
		const target = @options.target

		if const upto = module.isUpToDate(@filename, source) {
			if const metadata = this.readMetadata(getRequirementsPath(@filename)) {
				const variations = [module._options.target.name, module._options.target.version]
				const arguments = this.buildArguments(metadata)

				let next = 0
				for const argument in [...arguments.values].sort((a, b) => a.index - b.index) {
					while next != argument.index {
						variations.push(null)

						++next
					}

					argument.type.toVariations(variations)

					++next
				}

				const length = metadata.requirements.length / 3
				while next != length {
					variations.push(null)

					++next
				}

				const variationId = fs.djb2a(variations.join())

				if upto.variations:Array.contains(variationId) {
					@metaRequirements = metadata
					@arguments = arguments
					@variationId = variationId

					if const metadata = this.readMetadata(getExportsPath(@filename, variationId)) {
						@metaExports = metadata

						module.addHashes(@filename, upto.hashes)

						return
					}
				}
			}
		}

		const compiler = module.compiler().createServant(@filename)

		compiler.initiate(source)

		@metaRequirements = compiler.toRequirements()

		this.buildArguments(@metaRequirements, @arguments)

		const arguments = [false for const i from 0 til @metaRequirements.requirements.length / 3]

		for const argument in @arguments.values {
			arguments[argument.index] = {
				name: argument.identifier
				type: argument.type
			}
		}

		@scope.line(this.line())

		for const argument in @arguments.values when argument.required {

			if !@scope.hasVariable(argument.name) {
				@scope.define(argument.name, true, argument.type, true, this)
			}
		}

		compiler.setArguments(arguments, @data.source.value, this)

		compiler.finish()

		compiler.writeFiles()

		@metaExports = compiler.toExports()

		module.addHashes(@filename, compiler.toHashes())

		@variationId = compiler.toVariationId()
	} # }}}
	loadNodeFile(filename = null, moduleName = null) { # {{{
		const module = this.module()

		let file = null
		if moduleName == null {
			file = moduleName = module.path(filename, @data.source.value)
		}

		if @data.arguments? {
			for const argument in @data.arguments {
				if argument.name? {
					SyntaxException.throwInvalidImportAliasArgument(this)
				}
				else {
					this.addArgument(argument, false, @arguments)
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
					@alias = dots[0].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
				}
				else if $importExts.data[dots[last]] == true {
					@alias = dots.slice(0, last).join('.').replace(/[-_.]+(.)/g, (m, l, ...) => l.toUpperCase())
				}
				else if $importExts.source[dots[last]] == true {
					@alias = dots[last - 1].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
				}
				else {
					@alias = dots[last].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
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
	} # }}}
	loadNodeModule(moduleName, start) { # {{{
		let dirs = $nodeModulesPaths(start)

		let file, metadata
		for dir in dirs {
			file = path.join(dir, moduleName)

			if this.loadFile(file, '', moduleName) || this.loadDirectory(file, moduleName) {
				return true
			}
		}

		return false
	} # }}}
	readMetadata(file) { # {{{
		try {
			return JSON.parse(fs.readFile(file), fs.unescapeJSON)
		}
		catch {
			return null
		}
	} # }}}
	registerMacro(name, macro) { # {{{
		@parent.registerMacro(name, macro)
	} # }}}
	toImportFragments(fragments, destructuring = true) { # {{{
		if @isKSFile {
			this.toKSFileFragments(fragments, destructuring)
		}
		else {
			this.toNodeFileFragments(fragments, destructuring)
		}
	} # }}}
	toKSFileFragments(fragments, destructuring) { # {{{
		if @count == 0 {
			if @alias != null {
				const line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				this.toRequireFragments(line)

				line.done()
			}
			else if @arguments.values.length != 0 {
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
				let variable, name

				for variable, name of @variables {
				}

				if variable.systemic {
					const line = fragments
						.newLine()
						.code(`var __ks_\(variable.name) = `)

					this.toRequireFragments(line)

					line.code(`.__ks_\(name)`).done()
				}
				else {
					const line = fragments
						.newLine()
						.code(`var \(variable.name) = `)

					this.toRequireFragments(line)

					line.code(`.\(name)`).done()
				}
			}
			else {
				if !destructuring || @options.format.destructuring == 'es5' {
					lateinit const varname

					if @reusable {
						varname = @reuseName
					}
					else {
						const line = fragments
							.newLine()
							.code('var __ks__ = ')

						this.toRequireFragments(line)

						line.done()

						varname = '__ks__'
					}

					if destructuring {
						const line = fragments.newLine().code('var ')

						let nf = false
						for const variable, name of @variables {
							if nf {
								line.code(', ')
							}
							else {
								nf = true
							}

							if variable.name == name && $virtuals[name] {
								line.code(`__ks_\(variable.name) = \(varname).__ks_\(name)`)
							}
							else {
								if variable.systemic {
									line.code(`__ks_\(variable.name) = \(varname).__ks_\(name)`)
								}
								else {
									line.code(`\(variable.name) = \(varname).\(name)`)

									if variable.sealed {
										line.code(`, __ks_\(variable.name) = \(varname).__ks_\(name)`)
									}
								}
							}
						}

						line.done()
					}
				}
				else {
					const line = fragments.newLine().code('var {')

					let nf = false
					for const variable, name of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						if variable.name == name {
							if $virtuals[name] {
								line.code(`__ks_\(name)`)
							}
							else {
								if variable.systemic {
									line.code(`__ks_\(name)`)
								}
								else {
									line.code(name)

									if variable.sealed {
										line.code(`, __ks_\(name)`)
									}
								}
							}
						}
						else {
							if variable.systemic {
								line.code(`__ks_\(name): __ks_\(variable.name)`)
							}
							else {
								line.code(`\(name): \(variable.name)`)

								if variable.sealed {
									line.code(`, __ks_\(name): __ks_\(variable.name)`)
								}
							}
						}
					}

					line.code('} = ')

					this.toRequireFragments(line)

					line.done()
				}
			}
		}
	} # }}}
	toNodeFileFragments(fragments, destructuring) { # {{{
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
				let variable, name

				for variable, name of @variables {
				}

				const line = fragments
					.newLine()
					.code(`var \(variable.name) = `)

				this.toRequireFragments(line)

				line.code(`.\(name)`).done()
			}
			else if @count > 0 {
				if !destructuring || @options.format.destructuring == 'es5' {
					let line = fragments
						.newLine()
						.code(`var __ks__ = `)

					this.toRequireFragments(line)

					line.done()

					if destructuring {
						line = fragments.newLine().code('var ')

						let nf = false
						for const variable, name of @variables {
							if nf {
								line.code(', ')
							}
							else {
								nf = true
							}

							line.code(`\(variable.name) = __ks__.\(name)`)
						}

						line.done()
					}
				}
				else {
					let line = fragments.newLine().code('var {')

					let nf = false
					for const variable, name of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						if variable.name == name {
							line.code(name)
						}
						else {
							line.code(name, ': ', variable.name)
						}
					}

					line.code(`} = `)

					this.toRequireFragments(line)

					line.done()
				}
			}
		}
	} # }}}
	toRequireFragments(fragments) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			if @isKSFile {
				let modulePath = ''

				if @pathAddendum.length > 0 {
					const dirname = path.dirname(@pathAddendum)
					const basename = path.basename(@pathAddendum)

					modulePath = `\(@moduleName)\(path.sep)\(dirname)\(path.sep).\(basename).\(@variationId).ksb`
				}
				else if $localFileRegex.test(@moduleName) {
					const basename = path.basename(@moduleName)
					let dirname

					if @parent.includePath() == null {
						dirname = path.dirname(@moduleName)
					}
					else {
						dirname = path.dirname(@parent.includePath())
					}

					modulePath = `\(dirname)\(path.sep).\(basename).\(@variationId).ksb`
				}
				else {
					const dirname = path.dirname(@moduleName)
					const basename = path.basename(@moduleName)

					modulePath = `\(dirname)\(path.sep).\(basename)\(@extAddendum).\(@variationId).ksb`
				}

				fragments.code(`require(\($quote(modulePath)))`)
			}
			else {
				fragments.code(`require(\($quote(@moduleName)))`)
			}

			if @hasArguments {
				fragments.code(`(`)

				let nf = false

				for const argument in @arguments.values when argument.isApproved && argument.index != null {
					if nf {
						fragments.code($comma)
					}
					else {
						nf = true
					}

					if argument.isIdentifier && argument.type.isSystemic() {
						fragments.code(`__ks_\(argument.identifier)`)
					}
					else {
						fragments.compile(argument.value)

						 if argument.isIdentifier && argument.type.isSealed() {
							fragments.code(`, __ks_\(argument.identifier)`)
						}
					}
				}

				fragments.code(`)`)
			}

			@reusable = true
		}
	} # }}}
	private validateRequirement(required: Boolean | Number, name: String, metadata) { # {{{
		if required {
			SyntaxException.throwMissingRequirement(name, this)
		}
		else if this.mode() == ImportMode::Import && required is Number {
			for const i from 0 til metadata.aliens.length by 3 {
				if metadata.aliens[i] == required {
					metadata.aliens[i + 2] = true
					break
				}
			}
		}
	} # }}}
}

class ImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	initiate() { # {{{
		for declarator in @data.declarations {
			@declarators.push(declarator = new ImportDeclarator(declarator, this))

			declarator.initiate()
		}
	} # }}}
	analyse() { # {{{
		for declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	prepare() { # {{{
		for declarator in @declarators {
			declarator.prepare()
		}
	} # }}}
	translate()
	registerMacro(name, macro) { # {{{
		@parent.registerMacro(name, macro)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} # }}}
}

class ImportDeclarator extends Importer {
	flagForcefullyRebinded()
	override mode() => ImportMode::Import
	toStatementFragments(fragments, mode) { # {{{
		this.toImportFragments(fragments)
	} # }}}
}

class ImportWorker {
	private {
		_metaExports
		_metaRequirements
		_node
		_scope: Scope
	}
	constructor(@metaRequirements, @metaExports, @node) { # {{{
		@scope = new ImportScope(node.scope())
	} # }}}
	hasType(name: String) => @scope.hasDefinedVariable(name)
	getType(name: String) => @scope.getDefinedVariable(name).getDeclaredType()
	prepare(arguments) { # {{{
		const module = @node.module()
		const references = {}
		const queue = []
		const variables = {}

		const metadata = [...@metaRequirements.references, ...@metaExports.references]

		const alterations = {mode: @node.mode()}

		const newAliens = {}
		const oldAliens = []

		for const i from 0 til @metaRequirements.aliens.length by 3 {
			const index = @metaRequirements.aliens[i]
			const name = @metaRequirements.aliens[i + 1]
			let type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				const origin = type.origin()
				if origin? {
					type.origin(origin:TypeOrigin + TypeOrigin::Extern + TypeOrigin::Import)
				}
				else {
					type.origin(TypeOrigin::Extern + TypeOrigin::Import)
				}
			}
			else {
				type = references[index]
			}

			type = Type.toNamedType(name, type)

			if @metaRequirements.aliens[i + 2] {
				type = type.flagRequired()
			}

			if const alien = module.getAlien(name) {
				oldAliens.push(name, type, alien)

				references[index] = alien
			}
			else {
				newAliens[name] = index

				references[index] = type
			}
		}

		while queue.length > 0 {
			queue.shift()()
		}

		for const name, index in oldAliens by 3 {
			const newType = oldAliens[index + 1]
			const oldType = oldAliens[index + 1]

			if !oldType.isSubsetOf(newType, MatchingMode::Signature) {
				TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
			}
		}

		if @metaRequirements.requirements.length > 0 {
			const reqReferences = {...references}

			for const i from 0 til @metaRequirements.requirements.length by 3 {
				const index = @metaRequirements.requirements[i]
				const name = @metaRequirements.requirements[i + 1]
				const type = references[index] ?? Type.import(index, metadata, reqReferences, alterations, queue, @scope, @node)

				reqReferences[index] = Type.toNamedType(name, type)
			}

			while queue.length > 0 {
				queue.shift()()
			}

			for const i from 0 til @metaRequirements.requirements.length by 3 {
				const name = @metaRequirements.requirements[i + 1]
				const type = reqReferences[@metaRequirements.requirements[i]]

				if const index = arguments.toImport[name] {
					const argument = arguments.values[index]

					if !argument.required && !type.isAny() && !argument.type.isSubsetOf(type, MatchingMode::Signature) {
						if argument.isAutofill {
							argument.isApproved = false
						}
						else {
							TypeException.throwNotCompatibleArgument(argument.name, name, @node.data().source.value, @node)
						}
					}
				}
			}

			for const i from 0 til @metaRequirements.requirements.length by 3 {
				const reqIndex = @metaRequirements.requirements[i]
				const name = @metaRequirements.requirements[i + 1]

				if const index = arguments.toImport[name] {
					const argument = arguments.values[index]

					if argument.isApproved {
						if argument.required {
							argument.type = reqReferences[reqIndex]
						}

						if const type = references[reqIndex] {
							if !argument.type.isSubsetOf(type, MatchingMode::Signature) {
								TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
							}
						}

						references[reqIndex] = argument.type
					}
				}
				else if const type = references[reqIndex] {
					references[reqIndex] = type.flagRequired()
				}
			}
		}

		for const index, name of newAliens {
			module.addAlien(name, references[index])
		}

		for const i from 0 til @metaRequirements.requirements.length by 3 {
			const index = @metaRequirements.requirements[i]
			const name = @metaRequirements.requirements[i + 1]
			lateinit const type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				type.origin(TypeOrigin::Require)
			}
			else {
				type = references[index]

				const origin = type.origin()
				if origin? {
					type.origin(origin:TypeOrigin + TypeOrigin::Require)
				}
				else {
					type.origin(TypeOrigin::Require + TypeOrigin::Import)
				}
			}

			references[index] = Type.toNamedType(name, type)
		}

		for const i from 0 til @metaExports.exports.length by 2 {
			const index = @metaExports.exports[i]
			const name = @metaExports.exports[i + 1]
			let type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			type = Type.toNamedType(name, type)

			if const variable = @scope.getDefinedVariable(name) {
				variable.setDeclaredType(type)
			}
			else {
				@scope.addVariable(name, new Variable(name, false, false, type), @node)

				variables[index] = true
			}

			references[index] = type
		}

		for const i from 0 til @metaRequirements.aliens.length by 3 {
			const index = @metaRequirements.aliens[i]
			const name = @metaRequirements.aliens[i + 1]

			if !@scope.hasVariable(name) {
				@scope.addVariable(name, new Variable(name, false, false, references[index]), @node)

				variables[index] = true
			}
		}

		for const _, index in metadata {
			if !?references[index] {
				const type = Type.toNamedType(
					Type.import(index, metadata, references, alterations, queue, @scope, @node)
					true
					@scope
					@node
				)

				references[index] = type
			}
			else if !variables[index] {
				const type = references[index]

				if type is NamedType && !@scope.hasVariable(type.name()) {
					@scope.define(type.name(), true, type, @node)
				}
			}
		}

		while queue.length > 0 {
			queue.shift()()
		}
	} # }}}
	scope() => @scope
}
