extern process, require

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
	addVariable(module, file = null, node, name, variable, data) { // {{{
		if variable.requirement? && data.references? {
			let nf = true
			for reference in data.references while nf {
				if (reference.foreign? && reference.foreign.name == variable.requirement) || reference.alias.name == variable.requirement {
					nf = false
					
					variable = $variable.merge(node.scope().getVariable(reference.alias.name), variable)
				}
			}
		}
		
		variable.immutable = true
		
		node.scope().addVariable(name, variable)
		
		module.import(name, file)
	} // }}}
	define(module, file = null, node, name, kind, type = null) { // {{{
		$variable.define(node, node.scope(), name, true, kind, type)
		
		module.import(name.name || name, file)
	} // }}}
	loadCoreModule(x, module, data, node) { // {{{
		if $nodeModules[x] {
			return $import.loadNodeFile(null, x, module, data, node)
		}
		
		return null
	}, // }}}
	loadDirectory(x, moduleName = null, module, data, node) { // {{{
		let pkgfile = path.join(x, 'package.json')
		if fs.isFile(pkgfile) {
			let pkg
			try {
				pkg = JSON.parse(fs.readFile(pkgfile))
			}
			
			if pkg? {
				let metadata
				if pkg.kaoscript && (metadata ?= $import.loadKSFile(path.join(x, pkg.kaoscript.main), moduleName, module, data, node)) {
					return metadata
				}
				else if pkg.main && ((metadata ?= $import.loadFile(path.join(x, pkg.main), moduleName, module, data, node)) || (metadata ?= $import.loadDirectory(path.join(x, pkg.main), moduleName, module, data, node))) {
					return metadata
				}
			}
		}
		
		return $import.loadFile(path.join(x, 'index'), moduleName, module, data, node)
	} // }}}
	loadFile(x, moduleName = null, module, data, node) { // {{{
		if fs.isFile(x) {
			if x.endsWith($extensions.source) {
				return $import.loadKSFile(x, moduleName, module, data, node)
			}
			else {
				return $import.loadNodeFile(x, moduleName, module, data, node)
			}
		}
		
		if fs.isFile(x + $extensions.source) {
			return $import.loadKSFile(x + $extensions.source, moduleName!= null ? moduleName + $extensions.source : moduleName, module, data, node)
		}
		else {
			for ext of require.extensions {
				if fs.isFile(x + ext) {
					return $import.loadNodeFile(x, moduleName, module, data, node)
				}
			}
		}
		
		return null
	} // }}}
	loadKSFile(x, moduleName = null, module, data, node) { // {{{
		moduleName ??= module.path(x, data.module)
		
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
			if specifier.kind == NodeKind::ImportWildcardSpecifier {
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
				SyntaxException.throwMissingRequirement(name, node) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
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
						SyntaxException.throwMissingRequirement(name, node)
					}
				}
			}
		}
		
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			ReferenceException.throwNotDefinedInModule(name, data.module, node) unless variable ?= exports[name]
			
			$import.addVariable(module, moduleName, node, alias, variable, data)
		}
		else if importVarCount {
			nf = false
			for name, alias of importVariables {
				ReferenceException.throwNotDefinedInModule(name, data.module, node) unless variable ?= exports[name]
				
				$import.addVariable(module, moduleName, node, alias, variable, data)
			}
		}
		
		if importAll {
			for name, variable of exports {
				$import.addVariable(module, moduleName, node, name, variable, data)
			}
		}
		
		if importAlias.length {
			type = {
				typeName: {
					kind: NodeKind::Identifier
					name: 'Object'
				}
				properties: {}
			}
			
			for name, variable of exports {
				type.properties[name] = variable
			}
			
			variable = $variable.define(node, node.scope(), {
				kind: NodeKind::Identifier
				name: importAlias
			}, true, VariableKind::Variable, type)
			
			module.import(importAlias, moduleName)
		}
		
		return {
			kind: ImportKind::KSFile
			moduleName: moduleName
			exports: exports
			requirements: requirements
			importVariables: importVariables
			importVarCount: importVarCount
			importAll: importAll
			importAlias: importAlias
		}
	} // }}}
	loadNodeFile(x = null, moduleName = null, module, data, node) { // {{{
		let file = null
		if !moduleName {
			file = moduleName = module.path(x, data.module)
		}
		
		let metadata = {
			kind: ImportKind::NodeFile
			moduleName: moduleName
		}
		
		let variables = metadata.variables = {}
		let count = 0
		
		for specifier in data.specifiers {
			if specifier.kind == NodeKind::ImportWildcardSpecifier {
				if specifier.local {
					metadata.wilcard = specifier.local.name
					
					$import.define(module, file, node, specifier.local, VariableKind::Variable)
				}
				else {
					SyntaxException.throwExclusiveWildcardImport(node)
				}
			}
			else {
				variables[specifier.alias.name] = specifier.local ? specifier.local.name : specifier.alias.name
				++count
			}
		}
		
		metadata.count = count
		
		for alias of variables {
			$import.define(module, file, node, variables[alias], VariableKind::Variable)
		}
		
		return metadata
	} // }}}
	loadNodeModule(x, start, module, data, node) { // {{{
		let dirs = $import.nodeModulesPaths(start)
		
		let file, metadata
		for dir in dirs {
			file = path.join(dir, x)
			
			if (metadata ?= $import.loadFile(file, x, module, data, node)) || (metadata ?= $import.loadDirectory(file, x, module, data, node)) {
				return metadata
			}
		}
		
		return null
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
		
		let metadata
		if /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/.test(x) {
			x = fs.resolve(y, x)
			
			if (metadata ?= $import.loadFile(x, null, module, data, node)) || (metadata ?= $import.loadDirectory(x, null, module, data, node)) {
				return metadata
			}
		}
		else {
			if (metadata ?= $import.loadNodeModule(x, y, module, data, node)) || (metadata ?= $import.loadCoreModule(x, module, data, node)) {
				return metadata
			}
		}
		
		IOException.throwNotFoundModule(x, y, node)
	} // }}}
	use(data, node) { // {{{
		if data is Array {
			for item in data {
				ReferenceException.throwNotDefined(item.name, node) if item.kind == NodeKind::Identifier && !node.scope().hasVariable(item.name)
			}
		}
		else if data.kind == NodeKind::Identifier {
			ReferenceException.throwNotDefined(data.name, node) if !node.scope().hasVariable(data.name)
		}
	} // }}}
	toKSFileFragments(fragments, metadata, data, node) { // {{{
		let {moduleName, exports, requirements, importVariables, importVarCount, importAll, importAlias} = metadata
		
		let name, alias, variable, importCode
		let importCodeVariable = false
		
		if (importVarCount && importAll) || (importVarCount && importAlias.length) || (importAll && importAlias.length) {
			importCode = node._scope.acquireTempName()
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
						SyntaxException.throwMissingRequirement(name, node)
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
				SyntaxException.throwMissingRequirement(name, node) if !requirement.nullable && (!?data.references || data.references.length == 0)
				
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
						SyntaxException.throwMissingRequirement(name, node)
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
		
		node._scope.releaseTempName(importCode)
	} // }}}
	toNodeFileFragments(fragments, metadata, data, node) { // {{{
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
		for declarator in @data.declarations {
			@declarators.push(declarator = new ImportDeclarator(declarator, this))
			
			declarator.analyse()
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		for declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} // }}}
}

class ImportDeclarator extends Statement {
	private {
		_metadata
	}
	analyse() { // {{{
		@metadata = $import.resolve(@data, this.directory(), this.module(), this)
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		if @metadata.kind == ImportKind::KSFile {
			$import.toKSFileFragments(fragments, @metadata, @data, this)
		}
		else {
			$import.toNodeFileFragments(fragments, @metadata, @data, this)
		}
	} // }}}
}