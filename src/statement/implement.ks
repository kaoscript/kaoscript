class ImplementDeclaration extends Statement {
	private {
		_properties = []
		_variable
	}
	analyse() { // {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}
		
		if @variable.kind == VariableKind::Class {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementClassFieldDeclaration(property, this, @variable)
					}
					NodeKind::MethodAliasDeclaration => {
						property = new ImplementClassMethodAliasDeclaration(property, this, @variable)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementClassMethodDeclaration(property, this, @variable)
					}
					NodeKind::MethodLinkDeclaration => {
						property = new ImplementClassMethodLinkDeclaration(property, this, @variable)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(property.kind)`, this)
					}
				}
				
				property.analyse()
				
				@properties.push(property)
			}
		}
		else if @variable.kind == VariableKind::Variable {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementVariableFieldDeclaration(property, this, @variable)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementVariableMethodDeclaration(property, this, @variable)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(property.kind)`, this)
					}
				}
				
				property.analyse()
				
				@properties.push(property)
			}
		}
		else {
			TypeException.throwImplInvalidType(this)
		}
	} // }}}
	fuse() { // {{{
		for property in @properties {
			property.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for property in @properties {
			property.toFragments(fragments, Mode::None)
		}
	} // }}}
}

class ImplementClassFieldDeclaration extends Statement {
	private {
		_instance		= true
		_name
		_signature
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)
		
