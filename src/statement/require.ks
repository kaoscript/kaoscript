enum RequireKind {
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

const $require = {
	define(declaration, node) { // {{{
		let variable
		
		switch declaration.kind {
			NodeKind::ClassDeclaration => {
				variable = $variable.define(node, node.greatScope(), declaration.name, VariableKind::Class, declaration)
				
				variable.requirement = declaration.name.name
				
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
					$extern.classMember(declaration.members[i], variable, node)
				}
			}
			NodeKind::VariableDeclarator => {
				variable = $variable.define(node, node.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
				
				variable.requirement = declaration.name.name
				
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

class RequireDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		for declaration in @data.declarations {
			module.require($require.define(declaration, this), RequireKind::Require)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class ExternOrRequireDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in @data.declarations {
			module.require($require.define(declaration, this), RequireKind::ExternOrRequire)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrExternDeclaration extends Statement {
	analyse() { // {{{
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in @data.declarations {
			module.require($require.define(declaration, this), RequireKind::RequireOrExtern)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}