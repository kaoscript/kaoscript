class IncludeDeclaration extends Statement {
	private {
		_statements = []
	}
	IncludeDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let directory = this.directory()
		
		let path, data, declarator
		for file in this._data.files {
			if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(file) {
				path = fs.resolve(directory, file)
				
				if fs.isFile(path) || fs.isFile(path += $extensions.source) {
					declarator = new IncludeDeclarator(path, this)
					
					data = parse(fs.readFile(path))
					
					for statement in data.body {
						this._statements.push(statement = $compile.statement(statement, declarator))
						
						statement.analyse()
					}
				}
				else {
					throw new Error(`Cannot find file '\(file)' from '\(directory)'`)
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
					throw new Error(`Cannot find module '\(file)' from '\(directory)'`)
				}
				
				declarator = new IncludeDeclarator(path, this)
				
				data = parse(fs.readFile(path))
				
				for statement in data.body {
					this._statements.push(statement = $compile.statement(statement, declarator))
					
					statement.analyse()
				}
			}
		}
	} // }}}
	fuse() { // {{{
		for statement in this._statements {
			statement.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		for statement in this._statements {
			statement.toFragments(fragments, mode)
		}
	} // }}}
}

class IncludeDeclarator extends Statement {
	private {
		_directory
		_file
	}
	IncludeDeclarator(@file, parent) { // {{{
		super({}, parent)
		
		this._directory = path.dirname(file)
	} // }}}
	directory() => this._directory
	file() => this._file
}