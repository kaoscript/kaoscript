enum DependencyKind {
	Extern
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

const $dependency = {
	classMember(data, type: ClassType, node) { // {{{
		switch(data.kind) {
			NodeKind::FieldDeclaration => {
				throw new NotImplementedException(node)
			}
			NodeKind::MethodAliasDeclaration => {
				throw new NotImplementedException(node)
			}
			NodeKind::MethodDeclaration => {
				if type.isConstructor(data.name.name) {
					throw new NotImplementedException(node)
				}
				else if type.isDestructor(data.name.name) {
					throw new NotImplementedException(node)
				}
				else {
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind::Static
					}
					
					if instance {
						type.addInstanceMethod(data.name.name, Type.fromAST(data, node))
					}
					else {
						type.addClassMethod(data.name.name, Type.fromAST(data, node))
					}
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(data.kind)`, node)
			}
		}
	} // }}}
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
				
				for i from 0 til declaration.members.length {
					$dependency.classMember(declaration.members[i], type, node)
				}
				
				return variable
			}
			NodeKind::VariableDeclarator => {
				let type = Type.fromAST(declaration.type, node)
				
				if type is ReferenceType && type.name() == 'Class' {
					type = new ClassType(declaration.name.name, scope)
				}
				else if type is ObjectType {
					if declaration.sealed {
						type.seal(declaration.name.name)
					}
					
					if	kind == DependencyKind::Extern ||
						kind == DependencyKind::ExternOrRequire ||
						kind == DependencyKind::RequireOrExtern
					{
						type.alienize()
					}
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
			
			if variable.type().isSealed() {
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
				for name, alias of metadata.importVariables {
					requirement = module.require(Variable.import(alias, metadata.exports[name], this), DependencyKind::RequireOrImport)
					
					requirement.data = @data
					requirement.metadata = metadata
					requirement.node = this
				}
			}
			else if metadata.importAll {
				for name, data of metadata.exports {
					requirement = module.require(Variable.import(name, data, this), DependencyKind::RequireOrImport)
					
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