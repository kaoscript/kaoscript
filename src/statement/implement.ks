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
	prepare() { // {{{
		for property in @properties {
			property.prepare()
		}
	} // }}}
	translate() { // {{{
		for property in @properties {
			property.translate()
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
	} // }}}
	prepare() { // {{{
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
	translate()
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
				@name.analyse()
			}
		}
		
		$variable.define(this, @scope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, VariableKind::Variable, $type.reference(@variable.name))
		
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))
			
			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}
		
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
		
		@name.prepare() if @name?
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		@statements = []
		for statement in $body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
		}
		
		for statement in @statements {
			statement.prepare()
		}
		
		for statement in @statements {
			statement.translate()
		}
		@name.translate() if @name?
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
		
		let data = @data
		let variable = @variable
		
		if @isContructor {
			throw new NotImplementedException(this)
		}
		else if @isDestructor {
			throw new NotImplementedException(this)
		}
		else {
			let line = fragments
				.newLine()
				.code($runtime.helper(this), '.', @instance ? 'newInstanceMethod' : 'newClassMethod', '(')
			
			let object = line.newObject()
			
			object.newLine().code('class: ', variable.name is String ? variable.name : variable.name.name)
			
			if data.name.kind == NodeKind::Identifier {
				object.newLine().code('name: ' + $quote(data.name.name))
			}
			else if data.name.kind == NodeKind::TemplateExpression {
				object.newLine().code('name: ').compile(@name)
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
			
			for statement in @statements {
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
		if @isContructor = @data.name.kind == NodeKind::Identifier && $method.isConstructor(@data.name.name, @variable) {
			throw new NotImplementedException(this)
		}
		else if @isDestructor = @data.name.kind == NodeKind::Identifier && $method.isDestructor(@data.name.name, @variable) {
			throw new NotImplementedException(this)
		}
		else {
			if @data.name.kind == NodeKind::TemplateExpression {
				@name = $compile.expression(@data.name, this)
				@name.analyse()
			}
			
			for i from 0 til @data.modifiers.length while @instance {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
			}
			
			if @variable.sealed {
				if @instance {
					if @variable.sealed.instanceMethods[@data.name.name] != true {
						@variable.sealed.instanceMethods[@data.name.name] = true
					}
				}
				else {
					if @variable.sealed.classMethods[@data.name.name] != true {
						@variable.sealed.classMethods[@data.name.name] = true
					}
				}
			}
			
			if @data.name.kind == NodeKind::Identifier {
				if @instance {
					@variable.instanceMethods[@data.name.name] = @variable.instanceMethods[@data.alias.name]
				}
				else {
					@variable.classMethods[@data.name.name] = @variable.classMethods[@data.alias.name]
				}
			}
			
			@signature = Signature.fromAST(@data, this)
			
			if @data.arguments? {
				@arguments = []
				for argument in @data.arguments {
					@arguments.push(argument = $compile.expression(argument, this))
					
					argument.analyse()
				}
			}
		}
	} // }}}
	prepare() { // {{{
		if @arguments? {
			for argument in @arguments {
				argument.prepare()
			}
		}
	} // }}}
	translate() { // {{{
		if @arguments? {
			for argument in @arguments {
				argument.translate()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		let data = @data
		let variable = @variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', @instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name is String ? variable.name : variable.name.name)
		
		if data.name.kind == NodeKind::TemplateExpression {
			object.newLine().code('name: ').compile(@name).done()
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
			
			for argument in @arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, @signature)
		
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
		if @isContructor = @data.name.kind == NodeKind::Identifier && $method.isConstructor(@data.name.name, @variable) {
			throw new NotImplementedException(this)
		}
		else if @isDestructor = @data.name.kind == NodeKind::Identifier && $method.isDestructor(@data.name.name, @variable) {
			throw new NotImplementedException(this)
		}
		else {
			if @data.name.kind == NodeKind::TemplateExpression {
				@name = $compile.expression(@data.name, this)
				@name.analyse()
			}
			
			for i from 0 til @data.modifiers.length while @instance {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
			}
			
			if @variable.sealed {
				if @instance {
					if @variable.sealed.instanceMethods[@data.name.name] != true {
						@variable.sealed.instanceMethods[@data.name.name] = true
					}
				}
				else {
					if @variable.sealed.classMethods[@data.name.name] != true {
						@variable.sealed.classMethods[@data.name.name] = true
					}
				}
			}
			
			@functionName = $compile.expression(@data.alias, this)
			@functionName.analyse()
			
			if @data.arguments? {
				@arguments = []
				for argument in @data.arguments {
					@arguments.push(argument = $compile.expression(argument, this))
					
					argument.analyse()
				}
			}
		}
	} // }}}
	prepare() { // {{{
		@name.prepare() if @name?
		
		if @arguments? {
			for argument in @arguments {
				argument.prepare()
			}
		}
		
		@signature = Signature.fromAST(@data, this)
	} // }}}
	translate() { // {{{
		@name.translate() if @name?
		
		if @arguments? {
			for argument in @arguments {
				argument.translate()
			}
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		let data = @data
		let variable = @variable
		
		let line = fragments
			.newLine()
			.code($runtime.helper(this), '.', @instance ? 'newInstanceMethod' : 'newClassMethod', '(')
		
		let object = line.newObject()
		
		object.line('class: ', variable.name is String ? variable.name : variable.name.name)
		
		if data.name.kind == NodeKind::TemplateExpression {
			object.newLine().code('name: ').compile(@name).done()
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
		
		object.newLine().code('function: ').compile(@functionName)
		
		if data.arguments? {
			let argsLine = object.newLine().code('arguments: ')
			let array = argsLine.newArray()
			
			for argument in @arguments {
				array.newLine().compile(argument).done()
			}
			
			array.done()
			argsLine.done()
		}
		
		let signLine = object.newLine().code('signature: ')
		
		$helper.reflectMethod(this, signLine, @signature)
		
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
		@value = $compile.expression(@data.defaultValue, this)
		@value.analyse()
		
		let property = {
			kind: VariableKind::Variable
			name: @data.name.name
		}
		
		if @data.type? {
			property.type = $type.type(@data.type, @scope, this)
		}
		
		@variable.sealed.properties[property.name] = property
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments
			.newLine()
			.code(@variable.sealed.name, '.', @data.name.name, ' = ')
			.compile(@value)
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
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))
			
			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}
		
		let property = {
			kind: VariableKind::Function
			name: @data.name.name
			signature: $function.signature(@data, this)
		}
		
		if @data.type? {
			property.type = $type.type(@data.type, @scope, this)
		}
		
		@variable.sealed.properties[property.name] = property
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		if @data.body? {
			@statements = []
			for statement in $body(@data.body) {
				@statements.push(statement = $compile.statement(statement, this))
				
				statement.analyse()
			}
			
			for statement in @statements {
				statement.prepare()
			}
			
			for statement in @statements {
				statement.translate()
			}
		}
		else {
			@statements = []
		}
	} // }}}
	isMethod() => false
	toFragments(fragments, mode) { // {{{
		let line = fragments.newLine().code(@variable.sealed.name, '.', @data.name.name, ' = function(')
		
		let block = $function.parameters(this, line, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in @statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done()
	} // }}}
}