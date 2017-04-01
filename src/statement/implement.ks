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
					NodeKind::MethodDeclaration => {
						property = new ImplementClassMethodDeclaration(property, this, @variable)
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
		_defaultValue				= null
		_hasDefaultValue: Boolean	= false
		_instance: Boolean			= true
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
		
		if @data.defaultValue? {
			@hasDefaultValue = true
			
			if @instance {
				let scope = @scope
				
				@scope = @parent._instanceVariableScope
				
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
				
				@scope = scope
			}
			else {
				@defaultValue = $compile.expression(@data.defaultValue, this)
				@defaultValue.analyse()
			}
		}
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
		
		@defaultValue.prepare() if @defaultValue?
	} // }}}
	translate() { // {{{
		@defaultValue.translate() if @defaultValue?
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @hasDefaultValue {
			if @instance {
				throw new NotImplementedException(this)
			}
			else {
				throw new NotImplementedException(this)
			}
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
		else if type.name? {
			this.toTypeString(type.name, path)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}

class ImplementClassMethodDeclaration extends Statement {
	private {
		_isContructor: Boolean	= false
		_isDestructor: Boolean	= false
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_parameters
		_sealed: Boolean		= false
		_signature
		_statements
		_variable
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, new Scope(parent.scope()))
		
		@sealed = @variable.sealed?
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		
		if @isContructor = @data.name.kind == NodeKind::Identifier && $method.isConstructor(@name, @variable) {
			throw new NotImplementedException(this)
		}
		else if @isDestructor = @data.name.kind == NodeKind::Identifier && $method.isDestructor(@name, @variable) {
			throw new NotImplementedException(this)
		}
		else {
			for i from 0 til @data.modifiers.length while @instance {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
			}
			
			if !@instance && (@name == 'name' || @name == 'version') {
				SyntaxException.throwReservedClassMethod(@name, @parent)
			}
			
			if @sealed {
				if @instance {
					if @variable.sealed.instanceMethods[@name] != true {
						@variable.sealed.instanceMethods[@name] = true
					}
				}
				else {
					if @variable.sealed.classMethods[@name] != true {
						@variable.sealed.classMethods[@name] = true
					}
				}
			}
		}
		
		$variable.define(this, @scope, {
			kind: NodeKind::Identifier
			name: 'this'
		}, true, VariableKind::Variable, $type.reference(@variable.name))
		
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
		
		if @sealed {
			@signature.sealed = true
		}
		
		if @instance {
			if @variable.instanceMethods[@name] is Array {
				@internalName = `__ks_func_\(@name)_\(@variable.instanceMethods[@name].length)`
				
				@variable.instanceMethods[@name].push(@signature)
			}
			else {
				@internalName = `__ks_func_\(@name)_0`
				
				@variable.instanceMethods[@name] = [@signature]
			}
		}
		else {
			if @variable.classMethods[@name] is Array {
				@internalName = `__ks_sttc_\(@name)_\(@variable.classMethods[@name].length)`
				
				@variable.classMethods[@name].push(@signature)
			}
			else {
				@internalName = `__ks_sttc_\(@name)_0`
				
				@variable.classMethods[@name] = [@signature]
			}
		}
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
		if @isContructor {
			throw new NotImplementedException(this)
		}
		else if @isDestructor {
			throw new NotImplementedException(this)
		}
		else {
			const line = fragments.newLine()
			
			if @sealed {
				line.code(`\(@variable.sealed.name).\(@internalName) = function(`)
			}
			else {
				if @instance {
					line.code(`\(@variable.name.name || @variable.name).prototype.\(@internalName) = function(`)
				}
				else {
					line.code(`\(@variable.name.name || @variable.name).\(@internalName) = function(`)
				}
			}
			
			const block = $function.parameters(this, line, false, func(node) {
				line.code(')')
				
				return line.newBlock()
			})
			
			if @instance {
				for parameter in @parameters {
					if parameter._thisAlias && !$method.isUsingProperty($body(@data.body), parameter._name) {
						if parameter._setterAlias {
							if (@name != parameter._name || @signature.min != 1 || @signature.max != 1) && this.isInstanceMethod(parameter._name) {
								block.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
							}
							else {
								ReferenceException.throwNotDefinedMember(parameter._name, this)
							}
						}
						else {
							if this.isInstanceVariable(parameter._name) {
								block.newLine().code('this.' + parameter._name + ' = ').compile(parameter).done()
							}
							else if this.isInstanceVariable('_' + parameter._name) {
								block.newLine().code('this._' + parameter._name + ' = ').compile(parameter).done()
							}
							else if (@name != parameter._name || @signature.min != 1 || @signature.max != 1) && this.isInstanceMethod(parameter._name) {
								block.newLine().code('this.' + parameter._name + '(').compile(parameter).code(')').done()
							}
							else {
								ReferenceException.throwNotDefinedMember(parameter._name, this)
							}
						}
					}
				}
			}
			
			for statement in @statements {
				block.compile(statement)
			}
			
			block.done()
			line.done()
			
			if @instance {
				if @sealed {
					$helper.methods(this, fragments.newLine(), @variable, @variable.instanceMethods[@name], null, (node, fragments) => {
						const block = fragments.code(`\(@variable.sealed.name)._im_\(@name) = function(that)`).newBlock()
						
						block.line('var args = Array.prototype.slice.call(arguments, 1, arguments.length)')
						
						return block
					}, (fragments) => fragments.done(), (fragments, method, index) => {
						if method.max == 0 {
							if method.sealed {
								fragments.line(`return \(@variable.sealed.name).__ks_func_\(@name)_\(index).apply(that)`)
							}
							else {
								fragments.line(`return \(@variable.name.name || @variable.name).prototype.__ks_func_\(@name)_\(index).apply(that)`)
							}
						}
						else {
							if method.sealed {
								fragments.line(`return \(@variable.sealed.name).__ks_func_\(@name)_\(index).apply(that, args)`)
							}
							else {
								fragments.line(`return \(@variable.name.name || @variable.name).prototype.__ks_func_\(@name)_\(index).apply(that, args)`)
							}
						}
					}, 'args', true).done()
				}
				else {
					$helper.instanceMethod(this, fragments.newLine(), @variable, @variable.instanceMethods[@name], @name, (node, fragments) => {
						return fragments.code(`\(@variable.name.name || @variable.name).prototype.\(@name) = function()`).newBlock()
					}, (fragments) => fragments.done()).done()
				}
			}
			else {
				if @sealed {
					$helper.methods(this, fragments.newLine(), @variable, @variable.classMethods[@name], null, (node, fragments) => {
						const block = fragments.code(`\(@variable.sealed.name)._cm_\(@name) = function()`).newBlock()
						
						block.line('var args = Array.prototype.slice.call(arguments)')
						
						return block
					}, (fragments) => fragments.done(), (fragments, method, index) => {
						if method.max == 0 {
							if method.sealed {
								fragments.line(`return \(@variable.sealed.name).__ks_sttc_\(@name)_\(index)()`)
							}
							else {
								fragments.line(`return \(@variable.name.name || @variable.name).__ks_sttc_\(@name)_\(index)()`)
							}
						}
						else {
							if method.sealed {
								fragments.line(`return \(@variable.sealed.name).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
							else {
								fragments.line(`return \(@variable.name.name || @variable.name).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
						}
					}, 'args', true).done()
				}
				else {
					$helper.classMethod(this, fragments.newLine(), @variable, @variable.classMethods[@name], @name, (node, fragments) => {
						return fragments.code(`\(@variable.name.name || @variable.name).\(@name) = function()`).newBlock()
					}, (fragments) => fragments.done()).done()
				}
			}
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
		else if type.name? {
			this.toTypeString(type.name, path)
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
		
		let block = $function.parameters(this, line, false, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in @statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done()
	} // }}}
}