const $extern = {
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
					variable.constructors.push($function.signature(data, node))
				}
				else if $method.isDestructor(data.name.name, variable) {
					throw new NotImplementedException(node)
				}
				else {
					let method = {
						kind: NodeKind::MethodDeclaration
						name: data.name.name
						signature: $method.signature(data, node)
					}
					
					method.type = $type.type(data.type, node.scope(), node) if data.type
					
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind::Static
					}
					
					if instance {
						if !(variable.instanceMethods[data.name.name] is Array) {
							variable.instanceMethods[data.name.name] = []
						}
						
						variable.instanceMethods[data.name.name].push(method)
					}
					else {
						if !(variable.classMethods[data.name.name] is Array) {
							variable.classMethods[data.name.name] = []
						}
						
						variable.classMethods[data.name.name].push(method)
					}
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(data.kind)`, node)
			}
		}
	} // }}}
}

class ExternDeclaration extends Statement {
	private {
		_lines = []
	}
	analyse() { // {{{
		for declaration in @data.declarations {
			switch declaration.kind {
				NodeKind::ClassDeclaration => {
					variable = $variable.define(this, this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
					if declaration.extends? {
						if superVar !?= @scope.getVariable(declaration.extends.name) {
							ReferenceException.throwNotDefined(declaration.extends.name, this)
						}
						else if variable.kind != VariableKind::Class {
							TypeException.throwNotClass(declaration.extends.name, this)
						}
						
						variable.extends = declaration.extends.name
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
								extern: true
							}
							
							@lines.push('var ' + variable.sealed.name + ' = {}')
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
				}
				NodeKind::VariableDeclarator => {
					variable = $variable.define(this, this.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							properties: {}
							extern: true
						}
						
						@lines.push('var ' + variable.sealed.name + ' = {}')
					}
				}
				=> {
					throw new NotSupportedException(`Unknow kind \(declaration.kind)`, this)
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for line in @lines {
			fragments.line(line)
		}
	} // }}}
}