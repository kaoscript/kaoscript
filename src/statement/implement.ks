class ImplementDeclaration extends Statement {
	private {
		_properties			= []
		_sharingProperties	= {}
		_type: NamedType
		_variable: Variable
	}
	analyse() { // {{{
		if @variable !?= @scope.getVariable(@data.variable.name) {
			ReferenceException.throwNotDefined(@data.variable.name, this)
		}
	} // }}}
	prepare() { // {{{
		@variable.prepareAlteration()

		@type = @variable.getDeclaredType()

		unless @type is NamedType {
			TypeException.throwImplInvalidType(this)
		}

		const type = @type.type()

		if type is ClassType {
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
		else if type is NamespaceType {
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

		for const property of @sharingProperties {
			property.toSharedFragments(fragments)
		}
	} // }}}
	type() => @type
}

class ImplementClassFieldDeclaration extends Statement {
	private {
		_class: ClassType
		_classRef: ReferenceType
		_defaultValue				= null
		_hasDefaultValue: Boolean	= false
		_init: Number				= 0
		_instance: Boolean			= true
		_name: String
		_type: ClassVariableType
		_variable: NamedType<ClassType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)

		@class = @variable.type()

		if @class.isSealed() {
			TypeException.throwImplFieldToSealedType(this)
		}

		@classRef = @scope.reference(@variable)
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

				line.code(`\(@variable.name()).prototype.__ks_init_\(@init) = function()`)

				const block = line.newBlock()

				block.newLine().code(`this.\(@name) = `).compile(@defaultValue).done()

				block.done()
				line.done()
			}
			else {
				fragments.newLine().code(`\(@variable.name()).\(@name) = `).compile(@defaultValue).done()
			}
		}
	} // }}}
	toSharedFragments(fragments) { // {{{
		const line = fragments.newLine()

		line.code(`\(@variable.name()).prototype.__ks_init = function()`)

		const block = line.newBlock()

		for let i from 1 to @init {
			block.line(`\(@variable.name()).prototype.__ks_init_\(i).call(this)`)
		}

		block.done()
		line.done()
	} // }}}
	type() => @type
}

