class ImplementEnumFieldDeclaration extends Statement {
	private lateinit {
		@operands: Array
		@value: String
		@variable: EnumVariableType
	}
	private {
		@composite: Boolean					= false
		@defaultValue: Boolean				= false
		@enum: EnumType
		@enumName: NamedType<EnumType>
		@enumRef: ReferenceType
		@name: String
	}
	constructor(data, parent, @enumName) { // {{{
		super(data, parent)

		@enum = @enumName.type()
		@enumRef = @scope.reference(@enumName)

		@name = data.name.name

	} // }}}
	analyse() { // {{{
		const value = @data.value

		switch @enum.kind() {
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
								SyntaxException.throwEnumOverflow(@enumName.name(), this)
							}

							let tmp = @enum.index(value.value)
						}
						else {
							SyntaxException.throwInvalidEnumValue(value, this)
						}

						@value = `\(@enum.index() <= 0 ? 0 : Math.pow(2, @enum.index() - 1))`
					}
				}
				else {
					if @enum.step() > 53 {
						SyntaxException.throwEnumOverflow(@enumName.name(), this)
					}

					@value = `\(@enum.index() <= 0 ? 0 : Math.pow(2, @enum.index() - 1))`
				}
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
			}
			EnumTypeKind::Number => {
				if value? {
					if value.kind == NodeKind::NumericExpression {
						@value = `\(@enum.index(value.value))`
					}
					else {
						throw new NotSupportedException(this)
					}
				}
				else {
					@value = `\(@enum.step())`
				}
			}
		}
	} // }}}
	prepare() { // {{{
		@variable = @enum.addVariable(@name)

		@variable.flagAlteration()
	} // }}}
	translate() { // {{{
	} // }}}
	getSharedName() => null
	isMethod() => false
	toFragments(fragments, mode) { // {{{
		const name = @enumName.name()
		const line = fragments.newLine().code(name, '.', @name, ' = ', name, '(')

		if @composite {
			for const operand, i in @operands {
				line.code(' | ') if i > 0

				line.code(name, '.', operand.name)
			}
		}
		else {
			line.code(@value)
		}

		line.code(')').done()
	} // }}}
}

class ImplementEnumMethodDeclaration extends Statement {
	private lateinit {
		@block: Block
		@name: String
		@parameters: Array<Parameter>
		@type: EnumMethodType
	}
	private {
		@autoTyping: Boolean				= false
		@enum: EnumType
		@enumName: NamedType<EnumType>
		@enumRef: ReferenceType
		@instance: Boolean					= true
		@override: Boolean					= false
		@topNodes: Array					= []
	}
	constructor(data, parent, @enumName) { // {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		@enum = @enumName.type()
		@enumRef = @scope.reference(@enumName)
	} // }}}
	analyse() { // {{{
		@scope.line(@data.start.line)

		@name = @data.name.name

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Override {
				@override = true
			}
			else if modifier.kind == ModifierKind::Overwrite {
				NotSupportedException.throw(this)
			}
			else if modifier.kind == ModifierKind::Static {
				@instance = false
			}
		}

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@block = $compile.function($ast.body(@data), this)
	} // }}}
	prepare() { // {{{
		@scope.line(@data.start.line)

		if @instance {
			@scope.define('this', true, @enumRef, true, this)
			@scope.rename('this', 'that')
		}

		for const name in @enum.listVariables() {
			const var = @scope.define(name, true, @enumRef, true, @parent)

			var.renameAs(`\(@enumName.name()).\(name)`)
		}

		for const parameter in @parameters {
			parameter.prepare()
		}

		@type = new EnumMethodType([parameter.type() for const parameter in @parameters], @data, this)

		@type.flagAlteration()

		if @instance {
			if @override {
				const methods = @enum.listMatchingInstanceMethods(@name, @type, MatchingMode::ShiftableParameters)

				if methods.length == 0 {
					@override = false
					@enum.addInstanceMethod(@name, @type)
				}
			}
			else {
				if @enum.hasMatchingInstanceMethod(@name, @type, MatchingMode::ExactParameters) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@enum.addInstanceMethod(@name, @type)
				}
			}
		}
		else {
			if @override {
				NotImplementedException.throw(this)
			}
			else {
				if @enum.hasMatchingStaticMethod(@name, @type, MatchingMode::ExactParameters) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@enum.addStaticMethod(@name, @type)
				}
			}
		}

		@block.analyse()

		if @data.type?.kind == NodeKind::ReturnTypeReference {
			switch @data.type.value.kind {
				NodeKind::Identifier => {
					if @data.type.value.name == 'auto' {
						@type.returnType(@block.getUnpreparedType())

						@autoTyping = true
					}
					else {
						NotSupportedException.throw(this)
					}
				}
				NodeKind::ThisExpression => {
					NotSupportedException.throw(this)
				}
			}
		}
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.returnType(@block.type())
		}
		else {
			@block.type(@type.returnType()).prepare()
		}

		@block.translate()
	} // }}}
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
	getMatchingMode(): MatchingMode { // {{{
		if @override {
			return MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameters
		}
	} // }}}
	getParameterOffset() => @instance ? 1 : 0
	getSharedName() => null
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isInstance() => @instance
	isInstanceMethod() => @instance
	isMethod() => true
	name() => @name
	parameters() => @parameters
	toStatementFragments(fragments, mode) { // {{{
		const line = fragments.newLine()

		if @instance {
			line.code(`\(@enumName.name()).__ks_func_\(@name) = function(that`)
		}
		else {
			line.code(`\(@enumName.name()).\(@name) = function(`)
		}

		const block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			fragments.code(')')

			return fragments.newBlock()
		})

		for const node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		block.done()
		line.done()
	} // }}}
	type() => @type
}