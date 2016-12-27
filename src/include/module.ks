class Module {
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
			this._data = parse(data)
		}
		catch error {
			error.filename = file
			
			throw error
		}
		
		this._directory = path.dirname(file)
		this._options = $applyAttributes(this._data, this._compiler._options.config)
		
		for attr in this._data.attributes {
			if attr.declaration.kind == Kind::Identifier &&	attr.declaration.name == 'bin' {
				this._binary = true
			}
			else if attr.declaration.kind == Kind::AttributeExpression && attr.declaration.name.name == 'cfg' {
				for arg in attr.declaration.arguments {
					if arg.kind == Kind::AttributeOperator {
						this._options[arg.name.name] = arg.value.value
					}
				}
			}
		}
		
		this._body = new ModuleBlock(this._data, this)
		
		if this._compiler._options.output {
			this._output = this._compiler._options.output
		
			if this._compiler._options.rewire is Array {
				this._rewire = this._compiler._options.rewire
			}
			else {
				this._rewire = []
			}
		}
		else {
			this._output = null
		}
		
		this._hashes['.'] = this._compiler.sha256(file, data)
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
		this._body.analyse()
	} // }}}
	compiler() => this._compiler
	directory() => this._directory
	export(name, alias = false) { // {{{
		$throw('Binary file can\'t export', this) if this._binary
		
		let variable = this._body.scope().getVariable(name.name)
		
		$throw(`Undefined variable \(name.name)`, this) unless variable
		
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
	isUpToDate(file, data) { // {{{
		let hashes
		try {
			hashes = JSON.parse(fs.readFile(fs.hidden(file, $extensions.hash)))
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
	path(x?, name) { // {{{
		if !x || !this._output {
			return name
		}
		
		let output = null
		for rewire in this._rewire {
			if rewire.input == x {
				output = path.relative(this._output, rewire.output)
				break
			}
		}
		
		if !output {
			output = path.relative(this._output, x)
		}
		
		if output[0] != '.' {
			output = './' + output
		}
		
		return output
	} // }}}
	require(variable) { // {{{
		if this._binary {
			$throw('Binary file can\'t require', this)
		}
		
		this._requirements[variable.requirement] = {
			name: variable.requirement
			extendable: variable.kind == VariableKind::Class || variable.sealed
			requireFirst: false
		}
	} // }}}
	require(variable, requireFirst) { // {{{
		if this._binary {
			$throw('Binary file can\'t require', this)
		}
		
		let requirement = {
			name: variable.requirement
			extendable: variable.kind == VariableKind::Class || variable.sealed
			parameter: this._body.scope().acquireTempName()
			requireFirst: requireFirst
		}
		
		this._requirements[requirement.parameter] = requirement
		
		this._dynamicRequirements.push(requirement)
	} // }}}
	toHashes() => this._hashes
	toFragments() { // {{{
		let builder = new FragmentBuilder(this._binary ? 0 : 1)
		
		this._body.toFragments(builder)
		
		let fragments: Array = []
		
		if this._options.header {
			fragments.push($code(`// Generated by kaoscript \(metadata.version)\n`))
		}
		
		if this._register && this._options.register {
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
			else {
				helper = `Helper: \(helper)` unless helper == 'Helper'
				type = `Type: \(type)` unless type == 'Type'
				
				fragments.push($code('var {' + helper + ', ' + type + '} = require("' + $runtime.package(this) + '");\n'))
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
					
					if requirement.requireFirst {
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
					else {
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
				}
				else {
					fragments.push($code('\tvar req = [];\n'))
					
					for requirement in this._dynamicRequirements {
						if requirement.requireFirst {
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
						else {
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
				fragments.push($code('\tvar ['))
				
				for requirement, i in this._dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
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
		this._options = $applyAttributes(data, module._options)
		this._scope = new Scope()
	} // }}}
	analyse() { // {{{
		for statement in this._data.body {
			this._body.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
		}
	} // }}}
	directory() => this._module.directory()
	file() => this._module.file()
	fuse() { // {{{
		for statement in this._body {
			statement.fuse()
		}
	} // }}}
	module() => this._module
	toFragments(fragments) { // {{{
		for statement in this._body {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
}