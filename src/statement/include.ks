class IncludeDeclaration extends Statement {
	private {
		@declarators			= []
	}
	initiate() { # {{{
		var mut directory = @directory()

		for var data in @data.declarations {
			var file = data.file
			var dyn x

			if $localFileRegex.test(file) {
				x = $fs.resolve(directory, file)

				if $fs.isFile(x) {
					if x == @file() {
						SyntaxException.throwIncludeSelf(this)
					}

					if @canLoadLocalFile(x) {
						@loadLocalFile(data, x)
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else if file.startsWith('npm:') {
				var name = file.substr(4)

				var mut modulePath = file
				var mut moduleVersion = ''

				var mut nf = true
				for var dir in $listNPMModulePaths(directory) while nf {
					x = $fs.resolve(dir, name)

					if $fs.isFile(x) {
						nf = false
					}
					else {
						var mut pkgfile = $path.join(x, 'package.json')

						if $fs.isFile(pkgfile) {
							if var pkg ?= try JSON.parse($fs.readFile(pkgfile)) {
								if ?pkg.kaoscript && $fs.isFile($path.join(x, pkg.kaoscript.main)) {
									x = $path.join(x, pkg.kaoscript.main)
									modulePath = $path.join(modulePath, pkg.kaoscript.main)

									nf = false
								}
								else if ?pkg.main {
									if $fs.isFile($path.join(x, pkg.main)) {
										x = $path.join(x, pkg.main)
										modulePath = $path.join(modulePath, pkg.main)

										nf = false
									}
								}

								if !nf {
									moduleVersion = pkg.version
								}
							}
						}
					}
				}

				if nf {
					IOException.throwNotFoundModule(file, directory, this)
				}

				if @canLoadModuleFile(x, file, modulePath, moduleVersion) {
					@loadModuleFile(data, x, file, modulePath, moduleVersion)
				}
			}
			else {
				IOException.throwNotFoundModule(file, directory, this)
			}
		}
	} # }}}
	override postInitiate() { # {{{
		for var declarator in @declarators {
			declarator.postInitiate()
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
	override prepare(target, targetMode) { # {{{
		for var declarator in @declarators {
			declarator.prepare()
		}
	} # }}}
	translate() { # {{{
		for var declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	canLoadLocalFile(file) => !@module().hasInclude(file)
	canLoadModuleFile(file, name, path, version) { # {{{
		if var versions ?= @module().listIncludeVersions(file, name, path) {
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
		var module = @module()

		var mut data = $fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path)

		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path

			throw error
		}

		var declarator = IncludeDeclarator.new(declaration, data, path, this)

		declarator.initiate()

		@declarators.push(declarator)
	} # }}}
	loadModuleFile(declaration, path, moduleName, modulePath, moduleVersion) { # {{{
		var module = @module()

		var mut data = $fs.readFile(path)

		module.addHash(path, module.compiler().sha256(path, data))
		module.addInclude(path, moduleName, modulePath, moduleVersion)

		try {
			data = module.parse(data, path)
		}
		catch error {
			error.filename = path

			throw error
		}

		var declarator = IncludeDeclarator.new(declaration, data, path, moduleName, this)

		declarator.initiate()

		@declarators.push(declarator)
	} # }}}
	registerSyntimeFunction(name, macro) => @parent.registerSyntimeFunction(name, macro)
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
		@directory: String
		@file: String
		@includePath: String?
		@offsetEnd: Number		= 0
		@offsetStart: Number	= 0
		@statements				= []
	}
	constructor(declaration, @data, @file, moduleName: String? = null, @parent) { # {{{
		super(data, parent)

		@options = Attribute.configure(declaration, @options, AttributeTarget.Global, super.file(), true)

		@directory = $path.dirname(file)

		var includePath = parent.includePath()

		if !?moduleName {
			@includePath = includePath
		}
		else if !?includePath || !$localFileRegex.test(moduleName) {
			@includePath = moduleName.substr(4)
		}
		else {
			@includePath = $path.join(includePath, moduleName)
		}
	} # }}}
	initiate() { # {{{
		Attribute.configure(@data, @parent.parent()._options, AttributeTarget.Global, @file())

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
	override postInitiate() { # {{{
		for var statement in @statements {
			statement.postInitiate()
		}
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
	override prepare(target, targetMode) { # {{{
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
	isUsingStaticVariableBefore(class: String, varname: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariableBefore(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	recipient() => @module()
	registerSyntimeFunction(name, macro) => @parent.registerSyntimeFunction(name, macro)
	toFragments(fragments, mode) { # {{{
		for var statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} # }}}
}
