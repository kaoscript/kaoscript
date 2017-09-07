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
	addVariable(name: String, type: Type, node: AbstractNode, module, file: String = null) { // {{{
		if variable ?= node.scope().getVariable(name) {
			if variable.type().isCompatible(type) {
				/* variable.type().merge(type) */
				throw new NotImplementedException(node)
			}
			else {
				SyntaxException.throwAlreadyDeclared(name, node)
			}
		}
		else {
			node.scope().define(name, true, type, node)
		}
		
		module.import(name, file)
	} // }}}
	define(name: String, type: Type?, node: AbstractNode, module, file: String = null) { // {{{
		node.scope().define(name, true, type, node)
		
		module.import(name, file)
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
		moduleName ??= module.path(x, data.source.value)
		
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
		
		let importVariables = {}
		let importVarCount = 0
		let importAll = false
		let importAlias = ''
		
		if data.specifiers.length == 0 {
			importAll = true
		}
		else {
			for specifier in data.specifiers {
				if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					importAlias = specifier.local.name
				}
				else {
					if specifier.imported.kind == NodeKind::Identifier {
						importVariables[specifier.imported.name] = specifier.local.name
					}
					else {
						importVariables[specifier.imported.name.name] = specifier.local.name
					}
					
					++importVarCount
				}
			}
		}
		
		if data.arguments?.length != 0 {
			for argument in data.arguments {
				if argument.kind == NodeKind::NamedArgument {
					$import.use(argument.value, node)
				}
				else {
					$import.use(argument, node)
				}
			}
			
			let nf
			for name, requirement of metadata.requirements {
				nf = true
				
				for argument in data.arguments while nf {
					if argument.kind == NodeKind::NamedArgument {
						if argument.name.name == name {
							nf = false
						}
					}
					else {
						if argument.name == name {
							nf = false
						}
					}
				}
				
				unless !nf || requirement.nullable {
					SyntaxException.throwMissingRequirement(name, node)
				}
			}
		}
		else {
			for name, requirement of metadata.requirements {
				unless requirement.nullable {
					SyntaxException.throwMissingRequirement(name, node)
				}
			}
		}
		
		const domain = new ImportDomain(metadata, node)
		const variables = []
		
		if importAll {
			for i from 1 til metadata.exports.length by 2 {
				name = metadata.exports[i]
				
				$import.addVariable(name, domain.commit(name), node, module, moduleName)
				
				variables.push(name)
			}
		}
		
		for name, alias of importVariables {
			if !domain.hasTemporary(name) {
				ReferenceException.throwNotDefinedInModule(name, data.source.value, node)
			}
			
			$import.addVariable(alias, domain.commit(name, alias), node, module, moduleName)
		}
		
		if importAlias.length != 0 {
			const type = new NamespaceType(importAlias, node.scope())
			const ref = type.reference()
			
			for i from 1 til metadata.exports.length by 2 {
				name = metadata.exports[i]
				
				if domain.hasVariable(name) {
					type.addProperty(name, domain.getVariable(name))
				}
				else {
					type.addProperty(name, domain.commit(name).namespace(ref))
				}
			}
			
			$import.define(importAlias, type, node, module, moduleName)
		}
		
		domain.commit()
		
		return {
			kind: ImportKind::KSFile
			moduleName: moduleName
			exports: variables
			requirements: metadata.requirements
			importVariables: importVariables
			importVarCount: importVarCount
			importAll: importAll
			importAlias: importAlias
		}
	} // }}}
	loadNodeFile(x = null, moduleName = null, module, data, node) { // {{{
		let file = null
		if moduleName == null {
			file = moduleName = module.path(x, data.source.value)
		}
		
		if data.arguments?.length != 0 {
			for argument in data.arguments {
				if argument.kind == NodeKind::NamedArgument {
					SyntaxException.throwInvalidNamedArgument(argument.name.name, node)
				}
				else {
					$import.use(argument, node)
				}
			}
		}
		
		let metadata = {
			kind: ImportKind::NodeFile
			moduleName: moduleName
		}
		
		if data.specifiers.length == 0 {
			metadata.variables = {}
			metadata.count = 0
			
			const parts = data.source.value.split('/')
			for i from 0 til parts.length {
				if !/(?:^\.+$|^@)/.test(parts[i]) {
					metadata.wilcard = parts[i].split('.')[0]
					
					break
				}
			}
			
			if metadata.wilcard? {
				$import.define(metadata.wilcard, null, node, module, file)
			}
			else {
				SyntaxException.throwUnnamedWildcardImport(node)
			}
		}
		else {
			let variables = {}
			let count = 0
			let type
			
			for specifier in data.specifiers {
				if specifier.kind == NodeKind::ImportNamespaceSpecifier {
					metadata.wilcard = specifier.local.name
					
					if specifier.specifiers?.length != 0 {
						type = new NamespaceType(metadata.wilcard, node.scope().domain())
						
						for s in specifier.specifiers {
							if s.imported.kind == NodeKind::Identifier {
								type.addProperty(s.local.name, Type.Any)
							}
							else {
								type.addProperty(s.local.name, Type.fromAST(s.imported, node).alienize())
							}
						}
						
						$import.define(metadata.wilcard, type, node, module, file)
					}
					else {
						$import.define(metadata.wilcard, null, node, module, file)
					}
				}
				else {
					++count
					
					if specifier.imported.kind == NodeKind::Identifier {
						variables[specifier.imported.name] = specifier.local.name
						
						$import.define(variables[specifier.imported.name], null, node, module, file)
					}
					else {
						variables[specifier.imported.name.name] = specifier.local.name
						
						type = Type.fromAST(specifier.imported, node).alienize()
						
						$import.define(variables[specifier.imported.name.name], type, node, module, file)
					}
				}
			}
			
			metadata.variables = variables
			metadata.count = count
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
		let x = data.source.value
		
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
				if item.kind == NodeKind::Identifier && !node.scope().hasVariable(item.name) {
					ReferenceException.throwNotDefined(item.name, node)
				}
			}
		}
		else if data.kind == NodeKind::Identifier {
			unless node.scope().hasVariable(data.name) {
				ReferenceException.throwNotDefined(data.name, node)
			}
		}
	} // }}}
	toKSFileFragments(fragments, metadata, data, node) { // {{{
		const {moduleName, exports, requirements, importVariables, importVarCount, importAll, importAlias} = metadata
		
		let importCode = 'require(' + $quote(moduleName) + ')('
		let importCodeVariable = false
		
		if data.arguments?.length != 0 {
			let first = true
			let nf
			
			for name, requirement of requirements {
				if first {
					first = false
				}
				else {
					importCode += ', '
				}
				
				nf = true
				
				for argument in data.arguments while nf {
					if argument.kind == NodeKind::NamedArgument {
						if argument.name.name == name {
							importCode += argument.value.name
							
							if requirement.class {
								importCode += `, __ks_\(argument.value.name)`
							}
							
							nf = false
						}
					}
					else {
						if argument.name == name {
							importCode += name
							
							if requirement.class {
								importCode += `, __ks_\(name)`
							}
							
							nf = false
						}
					}
				}
				
				if nf {
					if requirement.class {
						importCode += 'null, null'
					}
					else {
						importCode += 'null'
					}
				}
			}
		}
		
		importCode += ')'
		
		if (importVarCount != 0 && importAll) || (importVarCount != 0 && importAlias.length != 0) || (importAll && importAlias.length != 0) {
			const variable = node._scope.acquireTempName()
			
			fragments.line(`var \(variable) = \(importCode)`)
			
			importCode = variable
			importCodeVariable = true
		}
		
		let name, alias, variable
		if importVarCount == 1 {
			for name, alias of importVariables {
			}
			
			if (variable = node.scope().getVariable(alias).type()) is not AliasType {
				if variable.isSealed() {
					fragments.newLine().code(`var {\(alias), __ks_\(alias)} = \(importCode)`).done()
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
						if node.scope().getVariable(alias).type() is not AliasType {
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
						if node.scope().getVariable(alias).type() is not AliasType {
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
					if (variable = node.scope().getVariable(alias).type()) is not AliasType {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}
						
						if alias == name {
							line.code(name)
							
							if variable.isSealed() {
								line.code(`, __ks_\(name)`)
							}
						}
						else {
							line.code(name, ': ', alias)
							
							if variable.isSealed() {
								line.code(`, __ks_\(alias)`)
							}
						}
					}
				}
				
				line.code('} = ', importCode).done()
			}
		}
		
		if importAll {
			let variables = []
			
			for name in exports {
				if (variable = node.scope().getVariable(name).type()) is not AliasType {
					variables.push(name)
					
					if variable.isSealed() {
						variables.push(`__ks_\(name)`)
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
			const line = fragments
				.newLine()
				.code(`var \(metadata.wilcard) = require(\($quote(moduleName)))`)
			
			if data.arguments? {
				line.code('(')
				
				for argument, index in data.arguments {
					if index != 0 {
						line.code(', ')
					}
					
					line.code(argument.name)
				}
				
				line.code(')')
			}
			
			line.done()
		}
		
		let variables = metadata.variables
		let count = metadata.count
		
		if count == 1 {
			let alias
			for alias of variables {
			}
			
			const line = fragments
				.newLine()
				.code(`var \(variables[alias]) = require(\($quote(moduleName)))`)
			
			if data.arguments? {
				line.code('(')
				
				for argument, index in data.arguments {
					if index != 0 {
						line.code(', ')
					}
					
					line.code(argument.name)
				}
				
				line.code(')')
			}
			
			line.code(`.\(alias)`).done()
		}
		else if count > 0 {
			if node._options.format.destructuring == 'es5' {
				let line = fragments
					.newLine()
					.code(`var __ks__ = require(\($quote(moduleName)))`)
				
				if data.arguments? {
					line.code('(')
					
					for argument, index in data.arguments {
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
				
				if data.arguments? {
					line.code('(')
					
					for argument, index in data.arguments {
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