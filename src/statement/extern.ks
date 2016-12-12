const $extern = {
	classMember(data, variable, node) { // {{{
		switch(data.kind) {
			Kind::FieldDeclaration => {
				console.error(data)
				throw new Error('Not Implemented')
			}
			Kind::MethodAliasDeclaration => {
				if data.name.name == variable.name.name {
					console.error(data)
					throw new Error('Not Implemented')
				}
				else {
				}
			}
			Kind::MethodDeclaration => {
				if data.name.name == variable.name.name {
					variable.constructors.push($function.signature(data, node.scope()))
				}
				else {
					let method = {
						kind: Kind::MethodDeclaration
						name: data.name.name
						signature: $method.signature(data, node)
					}
					
					method.type = $type.type(data.type, node.scope()) if data.type
					
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == MemberModifier::Static
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
				console.error(data)
				throw new Error('Unknow kind ' + data.kind)
			}
		}
	} // }}}
}

class ExternDeclaration extends Statement {
	private {
		_lines = []
	}
	ExternDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		for declaration in data.declarations {
			switch declaration.kind {
				Kind::ClassDeclaration => {
					variable = $variable.define(this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							constructors: false
							instanceMethods: {}
							classMethods: {}
						}
						
						this._lines.push('var ' + variable.sealed.name + ' = {}')
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							properties: {}
						}
						
						this._lines.push('var ' + variable.sealed.name + ' = {}')
					}
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
		for line in this._lines {
			fragments.line(line)
		}
	} // }}}
}