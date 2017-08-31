class IncludeDeclaration extends Statement {
	private {
		_statements = []
	}
	analyse() { // {{{
		let directory = this.directory()
		
		let x
		for file in @data.files {
			if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(file) {
				x = fs.resolve(directory, file)
				
				if fs.isFile(x) || fs.isFile(x += $extensions.source) {
					if this.canLoadFile(x) {
						this.loadLocalFile(x)
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else {
				let nf = true
				for dir in $import.nodeModulesPaths(directory) while nf {
					x = fs.resolve(dir, file)
				
					if fs.isFile(x) {
						nf = false
					}
					else if fs.isFile(x + $extensions.source) {
						x += $extensions.source
						
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
									
									nf = false
								}
								else if pkg.main? {
									if fs.isFile(path.join(x, pkg.main)) {
										x = path.join(x, pkg.main)
										
										nf = false
									}
									else if fs.isFile(path.join(x, pkg.main + $extensions.source)) {
										x = path.join(x, pkg.main + $extensions.source)
										
										nf = false
									}
									else if fs.isFile(path.join(x, pkg.main, 'index' + $extensions.source)) {
										x = path.join(x, pkg.main, 'index' + $extensions.source)
										
										nf = false
									}
								}
							}
						}
						
						if nf && fs.isFile(path.join(x, 'index' + $extensions.source)) {
							x = path.join(x, 'index' + $extensions.source)
							
							nf = false
						}
					}
				}
				
				if nf {
					IOException.throwNotFoundModule(file, directory, this)
				}
				
				if this.canLoadFile(x) {
					this.loadModuleFile(x)
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
	canLoadFile(path) => true
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
	loadModuleFile(path) { // {{{
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
		
		for statement in data.body {
			if statement.kind == NodeKind::ExportDeclaration {
				for declaration in statement.declarations
				when	declaration.kind != NodeKind::ExportAlias &&
						declaration.kind != NodeKind::Identifier &&
						(declaration ?= $compile.statement(declaration, declarator))
				{
					@statements.push(declaration)
					
					declaration.analyse()
				}
			}
			else if statement ?= $compile.statement(statement, declarator) {
				@statements.push(statement)
				
				statement.analyse()
			}
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}

class IncludeOnceDeclaration extends IncludeDeclaration {
	canLoadFile(path) => !this.module().hasInclude(path)
}

class IncludeDeclarator extends Statement {
	private {
		_directory
		_file
	}
	constructor(@file, parent) { // {{{
		super({}, parent)
		
		@directory = path.dirname(file)
	} // }}}
	analyse()
	prepare()
	translate()
	directory() => @directory
	file() => @file
	recipient() => this.module()
}