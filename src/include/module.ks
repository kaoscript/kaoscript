export class Module {
	private {
		_binary		: Boolean	= false
		_body
		_compiler	: Compiler
		_data
		_directory
		_dynamicRequirements	= []
		_exportSource			= []
		_exportMeta				= {}
		_file
		_flags					= {}
		_hashes					= {}
		_imports				= {}
		_includes				= {}
		_options
		_output
		_references				= {}
		_register				= false
		_requirements			= {}
		_rewire
	}
	$create(data, @compiler, @file) { // {{{
		try {
			@data = @parse(data, file)
		}
		catch error {
			error.filename = file
			
			throw error
		}
		
		@directory = path.dirname(file)
		@options = $attribute.apply(@data, @compiler._options.config)
		
		for attr in @data.attributes {
			if attr.declaration.kind == NodeKind::Identifier &&	attr.declaration.name == 'bin' {
				@binary = true
			}
			else if attr.declaration.kind == NodeKind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				for arg in attr.declaration.arguments {
					if arg.kind == NodeKind::AttributeOperator {
						@options[arg.name.name] = arg.value.value
					}
				}
			}
		}
		
		if @compiler._options.output {
			@output = @compiler._options.output
		
			if @compiler._options.rewire is Array {
				@rewire = @compiler._options.rewire
			}
			else {
				@rewire = []
			}
		}
		else {
			@output = null
		}
		
		@hashes['.'] = @compiler.sha256(file, data)
	} // }}}
	addHash(file, hash) { // {{{
		this._hashes[path.relative(this._directory, file)] = hash
	} // }}}
	addHashes(file, hashes) { // {{{
		let root = path.dirname(file)
		
		for name, hash of hashes {
			if name == '.' {
				this._hashes[path.relative(this._directory, file)] = hash
			}
			else {
				this._hashes[path.relative(this._directory, path.join(root, name))] = hash
			}
		}
	} // }}}
	addInclude(path) { // {{{
		this._includes[path] = true
	} // }}}
	addReference(key, code) { // {{{
		if this._references[key] {
			this._references[key].push(code)
		}
		else {
			this._references[key] = [code]
		}
		
		return this
	} // }}}
	analyse() { // {{{
		@body = new ModuleBlock(@data, this)
		
		@body.analyse()
	} // }}}
	compiler() => this._compiler
	directory() => this._directory
	export(name, alias = false) { // {{{
		if this._binary {
			SyntaxException.throwNotBinary('export', this)
		}
		
		let variable = this._body.scope().getVariable(name.name)
		
		ReferenceException.throwNotDefined(name.name, this) unless variable
		
		if variable.kind != VariableKind::TypeAlias {
			if alias {
				this._exportSource.push(`\(alias.name): \(name.name)`)
			}
			else {
				this._exportSource.push(`\(name.name): \(name.name)`)
			}
			
			if variable.sealed {
				if alias {
					this._exportSource.push(`__ks_\(alias.name): \(variable.sealed.name)`)
				}
				else {
					this._exportSource.push(`__ks_\(name.name): \(variable.sealed.name)`)
				}
			}
		}
		
		if alias {
			this._exportMeta[alias.name] = variable
		}
		else {
			this._exportMeta[name.name] = variable
		}
	} // }}}
	file() => this._file
	flag(name) { // {{{
		this._flags[name] = true
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	hasInclude(path) { // {{{
		return this._includes?[path]
	} // }}}
	import(name, file?) { // {{{
		this._imports[name] = true
		
		if file && file.slice(-$extensions.source.length).toLowerCase() == $extensions.source {
			this._register = true
		}
	} // }}}
	isUpToDate(file, target, data) { // {{{
		let hashes
		try {
			hashes = JSON.parse(fs.readFile(getHashPath(file, target)))
		}
		catch {
			return null
		}
		
		let root = path.dirname(file)
		
		for name, hash of hashes {
			if name == '.' {
				return null if this._compiler.sha256(file, data) != hash
			}
			else {
				return null if this._compiler.sha256(path.join(root, name)) != hash
			}
		}
		
		return hashes
	} // }}}
	listReferences(key) { // {{{
		if this._references[key] {
			let references = this._references[key]
			
			this._references[key] = null
			
			return references
		}
		else {
			return null
		}
	} // }}}
	parse(data, file) => parse(data)
	path(x?, name) { // {{{
		if !?x || !?this._output {
			return name
		}
		
		let output = null
		for rewire in this._rewire {
			if rewire.input == x {
				output = path.relative(this._output, rewire.output)
				break
			}
		}
		
		if !?output {
			output = path.relative(this._output, x)
		}
		
		if output[0] != '.' {
			output = './' + output
		}
		
		return output
	} // }}}
	require(variable, kind, data?) { // {{{
		if this._binary {
			SyntaxException.throwNotBinary('require', this)
		}
		
		if kind == RequireKind::Require {
			this._requirements[variable.requirement] = {
				kind: kind
				name: variable.requirement
				extendable: variable.kind == VariableKind::Class || variable.sealed
			}
		}
		else {
			let requirement = {
				kind: kind
				name: variable.requirement
				extendable: variable.kind == VariableKind::Class || variable.sealed
				parameter: this._body.scope().acquireTempName()
			}
			
			if data? {
				for name of data {
					requirement[name] = data[name]
				}
			}
			
			this._requirements[requirement.parameter] = requirement
			
			this._dynamicRequirements.push(requirement)
		}
	} // }}}
	toHashes() => this._hashes
	toFragments() { // {{{
		let builder = new FragmentBuilder(this._binary ? 0 : 1)
		
		this._body.toFragments(builder)
		
		let fragments: Array = []
		
		if this._options.header {
			fragments.push($code(`// Generated by kaoscript \(metadata.version)\n`))
		}
		
		if this._register && this._compiler._options.register {
			fragments.push($code('require("kaoscript/register");\n'))
		}
		
		let helper = $runtime.helper(this)
		let type = $runtime.type(this)
		
		let hasHelper = !this._flags.Helper || this._requirements[helper] || this._imports[helper]
		let hasType = !this._flags.Type || this._requirements[type] || this._imports[type]
		
		if !hasHelper || !hasType {
			if hasHelper {
				fragments.push($code('var ' + type + ' = require("' + $runtime.package(this) + '").Type;\n'))
			}
			else if hasType {
				fragments.push($code('var ' + helper + ' = require("' + $runtime.package(this) + '").Helper;\n'))
			}
			else if this._options.format.destructuring == 'es5' {
				fragments.push($code(`var __ks__ = require("\($runtime.package(this))");\n`))
				fragments.push($code(`var \(helper) = __ks__.Helper, \(type) = __ks__.Type;\n`))
			}
			else {
				helper = `Helper: \(helper)` unless helper == 'Helper'
				type = `Type: \(type)` unless type == 'Type'
				
				fragments.push($code(`var {\(helper), \(type)} = require("\($runtime.package(this))");\n`))
			}
		}
		
		if this._binary {
			fragments.append(builder.toArray())
		}
		else {
			if this._dynamicRequirements.length {
				fragments.push($code('function __ks_require('))
				
				for requirement, i in this._dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
					fragments.push($code(requirement.parameter))
					
					if requirement.extendable {
						fragments.push($code(', __ks_' + requirement.parameter))
					}
				}
				
				fragments.push($code(') {\n'))
				
				if this._dynamicRequirements.length == 1 {
					requirement = this._dynamicRequirements[0]
					
					switch requirement.kind {
						RequireKind::ExternOrRequire => {
							fragments.push($code('\tif(Type.isValue(' + requirement.name + ')) {\n'))
							
							if requirement.extendable {
								fragments.push($code('\t\treturn [' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treturn [' + requirement.parameter + ', __ks_' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
							}
							else {
								fragments.push($code('\t\treturn [' + requirement.name + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treturn [' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
							}
						}
						RequireKind::RequireOrExtern => {
							fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
							
							if requirement.extendable {
								fragments.push($code('\t\treturn [' + requirement.parameter + ', __ks_' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treturn [' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + '];\n'))
								fragments.push($code('\t}\n'))
							}
							else {
								fragments.push($code('\t\treturn [' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								fragments.push($code('\t\treturn [' + requirement.name + '];\n'))
								fragments.push($code('\t}\n'))
							}
						}
						RequireKind::RequireOrImport => {
							fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
							
							if requirement.extendable {
								fragments.push($code('\t\treturn [' + requirement.parameter + ', __ks_' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								
								const builder = new FragmentBuilder(2)
								
								if requirement.metadata.kind == ImportKind::KSFile {
									$import.toKSFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
								}
								else {
									$import.toNodeFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
								}
								
								fragments.append(builder.toArray())
								
								fragments.push($code('\t\treturn [' + requirement.name + ', __ks_' + requirement.name + '];\n'))
								
								fragments.push($code('\t}\n'))
							}
							else {
								fragments.push($code('\t\treturn [' + requirement.parameter + '];\n'))
								fragments.push($code('\t}\n'))
								fragments.push($code('\telse {\n'))
								
								const builder = new FragmentBuilder(2)
								
								if requirement.metadata.kind == ImportKind::KSFile {
									$import.toKSFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
								}
								else {
									$import.toNodeFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
								}
								
								fragments.push($code('\t\treturn [' + requirement.name + '];\n'))
								
								fragments.push($code('\t}\n'))
							}
						}
					}
				}
				else {
					fragments.push($code('\tvar req = [];\n'))
					
					for requirement in this._dynamicRequirements {
						switch requirement.kind {
							RequireKind::ExternOrRequire => {
								fragments.push($code('\tif(Type.isValue(' + requirement.name + ')) {\n'))
								
								if requirement.extendable {
									fragments.push($code('\t\treq.push(' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									fragments.push($code('\t\treq.push(' + requirement.parameter + ', __ks_' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
								}
								else {
									fragments.push($code('\t\treq.push(' + requirement.name + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									fragments.push($code('\t\treq.push(' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
								}
							}
							RequireKind::RequireOrExtern => {
								fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
								
								if requirement.extendable {
									fragments.push($code('\t\treq.push(' + requirement.parameter + ', __ks_' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									fragments.push($code('\t\treq.push(' + requirement.name + ', typeof __ks_' + requirement.name + ' === "undefined" ? {} : __ks_' + requirement.name + ');\n'))
									fragments.push($code('\t}\n'))
								}
								else {
									fragments.push($code('\t\treq.push(' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									fragments.push($code('\t\treq.push(' + requirement.name + ');\n'))
									fragments.push($code('\t}\n'))
								}
							}
							RequireKind::RequireOrImport => {
								fragments.push($code('\tif(Type.isValue(' + requirement.parameter + ')) {\n'))
								
								if requirement.extendable {
									fragments.push($code('\t\treq.push(' + requirement.parameter + ', __ks_' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									
									const builder = new FragmentBuilder(2)
									
									if requirement.metadata.kind == ImportKind::KSFile {
										$import.toKSFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
									}
									else {
										$import.toNodeFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
									}
									
									fragments.append(builder.toArray())
									
									fragments.push($code('\t\treq.push(' + requirement.name + ', __ks_' + requirement.name + ');\n'))
									
									fragments.push($code('\t}\n'))
								}
								else {
									fragments.push($code('\t\treq.push(' + requirement.parameter + ');\n'))
									fragments.push($code('\t}\n'))
									fragments.push($code('\telse {\n'))
									
									const builder = new FragmentBuilder(2)
									
									if requirement.metadata.kind == ImportKind::KSFile {
										$import.toKSFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
									}
									else {
										$import.toNodeFileFragments(builder, requirement.metadata, requirement.data, requirement.node)
									}
									
									fragments.push($code('\t\treq.push(' + requirement.name + ');\n'))
									
									fragments.push($code('\t}\n'))
								}
							}
						}
					}
					
					fragments.push($code('\treturn req;\n'))
				}
				
				fragments.push($code('}\n'))
			}
			
			fragments.push($code('module.exports = function('))
			
			let nf = false
			for name of this._requirements {
				if nf {
					fragments.push($comma)
				}
				else {
					nf = true
				}
				
				fragments.push($code(name))
				
				if this._requirements[name].extendable {
					fragments.push($code(', __ks_' + name))
				}
			}
			
			fragments.push($code(') {\n'))
			
			if this._dynamicRequirements.length {
				if this._options.format.destructuring == 'es5' {
					fragments.push($code('\tvar __ks__ = __ks_require('))
					
					for requirement, i in this._dynamicRequirements {
						if i {
							fragments.push($comma)
						}
						
						fragments.push($code(requirement.parameter))
						
						if requirement.extendable {
							fragments.push($code(', __ks_' + requirement.parameter))
						}
					}
					
					fragments.push($code(');\n'))
					
					fragments.push($code('\tvar '))
					
					let i = -1
					for requirement in this._dynamicRequirements {
						fragments.push($comma) if i != -1
						
						fragments.push($code(`\(requirement.name) = __ks__[\(++i)]`))
						
						if requirement.extendable {
							fragments.push($code(`, __ks_\(requirement.name) = __ks__[\(++i)]`))
						}
					}
					
					fragments.push($code(';\n'))
				}
				else {
					fragments.push($code('\tvar ['))
					
					for requirement, i in this._dynamicRequirements {
						fragments.push($comma) if i != 0
						
						fragments.push($code(requirement.name))
						
						if requirement.extendable {
							fragments.push($code(', __ks_' + requirement.name))
						}
					}
					
					fragments.push($code('] = __ks_require('))
					
					for requirement, i in this._dynamicRequirements {
						if i {
							fragments.push($comma)
						}
						
						fragments.push($code(requirement.parameter))
						
						if requirement.extendable {
							fragments.push($code(', __ks_' + requirement.parameter))
						}
					}
					
					fragments.push($code(');\n'))
				}
			}
			
			fragments.append(builder.toArray())
			
			if this._exportSource.length {
				fragments.push($code('\treturn {'))
				
				nf = false
				for src in this._exportSource {
					if nf {
						fragments.push($code(','))
					}
					else {
						nf = true
					}
					
					fragments.push($code('\n\t\t' + src))
				}
				
				fragments.push($code('\n\t};\n'))
			}
			
			fragments.push($code('}\n'))
		}
		
		return fragments
	} // }}}
	toMetadata() { // {{{
		let data = {
			requirements: {},
			exports: {}
		}
		
		for name, variable of this._requirements {
			if variable.parameter {
				if variable.extendable {
					data.requirements[variable.name] = {
						class: true
						nullable: true
					}
				}
				else {
					data.requirements[variable.name] = {
						nullable: true
					}
				}
			}
			else {
				if variable.extendable {
					data.requirements[name] = {
						class: true
					}
				}
				else {
					data.requirements[name] = {}
				}
			}
		}
		
		let d
		for name, variable of this._exportMeta {
			d = {}
			
			for n of variable {
				if n == 'name' {
					d[n] = variable[n].name || variable[n]
				}
				else if !(n == 'accessPath') {
					d[n] = variable[n]
				}
			}
			
			data.exports[name] = d
		}
		
		return data
	} // }}}
}

class ModuleBlock extends AbstractNode {
	private {
		_body: Array		= []
		_module
	}
	$create(data, @module) { // {{{
		this._data = data
		this._options = $attribute.apply(data, module._options)
		this._scope = new Scope()
	} // }}}
	analyse() { // {{{
		for statement in this._data.body {
			if statement ?= $compile.statement(statement, this) {
				this._body.push(statement)
				
				statement.analyse()
			}
		}
	} // }}}
	directory() => this._module.directory()
	file() => this._module.file()
	fuse() { // {{{
		for statement in this._body {
			statement.fuse()
		}
	} // }}}
	isConsumedError(name, variable): Boolean => false
	module() => this._module
	toFragments(fragments) { // {{{
		for statement in this._body {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
}