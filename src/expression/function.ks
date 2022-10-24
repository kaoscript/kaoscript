class AnonymousFunctionExpression extends Expression {
	private late {
		@autoTyping: Boolean			= false
		@awaiting: Boolean				= false
		@block: Block
		@exit: Boolean					= false
		@isObjectMember: Boolean		= false
		@parameters: Array<Parameter>
		@topNodes: Array				= []
		@type: FunctionType
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType::Function)
	} # }}}
	analyse() { # {{{
		@scope.define('this', true, Type.Any, this)

		@parameters = []
		for var data in @data.parameters {
			var parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}

		@isObjectMember = @parent.parent() is DictionaryExpression
	} # }}}
	override prepare(target) { # {{{
		for var parameter in @parameters {
			parameter.prepare(AnyType.NullableUnexplicit)
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, 0, this)

		@block = $compile.function($ast.body(@data), this)
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

		var blockFunction = Parameter.toFragments(this, fragments.code('function('), ParameterMode::Default, (fragments) => fragments.code(')').newBlock())

		blockFunction.compile(@block, Mode::None)

		if !@awaiting && !@exit && @type.isAsync() {
			blockFunction.line('__ks_cb()')
		}

		blockFunction.done()

		fragments.code($comma)

		var assessment = @type.assessment('<router>', this)

		fragments.code(`(fn, `)

		if assessment.labelable {
			fragments.code('kws, ')
		}

		var blockRouter = fragments.code(`...args) =>`).newBlock()

		Router.toFragments(
			(function, line) => {
				line.code(`fn.call(null`)

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
			@parameters[index].type(parameter)
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
		@es5: Boolean					= false
		@exit: Boolean					= false
		@name: String
		@parameters: Array<Parameter>
		@shiftToAuthority: Boolean		= false
		@type: FunctionType
		@usingThis: Boolean				= false
		@variables: Array<Variable>
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType::Block)
	} # }}}
	analyse() { # {{{
		@es5 = @options.format.functions == 'es5'
		@block = $compile.function($ast.body(@data), this)

		@parameters = []
		for var data in @data.parameters {
			var parameter = new Parameter(data, this)

			parameter.analyse()

			@parameters.push(parameter)
		}
	} # }}}
	override prepare(target) { # {{{
		for var parameter in @parameters {
			parameter.prepare(AnyType.NullableUnexplicit)
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, 0, this)

		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}

		@usingThis = @isUsingVariable('this')

		if @es5 {
			@variables = @block.listNonLocalVariables(@scope, [])

			if @usingThis || @variables.length != 0 {
				@shiftToAuthority = true

				var authority = @authority()

				@name = authority.scope().getReservedName()

				authority.addTopNode(this)
			}
		}
	} # }}}
	translate() { # {{{
		for parameter in @parameters {
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
		@exit = @block.isExit()
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
		for parameter in @parameters {
			if parameter.isUsingVariable(name) {
				return true
			}
		}

		return @block.isUsingVariable(name)
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
				var bind = @usingThis ? 'this' : 'null'

				fragments.code(`\($runtime.helper(this)).vcurry(\(@name), \(bind)`)

				for var variable in @variables {
					fragments.code(`, \(variable.getSecureName())`)
				}

				fragments.code(')')
			}
		}
		else {
			fragments.code(`\($runtime.helper(this)).function(`)

			var blockFunction = Parameter.toFragments(this, fragments.code('('), ParameterMode::Default, (fragments) => fragments.code(') =>').newBlock())

			blockFunction.compile(@block, Mode::None)

			if !@awaiting && !@exit && @type.isAsync() {
				blockFunction.line('__ks_cb()')
			}

			blockFunction.done()

			fragments.code($comma)

			var assessment = @type.assessment(@name ?? '<router>', this)

			fragments.code(`(fn, `)

			if assessment.labelable {
				fragments.code('kws, ')
			}

			var blockRouter = fragments.code(`...args) =>`).newBlock()

			Router.toFragments(
				(function, line) => {
					line.code(`fn.call(this`)

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

		Parameter.toFragments(this, ctrl, ParameterMode::Default, func(fragments) {
			return fragments.code(')').step()
		})

		ctrl.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			ctrl.line('__ks_cb()')
		}

		ctrl.done()
	} # }}}
	type() => @type
	type(@type) { # {{{
		for var parameter, index in @type.parameters() {
			@parameters[index].type(parameter)
		}
	} # }}}
	type(type: AnyType)
	type(type: ReferenceType) { # {{{
		if type.isAlias() {
			@type(type.discardAlias())
		}
	} # }}}
}
