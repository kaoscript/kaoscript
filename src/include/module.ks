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
	constructor(data, @compiler, @file) { // {{{
		try {
			@data = @parse(data, file)
		}
		catch error {
			error.filename = file
			
			throw error
		}
		
		@directory = path.dirname(file)
		@options = Attribute.configure(@data, @compiler._options.config, AttributeTarget::Global)
		
		for attr in @data.attributes {
			if attr.declaration.kind == NodeKind::Identifier &&	attr.declaration.name == 'bin' {
				@binary = true
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
		@hashes[path.relative(@directory, file)] = hash
	} // }}}
	addHashes(file, hashes) { // {{{
		let root = path.dirname(file)
		
		for name, hash of hashes {
			if name == '.' {
				@hashes[path.relative(@directory, file)] = hash
			}
			else {
				@hashes[path.relative(@directory, path.join(root, name))] = hash
			}
		}
	} // }}}
	addInclude(path) { // {{{
		@includes[path] = true
	} // }}}
	addReference(key, code) { // {{{
		if @references[key] {
			@references[key].push(code)
		}
		else {
			@references[key] = [code]
		}
		
		return this
	} // }}}
	compile() { // {{{
		@body = new ModuleBlock(@data, this)
		
		@body.analyse()
		
		@body.prepare()
		
		@body.translate()
	} // }}}
	compiler() => @compiler
	directory() => @directory
	export(name, alias = false) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('export', this)
		}
		
		const variable = @body.scope().getVariable(name.name)
		
		ReferenceException.throwNotDefined(name.name, this) unless variable
		
		if variable.kind != VariableKind::TypeAlias {
			if alias {
				@exportSource.push(`\(alias.name): \(name.name)`)
			}
			else {
				@exportSource.push(`\(name.name): \(name.name)`)
			}
			
			if variable.sealed {
				if alias {
					@exportSource.push(`__ks_\(alias.name): \(variable.sealed.name)`)
				}
				else {
					@exportSource.push(`__ks_\(name.name): \(variable.sealed.name)`)
				}
			}
		}
		
		if alias {
			const export = Object.clone(variable)
			
			export.name = alias
			
			@exportMeta[alias.name] = export
		}
		else {
			@exportMeta[name.name] = variable
		}
	} // }}}
	file() => @file
	flag(name) { // {{{
		@flags[name] = true
	} // }}}
	hasInclude(path) { // {{{
		return @includes?[path]
	} // }}}
	import(name, file = null) { // {{{
		@imports[name] = true
		
		if file && file.slice(-$extensions.source.length).toLowerCase() == $extensions.source {
			@register = true
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
				return null if @compiler.sha256(file, data) != hash
			}
			else {
				return null if @compiler.sha256(path.join(root, name)) != hash
			}
		}
		
		return hashes
	} // }}}
	listReferences(key) { // {{{
		if @references[key] {
			let references = @references[key]
			
			@references[key] = null
			
			return references
		}
		else {
			return null
		}
	} // }}}
	parse(data, file) => parse(data)
	path(x = null, name) { // {{{
		if !?x || !?@output {
			return name
		}
		
		let output = null
		for rewire in @rewire {
			if rewire.input == x {
				output = path.relative(@output, rewire.output)
				break
			}
		}
		
		if !?output {
			output = path.relative(@output, x)
		}
		
		if output[0] != '.' {
			output = './' + output
		}
		
		return output
	} // }}}
	require(variable, kind, data = null) { // {{{
		if @binary {
			SyntaxException.throwNotBinary('require', this)
		}
		
		if kind == DependencyKind::Require {
			@requirements[variable.requirement] = {
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
				parameter: @body.scope().acquireTempName()
			}
			
			if data? {
				for name of data {
					requirement[name] = data[name]
				}
			}
			
			@requirements[requirement.parameter] = requirement
			
			@dynamicRequirements.push(requirement)
		}
	} // }}}
	toHashes() => @hashes
	toFragments() { // {{{
		let builder = new FragmentBuilder(@binary ? 0 : 1)
		
		@body.toFragments(builder)
		
		let fragments: Array = []
		
		if @options.header {
			fragments.push($code(`// Generated by kaoscript \(metadata.version)\n`))
		}
		
		if @register && @compiler._options.register {
			fragments.push($code('require("kaoscript/register");\n'))
		}
		
		let helper = $runtime.helper(this)
		let type = $runtime.type(this)
		
		let hasHelper = !@flags.Helper || @requirements[helper] || @imports[helper]
		let hasType = !@flags.Type || @requirements[type] || @imports[type]
		
		if !hasHelper || !hasType {
			if hasHelper {
				fragments.push($code(`var \(type) = require("\(@options.runtime.type.package)").\(@options.runtime.type.member);\n`))
			}
			else if hasType {
				fragments.push($code(`var \(helper) = require("\(@options.runtime.helper.package)").\(@options.runtime.helper.member);\n`))
			}
			else if @options.runtime.helper.package == @options.runtime.type.package {
				if @options.format.destructuring == 'es5' {
					fragments.push($code(`var __ks__ = require("\(@options.runtime.helper.package)");\n`))
					fragments.push($code(`var \(helper) = __ks__.\(@options.runtime.helper.member), \(type) = __ks__.\(@options.runtime.type.member);\n`))
				}
				else {
					helper = `\(@options.runtime.helper.member): \(helper)` unless helper == @options.runtime.helper.member
					type = `\(@options.runtime.type.member): \(type)` unless type == @options.runtime.type.member
					
					fragments.push($code(`var {\(helper), \(type)} = require("\(@options.runtime.helper.package)");\n`))
				}
			}
			else {
				fragments.push($code(`var \(helper) = require("\(@options.runtime.helper.package)").\(@options.runtime.helper.member);\n`))
				fragments.push($code(`var \(type) = require("\(@options.runtime.type.package)").\(@options.runtime.type.member);\n`))
			}
		}
		
		if @binary {
			fragments.append(builder.toArray())
		}
		else {
			if @dynamicRequirements.length {
				fragments.push($code('function __ks_require('))
				
				for requirement, i in @dynamicRequirements {
					if i {
						fragments.push($comma)
					}
					
					fragments.push($code(requirement.parameter))
					
					if requirement.extendable {
						fragments.push($code(', __ks_' + requirement.parameter))
					}
				}
				
				fragments.push($code(') {\n'))
				
				if @dynamicRequirements.length == 1 {
					requirement = @dynamicRequirements[0]
					
					switch requirement.kind {
						DependencyKind::ExternOrRequire => {
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
						DependencyKind::RequireOrExtern => {
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
						DependencyKind::RequireOrImport => {
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
					
					for requirement in @dynamicRequirements {
						switch requirement.kind {
							DependencyKind::ExternOrRequire => {
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
							DependencyKind::RequireOrExtern => {
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
							DependencyKind::RequireOrImport => {
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
			for name of @requirements {
				if nf {
					fragments.push($comma)
				}
				else {
					nf = true
				}
				
				fragments.push($code(name))
				
				if @requirements[name].extendable {
					fragments.push($code(', __ks_' + name))
				}
			}
			
			fragments.push($code(') {\n'))
			
			if @dynamicRequirements.length {
				if @options.format.destructuring == 'es5' {
					fragments.push($code('\tvar __ks__ = __ks_require('))
					
					for requirement, i in @dynamicRequirements {
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
					for requirement in @dynamicRequirements {
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
					
					for requirement, i in @dynamicRequirements {
						fragments.push($comma) if i != 0
						
						fragments.push($code(requirement.name))
						
						if requirement.extendable {
							fragments.push($code(', __ks_' + requirement.name))
						}
					}
					
					fragments.push($code('] = __ks_require('))
					
					for requirement, i in @dynamicRequirements {
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
			
			if @exportSource.length {
				fragments.push($code('\treturn {'))
				
				nf = false
				for src in @exportSource {
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
		
		for name, variable of @requirements {
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
		
		for name, variable of @exportMeta {
			data.exports[name] = $variable.export(variable)
		}
		
		return data
	} // }}}
}

class ModuleBlock extends AbstractNode {
	private {
		_body: Array		= []
		_module
	}
	constructor(@data, @module) { // {{{
		super()
		
		@options = module._options
		@scope = new Scope()
	} // }}}
	analyse() { // {{{
		for statement in @data.body {
			if statement ?= $compile.statement(statement, this) {
				@body.push(statement)
				
				statement.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @body {
			statement.prepare()
		}
	} // }}}
	translate() { // {{{
		for statement in @body {
			statement.translate()
		}
	} // }}}
	directory() => @module.directory()
	file() => @module.file()
	isConsumedError(name, variable): Boolean => false
	module() => @module
	toFragments(fragments) { // {{{
		for statement in @body {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
}