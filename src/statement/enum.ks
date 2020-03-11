class EnumDeclaration extends Statement {
	private lateinit {
		@enum: EnumType
		@instanceMethods: Dictionary	= {}
		@name: String
		@staticMethods: Dictionary		= {}
		@type: NamedType<EnumType>
		@variable: Variable
		@variables: Dictionary			= {}
	}
	analyse() { // {{{
		@name = @data.name.name

		const type = Type.fromAST(@data.type, this)

		if type.isString() {
			@enum = new EnumType(@scope, EnumTypeKind::String)
		}
		else if @data.modifiers.length != 0 {
			let nf = true
			for const modifier in @data.modifiers while nf {
				if modifier.kind == ModifierKind::Flagged {
					@enum = new EnumType(@scope, EnumTypeKind::Flags)

					nf = false
				}
			}

			if nf {
				@enum = new EnumType(@scope)
			}
		}
		else {
			@enum = new EnumType(@scope)
		}

		@type = new NamedType(@name, @enum)

		@variable = @scope.define(@name, true, @type, this)

		let declaration
		for const data in @data.members {
			switch data.kind {
				NodeKind::CommentBlock => {
				}
				NodeKind::CommentLine => {
				}
				NodeKind::FieldDeclaration => {
					declaration = new EnumVariableDeclaration(data, this)

					declaration.analyse()
				}
				NodeKind::MethodDeclaration => {
					declaration = new EnumMethodDeclaration(data, this)

					declaration.analyse()
				}
				=> {
					throw new NotSupportedException(`Unknow kind \(data.kind)`, this)
				}
			}
		}
	} // }}}
	prepare() { // {{{
		@type = @variable.getRealType()
		@enum = @type.type()

		for const variable, name of @variables {
			variable.prepare()

			@enum.addVariable(name)
		}

		for const methods, name of @instanceMethods {
			let async: Boolean

			for const method, index in methods {
				method.prepare()

				if index == 0 {
					async = method.type().isAsync()
				}
				else if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @enum.hasMatchingInstanceMethod(name, method.type(), MatchingMode::ExactParameters) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@enum.addInstanceMethod(name, method.type())
			}
		}

		for const methods, name of @staticMethods {
			let async: Boolean

			for const method, index in methods {
				method.prepare()

				if index == 0 {
					async = method.type().isAsync()
				}
				else if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @enum.hasMatchingStaticMethod(name, method.type(), MatchingMode::ExactParameters) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@enum.addStaticMethod(name, method.type())
			}
		}
	} // }}}
	translate() { // {{{
		for const variable of @variables {
			variable.translate()
		}

		for const methods of @instanceMethods {
			for const method in methods {
				method.translate()
			}
		}

		for const methods of @staticMethods {
			for const method in methods {
				method.translate()
			}
		}
	} // }}}
	export(recipient) { // {{{
		recipient.export(@name, @variable)
	} // }}}
	name() => @name
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine().code($runtime.scope(this), @name, $equals, $runtime.helper(this), '.enum(')

		if @type.isString() {
			line.code('String, ')
		}
		else {
			line.code('Number, ')
		}

		const object = line.newObject()

		for const variable of @variables when !variable.isComposite() {
			variable.toFragments(object)
		}

		object.done()

		line.code(')').done()

		for const variable of @variables when variable.isComposite() {
			variable.toFragments(fragments)
		}

		for const methods of @staticMethods {
			if methods.length == 1 {
				fragments.compile(methods[0])
			}
			else {
				NotImplementedException.throw(methods[0])
			}
		}

		for const methods of @instanceMethods {
			if methods.length == 1 {
				fragments.compile(methods[0])
			}
			else {
				NotImplementedException.throw(methods[0])
			}
		}
	} // }}}
	type() => @type
}

