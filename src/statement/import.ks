enum ImportKind {
	KSFile
	NodeFile
}

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

const $import = {
	addVariable(module, file?, node, name, variable, data) { // {{{
		if variable.requirement? && data.references? {
			let nf = true
			for reference in data.references while nf {
				if (reference.foreign? && reference.foreign.name == variable.requirement) || reference.alias.name == variable.requirement {
					nf = false
					
					variable = $variable.merge(node.scope().getVariable(reference.alias.name), variable)
				}
			}
		}
		
		node.scope().addVariable(name, variable)
		
		module.import(name, file)
	} // }}}
	define(module, file?, node, name, kind, type?) { // {{{
		$variable.define(node, node.scope(), name, kind, type)
		
		module.import(name.name || name, file)
	} // }}}
	loadCoreModule(x, module, data, node) { // {{{
		if $nodeModules[x] {
			return $import.loadNodeFile(null, x, module, data, node)
		}
		
		return false
	}, // }}}
	loadDirectory(x, moduleName?, module, data, node) { // {{{
		let pkgfile = path.join(x, 'package.json')
		if fs.isFile(pkgfile) {
			let pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}
			
			if pkg.kaoscript && $import.loadKSFile(path.join(x, pkg.kaoscript.main), moduleName, module, data, node) {
				return true
			}
			else if pkg.main && ($import.loadFile(path.join(x, pkg.main), moduleName, module, data, node) || $import.loadDirectory(path.join(x, pkg.main), moduleName, module, data, node)) {
				return true
			}
		}
		
		return $import.loadFile(path.join(x, 'index'), moduleName, module, data, node)
	} // }}}
	loadFile(x, moduleName?, module, data, node) { // {{{
		if fs.isFile(x) {
			if x.endsWith($extensions.source) {
				return $import.loadKSFile(x, moduleName, module, data, node)
			}
			else {
				return $import.loadNodeFile(x, moduleName, module, data, node)
			}
		}
		
		if fs.isFile(x + $extensions.source) {
			return $import.loadKSFile(x + $extensions.source, moduleName, module, data, node)
		}
		else {
			for ext of require.extensions {
				if fs.isFile(x + ext) {
					return $import.loadNodeFile(x, moduleName, module, data, node)
				}
			}
		}
		
		return false
	} // }}}
	loadKSFile(x, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		let metadata, name, alias, variable, hashes
		
		let source = fs.readFile(x)
		let target = module.compiler()._options.target
		
		if fs.isFile(getMetadataPath(x, target)) && fs.isFile(getHashPath(x, target)) && (hashes ?= module.isUpToDate(x, target, source)) && (metadata ?= $import.readMetadata(getMetadataPath(x, target))) {
		}
		else {
			let compiler = module.compiler().createServant(x)
			
			compiler.compile(source)
			
			compiler.writeFiles()
			
			metadata = compiler.toMetadata()
			
			hashes = compiler.toHashes()
		}
		
		module.addHashes(x, hashes)
		
		let {exports, requirements} = metadata
		
		let importVariables = {}
		let importVarCount = 0
		let importAll = false
		let importAlias = ''
		
		for specifier in data.specifiers {
			if specifier.kind == Kind::ImportWildcardSpecifier {
				if specifier.local {
					importAlias = specifier.local.name
				}
				else {
					importAll = true
				}
			}
			else {
				importVariables[specifier.alias.name] = specifier.local ? specifier.local.name : specifier.alias.name
				++importVarCount
			}
		}
		
		if importVarCount || importAll || importAlias.length {
			let nf
			for name, requirement of requirements {
				$throw(`Missing requirement '\(name)' at line \(data.start.line)`, node) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								$import.use(reference.alias, node)
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								$import.use(reference.alias, node)
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if !requirement.nullable {
						$throw(`Missing requirement '\(name)' at line \(data.start.line)`, node)
					}
				}
			}
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			$throw(`Undefined variable \(name) in the imported module at line \(data.start.line)`, node) unless variable ?= exports[name]
			
			$import.addVariable(module, file, node, alias, variable, data)
		}
		else if importVarCount {
			nf = false
			for name, alias of importVariables {
				$throw(`Undefined variable \(name) in the imported module at line \(data.start.line)`, node) unless variable ?= exports[name]
				
				$import.addVariable(module, file, node, alias, variable, data)
			}
		}
		
		if importAll {
			for name, variable of exports {
				$import.addVariable(module, file, node, name, variable, data)
			}
		}
		
		if importAlias.length {
			type = {
				typeName: {
					kind: Kind::Identifier
					name: 'Object'
				}
				properties: {}
			}
			
			for name, variable of exports {
				type.properties[variable.name] = variable
			}
			
			variable = $variable.define(node, node.scope(), {
				kind: Kind::Identifier
				name: importAlias
			}, VariableKind::Variable, type)
		}
		
		node._kind = ImportKind::KSFile
		node._metadata = {
			moduleName: moduleName
			exports: exports
			requirements: requirements
			importVariables: importVariables
			importVarCount: importVarCount
			importAll: importAll
			importAlias: importAlias
		}
		
		return true
	} // }}}
	loadNodeFile(x?, moduleName?, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		node._kind = ImportKind::NodeFile
		node._metadata = {
			moduleName: moduleName
		}
		
		let variables = node._metadata.variables = {}
		let count = 0
		
		for specifier in data.specifiers {
			if specifier.kind == Kind::ImportWildcardSpecifier {
				if specifier.local {
					node._metadata.wilcard = specifier.local.name
					
					$import.define(module, file, node, specifier.local, VariableKind::Variable)
				}
				else {
					$throw('Wilcard import is only suppoted for ks files', node)
				}
			}
			else {
				variables[specifier.alias.name] = specifier.local ? specifier.local.name : specifier.alias.name
				++count
			}
		}
		
		node._metadata.count = count
		
		for alias of variables {
			$import.define(module, file, node, variables[alias], VariableKind::Variable)
		}
		
		return true
	} // }}}
	loadNodeModule(x, start, module, data, node) { // {{{
		let dirs = $import.nodeModulesPaths(start)
		
		let file
		for dir in dirs {
			file = path.join(dir, x)
			
			if $import.loadFile(file, x, module, data, node) || $import.loadDirectory(file, x, module, data, node) {
				return true
			}
		}
		
		return false
	} // }}}
	nodeModulesPaths(start) { // {{{
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
	readMetadata(file) { // {{{
		try {
			return JSON.parse(fs.readFile(file))
		}
		catch {
			return null
		}
	} // }}}
	resolve(data, y, module, node) { // {{{
		let x = data.module
		
		if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x) {
			x = fs.resolve(y, x)
			
			if !($import.loadFile(x, null, module, data, node) || $import.loadDirectory(x, null, module, data, node)) {
				$throw("Cannot find module '" + x + "' from '" + y + "'", node)
			}
		}
		else {
			if !($import.loadNodeModule(x, y, module, data, node) || $import.loadCoreModule(x, module, data, node)) {
				$throw("Cannot find module '" + x + "' from '" + y + "'", node)
			}
		}
	} // }}}
	use(data, node) { // {{{
		if data is Array {
			for item in data {
				$throw(`Undefined variable '\(item.name)' at line \(item.start.line)`, node) if item.kind == Kind::Identifier && !node.scope().hasVariable(item.name)
			}
		}
		else if data.kind == Kind::Identifier {
			$throw(`Undefined variable '\(data.name)' at line \(data.start.line)`, node) if !node.scope().hasVariable(data.name)
		}
	} // }}}
	toKSFileFragments(node, fragments, data, metadata) { // {{{
		let {moduleName, exports, requirements, importVariables, importVarCount, importAll, importAlias} = metadata
		
		let name, alias, variable, importCode
		let importCodeVariable = false
		
		if (importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length) {
			importCode = node.scope().acquireTempName()
			importCodeVariable = true
			
			let line = fragments
				.newLine()
				.code('var ', importCode, ' = require(', $quote(moduleName), ')(')
			
			let nf
			let first = true
			let nc = 0
			for name, requirement of requirements {
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								if first {
									first = false
								}
								else {
									line.code(', ')
								}
								
								for i from 0 til nc {
									if i {
										line.code(', ')
									}
									
									line.code('null')
								}
								
								line.code(reference.alias.name)
								
								if requirement.class {
									line.code(', __ks_' + reference.alias.name)
								}
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								if first {
									first = false
								}
								else {
									line.code(', ')
								}
								
								for i from 0 til nc {
									if i {
										line.code(', ')
									}
									
									line.code('null')
								}
								
								line.code(reference.alias.name)
								
								if requirement.class {
									line.code(', __ks_' + reference.alias.name)
								}
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if requirement.nullable {
						++nc
						++nc if requirement.class
					}
					else {
						$throw(`Missing requirement '\(name)' at line \(data.start.line)`, node)
					}
				}
			}
			
			line.code(')').done()
		}
		else if importVarCount || importAll || importAlias.length {
			importCode = 'require(' + $quote(moduleName) + ')('
			
			let nf
			let first = true
			let nc = 0
			for name, requirement of requirements {
				$throw(`Missing requirement '\(name)' at line \(data.start.line)`, node) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
				nf = true
				if data.references {
					for reference in data.references while nf {
						if reference.foreign? {
							if reference.foreign.name == name {
								if first {
									first = false
								}
								else {
									importCode += ', '
								}
								
								for i from 0 til nc {
									if i {
										importCode += ', '
									}
									
									importCode += 'null'
								}
								
								importCode += reference.alias.name
								
								if requirement.class {
									importCode += ', __ks_' + reference.alias.name
								}
								
								nf = false
							}
						}
						else {
							if reference.alias.name == name {
								if first {
									first = false
								}
								else {
									importCode += ', '
								}
								
								for i from 0 til nc {
									if i {
										importCode += ', '
									}
									
									importCode += 'null'
								}
								
								importCode += reference.alias.name
								
								if requirement.class {
									importCode += ', __ks_' + reference.alias.name
								}
								
								nf = false
							}
						}
					}
				}
				
				if nf {
					if requirement.nullable {
						++nc
						++nc if requirement.class
					}
					else {
						$throw(`Missing requirement '\(name)' at line \(data.start.line)`, node)
					}
				}
			}
			
			importCode += ')'
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			variable = exports[name]
			
			if variable.kind != VariableKind::TypeAlias {
				if variable.sealed {
					variable.sealed.name = '__ks_' + alias
					
					fragments.newLine().code(`var {\(alias), \(variable.sealed.name)} = \(importCode)`).done()
				}
				else {
					fragments.newLine().code(`var \(alias) = \(importCode).\(name)`).done()
				}
			}
		}
		else if importVarCount > 0 {
			if node._options.format.destructuring == 'es5' {
				if importCodeVariable {
					let line = fragments.newLine().code('var ')
					
					let nf = false
					for name, alias of importVariables {
						variable = exports[alias]
						
						if variable.kind != VariableKind::TypeAlias {
							if nf {
								line.code(', ')
							}
							else {
								nf = true
							}
							
							line.code(`\(alias) = \(importCode).\(name)`)
						}
					}
					
					line.done()
				}
				else {
					fragments.line(`var __ks__ = \(importCode)`)
					
					let line = fragments.newLine().code('var ')
					
					let nf = false
					for name, alias of importVariables {
						variable = exports[alias]
						
						if variable.kind != VariableKind::TypeAlias {
							if nf {
								line.code(', ')
							}
							else {
								nf = true
							}
							
							line.code(`\(alias) = __ks__.\(name)`)
						}
					}
					
					line.done()
				}
			}
			else {
				let line = fragments.newLine().code('var {')
				
				let nf = false
				for name, alias of importVariables {
					variable = exports[name]
					
					if variable.kind != VariableKind::TypeAlias {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}
						
						if alias == name {
							line.code(name)
							
							if variable.sealed {
								line.code(', ', variable.sealed.name)
							}
						}
						else {
							line.code(name, ': ', alias)
							
							if variable.sealed {
								variable.sealed.name = '__ks_' + alias
								
								line.code(', ', variable.sealed.name)
							}
						}
					}
				}
				
				line.code('} = ', importCode).done()
			}
		}
		
		if importAll {
			let variables = []
			
			for name, variable of exports {
				if variable.kind != VariableKind::TypeAlias {
					variables.push(name)
					
					if variable.sealed {
						variable.sealed.name = '__ks_' + name
						
						variables.push(variable.sealed.name)
					}
				}
			}
			
			if variables.length == 1 {
				fragments
					.newLine()
					.code('var ', variables[0], ' = ', importCode, '.' + variables[0])
					.done()
			}
			else if variables.length > 0 {
				if node._options.format.destructuring == 'es5' {
					if importCodeVariable {
						let line = fragments.newLine().code('var ')
						
						for name, i in variables {
							if i > 0 {
								line.code(', ')
							}
							
							line.code(`\(name) = \(importCode).\(name)`)
						}
						
						line.done()
					}
					else {
						fragments.line(`var __ks__ = \(importCode)`)
						
						let line = fragments.newLine().code('var ')
						
						for name, i in variables {
							if i > 0 {
								line.code(', ')
							}
							
							line.code(`\(name) = __ks__.\(name)`)
						}
						
						line.done()
					}
				}
				else {
					let line = fragments.newLine().code('var {')
					
					for name, i in variables {
						if i > 0 {
							line.code(', ')
						}
						
						line.code(name)
					}
					
					line.code('} = ', importCode).done()
				}
			}
		}
		
		if importAlias.length {
			fragments.newLine().code('var ', importAlias, ' = ', importCode).done()
		}
		
		node.scope().releaseTempName(importCode)
	} // }}}
	toNodeFileFragments(node, fragments, data, metadata) { // {{{
		let moduleName = metadata.moduleName
		
		if metadata.wilcard? {
			fragments.line('var ', metadata.wilcard, ' = require(', $quote(moduleName), ')')
		}
		
		let variables = metadata.variables
		let count = metadata.count
		
		if count == 1 {
			let alias
			for alias of variables {
			}
			
			fragments.line('var ', variables[alias], ' = require(', $quote(moduleName), ').', alias)
		}
		else if count > 0 {
			if node._options.format.destructuring == 'es5' {
				fragments.line('var __ks__ = require(', $quote(moduleName), ')')
				
				let line = fragments.newLine().code('var ')
				
				let nf = false
				for name, alias of variables {
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
				for alias of variables {
					if nf {
						line.code(', ')
					}
					else {
						nf = true
					}
					
					if variables[alias] == alias {
						line.code(alias)
					}
					else {
						line.code(alias, ': ', variables[alias])
					}
				}
				
				line.code('} = require(', $quote(moduleName), ')')
				
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
		for declarator in this._data.declarations {
			this._declarators.push(declarator = new ImportDeclarator(declarator, this))
			
			declarator.analyse()
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for declarator in this._declarators {
			declarator.toFragments(fragments, mode)
		}
	} // }}}
}

class ImportDeclarator extends Statement {
	private {
		_metadata
		_kind
	}
	analyse() { // {{{
		$import.resolve(this._data, this.directory(), this.module(), this)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if this._kind == ImportKind::KSFile {
			$import.toKSFileFragments(this, fragments, this._data, this._metadata)
		}
		else if this._kind == ImportKind::NodeFile {
			$import.toNodeFileFragments(this, fragments, this._data, this._metadata)
		}
		else {
			$throw('Not Implemented', this)
		}
	} // }}}
}