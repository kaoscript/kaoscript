class AnonymousFunctionExpression extends Expression {
	private late {
		@autoTyping: Boolean			= false
		@awaiting: Boolean				= false
		@block: Block
		@exit: Boolean					= false
		@isObjectMember: Boolean		= false
		@parameters: Array<Parameter>	= []
		@thisVariable: Variable?
		@topNodes: Array				= []
		@type: FunctionType
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType.Function)
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		if ?#@data.parameters {
			var mut firstParameter = 0
			var parameter = @data.parameters[0]

			if parameter.external?.name == 'this' || parameter.internal?.name == 'this' {
				if parameter.external?.name == parameter.internal?.name == 'this' {
					firstParameter = 1

					@thisVariable = @scope.define('this', true, Type.Any, this)
				}
				else {
					throw NotImplementedException.new()
				}
			}

			for var data in @data.parameters from firstParameter {
				Parameter.new(data, this)
					..analyse()
					|> @parameters.push
			}
		}

		@isObjectMember = @parent.parent() is ObjectExpression
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.canBeFunction() {
			TypeException.throwInvalidFunctionType(target, this)
		}

		@scope.line(@data.start.line)

		if ?@thisVariable && ?@data.parameters[0].type {
			var type = Type.fromAST(@data.parameters[0].type, this)

			@thisVariable.setDeclaredType(type)
		}

		if var root ?= target.extractFunction() {
			var targetParameters = root.parameters()

			unless @parameters.length == targetParameters.length {
				TypeException.throwInvalidFunctionType(root, this)
			}

			for var parameter, index in @parameters {
				parameter.prepare(targetParameters[index])
			}

			@type = FunctionType.new([parameter.type() for var parameter in @parameters], @data, 0, this)

			if ?@data.type {
				@type.setReturnType(@data.type, [], this)

				unless @type.getReturnType().isSubsetOf(root.getReturnType(), MatchingMode.FunctionSignature) {
					SyntaxException.throwInvalidReturnType(@type.getReturnType(), root.getReturnType(), this)
				}
			}
			else {
				@type.setReturnType(root.getReturnType())
			}

			@block = $compile.function($ast.body(@data), this)
			@block.analyse()

			@autoTyping = @type.isAutoTyping()

			if @autoTyping {
				var type = @block.getUnpreparedType()

				unless type.isSubsetOf(@type.getReturnType(), MatchingMode.FunctionSignature) {
					SyntaxException.throwInvalidFunctionReturn(@type.toString(), type.toString(), this)
				}

				@type.setReturnType(type)
			}
		}
		else {
			for var parameter in @parameters {
				parameter.prepare()
			}

			@type = FunctionType.new([parameter.type() for var parameter in @parameters], @data, 0, this)

			if ?@data.type {
				@type.setReturnType(@data.type, [], this)
			}

			@block = $compile.function($ast.body(@data), this)
			@block.analyse()

			@autoTyping = @type.isAutoTyping()

			if @autoTyping {
				@type.setReturnType(@block.getUnpreparedType())
			}
		}

		if ?@thisVariable {
			@type.setThisType(@thisVariable.getDeclaredType())
		}

		@type.flagComplete()
	} # }}}
	translate() { # {{{
		for var parameter in @parameters {
			parameter.translate()
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
		@exit = @block.isExit(.Statement + .Always)
	} # }}}
	addInitializableVariable(variable, node)
	addTopNode(node) { # {{{
		@topNodes.push(node)
	} # }}}
	authority() => this
	getFunctionNode() => this
	getParameterOffset() => 0
	hasRetainedParameters() { # {{{
		for var parameter in @parameters {
			return true if parameter.isRetained()
		}

		return false
	} # }}}
	initializeVariable(variable, expression, node)
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isComputed() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isOverridableFunction() => false
	isRefinable() => true
	isUsingVariable(name) => false
	parameters() => @parameters
	toFragments(fragments, mode) { # {{{
		fragments.code(`\($runtime.helper(this)).function(`)

		var blockFunction = Parameter.toFragments(this, fragments.code('function('), ParameterMode.Default, (writer) => writer.code(')').newBlock())

		blockFunction.compile(@block, Mode.None)

		if !@awaiting && !@exit && @type.isAsync() {
			blockFunction.line('__ks_cb()')
		}

		blockFunction.done()

		fragments.code($comma)

		var assessment = @type.assessment('<router>', this)

		fragments.code(`(that, fn, `)

		if assessment.labelable {
			fragments.code('kws, ')
		}

		var blockRouter = fragments.code(`...args) =>`).newBlock()

		Router.toFragments(
			(function, line) => {
				if @type.isMissingThis() {
					line.code(`fn.call(null`)
				}
				else {
					line.code(`fn.call(that`)
				}

				return true
			}
			null
			assessment
			blockRouter
			this
		)

		blockRouter.done()

		if @hasRetainedParameters() {
			fragments.code(', true')
		}

		fragments.code(')')
	} # }}}
	type() => @type
	type(@type) { # {{{
		for var parameter, index in @type.parameters() {
			@parameters[index]?.type(parameter)
		}
	} # }}}
	type(type: AnyType)
	type(type: ReferenceType) { # {{{
		if type.isAlias() {
			@type(type.discardAlias())
		}
	} # }}}
}

