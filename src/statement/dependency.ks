enum DependencyKind {
	Extern
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

const $dependency = {
	define(declaration, node, kind) { // {{{
		const scope = node.greatScope()
		
		switch declaration.kind {
			NodeKind::ClassDeclaration => {
				const type = new ClassType(declaration.name.name, scope)
				const variable = scope.define(declaration.name.name, true, type, node)
				
				if declaration.extends? {
					if superVar !?= node.scope().getVariable(declaration.extends.name) {
						ReferenceException.throwNotDefined(declaration.extends.name, node)
					}
					else if superVar.type() is not ClassType {
						TypeException.throwNotClass(declaration.extends.name, node)
					}
					
					type.extends(superVar.type())
				}
				
				if kind != DependencyKind::Extern {
					variable.require()
				}
				
				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type.alienize()
				}
				
				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Abstract {
						type.abstract()
					}
					else if modifier.kind == ModifierKind::Sealed {
						type.seal()
					}
				}
				
				for member in declaration.members {
					type.addPropertyFromAST(member, node)
				}
				
				return variable
			}
			NodeKind::NamespaceDeclaration => {
				const type = new NamespaceType(declaration.name.name, scope)
				const variable = scope.define(declaration.name.name, true, type, node)
				
				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						type.seal()
					}
				}
				
				for statement in declaration.statements {
					type.addPropertyFromAST(statement, node)
				}
				
				return variable
			}
			NodeKind::VariableDeclarator => {
				let type = Type.fromAST(declaration.type, node)
				
				let referenced = false
				
				if type is ReferenceType {
					if type.name() == 'Class' {
						type = new ClassType(declaration.name.name, scope)
					}
				}
				else if type is ClassType {
					referenced = true
				}
				
				if declaration.sealed {
					if type == Type.Any {
						type = new SealedReferenceType(node)
					}
					else if type is ReferenceType {
						type = new SealedReferenceType(type)
					}
					else {
						type.seal()
					}
				}
				
				if	type is ClassType &&
					(
						kind == DependencyKind::Extern ||
						kind == DependencyKind::ExternOrRequire ||
						kind == DependencyKind::RequireOrExtern
					)
				{
					type.alienize()
				}
				
				if referenced {
					type = type.reference()
				}
				
				const variable = scope.define(declaration.name.name, true, type, node)
				
				return variable
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(declaration.kind)`, node)
			}
		}
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
			
			if variable.type().isSealed() && variable.type().isExtendable() {
				@lines.push(`var \(variable.type().sealName()) = {}`)
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
		
		let metadata, requirement
		for declarator in @data.declarations {
			metadata = $import.resolve(declarator, directory, module, this)
			
			if metadata.importVarCount > 0 {
				for :alias of metadata.importVariables {
					requirement = module.require(@scope.getVariable(alias), DependencyKind::RequireOrImport)
					
					requirement.data = @data
					requirement.metadata = metadata
					requirement.node = this
				}
			}
			else if metadata.importAll {
				for name in metadata.exports {
					requirement = module.require(@scope.getVariable(name), DependencyKind::RequireOrImport)
					
					requirement.data = @data
					requirement.metadata = metadata
					requirement.node = this
				}
			}
			
			if metadata.importAlias.length != 0 {
				throw new NotImplementedException(this)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}