class RequireOrExternDeclaration extends Statement {
	RequireOrExternDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this, this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
					variable.requirement = declaration.name.name
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
					
					module.require(declaration.name.name, VariableKind::Class, true)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this, this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type, true)
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