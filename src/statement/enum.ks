class EnumDeclaration extends Statement {
	private late {
		@enum: EnumType
		@instanceMethods: Object	= {}
		@name: String
		@staticMethods: Object		= {}
		@type: NamedType<EnumType>
		@variable: Variable
		@variables: Object			= {}
	}
	initiate() { # {{{
		@name = @data.name.name

		var type = Type.fromAST(@data.type, this)

		if type.isString() {
			@enum = EnumType.new(@scope, EnumTypeKind.String)
		}
		else {
			@enum = EnumType.new(@scope)
		}

		@type = NamedType.new(@name, @enum)

		@variable = @scope.define(@name, true, @type, this)
	} # }}}
	analyse() { # {{{
		for var data in @data.members {
			match data.kind {
				NodeKind.CommentBlock {
					pass
				}
				NodeKind.CommentLine {
					pass
				}
				NodeKind.FieldDeclaration {
					var declaration = EnumVariableDeclaration.new(data, this)

					declaration.analyse()
				}
				NodeKind.MethodDeclaration {
					var declaration = EnumMethodDeclaration.new(data, this)

					declaration.analyse()
				}
				else {
					throw NotSupportedException.new(`Unknow kind \(data.kind)`, this)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = @variable.getRealType()
		@enum = @type.type()

		for var variable, name of @variables {
			variable.prepare()

			@enum.addVariable(name)
		}

		for var methods, name of @instanceMethods {
			var mut async: Boolean

			for var method, index in methods {
				method.prepare()

				if index == 0 {
					async = method.type().isAsync()
				}
				else if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @enum.hasMatchingInstanceMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@enum.addInstanceMethod(name, method.type())
			}
		}

		for var methods, name of @staticMethods {
			var mut async: Boolean

			for var method, index in methods {
				method.prepare()

				if index == 0 {
					async = method.type().isAsync()
				}
				else if async != method.type().isAsync() {
					SyntaxException.throwInvalidSyncMethods(@name, name, this)
				}

				if @enum.hasMatchingStaticMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@enum.addStaticMethod(name, method.type())
			}
		}

		@enum.flagComplete()
	} # }}}
	translate() { # {{{
		for var variable of @variables {
			variable.translate()
		}

		for var methods of @instanceMethods {
			for var method in methods {
				method.translate()
			}
		}

		for var methods of @staticMethods {
			for var method in methods {
				method.translate()
			}
		}
	} # }}}
	addVariable(variable: EnumVariableDeclaration) { # {{{
		@variables[variable.name()] = variable
	} # }}}
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toMainTypeFragments(fragments) { # {{{
		if @enum.isString() {
			fragments.code('String')
		}
		else {
			fragments.code('Number')
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.immutableScope(this), @name, $equals, $runtime.helper(this), '.enum(')

		@toMainTypeFragments(line)

		line.code($comma)

		var object = line.newObject()

		for var variable of @variables when !variable.isComposite() {
			variable.toFragments(object)
		}

		object.done()

		line.code(')').done()

		for var variable of @variables when variable.isComposite() {
			variable.toFragments(fragments)
		}

		for var methods, name of @staticMethods {
			var types = []

			for var method in methods {
				method.toFragments(fragments, Mode.None)

				types.push(method.type())
			}

			var assessment = Router.assess(types, name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(@name).\(name) = function()`).step()

			Router.toFragments(
				(function, line) => {
					line.code(`\(@name).__ks_sttc_\(name)_\(function.index())(`)

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

		for var methods, name of @instanceMethods {
			var types = []

			for var method in methods {
				method.toFragments(fragments, Mode.None)

				types.push(method.type())
			}

			var assessment = Router.assess(types, name, this)

			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(@name).__ks_func_\(name) = function(that, ...args)`).step()

			Router.toFragments(
				(function, line) => {
					line.code(`\(@name).__ks_func_\(name)_\(function.index())(that`)

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
	} # }}}
	type() => @type
}

class EnumVariableDeclaration extends AbstractNode {
	private late {
		@operands: Array
		@value: String
		@type: Type
	}
	private {
		@alias: Boolean					= false
		@composite: Boolean				= false
		@name: String
	}
	constructor(data, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		parent.addVariable(this)
	} # }}}
	analyse() { # {{{
		var enum = @parent.type().type()
		var value = @data.value

		match enum.kind() {
			EnumTypeKind.Bit {
				var length = enum.length()

				if ?value {
					if value.kind == NodeKind.BinaryExpression && value.operator.kind == BinaryOperatorKind.Addition | BinaryOperatorKind.BitwiseOr {
						@composite = true

						@operands = [value.left, value.right]
					}
					else if value.kind == NodeKind.PolyadicExpression && value.operator.kind == BinaryOperatorKind.Addition | BinaryOperatorKind.BitwiseOr {
						@composite = true

						@operands = value.operands
					}
					else {
						match value.kind {
							NodeKind.NumericExpression {
								if value.radix == 2 {
									@value = `\(value.value)`

									if value.value > 0 {
										var binary = value.value.toString(2)
										var index = binary.length

										if binary.lastIndexOf('1') != 0 {
											NotImplementedException.throw(this)
										}

										if index > length {
											SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
										}

										enum.index(index)
									}
									else {
										enum.index(0)
									}
								}
								else {
									if value.value > length {
										SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
									}

									enum.index(value.value)

									@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))\(length > 32 ? 'n' : '')`
								}
							}
							NodeKind.Identifier {
								@alias = true

								@operands = [value]
							}
							else {
								SyntaxException.throwInvalidEnumValue(value, this)
							}
						}
					}
				}
				else {
					if enum.step() > length {
						SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
					}

					@value = `\(enum.index() <= 0 ? 0 : Math.pow(2, enum.index() - 1))\(length > 32 ? 'n' : '')`
				}

				@type = @scope.reference('Number')
			}
			EnumTypeKind.String {
				if ?value {
					if value.kind == NodeKind.Literal {
						@value = $quote(value.value)
					}
					else {
						throw NotSupportedException.new(this)
					}
				}
				else {
					@value = $quote(@name.toLowerCase())
				}

				@type = @scope.reference('String')
			}
			EnumTypeKind.Number {
				if ?value {
					if value.kind == NodeKind.NumericExpression {
						@value = `\(enum.index(value.value))`
					}
					else {
						throw NotSupportedException.new(this)
					}
				}
				else {
					@value = `\(enum.step())`
				}

				@type = @scope.reference('Number')
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	isComposite() => @composite || @alias
	name() => @name
	toFragments(fragments) { # {{{
		if @alias {
			var name = @parent.name()
			var operand = @operands[0]

			fragments.line(`\(name).\(@name) = \(name).\(operand.name)`)
		}
		else if @composite {
			var name = @parent.name()
			var line = fragments.newLine().code(`\(name).\(@name) = \(name)(`)

			for var operand, i in @operands {
				line.code(' | ') if i > 0

				line.code(`\(name).\(operand.name)`)
			}

			line.code(')').done()
		}
		else {
			fragments.line(`\(@name): \(@value)`)
		}
	} # }}}
	type() => @type
}

class EnumMethodDeclaration extends Statement {
	private late {
		@block: FunctionBlock
		@internalName: String
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
		@thisVarname: String			= 'that'
		@topNodes: Array				= []
	}
	constructor(data, parent) { # {{{
		super(data, parent, @newScope(parent.scope(), ScopeType.Function))

		@name = data.name.name

		for var modifier in data.modifiers {
			if modifier.kind == ModifierKind.Static {
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
	} # }}}
	analyse() { # {{{
		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@block = MethodBlock.new($ast.block($ast.body(@data)), this, @scope)
	} # }}}
	override prepare(target, targetMode) { # {{{
		var enumName = @parent.name()
		var enumRef = @scope.reference(enumName)

		for var _, name of @parent._variables {
			var variable = @scope.define(name, true, enumRef, true, @parent)

			variable.renameAs(`\(enumName).\(name)`)
		}

		var names = []

		for {
			var parameter in @parameters
			var { name } in parameter.listAssignments([])
		}
		then {
			names.push(name)
		}

		if @instance {
			@scope.define('this', true, enumRef, true, this)

			if names.contains(@thisVarname) {
				@thisVarname = @scope.acquireTempName(false)
			}

			@scope.rename('this', @thisVarname)
		}

		for var parameter in @parameters {
			parameter.prepare()
		}

		var arguments = [parameter.type() for var parameter in @parameters]

		@type = EnumMethodType.new(arguments, @data, this)

		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}
	} # }}}
	translate() { # {{{
		if @instance {
			@internalName = `__ks_func_\(@name)_\(@type.index())`
		}
		else {
			@internalName = `__ks_sttc_\(@name)_\(@type.index())`
		}

		for var parameter in @parameters {
			parameter.translate()
		}

		for var indigent in @indigentValues {
			indigent.value.prepare()
			indigent.value.translate()
		}

		if @autoTyping {
			@block.prepare(AnyType.NullableUnexplicit)

			@type.setReturnType(@block.type())
		}
		else {
			@block.prepare(@type.getReturnType())
		}

		@block.translate()

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} # }}}
	addIndigentValue(value: Expression, parameters) { # {{{
		var name = `__ks_default_\(@parent.type().type().incDefaultSequence())`

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
	getOverridableVarname() => @parent.name()
	getParameterOffset() => @instance ? 1 : 0
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isOverridableFunction() => true
	parameters() => @parameters
	toIndigentFragments(fragments) { # {{{
		for var {name, value, parameters} in @indigentValues {
			var line = fragments.newLine()
			var ctrl = line.newControl(null, false, false)

			ctrl.code(`\(@parent.name()).\(name) = function(\(parameters.join(', ')))`).step()

			ctrl.newLine().code('return ').compile(value).done()

			ctrl.done()
			line.done()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine()
		var ctrl = line.newControl(null, false, false)

		ctrl.code(`\(@parent.name()).\(@internalName) = function(`)

		if @instance {
			ctrl.code(@thisVarname)
		}

		Parameter.toFragments(this, ctrl, ParameterMode.Default, node => node.code(')').step())

		for var node in @topNodes {
			node.toAuthorityFragments(ctrl)
		}

		if @awaiting {
			throw NotImplementedException.new(this)
		}
		else {
			ctrl.compile(@block)
		}

		ctrl.done()
		line.done()

		@toIndigentFragments(fragments)
	} # }}}
	type() => @type
}