class ImplementClassMethodDeclaration extends Statement {
	private {
		_aliases: Array			= []
		_block: Block
		_class: ClassType
		_classRef: ReferenceType
		_isContructor: Boolean	= false
		_isDestructor: Boolean	= false
		_instance: Boolean		= true
		_internalName: String
		_name: String
		_override: Boolean		= false
		_parameters: Array<Parameter>
		_this: Variable
		_type: Type
		_variable: NamedType<ClassType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		@class = @variable.type()
		@classRef = @scope.reference(@variable)
	} // }}}
	analyse() { // {{{
		@scope.line(@data.start.line)

		@name = @data.name.name

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

		@this = @scope.define('this', true, @classRef, this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = $compile.block($ast.body(@data), this)
	} // }}}
	prepare() { // {{{
		@scope.line(@data.start.line)

		for const parameter in @parameters {
			parameter.prepare()
		}

		@type = new ClassMethodType([parameter.type() for const parameter in @parameters] as Array<ParameterType>, @data, this)

		@type.flagAlteration()

		if @class.isSealed() {
			@type.flagSealed()
		}

		if @instance {
			if const index = @class.matchInstanceMethod(@name, @type) {
				if @override {
					@internalName = `__ks_func_\(@name)_\(index)`
				}
				else {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
			}
			else {
				@override = false
				@internalName = `__ks_func_\(@name)_\(@class.addInstanceMethod(@name, @type))`
			}
		}
		else {
			if const index = @class.matchClassMethod(@name, @type) {
				if @override {
					@internalName = `__ks_sttc_\(@name)_\(index)`
				}
				else {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
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

		@block.analyse(@aliases)

		@block.analyse()

		@block.type(@type.returnType()).prepare()

		@block.translate()
	} // }}}
	addAliasStatement(statement: AliasStatement) { // {{{
		if !ClassDeclaration.isAssigningAlias(@block.statements(), statement.name(), false, false) {
			@aliases.push(statement)
		}
	} // }}}
	class() => @class
	getSharedName() => @override ? null : @instance ? `_im_\(@name)` : `_cm_\(@name)`
	isConsumedError(error): Boolean => @type.isCatchingError(error)
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
				line.code(`\(@variable.getSealedName()).\(@internalName) = function(`)
			}
			else {
				if @instance {
					line.code(`\(@variable.name()).prototype.\(@internalName) = function(`)
				}
				else {
					line.code(`\(@variable.name()).\(@internalName) = function(`)
				}
			}

			const block = Parameter.toFragments(this, line, ParameterMode::Default, func(node) {
				line.code(')')

				return line.newBlock()
			})

			block.compile(@block)

			block.done()
			line.done()
		}
	} // }}}
	toSharedFragments(fragments) { // {{{
		return if @override

		if @instance {
			if @class.isSealed() {
				const assessment = Router.assess(@class.listInstanceMethods(@name), false)

				Router.toFragments(
					assessment
					fragments.newLine()
					'args'
					true
					(node, fragments) => {
						const block = fragments.code(`\(@variable.getSealedName())._im_\(@name) = function(that)`).newBlock()

						block.line('var args = Array.prototype.slice.call(arguments, 1, arguments.length)')

						return block
					}
					(fragments) => fragments.done()
					(fragments, method, index) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_func_\(@name)_\(index).apply(that)`)
							}
							else {
								fragments.line(`return \(@variable.name()).prototype.__ks_func_\(@name)_\(index).apply(that)`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_func_\(@name)_\(index).apply(that, args)`)
							}
							else {
								fragments.line(`return \(@variable.name()).prototype.__ks_func_\(@name)_\(index).apply(that, args)`)
							}
						}
					}
					ClassDeclaration.toWrongDoingFragments
					this
				).done()
			}
			else {
				ClassMethodDeclaration.toInstanceSwitchFragments(this, fragments.newLine(), @variable, @class.listInstanceMethods(@name), @name, (node, fragments) => fragments.code(`\(@variable.name()).prototype.\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
			}
		}
		else {
			if @class.isSealed() {
				const assessment = Router.assess(@class.listClassMethods(@name), false)

				Router.toFragments(
					assessment
					fragments.newLine()
					'args'
					true
					(node, fragments) => {
						const block = fragments.code(`\(@variable.getSealedName())._cm_\(@name) = function()`).newBlock()

						block.line('var args = Array.prototype.slice.call(arguments)')

						return block
					}
					(fragments) => fragments.done()
					(fragments, method, index) => {
						if method.max() == 0 {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_sttc_\(@name)_\(index)()`)
							}
							else {
								fragments.line(`return \(@variable.name()).__ks_sttc_\(@name)_\(index)()`)
							}
						}
						else {
							if method.isSealed() {
								fragments.line(`return \(@variable.getSealedName()).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
							else {
								fragments.line(`return \(@variable.name()).__ks_sttc_\(@name)_\(index).apply(null, args)`)
							}
						}
					}
					ClassDeclaration.toWrongDoingFragments
					this
				).done()
			}
			else {
				ClassMethodDeclaration.toClassSwitchFragments(this, fragments.newLine(), @variable, @class.listClassMethods(@name), @name, (node, fragments) => fragments.code(`\(@variable.name()).\(@name) = function()`).newBlock(), (fragments) => fragments.done()).done()
			}
		}
	} // }}}
	type() => @type
}

class ImplementNamespaceVariableDeclaration extends Statement {
	private {
		_namespace: NamespaceType
		_value
		_type: Type
		_variable: NamedType<NamespaceType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent)

		@namespace = @variable.type()
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.defaultValue, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()

		const property = NamespacePropertyType.fromAST(@data.type, this)

		property.flagAlteration()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@namespace.addProperty(@data.name.name, property)

		@type = property.type()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	getSharedName() => null
	toFragments(fragments, mode) { // {{{
		if @namespace.isSealed() {
			fragments
				.newLine()
				.code(@variable.getSealedName(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
		else {
			fragments
				.newLine()
				.code(@variable.name(), '.', @data.name.name, ' = ')
				.compile(@value)
				.done()
		}
	} // }}}
	type() => @type
}

class ImplementNamespaceFunctionDeclaration extends Statement {
	private {
		_block: Block
		_namespace: NamespaceType
		_namespaceRef: ReferenceType
		_parameters: Array
		_type: FunctionType
		_variable: NamedType<NamespaceType>
	}
	constructor(data, parent, @variable) { // {{{
		super(data, parent, parent.scope(), ScopeType::Block)

		@namespace = @variable.type()
		@namespaceRef = @scope.reference(@variable)
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

		const property = NamespacePropertyType.fromAST(@data, this)

		property.flagAlteration()

		if @namespace.isSealed() {
			property.flagSealed()
		}

		@namespace.addProperty(@data.name.name, property)

		@type = property.type()
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		@block = $compile.block($ast.body(@data), this)
		@block.analyse()

		@block.type(@type.returnType()).prepare()

		@block.translate()
	} // }}}
	getSharedName() => null
	isInstanceMethod() => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		const line = fragments.newLine()

		if @namespace.isSealed() {
			line.code(@variable.getSealedName())
		}
		else {
			line.code(@variable.name())
		}

		line.code('.', @data.name.name, ' = function(')

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			return fragments.code(')').newBlock()
		})

		block.compile(@block)

		block.done()

		line.done()
	} // }}}
	type() => @type
}