class EnumVariableDeclaration extends AbstractNode {
	private lateinit {
		@operands: Array
		@value: String
		@type: Type
	}
	private {
		@composite: Boolean				= false
		@name: String
	}
	constructor(data, parent) { // {{{
		super(data, parent)

		@name = data.name.name

		parent._variables[@name] = this
	} // }}}
	analyse() { // {{{
		const enum = @parent.type().type()
		const value = @data.value

		switch enum.kind() {
			EnumTypeKind::Flags => {
				if value? {
					if value.kind == NodeKind::BinaryExpression && (value.operator.kind == BinaryOperatorKind::BitwiseOr || value.operator.kind == BinaryOperatorKind::Addition) {
						@composite = true

						@operands = [value.left, value.right]
					}
					else if value.kind == NodeKind::PolyadicExpression && (value.operator.kind == BinaryOperatorKind::BitwiseOr || value.operator.kind == BinaryOperatorKind::Addition) {
						@composite = true

						@operands = value.operands
					}
					else {
						if value.kind == NodeKind::NumericExpression {
							if value.value > 53 {
								SyntaxException.throwEnumOverflow(@parent.name(), this)
							}

							enum.index(value.value)
						}
						else {
							SyntaxException.throwInvalidEnumValue(value, this)
						}

						@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))`
					}
				}
				else {
					if enum.step() > 53 {
						SyntaxException.throwEnumOverflow(@parent.name(), this)
					}

					@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))`
				}

				@type = @scope.reference('Number')
			}
			EnumTypeKind::String => {
				if value? {
					if value.kind == NodeKind::Literal {
						@value = $quote(value.value)
					}
					else {
						throw new NotSupportedException(this)
					}
				}
				else {
					@value = $quote(@name.toLowerCase())
				}

				@type = @scope.reference('String')
			}
			EnumTypeKind::Number => {
				if value? {
					if value.kind == NodeKind::NumericExpression {
						@value = `\(enum.index(value.value))`
					}
					else {
						throw new NotSupportedException(this)
					}
				}
				else {
					@value = `\(enum.step())`
				}

				@type = @scope.reference('Number')
			}
		}
	} // }}}
	prepare()
	translate()
	isComposite() => @composite
	name() => @name
	toFragments(fragments) { // {{{
		if @composite {
			const name = @parent.name()
			const line = fragments.newLine().code(name, '.', @name, ' = ', name, '(')

			for const operand, i in @operands {
				line.code(' | ') if i > 0

				line.code(name, '.', operand.name)
			}

			line.code(')').done()
		}
		else {
			fragments.line(@name, ': ', @value)
		}
	} // }}}
	type() => @type
}

class EnumMethodDeclaration extends Statement {
	private lateinit {
		@block: FunctionBlock
		@type: Type
	}
	private {
		@autoTyping: Boolean			= false
		@awaiting: Boolean				= false
		@exit: Boolean					= false
		@name: String
		@indigentValues: Array			= []
		@instance: Boolean				= true
		@parameters: Array<Parameter>	= []
		@topNodes: Array				= []
	}
	constructor(data, parent) { // {{{
		super(data, parent, this.newScope(parent.scope(), ScopeType::Function))

		@name = data.name.name

		for const modifier in data.modifiers {
			if modifier.kind == ModifierKind::Static {
				@instance = false
			}
		}

		if @instance {
			if parent._instanceMethods[@name] is Array {
				parent._instanceMethods[@name].push(this)
			}
			else {
				parent._instanceMethods[@name] = [this]
			}
		}
		else {
			if parent._staticMethods[@name] is Array {
				parent._staticMethods[@name].push(this)
			}
			else {
				parent._staticMethods[@name] = [this]
			}
		}
	} // }}}
	analyse() { // {{{
		for const data in @data.parameters {
			const parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = new MethodBlock($ast.block($ast.body(@data)), this, @scope)
	} // }}}
	prepare() { // {{{
		const enumName = @parent.name()
		const enumRef = @scope.reference(enumName)

		for const variable, name of @parent._variables {
			const var = @scope.define(name, true, enumRef, true, @parent)

			var.renameAs(`\(enumName).\(name)`)
		}

		if @instance {
			@scope.define('this', true, enumRef, true, this)
			@scope.rename('this', 'that')
		}

		for const parameter in @parameters {
			parameter.prepare()
		}

		const arguments = [parameter.type() for const parameter in @parameters]

		@type = new EnumMethodType(arguments, @data, this)

		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} // }}}
	translate() { // {{{
		for const parameter in @parameters {
			parameter.translate()
		}

		for const indigent in @indigentValues {
			indigent.value.prepare()
			indigent.value.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.type(@type.getReturnType()).prepare()
		}

		@block.translate()

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} // }}}
	addIndigentValue(value: Expression, parameters) { // {{{
		const name = `__ks_default_\(@parent.type().type().incDefaultSequence())`

		@indigentValues.push({
			name
			value
			parameters
		})

		return name
	} // }}}
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
	getOverridableVarname() => @parent.name()
	getParameterOffset() => @instance ? 1 : 0
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isOverridableFunction() => true
	parameters() => @parameters
	toIndigentFragments(fragments) { // {{{
		for const {name, value, parameters} in @indigentValues {
			const line = fragments.newLine()
			const ctrl = line.newControl(null, false, false)

			ctrl.code(`\(@parent.name()).\(name) = function(\(parameters.join(', ')))`).step()

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done()
			line.done()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine()
		const ctrl = line.newControl(null, false, false)

		if @instance {
			ctrl.code(`\(@parent.name()).__ks_func_\(@name) = function(that`)
		}
		else {
			ctrl.code(`\(@parent.name()).\(@name) = function(`)
		}

		Parameter.toFragments(this, ctrl, ParameterMode::Default, node => node.code(')').step())

		for const node in @topNodes {
			node.toAuthorityFragments(ctrl)
		}

		if @awaiting {
			throw new NotImplementedException(this)
		}
		else {
			ctrl.compile(@block)
		}

		ctrl.done()
		line.done()

		this.toIndigentFragments(fragments)
	} // }}}
	type() => @type
}