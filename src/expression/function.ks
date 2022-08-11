class AnonymousFunctionExpression extends Expression {
	private late {
		_autoTyping: Boolean			= false
		_awaiting: Boolean				= false
		_block: Block
		_exit: Boolean					= false
		_isObjectMember: Boolean		= false
		_parameters: Array<Parameter>
		_topNodes: Array				= []
		_type: Type
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType::Function)
	} # }}}
	analyse() { # {{{
		@scope.define('this', true, Type.Any, this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@isObjectMember = @parent.parent() is DictionaryExpression
	} # }}}
	prepare() { # {{{
		for parameter in @parameters {
			parameter.prepare()
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
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.type(@type.getReturnType()).prepare()
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
	hasPreservedParameter() { # {{{
		for var parameter in @parameters {
			return true if parameter.isPreserved()
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
	isUsingVariable(name) => false
	parameters() => @parameters
	toFragments(fragments, mode) { # {{{
		var assessment = this.type().assessment('__ks_rt', this)

		var block = fragments.code('(() =>').newBlock()

		var lineRouter = block.newLine().code(`const __ks_rt = (`)

		var preserved = @hasPreservedParameter()

		if preserved {
			for var parameter in @parameters {
				lineRouter.compile(parameter).code($comma)
			}
		}

		var blockRouter = lineRouter.code(`...args) =>`).newBlock()

		if preserved {
			var line = blockRouter.newLine().code(`args.unshift(`)

			for var parameter, index in @parameters {
				line.code($comma) unless index == 0

				line.compile(parameter)
			}

			line.code(')').done()
		}

		Router.toFragments(
			(function, line) => {
				line.code(`__ks_rt.__ks_\(function.index()).call(null`)

				return true
			}
			null
			assessment
			blockRouter
			this
		)

		blockRouter.done()
		lineRouter.done()

		var lineFunction = block.newLine()

		lineFunction.code('__ks_rt.__ks_0 = function(')

		var blockFunction = Parameter.toFragments(this, lineFunction, ParameterMode::Default, func(fragments) {
			return fragments.code(')').newBlock()
		})

		for var node in @topNodes {
			blockFunction.toAuthorityFragments(block)
		}

		blockFunction.compile(@block, Mode::None)

		if !@awaiting && !@exit && @type.isAsync() {
			blockFunction.line('__ks_cb()')
		}

		blockFunction.done()
		lineFunction.done()

		block.line('return __ks_rt')

		block.done()

		fragments.code(')()')
	} # }}}
	type() => @type
}

class ArrowFunctionExpression extends Expression {
	private late {
		_autoTyping: Boolean			= false
		_awaiting: Boolean				= false
		_block: Block
		_es5: Boolean					= false
		_exit: Boolean					= false
		_name: String
		_parameters: Array<Parameter>
		_shiftToAuthority: Boolean		= false
		_type: Type
		_usingThis: Boolean				= false
		_variables: Array<Variable>
	}
	constructor(data, parent, scope) { # {{{
		super(data, parent, scope, ScopeType::Block)
	} # }}}
	analyse() { # {{{
		@es5 = @options.format.functions == 'es5'
		@block = $compile.function($ast.body(@data), this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}
	} # }}}
	prepare() { # {{{
		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, 0, this)

		@block.analyse()

		@autoTyping = @type.isAutoTyping()

		if @autoTyping {
			@type.setReturnType(@block.getUnpreparedType())
		}

		@usingThis = this.isUsingVariable('this')

		if @es5 {
			@variables = @block.listNonLocalVariables(@scope, [])

			if @usingThis || @variables.length != 0 {
				@shiftToAuthority = true

				var authority = this.authority()

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
			@block.prepare()

			@type.setReturnType(@block.type())
		}
		else {
			@block.type(@type.getReturnType()).prepare()
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
	hasPreservedParameter() { # {{{
		for var parameter in @parameters {
			return true if parameter.isPreserved()
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
			if @es5 {
				throw new NotImplementedException(this)
			}
			else {
				var assessment = @type.assessment('__ks_rt', this)

				var block = fragments.code('(() =>').newBlock()

				var lineRouter = block.newLine().code(`const __ks_rt = (`)

				var preserved = @hasPreservedParameter()

				if preserved {
					for var parameter in @parameters {
						lineRouter.compile(parameter).code($comma)
					}
				}

				var blockRouter = lineRouter.code(`...args) =>`).newBlock()

				if preserved {
					var line = blockRouter.newLine().code(`args.unshift(`)

					for var parameter, index in @parameters {
						line.code($comma) unless index == 0

						line.compile(parameter)
					}

					line.code(')').done()
				}

				Router.toFragments(
					(function, line) => {
						line.code(`__ks_rt.__ks_\(function.index()).call(this`)

						return true
					}
					null
					assessment
					blockRouter
					this
				)

				blockRouter.done()
				lineRouter.done()

				var lineFunction = block.newLine()

				lineFunction.code('__ks_rt.__ks_0 = (')

				var blockFunction = Parameter.toFragments(this, lineFunction, ParameterMode::Default, func(fragments) {
					return fragments.code(') =>').newBlock()
				})

				blockFunction.compile(@block, Mode::None)

				if !@awaiting && !@exit && @type.isAsync() {
					blockFunction.line('__ks_cb()')
				}

				blockFunction.done()
				lineFunction.done()

				block.line('return __ks_rt')

				block.done()

				fragments.code(')()')
			}
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
}
