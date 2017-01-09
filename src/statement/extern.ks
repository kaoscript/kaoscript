const $extern = {
	classMember(data, variable, node) { // {{{
		switch(data.kind) {
			Kind::FieldDeclaration => {
				$throw('Not Implemented', node)
			}
			Kind::MethodAliasDeclaration => {
				$throw('Not Implemented', node)
			}
			Kind::MethodDeclaration => {
				if $method.isConstructor(data.name.name, variable) {
					variable.constructors.push($function.signature(data, node))
				}
				else if $method.isDestructor(data.name.name, variable) {
					$throw('Not Implemented', node)
				}
				else {
					let method = {
						kind: Kind::MethodDeclaration
						name: data.name.name
						signature: $method.signature(data, node)
					}
					
					method.type = $type.type(data.type, node.scope(), node) if data.type
					
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
				$throw('Unknow kind ' + data.kind, node)
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
				Kind::ClassDeclaration => {
					variable = $variable.define(this, this.greatScope(), declaration.name, VariableKind::Class, declaration)
					
					if declaration.extends? {
						if !@scope.hasVariable(declaration.extends.name) {
							$throw(`Undefined class \(declaration.extends.name) at line \(declaration.extends.start.line)`, this)
						}
						
						variable.extends = declaration.extends.name
					}
					
					for modifier in declaration.modifiers {
						if modifier.kind == ClassModifier::Abstract {
							variable.abstract = true
						}
						else if modifier.kind == ClassModifier::Sealed {
							variable.sealed = {
								name: '__ks_' + variable.name.name
								constructors: false
								instanceMethods: {}
								classMethods: {}
							}
							
							@lines.push('var ' + variable.sealed.name + ' = {}')
						}
					}
					
					for i from 0 til declaration.members.length {
						$extern.classMember(declaration.members[i], variable, this)
					}
				}
				Kind::VariableDeclarator => {
					variable = $variable.define(this, this.greatScope(), declaration.name, $variable.kind(declaration.type), declaration.type)
					
					if declaration.sealed {
						variable.sealed = {
							name: '__ks_' + variable.name.name
							properties: {}
						}
						
						@lines.push('var ' + variable.sealed.name + ' = {}')
					}
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
		for line in @lines {
			fragments.line(line)
		}
	} // }}}
}