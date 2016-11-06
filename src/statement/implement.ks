class ImplementDeclaration extends Statement {
	private {
		_members = []
	}
	ImplementDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._scope.getVariable(data.class.name)
		
		if variable.kind != VariableKind::Class {
			throw new Error('Invalid class for impl at line ' + data.start.line)
		}
		
		for member in data.members {
			switch member.kind {
				Kind::FieldDeclaration => {
					this._members.push(member = new ImplementFieldDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodAliasDeclaration => {
					this._members.push(member = new ImplementMethodAliasDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodDeclaration => {
					this._members.push(member = new ImplementMethodDeclaration(member, this, variable))
					
					member.analyse()
				}
				Kind::MethodLinkDeclaration => {
					this._members.push(member = new ImplementMethodLinkDeclaration(member, this, variable))
					
					member.analyse()
				}
				=> {
					console.error(member)
					throw new Error('Unknow kind ' + member.kind)
				}
			}
		}
	} // }}}
	fuse() { // {{{
		for member in this._members {
			member.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		for member in this._members {
			member.toFragments(fragments, Mode::None)
		}
	} // }}}
}

class ImplementFieldDeclaration extends Statement {
	private {
		_variable
	}
	ImplementFieldDeclaration(data, parent, @variable) { // {{{
		super(data, parent)
		
		if variable.final {
			throw new Error('Can\'t add a field to a final class')
		}
	} // }}}
	analyse() { // {{{
		this._type = $helper.analyseType($signature.type(this._data.type, this._scope), this)
		
		if this._type.kind == HelperTypeKind::Unreferenced {
			throw new Error(`Invalid type \(this._type.type) at line \(this._data.start.line)`)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.line($runtime.helper(this), '.newField(' + $quote(this._data.name.name) + ', ' + $helper.type(this._type, this) + ')')
	} // }}}
}

class ImplementMethodDeclaration extends Statement {
	private {
		_instance	= true
		_name
		_parameters
		_statements
		_variable
	}
	ImplementMethodDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier.Static {
					this._instance = false
				}
			}
			
			if variable.final {
				if this._instance {
					if variable.final.instanceMethods[data.name.name] != true {
						variable.final.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.final.classMethods[data.name.name] != true {
						variable.final.classMethods[data.name.name] = true
					}
				}
			}
			
			if data.name.kind == Kind::Identifier {
				let method = {
					kind: Kind::MethodDeclaration
					name: data.name.name
					signature: $method.signature(data, this)
				}
				
				method.type = $type.type(data.type, this._scope) if data.type
				
				if this._instance {
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
			else if data.name.kind == Kind.TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
		}
		
		$variable.define(this._scope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(variable.name))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $statements(data.body)]
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		
		this.compile(this._statements)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			let line = fragments
				.newLine()
				.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
			
			let object = line.newObject()
			
			object.newLine().code('class: ' + variable.name.name)
			
			if data.name.kind == Kind::Identifier {
				object.newLine().code('name: ' + $quote(data.name.name))
			}
			else if data.name.kind == Kind.TemplateExpression {
				object.newLine().code('name: ').compile(this._name)
			}
			else {
				console.error(data.name)
				throw new Error('Not Implemented')
			}
			
			if variable.final {
				object.newLine().code('final: ' + variable.final.name)
			}
			
			let ctrl = object.newControl().code('function: function(')
			
			$function.parameters(this, ctrl, func(fragments) {
				return fragments.code(')').step()
			})
			
			for statement in this._statements {
				ctrl.compile(statement)
			}
			
			let signature = $method.signature(data, this)
			$helper.reflectMethod(this, object.newLine().code('signature: '), signature, [$helper.analyseType(parameter.type, this) for parameter in signature.parameters])
			
			object.done()
			line.code(')').done()
		}
	} // }}}
}

class ImplementMethodAliasDeclaration extends Statement {
	private {
		_arguments
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementMethodAliasDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			if data.name.kind == Kind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier::Static {
					this._instance = false
				}
			}
			
			if variable.final {
				if this._instance {
					if variable.final.instanceMethods[data.name.name] != true {
						variable.final.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.final.classMethods[data.name.name] != true {
						variable.final.classMethods[data.name.name] = true
					}
				}
			}
			
			if data.name.kind == Kind::Identifier {
				if this._instance {
					variable.instanceMethods[data.name.name] = variable.instanceMethods[data.alias.name]
				}
				else {
					variable.classMethods[data.name.name] = variable.classMethods[data.alias.name]
				}
			}
			
			this._signature = $method.signature(data, this)
			
			this._parameters = [$helper.analyseType(parameter.type, this) for parameter in this._signature.parameters]
			
			if data.arguments? {
				this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
			}
		}
	} // }}}
	fuse() { // {{{
		if this._arguments? {
			for argument in this._arguments {
				argument.fuse()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		let variable = this._variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name.name)
		
		if data.name.kind == Kind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == Kind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			console.error(data.name)
			throw new Error('Not Implemented')
		}
		
		if variable.final {
			object.line('final: ', variable.final.name)
		}
		
		object.line('method: ', $quote(data.alias.name))
		
		if data.arguments? {
			let argsLine = object.newLine().code('arguments: ')
			let array = argsLine.newArray()
			
			for argument in this._arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, this._signature, this._parameters)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
}

class ImplementMethodLinkDeclaration extends Statement {
	private {
		_arguments
		_functionName
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementMethodLinkDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			console.error(data)
			throw new Error('Not Implemented')
		}
		else {
			if data.name.kind == Kind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier::Static {
					this._instance = false
				}
			}
			
			if variable.final {
				if this._instance {
					if variable.final.instanceMethods[data.name.name] != true {
						variable.final.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.final.classMethods[data.name.name] != true {
						variable.final.classMethods[data.name.name] = true
					}
				}
			}
			
			this._functionName = $compile.expression(data.alias, this)
			
			this._signature = $method.signature(data, this)
			
			this._parameters = [$helper.analyseType(parameter.type, this) for parameter in this._signature.parameters]
			
			if data.arguments? {
				this._arguments = [$compile.expression(argument, this) for argument in data.arguments]
			}
		}
	} // }}}
	fuse() { // {{{
		if this._arguments? {
			for argument in this._arguments {
				argument.fuse()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		let variable = this._variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name.name)
		
		if data.name.kind == Kind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == Kind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			console.error(data.name)
			throw new Error('Not Implemented')
		}
		
		if variable.final {
			object.line('final: ', variable.final.name)
		}
		
		object.newLine().code('function: ').compile(this._functionName)
		
		if data.arguments? {
			let argsLine = object.newLine().code('arguments: ')
			let array = argsLine.newArray()
			
			for argument in this._arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, this._signature, this._parameters)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
}