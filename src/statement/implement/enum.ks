class ImplementEnumFieldDeclaration extends Statement {
	private late {
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
	constructor(data, parent, @enumName) { # {{{
		super(data, parent)

		@enum = @enumName.type()
		@enumRef = @scope.reference(@enumName)

		@name = data.name.name

	} # }}}
	analyse() { # {{{
		var value = @data.value

		match @enum.kind() {
			EnumTypeKind::Bit {
				if ?value {
					if value.kind == NodeKind::BinaryExpression && value.operator.kind == BinaryOperatorKind::Or | BinaryOperatorKind::Addition {
						@composite = true

						@operands = [value.left, value.right]
					}
					else if value.kind == NodeKind::PolyadicExpression && value.operator.kind == BinaryOperatorKind::Or | BinaryOperatorKind::Addition {
						@composite = true

						@operands = value.operands
					}
					else {
						if value.kind == NodeKind::NumericExpression {
							if value.value > 53 {
								SyntaxException.throwEnumOverflow(@enumName.name(), this)
							}

							var mut tmp = @enum.index(value.value)
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
			EnumTypeKind::String {
				if ?value {
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
			EnumTypeKind::Number {
				if ?value {
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
	} # }}}
	override prepare(target, targetMode) { # {{{
		@variable = @enum.addVariable(@name)

		@variable.flagAlteration()
	} # }}}
	translate() { # {{{
	} # }}}
	getSharedName() => null
	isMethod() => false
	toFragments(fragments, mode) { # {{{
		var name = @enumName.name()
		var line = fragments.newLine().code(name, '.', @name, ' = ', name, '(')

		if @composite {
			for var operand, i in @operands {
				line.code(' | ') if i > 0

				line.code(name, '.', operand.name)
			}
		}
		else {
			line.code(@value)
		}

		line.code(')').done()
	} # }}}
}

class ImplementEnumMethodDeclaration extends Statement {
	private late {
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
		@indigentValues: Array				= []
		@instance: Boolean					= true
		@override: Boolean					= false
		@topNodes: Array					= []
	}
	constructor(data, parent, @enumName) { # {{{
		super(data, parent, parent.scope(), ScopeType::Function)

		@enum = @enumName.type()
		@enumRef = @scope.reference(@enumName)
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		@name = @data.name.name

		for var modifier in @data.modifiers {
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
		for var data in @data.parameters {
			var parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = $compile.function($ast.body(@data), this)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.line(@data.start.line)

		if @instance {
			@scope.define('this', true, @enumRef, true, this)
			@scope.rename('this', 'that')
		}

		for var name in @enum.listVariables() {
			var variable = @scope.define(name, true, @enumRef, true, @parent)

			variable.renameAs(`\(@enumName.name()).\(name)`)
		}

		for var parameter in @parameters {
			parameter.prepare()
		}

		@type = new EnumMethodType([parameter.type() for var parameter in @parameters], @data, this)

		@type.flagAlteration()

		if @instance {
			var mut mode = MatchingMode::FunctionSignature + MatchingMode::IgnoreReturn + MatchingMode::MissingError

			if @override {
				if var method ?= @enum.getInstantiableMethod(@name, @type, mode) {
					@type = method.clone().flagAlteration()

					var parameters = @type.parameters()

					for var parameter, index in @parameters {
						parameter.type(parameters[index])
					}
				}
				else if @isAssertingOverride() {
					SyntaxException.throwNoOverridableMethod(@enumName, @name, @parameters, this)
				}
				else {
					@override = false
					@enum.addInstanceMethod(@name, @type)
				}
			}
			else {
				mode -= MatchingMode::MissingParameterType - MatchingMode::MissingParameterArity

				if @enum.hasMatchingInstanceMethod(@name, @type, MatchingMode::ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@enum.addInstanceMethod(@name, @type)
				}
			}
		}
		else {
			if @override {
				NotSupportedException.throw(this)
			}
			else {
				if @enum.hasMatchingStaticMethod(@name, @type, MatchingMode::ExactParameter) {
					SyntaxException.throwDuplicateMethod(@name, this)
				}
				else {
					@enum.addStaticMethod(@name, @type)
				}
			}
		}

		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} # }}}
	translate() { # {{{
		for parameter in @parameters {
			parameter.translate()
		}

		for var indigent in @indigentValues {
			indigent.value.prepare()
			indigent.value.translate()
		}

		if @autoTyping {
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.prepare(@type.getReturnType())
		}

		@block.translate()
	} # }}}
	addIndigentValue(value: Expression, parameters) { # {{{
		var name = `__ks_default_\(@enum.incDefaultSequence())`

		@indigentValues.push({
			name
			value
			parameters
		})

		return name
	} # }}}
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	getMatchingMode(): MatchingMode { # {{{
		if @override {
			return MatchingMode::ShiftableParameters
		}
		else {
			return MatchingMode::ExactParameter
		}
	} # }}}
	getOverridableVarname() => @enumName.name()
	getParameterOffset() => @instance ? 1 : 0
	getSharedName() => @override ? null : @instance ? `__ks_func_\(@name)` : @name
	isAssertingOverride() => @options.rules.assertOverride
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isInstance() => @instance
	isInstanceMethod() => @instance
	isMethod() => true
	isOverridableFunction() => true
	name() => @name
	parameters() => @parameters
	toIndigentFragments(fragments) { # {{{
		for var {name, value, parameters} in @indigentValues {
			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(@enumName.name()).\(name) = function(\(parameters.join(', ')))`).step()

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done()
			line.done()
		}
	} # }}}
	toSharedFragments(fragments, _) { # {{{
		var name = @enumName.name()

		if @instance {
			var assessment = @enum.getInstanceAssessment(@name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(name).__ks_func_\(@name) = function(that, ...args)`).step()

			Router.toFragments(
				(function, line) => {
					line.code(`\(name).__ks_func_\(@name)_\(function.index())(that`)

					return true
				}
				`args`
				assessment
				ctrl.block()
				this
			)

			ctrl.done()
			line.done()
		}
		else {
			var assessment = @enum.getStaticAssessment(@name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(name).\(@name) = function()`).step()

			Router.toFragments(
				(function, line) => {
					line.code(`\(name).__ks_sttc_\(@name)_\(function.index())(`)

					return false
				}
				`arguments`
				assessment
				ctrl.block()
				this
			)

			ctrl.done()
			line.done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine()

		if @instance {
			line.code(`\(@enumName.name()).__ks_func_\(@name)_\(@type.index()) = function(that`)
		}
		else {
			line.code(`\(@enumName.name()).__ks_sttc_\(@name)_\(@type.index()) = function(`)
		}

		var block = Parameter.toFragments(this, line, ParameterMode::Default, func(fragments) {
			fragments.code(')')

			return fragments.newBlock()
		})

		for var node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		block.done()
		line.done()

		@toIndigentFragments(fragments)
	} # }}}
	type() => @type
}
