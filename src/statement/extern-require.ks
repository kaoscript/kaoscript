class ExternOrRequireDeclaration extends Statement {
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				NodeKind::ClassDeclaration => {
					variable = $variable.define(this, this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
						$extern.classMember(declaration.members[i], variable, this)
					}
					
					module.require(variable, false)
				}
				NodeKind::VariableDeclarator => {
					variable = $variable.define(this, this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							properties: {}
						}
					}
					
					module.require(variable, false)
				}
				=> {
					$throw('Unknow kind ' + declaration.kind, this)
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}