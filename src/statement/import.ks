extern process, require

var $importExts = { # {{{
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

var $nodeModules = { # {{{
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

func $nodeModulesPaths(mut start) { # {{{
	start = fs.resolve(start)

	var mut prefix = '/'
	if /^([A-Za-z]:)/.test(start) {
		prefix = ''
	}
	else if /^\\\\/.test(start) {
		prefix = '\\\\'
	}

	var mut splitRe = process.platform == 'win32' ? /[\/\\]/ : /\/+/

	var mut parts = start.split(splitRe)

	var mut dirs = []
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
	system: Boolean	= false
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
	private late {
		_alias: String?								= null
		_arguments: Arguments						= Arguments()
		_autofill: Boolean							= false
		_count: Number								= 0
		_extAddendum: String						= ''
		_filename: String?							= null
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
		var mut x = @data.source.value
		var mut y = this.directory()

		var mut metadata
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

		var module = this.module()

		if @isKSFile {
			@worker.prepare(@arguments)

			@scope.line(this.line())

			for var argument in @arguments.values when argument.required {
				module.addRequirement(new ImportingRequirement(argument.name, argument.type, this))

				if var variable ?= @scope.getVariable(argument.name) {
					variable.setDeclaredType(argument.type)
				}
				else {
					@scope.define(argument.name, true, argument.type, true, this)
				}
			}

			var matchables = []
			var workerScope = @worker.scope()

			for var def, name of @imports {
				workerScope.rename(name, def.internal, @scope)
			}

			for var def, name of @imports {
				var variable = @scope.getVariable(def.internal)

				if def.isAlias {
					var type = new NamedContainerType(def.internal, new NamespaceType(@scope:Scope))

					for i from 1 til @metaExports.exports.length by 2 {
						var name = @metaExports.exports[i]

						type.addProperty(name, @worker.getType(name))
					}

					variable.setDeclaredType(type)
				}
				else {
					if !@worker.hasType(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					var type = @worker.getType(name)
					if def.type != null && !type.isSubsetOf(def.type, MatchingMode::Signature) {
						TypeException.throwNotCompatibleDefinition(def.internal, name, @data.source.value, this)
					}

					if def.newVariable {
						variable.setDeclaredType(type ?? def.type)
					}
					else if !variable.isPredefined() && @arguments.fromLocal[def.internal] is not Number {
						ReferenceException.throwNotPassed(def.internal, @data.source.value, this)
					}
					else if type.isSubsetOf(variable.getDeclaredType(), MatchingMode::Signature + MatchingMode::Renamed) {
						var alien = variable.getDeclaredType().isAlien()

						variable.setDeclaredType(type ?? def.type)

						if alien {
							variable.getDeclaredType().flagAlien()
						}
					}
					else {
						TypeException.throwNotCompatibleArgument(def.internal, name, @data.source.value, this)
					}

					if type.isNamed() {
						type.name(def.internal)

						type.scope().reassignReference(name, def.internal, @scope)

					}

					if !type.isAlias() {
						var var = ImportedVariable(
							name: def.internal
							sealed: type.isSealed() && !type.isSystem()
							system: type.isSystem()
						)

						@variables[name] = var

						if var.sealed {
							@count += 2
						}
						else {
							@count += 1
						}

						if type.isSystem() && def.internal == 'Dictionary' {
							module.flag('Dictionary')
						}
						else {
							module.import(def.internal)
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
			for var import of @imports {
				module.import(import.internal)
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
		for var argument in @arguments.values when !argument.required {
			var variable = @scope.getVariable(argument.identifier)

			if !variable.isImmutable() || !variable.isComplete() {
				SyntaxException.throwOnlyStaticImport(variable.name(), @data.source.value, this)
			}
		}
	} # }}}
	override prepare(target)
	translate()
	addArgument(data, autofill, arguments) { # {{{
		var argument = {
			index: @isKSFile ? null : 0
			isApproved: true
			isAutofill: autofill
			isIdentifier: false
			isNamed: false
			required: false
			value: $compile.expression(data.value, this)
		}

		for var modifer in data.modifiers {
			if modifer.kind == ModifierKind::Required {
				argument.required = true

				break
			}
		}

		if argument.required {
			if (variable ?= @scope.getVariable(data.value.name)) && !variable.getDeclaredType().isPredefined() {
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
		else if ?data.name {
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
	addImport(external: String, internal: String, isAlias: Boolean, type: Type? = null) { # {{{
		var variable = @scope.getVariable(internal)
		var newVariable = !?variable || variable.isPredefined()

		if newVariable {
			@scope.define(internal, true, null, true, this)
		}
		else if @parent.includePath() != null {
			return
		}
		else if isAlias {
			SyntaxException.throwAlreadyDeclared(internal, this)
		}

		@imports[external] = {
			internal
			isAlias
			newVariable
			type
		}
	} # }}}
	addVariable(external: String, internal: String, isVariable: Boolean, type: Type?) { # {{{
		if (variable ?= @scope.getVariable(internal)) && !variable.isPredefined() {
			if @parent.includePath() != null {
				// TODO check & merge type
				return
			}
			else if isVariable {
				if @arguments.fromLocal[internal] is not Number {
					ReferenceException.throwNotPassed(internal, @data.source.value, this)
				}
				else if variable.getDeclared().isMergeable(type) {
					variable.getDeclared().merge(type, this)
				}
				else {
					ReferenceException.throwNotMergeable(internal, @data.source.value, this)
				}
			}
			else {
				SyntaxException.throwAlreadyDeclared(internal, this)
			}
		}
		else {
			@scope.define(internal, true, type, true, this)
		}

		this.module().import(internal)

		if isVariable && type is not AliasType {
			@variables[external] = ImportedVariable(internal)
			@count += 1
		}
	} # }}}
	buildArguments(metadata, arguments: Arguments = Arguments()): Arguments { # {{{
		@scope.line(this.line() - 1)

		if @data.arguments?.length != 0 {
			for var argument in @data.arguments {
				this.addArgument(argument, false, arguments)
			}

			if @autofill {
				for var i from 0 til metadata.requirements.length by 3 {
					var name = metadata.requirements[i + 1]

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
			for var i from 0 til metadata.requirements.length by 3 {
				var name = metadata.requirements[i + 1]

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
			for var i from 0 til metadata.requirements.length by 3 {
				this.validateRequirement(metadata.requirements[i + 2], metadata.requirements[i + 1], metadata)
			}
		}

		if arguments.values.length != 0 {
			var unmatchedArguments = [0..<arguments.values.length]
			var requirements = []
			var queue = []

			var reqReferences = {}
			var alterations = {}

			for var i from 0 til metadata.aliens.length by 3 {
				var index = metadata.aliens[i]
				var name = metadata.aliens[i + 1]
				var late type

				if !?reqReferences[index] {
					type = Type.import(index, metadata.references, reqReferences, alterations, queue, @scope, this)
				}
				else {
					type = reqReferences[index]
				}

				reqReferences[index] = Type.toNamedType(name, type)
			}

			for var i from 0 til metadata.requirements.length by 3 {
				var index = metadata.requirements[i]
				var name = metadata.requirements[i + 1]

				if arguments.toImport[name] is Number {
					var argument = arguments.values[arguments.toImport[name]]

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

			var len = arguments.values.length
			var mut nextArgument = 0
			for var requirement in requirements {
				while nextArgument < len && arguments.values[nextArgument].index != null {
					nextArgument += 1
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
				SyntaxException.throwUnmatchedImportArguments([arguments.values[i].name for var i in unmatchedArguments], this)
			}
		}

		for var argument, index in [...arguments.values] when !argument.required {
			var variable = @scope.getVariable(argument.identifier)

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
	loadDirectory(dir, moduleName? = null) { # {{{
		var mut pkgfile = path.join(dir, 'package.json')
		if fs.isFile(pkgfile) {
			var mut pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}

			if ?pkg {
				var mut metadata

				if ?pkg.kaoscript {
					var metadata = ?pkg.kaoscript.metadata ? path.join(dir, pkg.kaoscript.metadata) : null

					if ?pkg.kaoscript.main {
						if this.loadKSFile(path.join(dir, pkg.kaoscript.main), pkg.kaoscript.main, null, moduleName, metadata) {
							return true
						}
					}
					else if ?metadata {
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
	loadFile(filename, pathAddendum, moduleName? = null) { # {{{
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
			for var _, ext of require.extensions {
				if fs.isFile(filename + ext) {
					return this.loadNodeFile(filename, moduleName)
				}
			}
		}

		return false
	} # }}}
	loadKSFile(filename: String?, pathAddendum: String = '', extAddendum: String = '', mut moduleName: String? = null, metadataPath? = null) { # {{{
		var module = this.module()

		if moduleName == null {
			moduleName = module.path(filename, @data.source.value) as String

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

		for var modifer in @data.modifiers until @autofill {
			if modifer.kind == ModifierKind::Autofill {
				@autofill = true
			}
		}

		this.loadMetadata()

		@worker = new ImportWorker(@metaRequirements, @metaExports, this)

		var macros = {}
		for var i from 0 til @metaExports.macros.length by 2 {
			macros[@metaExports.macros[i]] = [JSON.parse(Buffer.from(data, 'base64').toString('utf8')) for data in @metaExports.macros[i + 1]]
		}

		@scope.line(this.line())

		if @data.specifiers.length == 0 {
			for var i from 1 til @metaExports.exports.length by 2 {
				name = @metaExports.exports[i]

				this.addImport(name, name, false)
			}

			for var datas, name of macros {
				for data in datas {
					new MacroDeclaration(data, this, null, name)
				}
			}
		}
		else {
			var mut name, type
			for var specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportExclusionSpecifier {
					var exclusions = [exclusion.name for exclusion in specifier.exclusions]

					for var i from 1 til @metaExports.exports.length by 2 when exclusions.indexOf(@metaExports.exports[i]) == -1 {
						name = @metaExports.exports[i]

						this.addImport(name, name, false)
					}

					for var datas, name of macros when exclusions.indexOf(name) == -1 {
						for data in datas {
							new MacroDeclaration(data, this, null, name)
						}
					}
				}
				else if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.internal.name
				}
				else {
					switch specifier.external.kind {
						NodeKind::ClassDeclaration => {
							name = specifier.external.name.name
							type = Type.fromAST(specifier.external, this)
						}
						NodeKind::Identifier => {
							name = specifier.external.name
							type = null
						}
						NodeKind::VariableDeclarator => {
							name = specifier.external.name.name
							type = ?specifier.external.type ? Type.fromAST(specifier.external.type, this) : null
						}
						=> {
							console.info(specifier.external)
							throw new NotImplementedException()
						}
					}

					if ?macros[name] {
						for data in macros[name] {
							new MacroDeclaration(data, this, null, specifier.internal.name)
						}
					}
					else {
						this.addImport(name, specifier.internal.name, false, type)
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
		var module = this.module()
		var source = fs.readFile(@filename)
		var target = @options.target

		if var upto ?= module.isUpToDate(@filename, source) {
			if var metadata ?= this.readMetadata(getRequirementsPath(@filename)) {
				var variations = [module._options.target.name, module._options.target.version]
				var arguments = this.buildArguments(metadata)

				var mut next = 0
				for var argument in [...arguments.values].sort((a, b) => a.index - b.index) {
					while next != argument.index {
						variations.push(null)

						next += 1
					}

					argument.type.toVariations(variations)

					next += 1
				}

				var length = metadata.requirements.length / 3
				while next != length {
					variations.push(null)

					next += 1
				}

				var variationId = fs.djb2a(variations.join())

				if upto.variations:Array.contains(variationId) {
					@metaRequirements = metadata
					@arguments = arguments
					@variationId = variationId

					if var metadata ?= this.readMetadata(getExportsPath(@filename, variationId)) {
						@metaExports = metadata

						module.addHashes(@filename, upto.hashes)

						return
					}
				}
			}
		}

		var compiler = module.compiler().createServant(@filename)

		compiler.initiate(source)

		@metaRequirements = compiler.toRequirements()

		this.buildArguments(@metaRequirements, @arguments)

		var arguments = [false for var i from 0 til @metaRequirements.requirements.length / 3]

		for var argument in @arguments.values {
			arguments[argument.index] = {
				name: argument.identifier
				type: argument.type
			}
		}

		@scope.line(this.line())

		for var argument in @arguments.values when argument.required {

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
	loadNodeFile(filename: String? = null, mut moduleName: String? = null) { # {{{
		var module = this.module()

		var mut file: String? = null
		if moduleName == null {
			file = moduleName = module.path(filename, @data.source.value)
		}

		if ?@data.arguments {
			for var argument in @data.arguments {
				if ?argument.name {
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
		@moduleName = moduleName!?

		if @data.specifiers.length == 0 {
			var parts = @data.source.value.split('/')

			for var part in parts desc while @alias == null when !/(?:^\.+$|^@)/.test(part) {
				var dots = part.split('.')
				var last = dots.length - 1

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
			var mut type
			for var specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportExclusionSpecifier {
					NotSupportedException.throw(`JavaScript import doesn't support exclusions`, this)
				}
				else if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.internal.name

					if specifier.specifiers?.length != 0 {
						type = new NamespaceType(@scope:Scope)

						for s in specifier.specifiers {
							if s.external.kind == NodeKind::Identifier {
								type.addProperty(s.internal.name, Type.Any)
							}
							else {
								type.addProperty(s.internal.name, Type.fromAST(s.external, this).flagAlien())
							}
						}

						this.addVariable(@alias, @alias, false, type)
					}
					else {
						this.addVariable(@alias, @alias, false, null)
					}
				}
				else {
					if specifier.external.kind == NodeKind::Identifier {
						this.addVariable(specifier.external.name, specifier.internal.name, true, null)
					}
					else {
						type = Type.fromAST(specifier.external, this).flagAlien()

						this.addVariable(specifier.external.name.name, specifier.internal.name, true, type)
					}
				}
			}
		}

		return true
	} # }}}
	loadNodeModule(moduleName, start) { # {{{
		var mut dirs = $nodeModulesPaths(start)

		var mut file, metadata
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
				var line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				this.toRequireFragments(line)

				line.done()
			}
			else if @arguments.values.length != 0 {
				var line = fragments.newLine()

				this.toRequireFragments(line)

				line.done()
			}
		}
		else {
			if @alias != null {
				var line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				this.toRequireFragments(line)

				line.done()
			}

			if @count == 1 {
				var mut variable, name

				for variable, name of @variables {
				}

				if variable.system {
					var line = fragments
						.newLine()
						.code(`var __ks_\(variable.name) = `)

					this.toRequireFragments(line)

					line.code(`.__ks_\(name)`).done()
				}
				else {
					var line = fragments
						.newLine()
						.code(`var \(variable.name) = `)

					this.toRequireFragments(line)

					line.code(`.\(name)`).done()
				}
			}
			else {
				if !destructuring || @options.format.destructuring == 'es5' {
					var late varname

					if @reusable {
						varname = @reuseName
					}
					else {
						var line = fragments
							.newLine()
							.code('var __ks__ = ')

						this.toRequireFragments(line)

						line.done()

						varname = '__ks__'
					}

					if destructuring {
						var line = fragments.newLine().code('var ')

						var mut nf = false
						for var variable, name of @variables {
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
								if variable.system {
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
					var line = fragments.newLine().code('var {')

					var mut nf = false
					for var variable, name of @variables {
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
								if variable.system {
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
							if variable.system {
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
				var line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				this.toRequireFragments(line)

				line.done()
			}
		}
		else {
			if @alias != null {
				var line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				this.toRequireFragments(line)

				line.done()
			}

			var mut name, alias
			if @count == 1 {
				var mut variable, name

				for variable, name of @variables {
				}

				var line = fragments
					.newLine()
					.code(`var \(variable.name) = `)

				this.toRequireFragments(line)

				line.code(`.\(name)`).done()
			}
			else if @count > 0 {
				if !destructuring || @options.format.destructuring == 'es5' {
					var mut line = fragments
						.newLine()
						.code(`var __ks__ = `)

					this.toRequireFragments(line)

					line.done()

					if destructuring {
						line = fragments.newLine().code('var ')

						var mut nf = false
						for var variable, name of @variables {
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
					var mut line = fragments.newLine().code('var {')

					var mut nf = false
					for var variable, name of @variables {
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
				var mut modulePath = ''

				if @pathAddendum.length > 0 {
					var dirname = path.dirname(@pathAddendum)
					var basename = path.basename(@pathAddendum)

					modulePath = `\(@moduleName)\(path.sep)\(dirname)\(path.sep).\(basename).\(@variationId).ksb`
				}
				else if $localFileRegex.test(@moduleName) {
					var basename = path.basename(@moduleName)
					var mut dirname

					if @parent.includePath() == null {
						dirname = path.dirname(@moduleName)
					}
					else {
						dirname = path.dirname(@parent.includePath())
					}

					modulePath = `\(dirname)\(path.sep).\(basename).\(@variationId).ksb`
				}
				else {
					var dirname = path.dirname(@moduleName)
					var basename = path.basename(@moduleName)

					modulePath = `\(dirname)\(path.sep).\(basename)\(@extAddendum).\(@variationId).ksb`
				}

				fragments.code(`require(\($quote(modulePath)))`)
			}
			else {
				fragments.code(`require(\($quote(@moduleName)))`)
			}

			if @hasArguments {
				fragments.code(`(`)

				var mut nf = false

				for var argument in @arguments.values when argument.isApproved && argument.index != null {
					if nf {
						fragments.code($comma)
					}
					else {
						nf = true
					}

					if argument.isIdentifier && argument.type.isSystem() {
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
			for var i from 0 til metadata.aliens.length by 3 {
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
		for var data in @data.declarations {
			var declarator = new ImportDeclarator(data, this)

			declarator.initiate()

			@declarators.push(declarator)
		}
	} # }}}
	analyse() { # {{{
		for declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	override prepare(target) { # {{{
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
		var module = @node.module()
		var references = {}
		var queue = []
		var variables = {}

		var metadata = [...@metaRequirements.references, ...@metaExports.references]

		var alterations = {mode: @node.mode()}

		var newAliens = {}
		var oldAliens = []

		for var i from 0 til @metaRequirements.aliens.length by 3 {
			var index = @metaRequirements.aliens[i]
			var name = @metaRequirements.aliens[i + 1]
			var mut type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				var origin = type.origin()
				if ?origin {
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

			if var alien ?= module.getAlien(name) {
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

		for var name, index in oldAliens by 3 {
			var newType = oldAliens[index + 1]
			var oldType = oldAliens[index + 1]

			if !oldType.isSubsetOf(newType, MatchingMode::Signature) {
				TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
			}
		}

		if @metaRequirements.requirements.length > 0 {
			var reqReferences = {...references}

			for var i from 0 til @metaRequirements.requirements.length by 3 {
				var index = @metaRequirements.requirements[i]
				var name = @metaRequirements.requirements[i + 1]
				var type = references[index] ?? Type.import(index, metadata, reqReferences, alterations, queue, @scope, @node)

				reqReferences[index] = Type.toNamedType(name, type)
			}

			while queue.length > 0 {
				queue.shift()()
			}

			for var i from 0 til @metaRequirements.requirements.length by 3 {
				var name = @metaRequirements.requirements[i + 1]
				var type = reqReferences[@metaRequirements.requirements[i]]

				if var index ?= arguments.toImport[name] {
					var argument = arguments.values[index]

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

			for var i from 0 til @metaRequirements.requirements.length by 3 {
				var reqIndex = @metaRequirements.requirements[i]
				var name = @metaRequirements.requirements[i + 1]

				if var index ?= arguments.toImport[name] {
					var argument = arguments.values[index]

					if argument.isApproved {
						if argument.required {
							argument.type = reqReferences[reqIndex]
						}

						if var type ?= references[reqIndex] {
							if !argument.type.isSubsetOf(type, MatchingMode::Signature) {
								TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
							}
						}

						references[reqIndex] = argument.type
					}
				}
				else if var type ?= references[reqIndex] {
					references[reqIndex] = type.flagRequired()
				}
			}
		}

		for var index, name of newAliens {
			module.addAlien(name, references[index])
		}

		for var i from 0 til @metaRequirements.requirements.length by 3 {
			var index = @metaRequirements.requirements[i]
			var name = @metaRequirements.requirements[i + 1]
			var late type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				type.origin(TypeOrigin::Require)
			}
			else {
				type = references[index]

				var origin = type.origin()
				if ?origin {
					type.origin(origin:TypeOrigin + TypeOrigin::Require)
				}
				else {
					type.origin(TypeOrigin::Require + TypeOrigin::Import)
				}
			}

			references[index] = Type.toNamedType(name, type)
		}

		for var i from 0 til @metaExports.exports.length by 2 {
			var index = @metaExports.exports[i]
			var name = @metaExports.exports[i + 1]
			var mut type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			type = Type.toNamedType(name, type)

			if var variable ?= @scope.getDefinedVariable(name) {
				variable.setDeclaredType(type)
			}
			else {
				@scope.addVariable(name, new Variable(name, false, false, type), @node)

				variables[index] = true
			}

			references[index] = type
		}

		for var i from 0 til @metaRequirements.aliens.length by 3 {
			var index = @metaRequirements.aliens[i]
			var name = @metaRequirements.aliens[i + 1]

			if !@scope.hasVariable(name) {
				@scope.addVariable(name, new Variable(name, false, false, references[index]), @node)

				variables[index] = true
			}
		}

		for var _, index in metadata {
			if !?references[index] {
				var type = Type.toNamedType(
					Type.import(index, metadata, references, alterations, queue, @scope, @node)
					true
					@scope
					@node
				)

				references[index] = type
			}
			else if !variables[index] {
				var type = references[index]

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
