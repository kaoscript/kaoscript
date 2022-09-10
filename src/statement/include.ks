var $localFileRegex = /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/

class IncludeDeclaration extends Statement {
	private {
		_declarators			= []
	}
	initiate() { # {{{
		var mut directory = this.directory()

		var mut x
		for var data in @data.declarations {
			var file = data.file

			if $localFileRegex.test(file) {
				x = fs.resolve(directory, file)

				if fs.isFile(x) || fs.isFile((x += $extensions.source, x)) {
					if this.canLoadLocalFile(x) {
						this.loadLocalFile(data, x)
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else {
				var mut modulePath = file
				var mut moduleVersion = ''

				var mut nf = true
				for var dir in $nodeModulesPaths(directory) while nf {
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
						var mut pkgfile = path.join(x, 'package.json')

						if fs.isFile(pkgfile) {
							if var pkg ?= try JSON.parse(fs.readFile(pkgfile)) {
								if ?pkg.kaoscript && fs.isFile(path.join(x, pkg.kaoscript.main)) {
									x = path.join(x, pkg.kaoscript.main)
									modulePath = path.join(modulePath, pkg.kaoscript.main)

									nf = false
								}
								else if ?pkg.main {
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
	} # }}}
	analyse() { # {{{
		for var declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	enhance() { # {{{
		for var declarator in @declarators {
			declarator.enhance()
		}
	} # }}}
	override prepare(target) { # {{{
		for var declarator in @declarators {
			declarator.prepare()
		}
	} # }}}
	translate() { # {{{
		for var declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	canLoadLocalFile(file) => !this.module().hasInclude(file)
	canLoadModuleFile(file, name, path, version) { # {{{
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
	} # }}}
	export(recipient, enhancement: Boolean = false) { # {{{
		for var declarator in @declarators {
			declarator.export(recipient, enhancement)
		}
	} # }}}
	isExportable() => true
	loadLocalFile(declaration, path) { # {{{
		var module = this.module()

		var mut data = fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path)

		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path

			throw error
		}

		var declarator = new IncludeDeclarator(declaration, data, path, this)

		declarator.initiate()

		@declarators.push(declarator)
	} # }}}
	loadModuleFile(declaration, path, moduleName, modulePath, moduleVersion) { # {{{
		var module = this.module()

		var mut data = fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path, modulePath, moduleVersion)

		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path

			throw error
		}

		var declarator = new IncludeDeclarator(declaration, data, path, moduleName, this)

		declarator.initiate()

		@declarators.push(declarator)
	} # }}}
	registerMacro(name, macro) => @parent.registerMacro(name, macro)
	toFragments(fragments, mode) { # {{{
		for var declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} # }}}
}

class IncludeAgainDeclaration extends IncludeDeclaration {
	canLoadLocalFile(file) => true
	canLoadModuleFile(file, name, path, version) => true
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
	constructor(declaration, @data, @file, moduleName: String? = null, @parent) { # {{{
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
	} # }}}
	initiate() { # {{{
		Attribute.configure(@data, @parent.parent()._options, AttributeTarget::Global, this.file())

		var offset = @scope.getLineOffset()

		@offsetStart = @scope.line()

		@scope.setLineOffset(@offsetStart)

		for var data in @data.body {
			@scope.line(data.start.line)

			if var statement ?= $compile.statement(data, this) {
				@statements.push(statement)

				statement.initiate()
			}
		}

		@scope.line(@data.end.line)

		@offsetEnd = offset + @scope.line() - @offsetStart

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	analyse() { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.analyse()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	enhance() { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	override prepare(target) { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.prepare()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	translate() { # {{{
		@scope.setLineOffset(@offsetStart)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}

		@scope.setLineOffset(@offsetEnd)
	} # }}}
	directory() => @directory
	export(recipient, enhancement: Boolean = false) { # {{{
		for var statement in @statements when statement.isExportable() {
			statement.export(recipient, enhancement)
		}
	} # }}}
	file() => @file
	includePath() => @includePath
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { # {{{
		var line = stmt.line()

		for var statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	recipient() => this.module()
	registerMacro(name, macro) => @parent.registerMacro(name, macro)
	toFragments(fragments, mode) { # {{{
		for var statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} # }}}
}
