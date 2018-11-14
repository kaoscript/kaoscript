const $localFileRegex = /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/

class IncludeDeclaration extends Statement {
	private {
		_statements = []
	}
	analyse() { // {{{
		let directory = this.directory()

		let x
		for file in @data.files {
			if $localFileRegex.test(file) {
				x = fs.resolve(directory, file)

				if fs.isFile(x) || fs.isFile(x += $extensions.source) {
					if this.canLoadLocalFile(x) {
						this.loadLocalFile(x)
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
				for dir in $nodeModulesPaths(directory) while nf {
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
							let pkg
							try {
								pkg = JSON.parse(fs.readFile(pkgfile))
							}

							if pkg? {
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
					this.loadModuleFile(x, file, modulePath, moduleVersion)
				}
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
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
	loadLocalFile(path) { // {{{
		const module = this.module()
		const declarator = new IncludeDeclarator(path, this)

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

		Attribute.configure(data, this.module()._options, false, AttributeTarget::Global)

		for statement in data.body when statement ?= $compile.statement(statement, declarator) {
			@statements.push(statement)

			statement.analyse()
		}
	} // }}}
	loadModuleFile(path, moduleName, modulePath, moduleVersion) { // {{{
		const module = this.module()
		const declarator = new IncludeDeclarator(path, moduleName, this)

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

		Attribute.configure(data, this.module()._options, false, AttributeTarget::Global)

		for statement in data.body when statement ?= $compile.statement(statement, declarator) {
			@statements.push(statement)

			statement.analyse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
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
	}
	constructor(@file, moduleName: String = null, @parent) { // {{{
		super({}, parent)

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
	analyse()
	prepare()
	translate()
	directory() => @directory
	file() => @file
	includePath() => @includePath
	recipient() => this.module()
}