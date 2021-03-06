const $localFileRegex = /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/

class IncludeDeclaration extends Statement {
	private {
		_declarators			= []
	}
	analyse() { // {{{
		let directory = this.directory()

		let x
		for const data in @data.declarations {
			const file = data.file

			if $localFileRegex.test(file) {
				x = fs.resolve(directory, file)

				if fs.isFile(x) || fs.isFile(x += $extensions.source) {
					if this.canLoadLocalFile(x) {
						this.loadLocalFile(data, x)
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else {
				let modulePath = file
				let moduleVersion = ''

				let nf = true
				for const dir in $nodeModulesPaths(directory) while nf {
					x = fs.resolve(dir, file)

					if fs.isFile(x) {
						nf = false
					}
					else if fs.isFile(x + $extensions.source) {
						x += $extensions.source
						modulePath += $extensions.source

						nf = false
					}
					else {
						let pkgfile = path.join(x, 'package.json')

						if fs.isFile(pkgfile) {
							if const pkg = try JSON.parse(fs.readFile(pkgfile)) {
								if pkg.kaoscript? && fs.isFile(path.join(x, pkg.kaoscript.main)) {
									x = path.join(x, pkg.kaoscript.main)
									modulePath = path.join(modulePath, pkg.kaoscript.main)

									nf = false
								}
								else if pkg.main? {
									if fs.isFile(path.join(x, pkg.main)) {
										x = path.join(x, pkg.main)
										modulePath = path.join(modulePath, pkg.main)

										nf = false
									}
									else if fs.isFile(path.join(x, pkg.main + $extensions.source)) {
										x = path.join(x, pkg.main + $extensions.source)
										modulePath = path.join(modulePath, pkg.main + $extensions.source)

										nf = false
									}
									else if fs.isFile(path.join(x, pkg.main, 'index' + $extensions.source)) {
										x = path.join(x, pkg.main, 'index' + $extensions.source)
										modulePath = path.join(modulePath, pkg.main, 'index' + $extensions.source)

										nf = false
									}
								}

								if !nf {
									moduleVersion = pkg.version
								}
							}
						}

						if nf && fs.isFile(path.join(x, 'index' + $extensions.source)) {
							x = path.join(x, 'index' + $extensions.source)
							modulePath = path.join(modulePath, 'index' + $extensions.source)

							nf = false
						}
					}
				}

				if nf {
					IOException.throwNotFoundModule(file, directory, this)
				}

				if this.canLoadModuleFile(x, file, modulePath, moduleVersion) {
					this.loadModuleFile(data, x, file, modulePath, moduleVersion)
				}
			}
		}
	} // }}}
	prepare() { // {{{
		for const declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate() { // {{{
		for const declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	canLoadLocalFile(file) => !this.module().hasInclude(file)
	canLoadModuleFile(file, name, path, version) { // {{{
		if versions ?= this.module().listIncludeVersions(file, path) {
			if versions.length > 1 || versions[0] == version {
				return false
			}
			else {
				SyntaxException.throwMismatchedInclude(name, this)
			}
		}
		else {
			return true
		}
	} // }}}
	export(recipient) { // {{{
		for const declarator in @declarators {
			declarator.export(recipient)
		}
	} // }}}
	isExportable() => true
	loadLocalFile(declaration, path) { // {{{
		const module = this.module()

		let data = fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path)

		try {
			//console.time('parse')
			data = module.parse(data, path)
			//console.timeEnd('parse')
		}
		catch error {
			error.filename = path

			throw error
		}

		const declarator = new IncludeDeclarator(declaration, data, path, this)

		declarator.analyse()

		@declarators.push(declarator)
	} // }}}
	loadModuleFile(declaration, path, moduleName, modulePath, moduleVersion) { // {{{
		const module = this.module()

		let data = fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path, modulePath, moduleVersion)

		try {
			//console.time('parse')
			data = module.parse(data, path)
			//console.timeEnd('parse')
		}
		catch error {
			error.filename = path

			throw error
		}

		const declarator = new IncludeDeclarator(declaration, data, path, moduleName, this)

		declarator.analyse()

		@declarators.push(declarator)
	} // }}}
	registerMacro(name, macro) => @parent.registerMacro(name, macro)
	toFragments(fragments, mode) { // {{{
		for const declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} // }}}
}

class IncludeAgainDeclaration extends IncludeDeclaration {
	canLoadLocalFile(...) => true
	canLoadModuleFile(...) => true
}

class IncludeDeclarator extends Statement {
	private {
		_directory: String
		_file: String
		_includePath: String
		_offsetEnd: Number		= 0
		_offsetStart: Number	= 0
		_statements				= []
	}
	constructor(declaration, @data, @file, moduleName: String = null, @parent) { // {{{
		super(data, parent)

		@options = Attribute.configure(declaration, @options, AttributeTarget::Global, super.file(), true)

		@directory = path.dirname(file)

		if moduleName == null {
			@includePath = parent.includePath()
		}
		else if parent.includePath() == null || !$localFileRegex.test(moduleName) {
			@includePath = moduleName
		}
		else {
			@includePath = path.join(parent.includePath(), moduleName)
		}
	} // }}}
	analyse() { // {{{
		Attribute.configure(@data, @parent.parent()._options, AttributeTarget::Global, this.file())

		const offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		for const data in @data.body {
			@scope.line(data.start.line)

			if const statement = $compile.statement(data, this) {
				@statements.push(statement)

				statement.analyse()
			}
		}

		@scope.line(@data.end.line)

		@offsetEnd = offset + @scope.line() - @offsetStart

		@scope.setLineOffset(@offsetEnd)
	} // }}}
	prepare() { // {{{
		@scope.setLineOffset(@offsetStart)

		for const statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		@scope.setLineOffset(@offsetEnd)
	} // }}}
	translate() { // {{{
		@scope.setLineOffset(@offsetStart)

		for const statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}

		@scope.setLineOffset(@offsetEnd)
	} // }}}
	directory() => @directory
	export(recipient) { // {{{
		for const statement in @statements when statement.isExportable() {
			statement.export(recipient)
		}
	} // }}}
	file() => @file
	includePath() => @includePath
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { // {{{
		const line = stmt.line()

		for const statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} // }}}
	recipient() => this.module()
	registerMacro(name, macro) => @parent.registerMacro(name, macro)
	toFragments(fragments, mode) { // {{{
		for const statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}