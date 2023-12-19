class EnumDeclaration extends Statement {
	private late {
		@enum: EnumType
		@fields: EnumFieldDeclaration[]		= []
		@initial: Expression?
		@instanceMethods: Object			= {}
		@name: String
		@staticMethods: Object				= {}
		@step: Expression?
		@type: NamedType<EnumType>
		@variable: Variable
		@values: Object						= {}
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

		@enum.fillProperties(@name, this)
	} # }}}
	analyse() { # {{{
		@enum = @type.type()

		if ?@data.initial {
			@initial = $compile.expression(@data.initial, this)
				..analyse()

			if ?@data.step {
				@step = $compile.expression(@data.step, this)
					..analyse()
			}

			@enum.setGenerator(@initial, @step)
		}

		for var data in @data.members when data.kind == NodeKind.FieldDeclaration {
			EnumFieldDeclaration.new(data, @enum, this).analyse()
		}

		if ?#@fields {
			@enum.buildMatcher(@name, this)
		}

		for var data in @data.members {
			match data.kind {
				NodeKind.EnumValue {
					var value = EnumValueDeclaration.new(data, @enum, this)
					var name = value.name()

					if @enum.hasValue(name) || @enum.hasStaticMethod(name) {
						ReferenceException.throwAlreadyDefinedField(name, value)
					}

					value.analyse()
				}
				NodeKind.FieldDeclaration {
					pass
				}
				NodeKind.MethodDeclaration {
					var method = EnumMethodDeclaration.new(data, this)
					var name = method.name()

					if method.isInstance() {
						if @enum.hasField(name) {
							ReferenceException.throwAlreadyDefinedField(name, method)
						}
					}
					else {
						if @enum.hasValue(name) {
							ReferenceException.throwAlreadyDefinedField(name, method)
						}
					}

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

		for var value of @values {
			value.prepare()
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
		for var value of @values {
			value.translate()
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
	addField(field: EnumFieldDeclaration) { # {{{
		if field.name() == 'value' {
			var type = field.type().type()

			unless type == Type.Unknown || type.isSubsetOf(@enum.type(), MatchingMode.Default) {
				NotImplementedException.throw()
			}

			if var value ?= field.value() {
				@enum.setGenerator(value)
			}
		}
		else {
			@fields.push(field)

			@enum.addField(field.type())
		}
	} # }}}
	addValue(value: EnumValueDeclaration) { # {{{
		@values[value.name()] = value
	} # }}}
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	toMainTypeFragments(fragments) { # {{{
		if @enum.type().isString() {
			fragments.code('String')
		}
		else {
			fragments.code('Number')
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.immutableScope(this), @name, $equals, $runtime.helper(this), '.enum(')

		@toMainTypeFragments(line)

		line.code(`, \(@fields.length)`)

		for var field in @fields {
			line.code(`\($comma)\($quote(field.name()))`)
		}

		for var value of @values when !value.type().isAlias() {
			value.toFragments(line)
		}

		line.code(')').done()

		for var value of @values when value.type().isTopDerivative() {
			var line = fragments.newLine()

			line.code(`\(@name).__ks_eq_\(value.name()) = value => `)

			value.toConditionFragments(@name, 'value', line)

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

class EnumValueDeclaration extends AbstractNode {
	private late {
		@arguments: Expression[]					= []
		@enum: EnumType
		@type: EnumValueType | EnumAliasType
		@value: String?
	}
	private {
		@name: String
	}
	constructor(data, @enum, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		parent.addValue(this)
	} # }}}
	analyse() { # {{{
		var value = @data.value

		if ?value {
			match value.kind {
				NodeKind.Identifier {
					@type = @enum.createAlias(@name)
						..setAlias(value.name, @enum)
				}
				NodeKind.JunctionExpression when value.operator.kind == BinaryOperatorKind.JunctionOr {
					@type = @enum.createAlias(@name)

					for var { name } in value.operands {
						@type.addAlias(name, @enum)
					}
				}
				NodeKind.Literal when @enum.kind() == EnumTypeKind.String {
					{ @type, @value } = @enum.createValue(@name, value.value)
				}
				NodeKind.NumericExpression when @enum.kind() == EnumTypeKind.Number {
					{ @type, @value } = @enum.createValue(@name, value.value)
				}
				else {
					echo(value)
					throw NotSupportedException.new(this)
				}
			}
		}
		else {
			{ @type, @value } = @enum.createValue(@name)
		}

		if ?@data.arguments {
			if @type.isAlias() {
				NotImplementedException.throw()
			}

			for var data in @data.arguments {
				// TODO!
				// var argument = $compile.expression(data, this)
				// 	..analyse()
				// 	..flagNewExpression()
				// 	..unflagCompleteObject() if _ is MemberExpression
				// 	..prepare(AnyType.NullableUnexplicit)

				var argument = $compile.expression(data, this)
					..analyse()
					..flagNewExpression()

				argument.unflagCompleteObject() if argument is MemberExpression

				@arguments.push(argument)
			}

			for var argument in @arguments {
				argument.prepare(AnyType.NullableUnexplicit)
			}

			var names = @enum.listFieldNames()
			var expressions = @arguments

			@arguments = []

			match @enum.matchValueArguments(expressions, this) {
				is PreciseCallMatchResult with var { matches } {
					unless matches.length == 1 {
						NotImplementedException.throw(this)
					}

					for var position, index in matches[0].positions {
						if position is Array {
							NotImplementedException.throw(this)
						}
						else {
							var { index?, element? } = position

							if !?index {
								@type.setArgument(names[@arguments.length + 3], 'null')

								@arguments.push('void 0')
							}
							else if ?element {
								NotImplementedException.throw(this)
							}
							else {
								@type.argument(names[@arguments.length + 3], expressions[index].type().path())

								@arguments.push(expressions[index])
							}
						}
					}
				}
				else {
					NotImplementedException.throw(this)
				}
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	arguments() => @arguments
	assessment() => @enum.fieldAssessment()
	name() => @name
	toConditionFragments(enum, varname, fragments) { # {{{
		for var name, index in @type.originals() {
			fragments
				..code(' || ') if index > 0
				..code(`\(varname) === \(enum).\(name)`)
		}
	} # }}}
	toFragments(fragments) { # {{{
		fragments.code(`, \($quote(@name)), \(@value)`)

		for var argument in @arguments {
			fragments.code($comma).compile(argument)
		}
	} # }}}
	type() => @type
}

class EnumFieldDeclaration extends AbstractNode {
	private late {
		@enum: EnumType
		@type: EnumFieldType
		@value: Expression?
	}
	private {
		@name: String
	}
	constructor(data, @enum, parent) { # {{{
		super(data, parent)

		@name = data.name.name
	} # }}}
	analyse() { # {{{
		if ?@data.value {
			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}

		@type = EnumFieldType.fromAST(@data!?, this)

		@parent.addField(this)
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value?.prepare()
	} # }}}
	translate() { # {{{
		@value?.translate()
	} # }}}
	name() => @name
	toFragments(fragments) { # {{{
	} # }}}
	type() => @type
	value() => @value
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

		for var _, name of @parent._values {
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
	isInstance() => @instance
	isOverridableFunction() => true
	name() => @name
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
