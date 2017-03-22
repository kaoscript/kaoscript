enum DependencyKind {
	Extern
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

const $dependency = {
	classMember(data, variable, node) { // {{{
		switch(data.kind) {
			NodeKind::FieldDeclaration => {
				throw new NotImplementedException(node)
			}
			NodeKind::MethodAliasDeclaration => {
				throw new NotImplementedException(node)
			}
			NodeKind::MethodDeclaration => {
				if $method.isConstructor(data.name.name, variable) {
					variable.constructors.push(Signature.fromAST(data, node))
				}
				else if $method.isDestructor(data.name.name, variable) {
					throw new NotImplementedException(node)
				}
				else {
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind::Static
					}
					
					let signature = Signature.fromAST(data, node)
					
					if instance {
						if variable.instanceMethods[data.name.name] is Array {
							variable.instanceMethods[data.name.name].push(signature)
						}
						else {
							variable.instanceMethods[data.name.name] = [signature]
						}
					}
					else {
						if variable.classMethods[data.name.name] is Array {
							variable.classMethods[data.name.name].push(signature)
						}
						else {
							variable.classMethods[data.name.name] = [signature]
						}
					}
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(data.kind)`, node)
			}
		}
	} // }}}
	define(declaration, node, kind) { // {{{
		let variable
		
		switch declaration.kind {
			NodeKind::ClassDeclaration => {
				variable = $variable.define(node, node.greatScope(), declaration.name, VariableKind::Class, declaration)
				
				if declaration.extends? {
					if superVar !?= node.scope().getVariable(declaration.extends.name) {
						ReferenceException.throwNotDefined(declaration.extends.name, node)
					}
					else if variable.kind != VariableKind::Class {
						TypeException.throwNotClass(declaration.extends.name, node)
					}
					
					variable.extends = declaration.extends.name
				}
				
				unless kind == DependencyKind::Extern {
					variable.requirement = declaration.name.name
				}
				
				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Abstract {
						variable.abstract = true
					}
					else if modifier.kind == ModifierKind::Sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
					}
				}
				
				for i from 0 til declaration.members.length {
					$dependency.classMember(declaration.members[i], variable, node)
				}
			}
			NodeKind::VariableDeclarator => {
				variable = $variable.define(node, node.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
				
				unless kind == DependencyKind::Extern {
					variable.requirement = declaration.name.name
				}
				
				if declaration.sealed {
					variable.sealed = {
						name: '__ks_' + variable.name.name
						properties: {}
					}
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(declaration.kind)`, node)
			}
		}
		
		return variable
	} // }}}
}

class ExternDeclaration extends Statement {
	private {
		_lines = []
	}
	analyse() { // {{{
		let module = this.module()
		
		let variable
		for declaration in @data.declarations {
			variable = $dependency.define(declaration, this, DependencyKind::Extern)
			
			if variable.sealed? {
				variable.sealed.extern = true
				
				@lines.push(`var \(variable.sealed.name) = {}`)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		for line in @lines {
			fragments.line(line)
		}
	} // }}}
}

class RequireDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		for declaration in @data.declarations {
			module.require($dependency.define(declaration, this, DependencyKind::Require), DependencyKind::Require)
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class ExternOrRequireDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in @data.declarations {
			module.require($dependency.define(declaration, this, DependencyKind::ExternOrRequire), DependencyKind::ExternOrRequire)
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrExternDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in @data.declarations {
			module.require($dependency.define(declaration, this, DependencyKind::RequireOrExtern), DependencyKind::RequireOrExtern)
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		const directory = this.directory()
		const module = this.module()
		
		let metadata, variable
		for declarator in @data.declarations {
			metadata = $import.resolve(declarator, directory, module, this)
			
			if metadata.importVarCount > 0 {
				for name, alias of metadata.importVariables {
					variable = metadata.exports[name]
					
					variable.requirement = alias
					
					module.require(variable, DependencyKind::RequireOrImport, {
						data: @data
						metadata: metadata
						node: this
					})
				}
			}
			else if metadata.importAll {
				for name, variable of metadata.exports {
					variable.requirement = name
					
					module.require(variable, DependencyKind::RequireOrImport, {
						data: @data
						metadata: metadata
						node: this
					})
				}
			}
			
			if metadata.importAlias.length {
				throw new NotImplementedException(this)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}