class RequireDeclaration extends Statement {
	RequireDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		let type
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
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
						$extern.classMember(declaration.members[i], variable, this._parent)
					}
					
					module.require(declaration.name.name, VariableKind::Class)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type)
				}
				=> {
					console.error(declaration)
					throw new Error('Unknow kind ' + declaration.kind)
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}