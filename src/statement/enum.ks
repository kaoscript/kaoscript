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
		@enum = @type.type()

		for var data in @data.members {
			match data.kind {
				NodeKind.CommentBlock {
					pass
				}
				NodeKind.CommentLine {
					pass
				}
				NodeKind.FieldDeclaration {
					var variable = @createVariable(data)

					variable.analyse()

					@enum.addVariable(variable.type())
				}
				NodeKind.MethodDeclaration {
					var method = EnumMethodDeclaration.new(data, this)

					method.analyse()
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

		for var variable of @variables {
			variable.prepare()
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
	createVariable(data) => EnumVariableDeclaration.new(data, this)
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

		for var variable of @variables when !variable.type().isAlias() {
			variable.toFragments(object)
		}

		object.done()

		line.code(')').done()

		for var variable of @variables when variable.type().isTopDerivative() {
			var line = fragments.newLine()

			line.code(`\(@name).__ks_eq_\(variable.name()) = value => `)

			variable.toConditionFragments(@name, 'value', line)

			line.done()
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
		@type: EnumVariableType
		@value: String?
	}
	private {
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

		if ?value {
			match value.kind {
				NodeKind.Identifier {
					@type = EnumVariableAliasType.new(@name)
						// TODO!
						// ...setAlias(value.name, enum)

					@type.setAlias(value.name, enum)
				}
				NodeKind.JunctionExpression when value.operator.kind == BinaryOperatorKind.JunctionOr {
					@type = EnumVariableAliasType.new(@name)

					for var { name } in value.operands {
						@type.addAlias(name, enum)
					}
				}
				NodeKind.Literal when enum.kind() == EnumTypeKind.String {
					@value = $quote(value.value)
					@type = EnumVariableType.new(@name)
				}
				NodeKind.NumericExpression when enum.kind() == EnumTypeKind.Number {
					@value = `\(enum.index(value.value))`
					@type = EnumVariableType.new(@name)
				}
				else {
					echo(value)
					throw NotSupportedException.new(this)
				}
			}
		}
		else {
			if enum.kind() == EnumTypeKind.String {
				@value = $quote(@name.toLowerCase())
			}
			else {
				@value = `\(enum.step())`
			}

			@type = EnumVariableType.new(@name)
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	name() => @name
	toConditionFragments(enum, varname, fragments) { # {{{
		for var name, index in @type.originals() {
			fragments
				..code(' || ') if index > 0
				..code(`\(varname) === \(enum).\(name)`)
		}
	} # }}}
	toFragments(fragments) { # {{{
		fragments.line(`\(@name): \(@value)`)
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
