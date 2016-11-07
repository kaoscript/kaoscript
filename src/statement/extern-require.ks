class ExternOrRequireDeclaration extends Statement {
	ExternOrRequireDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let module = this.module()
		
		module.flag('Type')
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
					variable.requirement = declaration.name.name
					
					let continuous = true
					for i from 0 til declaration.modifiers.length while continuous {
						continuous = false if declaration.modifiers[i].kind == ClassModifier::Final
					}
					
					if !continuous {
						variable.final = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
					
					module.require(declaration.name.name, VariableKind::Class, false)
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this.greatScope(), declaration.name, type = $variable.kind(declaration.type), declaration.type)
					
					variable.requirement = declaration.name.name
					
					module.require(declaration.name.name, type, false)
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