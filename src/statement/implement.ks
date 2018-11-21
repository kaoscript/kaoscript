class ImplementDeclaration extends Statement {
	private {
		_properties			= []
		_sharingProperties	= {}
		_type: Type
		_variable
	}
	analyse() { // {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}
	} // }}}
	prepare() { // {{{
		@variable.prepareAlteration()

		@type = @variable.type().unalias()

		if @type is ClassType {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementClassFieldDeclaration(property, this, @type:ClassType)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementClassMethodDeclaration(property, this, @type:ClassType)
					}
					=> {
						throw new NotSupportedException(`Unexpected kind \(property.kind)`, this)
					}
				}

				property.analyse()

				@properties.push(property)
			}
		}
		else if @type is NamespaceType {
			for property in @data.properties {
				switch property.kind {
					NodeKind::FieldDeclaration => {
						property = new ImplementNamespaceVariableDeclaration(property, this, @type:NamespaceType)
					}
					NodeKind::MethodDeclaration => {
						property = new ImplementNamespaceFunctionDeclaration(property, this, @type:NamespaceType)
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

		let name
		for property in @properties {
			property.prepare()
			
			if name ?= property.getSharedName() {
				@sharingProperties[name] = property
			}
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
		
		for :property of @sharingProperties {
			property.toSharedFragments(fragments)
		}
	} // }}}
	type() => @type
}

class ImplementClassFieldDeclaration extends Statement {
	private {
		_class: ClassType
		_defaultValue				= null
		_hasDefaultValue: Boolean	= false
		_init: Number				= 0
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

			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}
	} // }}}
	prepare() { // {{{
		@type = ClassVariableType.fromAST(@data, this)

		@type.flagAlteration()

		if @instance {
			@class.addInstanceVariable(@name, @type)
		}
		else {
			@class.addClassVariable(@name, @type)
		}

		if @hasDefaultValue {
			if @instance {
				@init = @class.init() + 1
				
				@class.init(@init)
			}
			
			@defaultValue.prepare()
		}
	} // }}}
	translate() { // {{{
		if @hasDefaultValue {
			@defaultValue.translate()
		}
	} // }}}
	getSharedName() => @hasDefaultValue && @instance ? '__ks_init' : null
	toFragments(fragments, mode) { // {{{
		if @hasDefaultValue {
			if @instance {
				const line = fragments.newLine()
				
				line.code(`\(@class.name()).prototype.__ks_init_\(@init) = function()`)

				const block = line.newBlock()

				block.newLine().code(`this.\(@name) = `).compile(@defaultValue).done()

				block.done()
				line.done()
			}
			else {
				fragments.newLine().code(`\(@class.name()).\(@name) = `).compile(@defaultValue).done()
			}
		}
	} // }}}
	toSharedFragments(fragments) { // {{{
		const line = fragments.newLine()

		line.code(`\(@class.name()).prototype.__ks_init = function()`)

		const block = line.newBlock()

		for let i from 1 to @init {
			block.line(`\(@class.name()).prototype.__ks_init_\(i).call(this)`)
		}

		block.done()
		line.done()
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
		_override: Boolean		= false
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
			for i from 0 til @data.modifiers.length {
				if @data.modifiers[i].kind == ModifierKind::Static {
					@instance = false
				}
				else if @data.modifiers[i].kind == ModifierKind::Override {
					@override = true
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

		@type.flagAlteration()

		if @class.isSealed() {
			@type.seal()
		}

		if @instance {
			if @override && (index ?= @class.matchInstanceMethod(@name, @type)) {
				@internalName = `__ks_func_\(@name)_\(index)`
			}
			else {
				@override = false
				@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
			}
		}
		else {
			if @override && (index ?= @class.matchClassMethod(@name, @type)) {
				@internalName = `__ks_sttc_\(@name)_\(index)`
			}
			else {
				@override = false
				@internalName = `__ks_sttc_\(@name)_\(@class.addClassMethod(@name, @type))`
			}
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
	getSharedName() => @override ? null : @instance ? `_im_\(@name)` : `_cm_\(@name)`
	isInstance() => @instance
	isInstanceMethod() => @instance
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

			const block = Parameter.toFragments(this, line, ParameterMode::Default, func(node) {
				line.code(')')

				return line.newBlock()
			})

			for statement in @statements {
				block.compile(statement)
			}

			block.done()
			line.done()
		}
	} // }}}
	toSharedFragments(fragments) { // {{{
		return if @override
		
		if @instance {
			if @class.isSealed() {
				ClassDeclaration.toSwitchFragments(this, fragments.newLine(), @class, @class.getInstanceMethods(@name), @name, null, (node, fragments) => {
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
				}, ClassDeclaration.toWrongDoingFragments, 'args', true).done()
			}
			else {
				ClassMethodDeclaration.toInstanceSwitchFragments(this, fragments.newLine(), @class, @class.getInstanceMethods(@name), @name, (node, fragments) => fragments.code(`\(@class.name()).prototype.\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
			}
		}
		else {
			if @class.isSealed() {
				ClassDeclaration.toSwitchFragments(this, fragments.newLine(), @class, @class.getClassMethods(@name), @name, null, (node, fragments) => {
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
				}, ClassDeclaration.toWrongDoingFragments, 'args', true).done()
			}
			else {
				ClassMethodDeclaration.toClassSwitchFragments(this, fragments.newLine(), @class, @class.getClassMethods(@name), @name, (node, fragments) => fragments.code(`\(@class.name()).\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
			}
		}
	} // }}}
	type() => @type
}

class ImplementNamespaceVariableDeclaration extends Statement {
	private {
		_namespace: NamespaceType
		_value
		_type: FunctionType
	}
	constructor(data, parent, @namespace) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.defaultValue, this)
		@value.analyse()

		//@namespace.addProperty(@data.name.name, Type.fromAST(@data.type, this))
	} // }}}
	prepare() { // {{{
		@value.prepare()

		@type = NamespaceVariableType.fromAST(@data, this)

		@namespace.addProperty(@data.name.name, @type)
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	getSharedName() => null
	toFragments(fragments, mode) { // {{{
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
	type() => @type
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

		@type = NamespaceFunctionType.fromAST(@data, this)

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
	getSharedName() => null
	isInstanceMethod() => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		const line = fragments.newLine()

		if @namespace.isSealed() {
			line.code(@namespace.sealName())
		}
		else {
			line.code(@namespace.name())
		}

		line.code('.', @data.name.name, ' = function(')

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
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