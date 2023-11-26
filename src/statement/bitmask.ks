class BitmaskDeclaration extends Statement {
	private late {
		@bitmask: BitmaskType
		@instanceMethods: Object	= {}
		@name: String
		@staticMethods: Object		= {}
		@type: NamedType<BitmaskType>
		@variable: Variable
		@values: Object				= {}
	}
	private {
		@length: Number		= 16
	}
	initiate() { # {{{
		@name = @data.name.name
		@bitmask = BitmaskType.new(@scope)
		@type = NamedType.new(@name, @bitmask)
		@variable = @scope.define(@name, true, @type, this)

		if ?@data.type {
			match @data.type.name {
				'u8' {
					@length = 8
				}
				'u32' {
					@length = 32
				}
				'u48' {
					@length = 48
				}
				'u64' {
					@length = 64
				}
				'u128' {
					@length = 128
				}
				'u256' {
					@length = 256
				}
			}
		}

		unless @length < 64 {
			NotSupportedException.throwBitmaskLength(@name, @length, this)
		}

		@bitmask.length(@length)
	} # }}}
	analyse() { # {{{
		@bitmask = @type.type()

		for var data in @data.members {
			match data.kind {
				NodeKind.BitmaskValue {
					var value = BitmaskValueDeclaration.new(data, @bitmask, this)
					var name = value.name()

					if @bitmask.hasValue(name) || @bitmask.hasStaticMethod(name) {
						ReferenceException.throwAlreadyDefinedField(name, value)
					}

					value.analyse()
				}
				NodeKind.CommentBlock {
					pass
				}
				NodeKind.CommentLine {
					pass
				}
				NodeKind.MethodDeclaration {
					var method = BitmaskMethodDeclaration.new(data, this)
					var name = method.name()

					if !method.isInstance() && @bitmask.hasValue(name) {
						ReferenceException.throwAlreadyDefinedField(name, method)
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
		@bitmask = @type.type()

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

				if @bitmask.hasMatchingInstanceMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@bitmask.addInstanceMethod(name, method.type())
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

				if @bitmask.hasMatchingStaticMethod(name, method.type(), MatchingMode.ExactParameter) {
					SyntaxException.throwIdenticalMethod(name, method)
				}

				@bitmask.addStaticMethod(name, method.type())
			}
		}

		@bitmask.flagComplete()
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
	addValue(value: BitmaskValueDeclaration) { # {{{
		@values[value.name()] = value
	} # }}}
	export(recipient) { # {{{
		recipient.export(@name, @variable)
	} # }}}
	name() => @name
	length(): valueof @length
	toMainTypeFragments(fragments) { # {{{
		if @length <= 32 {
			fragments.code('Number')
		}
		else {
			fragments.code('Object')
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var line = fragments.newLine().code($runtime.immutableScope(this), @name, $equals, $runtime.helper(this), '.bitmask(')

		@toMainTypeFragments(line)

		line.code(`, [`)

		var mut first = true
		var aliases = []

		for var value of @values {
			if value.type().isAlias() {
				aliases.push(value)
			}
			else {
				if first {
					first = false
				}
				else {
					line.code($comma)
				}

				value.toFragments(line)
			}
		}

		if ?#aliases {
			line.code(`], [`)

			for var value, index in aliases {
				line.code($comma) if index != 0

				value.toFragments(line)
			}
		}

		line.code('])').done()

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

class BitmaskValueDeclaration extends AbstractNode {
	private late {
		@bitmask: BitmaskType
		@operands: Array
		@type: BitmaskValueType | BitmaskAliasType
		@value: String?
	}
	private {
		@name: String
	}
	constructor(data, @bitmask, parent) { # {{{
		super(data, parent)

		@name = data.name.name

		parent.addValue(this)
	} # }}}
	analyse() { # {{{
		var length = @bitmask.length()
		var value = @data.value

		if ?value {
			match value.kind {
				// TODO!
				// NodeKind.BinaryExpression when value.operator.kind == BinaryOperatorKind.Addition | BinaryOperatorKind.BitwiseOr {
				NodeKind.BinaryExpression {
					if value.operator.kind == BinaryOperatorKind.Addition {
						@type = @bitmask.createAlias(@name)
						@operands = [value.left, value.right]
					}
				}
				NodeKind.Identifier {
					@type = @bitmask.createAlias(@name)

					@operands = [value]
				}
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

							@type = @bitmask.createValue(@name, index)
						}
						else {
							@type = @bitmask.createValue(@name, 0)
						}
					}
					else {
						if value.value > length {
							SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
						}

						@type = @bitmask.createValue(@name, value.value)
						@value = @type.value()
					}
				}
				NodeKind.PolyadicExpression when value.operator.kind == BinaryOperatorKind.Addition {
					@type = @bitmask.createAlias(@name)
					@operands = value.operands
				}
				else {
					SyntaxException.throwInvalidBitmaskValue(value, this)
				}
			}
		}
		else {
			if @bitmask.getNextValue() > length {
				SyntaxException.throwBitmaskOverflow(@parent.name(), length, this)
			}

			@type = @bitmask.createValue(@name)
			@value = @type.value()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if ?#@operands {
			var bitmask = @parent.type().type()

			if bitmask.length() > 32 {
				@value = ''

				for var { name }, index in @operands {
					@value += ' | ' if index > 0

					if var value ?= bitmask.getValue(name) {
						@value += value.value()
					}
					else {
						NotImplementedException.throw(this)
					}
				}
			}
			else {
				var mut result = 0

				for var { name } in @operands {
					if var value ?= bitmask.getValue(name) {
						result +|= value.value()
					}
					else {
						NotImplementedException.throw(this)
					}
				}

				@value = `\(result)`
			}

			@type.value(@value)
		}
	} # }}}
	translate()
	name() => @name
	toConditionFragments(bitmask, varname, fragments) { # {{{
		for var name, index in @type.originals() {
			fragments
				..code(' || ') if index > 0
				..code(`\(varname) === \(bitmask).\(name)`)
		}
	} # }}}
	toFragments(fragments) { # {{{
		fragments.code(`\($quote(@name)), \(@value)`)
	} # }}}
	type() => @type
}

class BitmaskMethodDeclaration extends Statement {
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
		var bitmaskName = @parent.name()
		var bitmaskRef = @scope.reference(bitmaskName)

		for var _, name of @parent._values {
			var variable = @scope.define(name, true, bitmaskRef, true, @parent)

			variable.renameAs(`\(bitmaskName).\(name)`)
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
			@scope.define('this', true, bitmaskRef, true, this)

			if names.contains(@thisVarname) {
				@thisVarname = @scope.acquireTempName(false)
			}

			@scope.rename('this', @thisVarname)
		}

		for var parameter in @parameters {
			parameter.prepare()
		}

		var arguments = [parameter.type() for var parameter in @parameters]

		@type = BitmaskMethodType.new(arguments, @data, this)

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