		if variable.sealed {
			TypeException.throwImplFieldToSealedType(this)
		}
	} // }}}
	analyse() { // {{{
		for i from 0 til @data.modifiers.length while @instance {
			if @data.modifiers[i].kind == ModifierKind::Static {
				@instance = false
			}
		}
		
		@name = @data.name.name
		
		@signature = $field.signature(@data, this)
		
		if @instance {
			@variable.instanceVariables[@name] = @signature
		}
		else {
			@variable.classVariables[@name] = @signature
		}
		
		if @variable.sealed? {
			if @instance {
				if @variable.sealed.instanceVariables[@name] != true {
					@variable.sealed.instanceVariables[@name] = true
				}
			}
			else {
				if @variable.sealed.classVariables[@name] != true {
					@variable.sealed.classVariables[@name] = true
				}
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @instance {
			this.module().flag('Helper')
			
			fragments.line($runtime.helper(this), '.newField(' + $quote(@name) + ', ' + this.toTypeString(@signature.type, '') + ')')
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	toTypeString(type, path) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += this.toTypeString(type[i], path)
			}
			
			return '[' + src + ']'
		}
		else if type is String {
			if type == 'Any' || $typeofs[type] == true {
				return $quote(type)
			}
			else if @scope.hasVariable(type) {
				return type
			}
			else {
				if path? {
					this.module().addReference(type, path + '.type = ' + type)
					
					return $quote('#' + type)
				}
				else {
					TypeException.throwInvalid(type, this)
				}
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ImplementClassMethodDeclaration extends Statement {
	private {
		_isContructor	= false
		_isDestructor	= false
		_instance		= true
		_name
		_parameters
		_signature
		_statements
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let name = @data.name.name
		
		if @isContructor = @data.name.kind == NodeKind::Identifier && $method.isConstructor(name, @variable) {
			throw new NotImplementedException(this)
		}
		else if @isDestructor = @data.name.kind == NodeKind::Identifier && $method.isDestructor(name, @variable) {
			throw new NotImplementedException(this)
		}
		else {
			for i from 0 til @data.modifiers.length while @instance {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
			}
			
			if @variable.sealed? {
				if @instance {
					if @variable.sealed.instanceMethods[name] != true {
						@variable.sealed.instanceMethods[name] = true
					}
				}
				else {
					if @variable.sealed.classMethods[name] != true {
						@variable.sealed.classMethods[name] = true
					}
				}
			}
			
			if @data.name.kind == NodeKind::TemplateExpression {
				@name = $compile.expression(@data.name, this)
			}
		}
		
		$variable.define(this, @scope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(@variable.name))
		
		@parameters = [new Parameter(parameter, this) for parameter in @data.parameters]
		
		@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
	} // }}}
	fuse() { // {{{
		this.compile(this._parameters)
		
		this.compile(this._statements)
		
		@signature = Signature.fromNode(this)
		
		if @data.name.kind == NodeKind::Identifier {
			let name = @data.name.name
			
			if @instance {
				if @variable.instanceMethods[name] is Array {
					@variable.instanceMethods[name].push(@signature)
				}
				else {
					@variable.instanceMethods[name] = [@signature]
				}
			}
			else {
				if @variable.classMethods[name] is Array {
					@variable.classMethods[name].push(@signature)
				}
				else {
					@variable.classMethods[name] = [@signature]
				}
			}
		}
	} // }}}
	getAliasType(name, node) { // {{{
		if	(variable ?= this.getInstanceVariable(name)) ||
			(variable ?= this.getInstanceMethod(name)) ||
			(variable ?= this.getInstanceVariable('_' + name)) {
			
			let type = $type.reference(variable.type ?? 'Any')
			
			if variable.nullable {
				type.nullable = true
			}
			
			return type
		}
		else {
			ReferenceException.throwNotDefinedMember(name, node)
		}
	} // }}}
	getInstanceMethod(name, variable = @variable) { // {{{
		if variable.instanceMethods[name]?['1']? {
			throw new NotImplementedException()
		}
		else if variable.extends? {
			return this.getInstanceMethod(name, @scope.getVariable(variable.extends))
		}
		
		return null
	} // }}}
	getInstanceVariable(name, variable = @variable) { // {{{
		if variable.instanceVariables[name]? {
			return variable.instanceVariables[name]
		}
		else if variable.extends? {
			return this.getInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return null
	} // }}}
	isInstanceMethod(name, variable = @variable) { // {{{
		if variable.instanceMethods[name]?['1']? {
			return true
		}
		else if variable.extends? {
			return this.getInstanceMethod(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	isInstanceVariable(name, variable = @variable) { // {{{
		if variable.instanceVariables[name]? {
			return true
		}
		else if variable.extends? {
			return this.isInstanceVariable(name, @scope.getVariable(variable.extends))
		}
		
		return false
	} // }}}
	isMethod() => true
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		let data = this._data
		let variable = this._variable
		
		if this._isContructor {
			throw new NotImplementedException(this)
		}
		else if this._isDestructor {
			throw new NotImplementedException(this)
		}
		else {
			let line = fragments
				.newLine()
				.code($runtime.helper(this), '.', this._instance ? 'newInstanceMethod' : 'newClassMethod', '(')
			
			let object = line.newObject()
			
			object.newLine().code('class: ', variable.name is String ? variable.name : variable.name.name)
			
			if data.name.kind == NodeKind::Identifier {
				object.newLine().code('name: ' + $quote(data.name.name))
			}
			else if data.name.kind == NodeKind::TemplateExpression {
				object.newLine().code('name: ').compile(this._name)
			}
			else {
				throw new NotImplementedException(this)
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
			
			$helper.reflectMethod(this, object.newLine().code('signature: '), @signature)
			
			object.done()
			line.code(')').done()
		}
	} // }}}
	toTypeString(type, path) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += this.toTypeString(type[i], path)
			}
			
			return '[' + src + ']'
		}
		else if type is String {
			if type == 'Any' || $typeofs[type] == true {
				return $quote(type)
			}
			else if @scope.hasVariable(type) {
				return type
			}
			else {
				if path? {
					this.module().addReference(type, path + '.type = ' + type)
					
					return $quote('#' + type)
				}
				else {
					TypeException.throwInvalid(type, this)
				}
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ImplementClassMethodAliasDeclaration extends Statement {
	private {
		_arguments
		_isContructor	= false
		_isDestructor	= false
		_instance		= true
		_name
		_parameters
		_signature
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if this._isContructor = data.name.kind == NodeKind::Identifier && $method.isConstructor(data.name.name, variable) {
			throw new NotImplementedException(this)
		}
		else if this._isDestructor = data.name.kind == NodeKind::Identifier && $method.isDestructor(data.name.name, variable) {
			throw new NotImplementedException(this)
		}
		else {
			if data.name.kind == NodeKind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == ModifierKind::Static {
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
			
			if data.name.kind == NodeKind::Identifier {
				if this._instance {
					variable.instanceMethods[data.name.name] = variable.instanceMethods[data.alias.name]
				}
				else {
					variable.classMethods[data.name.name] = variable.classMethods[data.alias.name]
				}
			}
			
			this._signature = Signature.fromAST(data, this)
			
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
		
		object.line('class: ', variable.name is String ? variable.name : variable.name.name)
		
		if data.name.kind == NodeKind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == NodeKind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			throw new NotImplementedException(this)
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
		
		$helper.reflectMethod(this, signLine, this._signature)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
	toTypeString(type, path) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += this.toTypeString(type[i], path)
			}
			
			return '[' + src + ']'
		}
		else if type is String {
			if type == 'Any' || $typeofs[type] == true {
				return $quote(type)
			}
			else if @scope.hasVariable(type) {
				return type
			}
			else {
				if path? {
					this.module().addReference(type, path + '.type = ' + type)
					
					return $quote('#' + type)
				}
				else {
					TypeException.throwInvalid(type, this)
				}
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ImplementClassMethodLinkDeclaration extends Statement {
	private {
		_arguments
		_functionName
		_isContructor	= false
		_isDestructor	= false
		_instance	= true
		_name
		_parameters
		_signature
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		let data = this._data
		let variable = this._variable
		
		if this._isContructor = data.name.kind == NodeKind::Identifier && $method.isConstructor(data.name.name, variable) {
			throw new NotImplementedException(this)
		}
		else if this._isDestructor = data.name.kind == NodeKind::Identifier && $method.isDestructor(data.name.name, variable) {
			throw new NotImplementedException(this)
		}
		else {
			if data.name.kind == NodeKind::TemplateExpression {
				this._name = $compile.expression(data.name, this)
			}
			
			for i from 0 til data.modifiers.length while this._instance {
				if data.modifiers[i].kind == ModifierKind::Static {
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
			
			this._signature = Signature.fromAST(data, this)
			
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
		
		object.line('class: ', variable.name is String ? variable.name : variable.name.name)
		
		if data.name.kind == NodeKind::TemplateExpression {
			object.newLine().code('name: ').compile(this._name).done()
		}
		else if data.name.kind == NodeKind::Identifier {
			object.line('name: ', $quote(data.name.name))
		}
		else {
			throw new NotImplementedException(this)
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
		
		$helper.reflectMethod(this, signLine, this._signature)
		
		signLine.done()
		
		object.done()
		
		line.code(')').done()
	} // }}}
	toTypeString(type, path) { // {{{
		if type is Array {
			let src = ''
			
			for i from 0 til type.length {
				if i {
					src += ','
				}
				
				src += this.toTypeString(type[i], path)
			}
			
			return '[' + src + ']'
		}
		else if type is String {
			if type == 'Any' || $typeofs[type] == true {
				return $quote(type)
			}
			else if @scope.hasVariable(type) {
				return type
			}
			else {
				if path? {
					this.module().addReference(type, path + '.type = ' + type)
					
					return $quote('#' + type)
				}
				else {
					TypeException.throwInvalid(type, this)
				}
			}
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ImplementVariableFieldDeclaration extends Statement {
	private {
		_value
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
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
		_signature
		_statements
		_variable
	}
	constructor(data, parent, @variable) { // {{{
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
		
		@signature = Signature.fromNode(this)
	} // }}}
	isMethod() => false
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