class ImplementDeclaration extends Statement {
	private {
		_properties = []
		_type: Type
		_variable
	}
	analyse() { // {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}
		
		@type = @variable.type().unalias()
		
		if @type is ClassType {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementClassFieldDeclaration(property, this, @type)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementClassMethodDeclaration(property, this, @type)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(property.kind)`, this)
					}
				}
				
				property.analyse()
				
				@properties.push(property)
			}
		}
		/* else if @type is ObjectType {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementObjectVariableDeclaration(property, this, @type)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementObjectFunctionDeclaration(property, this, @type)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(property.kind)`, this)
					}
				}
				
				property.analyse()
				
				@properties.push(property)
			}
		} */
		else if @type is NamespaceType {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementNamespaceVariableDeclaration(property, this, @type)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementNamespaceFunctionDeclaration(property, this, @type)
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
	type() => @type
}

class ImplementClassFieldDeclaration extends Statement {
	private {
		_class: ClassType
		_defaultValue				= null
		_hasDefaultValue: Boolean	= false
		_instance: Boolean			= true
		_name: String
		_type: ClassVariableType
	}
	constructor(data, parent, @class) { // {{{
		super(data, parent)
		
		if class.isSealed() {
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
		@type = Type.fromAST(@data, this)
		
		if @instance {
			@class.addInstanceVariable(@name, @type)
		}
		else {
			@class.addClassVariable(@name, @type)
		}
		
		if @hasDefaultValue {
			@defaultValue.prepare()
		}
	} // }}}
	translate() { // {{{
		if @hasDefaultValue {
			@defaultValue.translate()
		}
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
	type() => @type
}

class ImplementClassMethodDeclaration extends Statement {
	private {
		_aliases: Array			= []
		_body: Array
		_class: ClassType
		_isContructor: Boolean	= false
		_isDestructor: Boolean	= false
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_parameters: Array<Parameter>
		_statements
		_this: Variable
		_type: Type
	}
	constructor(data, parent, @class) { // {{{
		super(data, parent, new Scope(parent.scope()))
	} // }}}
	analyse() { // {{{
		@name = @data.name.name
		@body = $ast.body(@data.body)
		
		if @isContructor = (@data.name.kind == NodeKind::Identifier && @class.isConstructor(@name)) {
			throw new NotImplementedException(this)
		}
		else if @isDestructor = (@data.name.kind == NodeKind::Identifier && @class.isDestructor(@name)) {
			throw new NotImplementedException(this)
		}
		else {
			for i from 0 til @data.modifiers.length while @instance {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
			}
		}
		
		@this = @scope.define('this', true, @class.reference(), this)
		
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
		
		@type = new ClassMethodType([parameter.type() for parameter in @parameters], @data, this)
		
		if @class.isSealed() {
			@type.seal()
		}
		
		if @instance {
			@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
		}
		else {
			@internalName = `__ks_sttc_\(@name)_\(@class.addClassMethod(@name, @type))`
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		@statements = []
		
		for statement in @aliases {
			@statements.push(statement)
			
			statement.analyse()
		}
		
		for statement in @body {
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
	addAliasStatement(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@body, statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	class() => @class
	isMethod() => true
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		if @isContructor {
			throw new NotImplementedException(this)
		}
		else if @isDestructor {
			throw new NotImplementedException(this)
		}
		else {
			const line = fragments.newLine()
			
			if @class.isSealed() {
				line.code(`\(@class.sealName()).\(@internalName) = function(`)
			}
			else {
				if @instance {
					line.code(`\(@class.name()).prototype.\(@internalName) = function(`)
				}
				else {
					line.code(`\(@class.name()).\(@internalName) = function(`)
				}
			}
			
			const block = Parameter.toFragments(this, line, false, func(node) {
				line.code(')')
				
				return line.newBlock()
			})
			
			for statement in @statements {
				block.compile(statement)
			}
			
			block.done()
			line.done()
			
			if @instance {
				if @class.isSealed() {
					ClassDeclaration.toSwitchFragments(this, fragments.newLine(), @class, @class.getInstanceMethods(@name), null, (node, fragments) => {
						const block = fragments.code(`\(@class.sealName())._im_\(@name) = function(that)`).newBlock()
						
						block.line('var args = Array.prototype.slice.call(arguments, 1, arguments.length)')
						
						return block
					}, (fragments) => fragments.done(), (fragments, method, index) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@class.sealName()).__ks_func_\(@name)_\(index).apply(that)`)
							}
							else {
								fragments.line(`return \(@class.name()).prototype.__ks_func_\(@name)_\(index).apply(that)`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@class.sealName()).__ks_func_\(@name)_\(index).apply(that, args)`)
							}
							else {
								fragments.line(`return \(@class.name()).prototype.__ks_func_\(@name)_\(index).apply(that, args)`)
							}
						}
					}, 'args', true).done()
				}
				else {
					ClassMethodDeclaration.toInstanceSwitchFragments(this, fragments.newLine(), @class, @class.getInstanceMethods(@name), @name, (node, fragments) => fragments.code(`\(@class.name()).prototype.\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
				}
			}
			else {
				if @class.isSealed() {
					ClassDeclaration.toSwitchFragments(this, fragments.newLine(), @class, @class.getClassMethods(@name), null, (node, fragments) => {
						const block = fragments.code(`\(@class.sealName())._cm_\(@name) = function()`).newBlock()
						
						block.line('var args = Array.prototype.slice.call(arguments)')
						
						return block
					}, (fragments) => fragments.done(), (fragments, method, index) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@class.sealName()).__ks_sttc_\(@name)_\(index)()`)
							}
							else {
								fragments.line(`return \(@class.name()).__ks_sttc_\(@name)_\(index)()`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@class.sealName()).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
							else {
								fragments.line(`return \(@class.name()).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
						}
					}, 'args', true).done()
				}
				else {
					ClassMethodDeclaration.toClassSwitchFragments(this, fragments.newLine(), @class, @class.getClassMethods(@name), @name, (node, fragments) => fragments.code(`\(@class.name()).\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
				}
			}
		}
	} // }}}
	type() => @type
}

/* class ImplementObjectVariableDeclaration extends Statement {
	private {
		_object: ObjectType
		_value
	}
	constructor(data, parent, @object) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.defaultValue, this)
		@value.analyse()
		
		@object.addSealedProperty(@data.name.name, Type.fromAST(@data.type, this))
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
			.code(@object.sealName(), '.', @data.name.name, ' = ')
			.compile(@value)
			.done()
	} // }}}
}

class ImplementObjectFunctionDeclaration extends Statement {
	private {
		_object: ObjectType
		_parameters: Array
		_statements: Array
		_type: FunctionType
	}
	constructor(data, parent, @object) { // {{{
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
		
		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)
		
		@object.addSealedProperty(@data.name.name, @type)
	} // }}}
	translate() { // {{{
		if @data.body? {
			@statements = []
			for statement in $ast.body(@data.body) {
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
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code(@object.sealName(), '.', @data.name.name, ' = function(')
		
		const block = Parameter.toFragments(this, line, false, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in @statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done()
	} // }}}
	type() => @type
} */
class ImplementNamespaceVariableDeclaration extends Statement {
	private {
		_namespace: NamespaceType
		_value
	}
	constructor(data, parent, @namespace) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.defaultValue, this)
		@value.analyse()
		
		@namespace.addProperty(@data.name.name, Type.fromAST(@data.type, this))
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	toFragments(fragments, mode) { // {{{
		/* fragments
			.newLine()
			.code(@object.sealName(), '.', @data.name.name, ' = ')
			.compile(@value)
			.done() */
		if @namespace.isSealed() {
			fragments
				.newLine()
				.code(@namespace.sealName(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
		else {
			fragments
				.newLine()
				.code(@namespace.name(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
	} // }}}
}

class ImplementNamespaceFunctionDeclaration extends Statement {
	private {
		_namespace: NamespaceType
		_parameters: Array
		_statements: Array
		_type: FunctionType
	}
	constructor(data, parent, @namespace) { // {{{
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
		
		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)
		
		@namespace.addProperty(@data.name.name, @type)
	} // }}}
	translate() { // {{{
		if @data.body? {
			@statements = []
			for statement in $ast.body(@data.body) {
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
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		/* const line = fragments.newLine().code(@object.sealName(), '.', @data.name.name, ' = function(')
		
		const block = Parameter.toFragments(this, line, false, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in @statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done() */
		const line = fragments.newLine()
		
		if @namespace.isSealed() {
			line.code(@namespace.sealName())
		}
		else {
			line.code(@namespace.name())
		}
		
		line.code('.', @data.name.name, ' = function(')
		
		const block = Parameter.toFragments(this, line, false, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		for statement in @statements {
			block.compile(statement)
		}
		
		block.done()
		
		line.done()
	} // }}}
	type() => @type
}