class IncludeDeclaration extends Statement {
	private {
		_statements = []
	}
	analyse() { // {{{
		let directory = this.directory()
		let module = this.module()
		let compiler = module.compiler()
		
		let path, data, declarator
		for file in @data.files {
			if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(file) {
				path = fs.resolve(directory, file)
				
				if fs.isFile(path) || fs.isFile(path += $extensions.source) {
					declarator = new IncludeDeclarator(path, this)
					
					data = fs.readFile(path)
					
					module.addHash(path, compiler.sha256(path, data))
					module.addInclude(path)
					
					try {
						data = module.parse(data, path)
					}
					catch error {
						error.filename = path
						
						throw error
					}
					
					for statement in data.body when statement ?= $compile.statement(statement, declarator) {
						@statements.push(statement)
						
						statement.analyse()
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else {
				let nf = true
				for dir in $import.nodeModulesPaths(directory) while nf {
					path = fs.resolve(dir, file)
				
					if fs.isFile(path) || fs.isFile(path += $extensions.source) {
						nf = false
					}
				}
				
				if nf {
					IOException.throwNotFoundModule(file, directory, this)
				}
				
				declarator = new IncludeDeclarator(path, this)
				
				data = fs.readFile(path)
				
				module.addHash(path, compiler.sha256(path, data))
				module.addInclude(path)
				
				try {
					data = module.parse(data, path)
				}
				catch error {
					error.filename = path
					
					throw error
				}
				
				for statement in data.body when statement ?= $compile.statement(statement, declarator) {
					@statements.push(statement)
					
					statement.analyse()
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
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}

class IncludeOnceDeclaration extends Statement {
	private {
		_statements = []
	}
	analyse() { // {{{
		let directory = this.directory()
		let module = this.module()
		let compiler = module.compiler()
		
		let path, data, declarator
		for file in @data.files {
			if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(file) {
				path = fs.resolve(directory, file)
				
				if fs.isFile(path) || fs.isFile(path += $extensions.source) {
					if !module.hasInclude(path) {
						declarator = new IncludeDeclarator(path, this)
						
						data = fs.readFile(path)
						
						module.addHash(path, compiler.sha256(path, data))
						module.addInclude(path)
						
						try {
							data = module.parse(data, path)
						}
						catch error {
							error.filename = path
							
							throw error
						}
						
						for statement in data.body when statement ?= $compile.statement(statement, declarator) {
							@statements.push(statement)
							
							statement.analyse()
						}
					}
				}
				else {
					IOException.throwNotFoundFile(file, directory, this)
				}
			}
			else {
				let nf = true
				for dir in $import.nodeModulesPaths(directory) while nf {
					path = fs.resolve(dir, file)
				
					if fs.isFile(path) || fs.isFile(path += $extensions.source) {
						nf = false
					}
				}
				
				if nf {
					IOException.throwNotFoundModule(file, directory, this)
				}
				
				if !module.hasInclude(path) {
					declarator = new IncludeDeclarator(path, this)
					
					data = fs.readFile(path)
					
					module.addHash(path, compiler.sha256(path, data))
					module.addInclude(path)
					
					try {
						data = module.parse(data, path)
					}
					catch error {
						error.filename = path
						
						throw error
					}
					
					for statement in data.body when statement ?= $compile.statement(statement, declarator) {
						@statements.push(statement)
						
						statement.analyse()
					}
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
	toFragments(fragments, mode) { // {{{
		for statement in @statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
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
}