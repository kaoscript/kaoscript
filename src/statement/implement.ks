class ImplementDeclaration extends Statement {
	private {
		_properties = []
	}
	ImplementDeclaration(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		let data = this._data
		this._variable = this._scope.getVariable(data.variable.name)
		
		if this._variable.kind == VariableKind::Class {
			for property in data.properties {
				switch property.kind {
					Kind::FieldDeclaration => {
						property = new ImplementClassFieldDeclaration(property, this, this._variable)
					}
					Kind::MethodAliasDeclaration => {
						property = new ImplementClassMethodAliasDeclaration(property, this, this._variable)
					}
					Kind::MethodDeclaration => {
						property = new ImplementClassMethodDeclaration(property, this, this._variable)
					}
					Kind::MethodLinkDeclaration => {
						property = new ImplementClassMethodLinkDeclaration(property, this, this._variable)
					}
					=> {
						$throw('Unknow kind ' + property.kind, this)
					}
				}
				
				property.analyse()
				
				this._properties.push(property)
			}
		}
		else if this._variable.kind == VariableKind::Variable {
			for property in data.properties {
				switch property.kind {
					Kind::FieldDeclaration => {
						property = new ImplementVariableFieldDeclaration(property, this, this._variable)
					}
					Kind::MethodDeclaration => {
						property = new ImplementVariableMethodDeclaration(property, this, this._variable)
					}
					=> {
						$throw('Unknow kind ' + property.kind, this)
					}
				}
				
				property.analyse()
				
				this._properties.push(property)
			}
		}
		else {
			$throw('Invalid class/variable for impl at line ' + data.start.line, this)
		}
	} // }}}
	fuse() { // {{{
		for property in this._properties {
			property.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for property in this._properties {
			property.toFragments(fragments, Mode::None)
		}
	} // }}}
}

class ImplementClassFieldDeclaration extends Statement {
	private {
		_variable
	}
	ImplementClassFieldDeclaration(data, parent, @variable) { // {{{
		super(data, parent)
		
		if variable.sealed {
			$throw('Can\'t add a field to a sealed class', this)
		}
	} // }}}
	analyse() { // {{{
		this._type = $helper.analyseType($signature.type(this._data.type, this._scope), this)
		
		if this._type.kind == HelperTypeKind::Unreferenced {
			$throw(`Invalid type \(this._type.type) at line \(this._data.start.line)`, this)
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments.line($runtime.helper(this), '.newField(' + $quote(this._data.name.name) + ', ' + $helper.type(this._type, this) + ')')
	} // }}}
}

class ImplementClassMethodDeclaration extends Statement {
	private {
		_instance	= true
		_name
		_parameters
		_statements
		_variable
	}
	ImplementClassMethodDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			$throw('Not Implemented', this)
		}
		else {
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == MemberModifier.Static {
					this._instance = false
				}
			}
			
			if variable.sealed {
				if this._instance {
					if variable.sealed.instanceMethods[data.name.name] != true {
						variable.sealed.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.sealed.classMethods[data.name.name] != true {
						variable.sealed.classMethods[data.name.name] = true
					}
				}
			}
			
			if data.name.kind == Kind::Identifier {
				let method = {
					kind: Kind::MethodDeclaration
					name: data.name.name
					signature: $method.signature(data, this)
				}
				
				method.type = $type.type(data.type, this._scope, this) if data.type
				
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
		
		$variable.define(this, this._scope, {
			kind: Kind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(variable.name))
		
		this._parameters = [new Parameter(parameter, this) for parameter in data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $body(data.body)]
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		
		this.compile(this._statements)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			$throw('Not Implemented', this)
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
				$throw('Not Implemented', this)
			}
			
			if variable.sealed {
				object.newLine().code('sealed: ' + variable.sealed.name)
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

class ImplementClassMethodAliasDeclaration extends Statement {
	private {
		_arguments
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementClassMethodAliasDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			$throw('Not Implemented', this)
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
			
			if variable.sealed {
				if this._instance {
					if variable.sealed.instanceMethods[data.name.name] != true {
						variable.sealed.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.sealed.classMethods[data.name.name] != true {
						variable.sealed.classMethods[data.name.name] = true
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
		this.module().flag('Helper')
		
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
			$throw('Not Implemented', this)
		}
		
		if variable.sealed {
			object.line('sealed: ', variable.sealed.name)
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

class ImplementClassMethodLinkDeclaration extends Statement {
	private {
		_arguments
		_functionName
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	ImplementClassMethodLinkDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if data.name.name == variable.name.name {
			$throw('Not Implemented', this)
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
			
			if variable.sealed {
				if this._instance {
					if variable.sealed.instanceMethods[data.name.name] != true {
						variable.sealed.instanceMethods[data.name.name] = true
					}
				}
				else {
					if variable.sealed.classMethods[data.name.name] != true {
						variable.sealed.classMethods[data.name.name] = true
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
		this.module().flag('Helper')
		
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
			$throw('Not Implemented', this)
		}
		
		if variable.sealed {
			object.line('sealed: ', variable.sealed.name)
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

class ImplementVariableFieldDeclaration extends Statement {
	private {
		_type
		_value
		_variable
	}
	ImplementVariableFieldDeclaration(data, parent, @variable) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._type = $helper.analyseType($signature.type(this._data.type, this._scope), this)
		this._value = $compile.expression(this._data.defaultValue, this)
		
		let property = {
			kind: VariableKind::Variable
			name: this._data.name.name
		}
		
		if this._data.type? {
			property.type = $type.type(this._data.type, this._scope, this)
		}
		
		this._variable.sealed.properties[property.name] = property
	} // }}}
	fuse() { // {{{
		this._value.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code(this._variable.sealed.name, '.', this._data.name.name, ' = ')
			.compile(this._value)
			.done()
	} // }}}
}

class ImplementVariableMethodDeclaration extends Statement {
	private {
		_parameters
		_statements
		_variable
	}
	ImplementVariableMethodDeclaration(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		if this._data.body? {
			this._statements = [$compile.statement(statement, this) for statement in $body(this._data.body)]
		}
		else {
			this._statements = []
		}
		
		let property = {
			kind: VariableKind::Function
			name: this._data.name.name
			signature: $function.signature(this._data, this)
		}
		
		if this._data.type? {
			property.type = $type.type(this._data.type, this._scope, this)
		}
		
		this._variable.sealed.properties[property.name] = property
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		
		this.compile(this._statements)
	} // }}}
	toFragments(fragments, mode) { // {{{
		let line = fragments.newLine().code(this._variable.sealed.name, '.', this._data.name.name, ' = function(')
		
		let block = $function.parameters(this, line, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in this._statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done()
	} // }}}
}