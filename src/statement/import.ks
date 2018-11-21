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
		_count: Number				= 0
		_domain: ImportDomain
		_imports					= {}
		_isKSFile: Boolean
		_localToModuleArguments		= {}
		_metadata
		_moduleToLocalArguments		= {}
		_moduleName: String
		_requirements				= {}
		_sealedVariables			= {}
		_variables					= {}
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
			let moduleType, type
			for name, requirement of @requirements {
				type = @scope.getVariable(@moduleToLocalArguments[name]).type()
				moduleType = Type.import(name, requirement.data, @metadata.references, @domain, this)

				if !type.match(moduleType) {
					TypeException.throwNotCompatible(@moduleToLocalArguments[name], name, @data.source.value, this)
				}

				requirement.type = type
			}

			@domain.prepare(@requirements)

			let variable
			for name, def of @imports {
				variable = @scope.getVariable(def.local)

				if def.isAlias {
					type = new NamespaceType(@alias, @scope)
					const ref = type.reference()

					for i from 1 til @metadata.exports.length by 2 {
						const name = @metadata.exports[i]

						if @domain.hasVariable(name) {
							type.addProperty(name, @domain.getVariable(name))
						}
						else {
							type.addProperty(name, @domain.commit(name).namespace(ref))
						}
					}

					variable.type(type)
				}
				else {
					if !@domain.hasTemporary(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					type = @domain.commit(name)

					if def.newVariable {
						variable.type(type)
					}
					else if @localToModuleArguments[def.local] is not String {
						ReferenceException.throwNotPassed(def.local, @data.source.value, this)
					}
					else if type.match(variable.type()) {
						if variable.type().isAlien() {
							type.alienize()
						}

						variable.type(type)
					}
					else {
						TypeException.throwNotCompatible(def.local, name, @data.source.value, this)
					}

					if type is not AliasType {
						@variables[name] = def.local
						++@count

						if type.isSealed() {
							@sealedVariables[name] = true
							++@count
						}
					}
				}
			}

			@domain.commit()

			if @data.arguments?.length != 0 || @count != 0 || @alias? {
				this.module().flagRegister()
			}
		}
	} // }}}
	translate()
	addArgument(data) { // {{{
		if data.kind == NodeKind::Identifier {
			unless @scope.hasVariable(data.name) {
				ReferenceException.throwNotDefined(data.name, this)
			}

			@localToModuleArguments[data.name] = data.name
			@moduleToLocalArguments[data.name] = data.name
		}
		else if data.kind == NodeKind::NamedArgument {
			unless @scope.hasVariable(data.value.name) {
				ReferenceException.throwNotDefined(data.value.name, this)
			}

			@localToModuleArguments[data.value.name] = data.name.name
			@moduleToLocalArguments[data.name.name] = data.value.name
		}
		else {
			console.log(data)
			throw new NotImplementedException(this)
		}
	} // }}}
	addImport(imported: String, local: String, isAlias: Boolean) { // {{{
		const newVariable = !@scope.hasVariable(local)
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
			local: local
			isAlias: isAlias
			newVariable: newVariable
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
			let target = module.compiler()._options.target

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

		@domain = new ImportDomain(@metadata, this)

		if @data.arguments?.length != 0 {
			for argument in @data.arguments {
				this.addArgument(argument)
			}

			let name
			for i from 0 til @metadata.requirements.length by 3 {
				name = @metadata.requirements[i + 1]

				if @moduleToLocalArguments[name] is not String {
					SyntaxException.throwMissingRequirement(name, this)
				}

				@requirements[name] = {
					index: Math.floor(i / 3) + 1
					data: @metadata.references[@metadata.requirements[i]]
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
					new MacroDeclaration(data, this, name)
				}
			}
		}
		else {
			let name
			for specifier in @data.specifiers {
				if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					@alias = specifier.local.name
				}
				else {
					name = specifier.imported.kind == NodeKind::Identifier ? specifier.imported.name : specifier.imported.name.name

					if macros[name]? {
						for data in macros[name] {
							new MacroDeclaration(data, this, specifier.local.name)
						}
					}
					else {
						this.addImport(name, specifier.local.name, false)
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
				if argument.kind == NodeKind::NamedArgument {
					SyntaxException.throwInvalidNamedArgument(argument.name.name, this)
				}
				else {
					this.addArgument(argument)
				}
			}
		}

		@isKSFile = false
		@moduleName = moduleName

		if @data.specifiers.length == 0 {
			const parts = @data.source.value.split('/')
			for i from 0 til parts.length {
				if !/(?:^\.+$|^@)/.test(parts[i]) {
					@alias = parts[i].split('.')[0]

					break
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
						type = new NamespaceType(@alias, @scope)

						for s in specifier.specifiers {
							if s.imported.kind == NodeKind::Identifier {
								type.addProperty(s.local.name, Type.Any)
							}
							else {
								type.addProperty(s.local.name, Type.fromAST(s.imported, this).alienize())
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
						type = Type.fromAST(specifier.imported, this).alienize()

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

		if @data.arguments?.length != 0 {
			let nf = false

			for name of @requirements {
				if nf {
					importCode += ', '
				}
				else {
					nf = true
				}

				if @moduleToLocalArguments[name] is String {
					importCode += @moduleToLocalArguments[name]

					if @requirements[name].type.isSealed() {
						importCode += `, __ks_\(@moduleToLocalArguments[name])`
					}
				}
				else {
					importCode += 'null'
				}
			}
		}

		importCode += ')'

		if @count != 0 && @alias != null {
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
		else if @count > 0 {
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

		@scope.releaseTempName(importCode)
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

					line.code(argument.name)
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

					line.code(argument.name)
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

						line.code(argument.name)
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

						line.code(argument.name)
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