class ArrowFunctionExpression extends Expression {
	private late {
		@autoTyping: Boolean			= false
		@awaiting: Boolean				= false
		@block: Block
		@exit: Boolean					= false
		@name: String
		@parameters: Array<Parameter>
		@shiftToAuthority: Boolean		= false
		@type: FunctionType
		@usingThis: Boolean				= false
		@variables: Array<Variable>
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType.Block)
	} # }}}
	analyse() { # {{{
		@scope.line(@data.start.line)

		@parameters = []
		for var data in @data.parameters {
			var parameter = Parameter.new(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless target.canBeFunction() {
			TypeException.throwInvalidFunctionType(target, this)
		}

		@scope.line(@data.start.line)

		if var root ?= target.extractFunction() {
			var targetParameters = root.parameters()

			unless @parameters.length == targetParameters.length {
				TypeException.throwInvalidFunctionType(root, this)
			}

			for var parameter, index in @parameters {
				parameter.prepare(targetParameters[index])
			}

			@type = FunctionType.new([parameter.type() for var parameter in @parameters], @data, 0, this)

			if ?@data.type {
				@type.setReturnType(@data.type, [], this)

				unless @type.getReturnType().isSubsetOf(root.getReturnType(), MatchingMode.FunctionSignature) {
					SyntaxException.throwInvalidReturnType(@type.getReturnType(), root.getReturnType(), this)
				}
			}
			else {
				@type.setReturnType(root.getReturnType())
			}

			@block = $compile.function($ast.body(@data), this)
			@block.analyse()

			@autoTyping = @type.isAutoTyping()

			if @autoTyping {
				var type = @block.getUnpreparedType()

				unless type.isSubsetOf(@type.getReturnType(), MatchingMode.FunctionSignature) {
					SyntaxException.throwInvalidFunctionReturn(@type.toString(), type.toString(), this)
				}

				@type.setReturnType(type)
			}
		}
		else {
			for var parameter in @parameters {
				parameter.prepare()
			}

			@type = FunctionType.new([parameter.type() for var parameter in @parameters], @data, 0, this)

			if ?@data.type {
				@type.setReturnType(@data.type, [], this)
			}

			@block = $compile.function($ast.body(@data), this)
			@block.analyse()

			@autoTyping = @type.isAutoTyping()

			if @autoTyping {
				@type.setReturnType(@block.getUnpreparedType())
			}
		}

		@type.flagComplete()
	} # }}}
	translate() { # {{{
		for var parameter in @parameters {
			parameter.translate()
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
		@exit = @block.isExit(.Statement + .Always)
		@usingThis = @isUsingVariable('this')
	} # }}}
	addInitializableVariable(variable, node)
	getFunctionNode() => this
	getParameterOffset() { # {{{
		if @shiftToAuthority {
			return @variables.length
		}
		else {
			return 0
		}
	} # }}}
	hasRetainedParameters() { # {{{
		for var parameter in @parameters {
			return true if parameter.isRetained()
		}

		return false
	} # }}}
	initializeVariable(variable, expression, node)
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isComputed() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isOverridableFunction() => false
	isRefinable() => true
	isUsingVariable(name) { # {{{
		for var parameter in @parameters {
			if parameter.isUsingVariable(name) {
				return true
			}
		}

		return @block?.isUsingVariable(name) ?? false
	} # }}}
	override makeCallee(generics, node) { # {{{
		var assessment = @type.assessment(@toQuote(), node)

		match node.matchArguments(assessment) {
			is LenientCallMatchResult with var result {
				node.addCallee(LenientFunctionCallee.new(node.data(), assessment, result, node))
			}
			is PreciseCallMatchResult with var { matches } {
				var callee = PreciseFunctionCallee.new(node.data(), this, assessment, matches, node)

				callee.flagDirect()

				node.addCallee(callee)
			}
			else {
				ReferenceException.throwNoMatchingFunction(assessment.name, node.arguments(), node)
			}
		}
	} # }}}
	parameters() => @parameters
	toFragments(fragments, mode) { # {{{
		if @shiftToAuthority {
			if @variables.length == 0 {
				if @usingThis {
					fragments.code(`\(@name).bind(this)`)
				}
				else {
					fragments.code(@name)
				}
			}
			else {
				var bind = if @usingThis set 'this' else 'null'

				fragments.code(`\($runtime.helper(this)).vcurry(\(@name), \(bind)`)

				for var variable in @variables {
					fragments.code(`, \(variable.getSecureName())`)
				}

				fragments.code(')')
			}
		}
		else {
			fragments.code(`\($runtime.helper(this)).function(`)

			var blockFunction = Parameter.toFragments(this, fragments.code('('), ParameterMode.Default, (writer) => writer.code(') =>').newBlock())

			blockFunction.compile(@block, Mode.None)

			if !@awaiting && !@exit && @type.isAsync() {
				blockFunction.line('__ks_cb()')
			}

			blockFunction.done()

			fragments.code($comma)

			var assessment = @type.assessment(@name ?? '<router>', this)

			fragments.code(`(that, fn, `)

			if assessment.labelable {
				fragments.code('kws, ')
			}

			var blockRouter = fragments.code(`...args) =>`).newBlock()

			var bind = if @usingThis set 'that' else 'null'

			Router.toFragments(
				(function, line) => {
					line.code(`fn.call(\(bind)`)

					return true
				}
				null
				assessment
				blockRouter
				this
			)

			blockRouter.done()

			if @hasRetainedParameters() {
				fragments.code(', true')
			}

			fragments.code(')')
		}
	} # }}}
	toAuthorityFragments(fragments) { # {{{
		var ctrl = fragments.newControl().code(`\($runtime.immutableScope(this))\(@name) = function(`)

		for var variable, index in @variables {
			if index != 0 {
				ctrl.code($comma)
			}

			ctrl.code(variable.getSecureName())
		}

		Parameter.toFragments(this, ctrl, ParameterMode.Default, (writer) => writer.code(')').step())

		ctrl.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			ctrl.line('__ks_cb()')
		}

		ctrl.done()
	} # }}}
	toBlockFragments(fragments) { # {{{
		fragments.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			fragments.line('__ks_cb()')
		}
	} # }}}
	toQuote() { # {{{
		var mut fragments = '('

		for var parameter, index in @parameters {
			fragments += ', ' if index > 0

			fragments += parameter.toQuote()
		}

		fragments += ') => ...'

		return fragments
	} # }}}
	type() => @type
	type(@type) { # {{{
		for var parameter, index in @type.parameters() {
			@parameters[index]?.type(parameter)
		}
	} # }}}
	type(type: AnyType)
	type(type: ReferenceType) { # {{{
		if type.isAlias() {
			@type(type.discardAlias())
		}
	} # }}}
}
