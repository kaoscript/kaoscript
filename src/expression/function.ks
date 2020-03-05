class AnonymousFunctionExpression extends Expression {
	private lateinit {
		_autoTyping: Boolean			= false
		_awaiting: Boolean				= false
		_block: Block
		_exit: Boolean					= false
		_isObjectMember: Boolean		= false
		_parameters: Array<Parameter>
		_topNodes: Array				= []
		_type: Type
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope, ScopeType::Function)
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, Type.Any, this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@isObjectMember = @parent.parent() is DictionaryExpression
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)

		@block = $compile.function($ast.body(@data), this)
		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.returnType(@block.getUnpreparedType())
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

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} // }}}
	addInitializableVariable(variable, node)
	addTopNode(node) { // {{{
		@topNodes.push(node)
	} // }}}
	authority() => this
	getFunctionNode() => this
	getParameterOffset() => 0
	initializeVariable(variable, expression, node)
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isComputed() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isUsingVariable(name) => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		fragments.code('function(')

		const block = Parameter.toFragments(this, fragments, ParameterMode::Default, func(fragments) {
			return fragments.code(')').newBlock()
		})

		for const node in @topNodes {
			node.toAuthorityFragments(block)
		}

		block.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			block.line('__ks_cb()')
		}

		block.done()
	} // }}}
	type() => @type
}

class ArrowFunctionExpression extends Expression {
	private lateinit {
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
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope, ScopeType::Block)
	} // }}}
	analyse() { // {{{
		@es5 = @options.format.functions == 'es5'
		@block = $compile.function($ast.body(@data), this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)

		@block.analyse()

		@autoTyping = @data.type?.kind == NodeKind::ReturnTypeReference

		if @autoTyping {
			@type.returnType(@block.getUnpreparedType())
		}

		@usingThis = this.isUsingVariable('this')

		if @es5 {
			@variables = @block.listUsedVariables(@scope, [])

			if @usingThis || @variables.length != 0 {
				@shiftToAuthority = true

				const authority = this.authority()

				@name = authority.scope().getReservedName()

				authority.addTopNode(this)
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

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} // }}}
	addInitializableVariable(variable, node)
	getFunctionNode() => this
	getParameterOffset() { // {{{
		if @shiftToAuthority {
			return @variables.length
		}
		else {
			return 0
		}
	} // }}}
	initializeVariable(variable, expression, node)
	isAssertingParameter() => @options.rules.assertParameter
	isAssertingParameterType() => @options.rules.assertParameter && @options.rules.assertParameterType
	isComputed() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isUsingVariable(name) { // {{{
		for parameter in @parameters {
			if parameter.isUsingVariable(name) {
				return true
			}
		}

		return @block.isUsingVariable(name)
	} // }}}
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
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
				const bind = @usingThis ? 'this' : 'null'

				fragments.code(`\($runtime.helper(this)).vcurry(\(@name), \(bind)`)

				for const variable in @variables {
					fragments.code(`, \(variable.getSecureName())`)
				}

				fragments.code(')')
			}
		}
		else {
			if @es5 || (@parameters.length != 0 && !@usingThis) {
				fragments.code('function(')

				const block = Parameter.toFragments(this, fragments, ParameterMode::Default, func(fragments) {
					return fragments.code(')').newBlock()
				})

				block.compile(@block)

				if !@awaiting && !@exit && @type.isAsync() {
					block.line('__ks_cb()')
				}

				block.done()
			}
			else {
				fragments.code('(')

				const block = Parameter.toFragments(this, fragments, ParameterMode::ArrowFunction, func(fragments) {
					return fragments.code(') =>').newBlock()
				})

				block.compile(@block)

				if !@awaiting && !@exit && @type.isAsync() {
					block.line('__ks_cb()')
				}

				block.done()
			}
		}
	} // }}}
	toAuthorityFragments(fragments) { // {{{
		const ctrl = fragments.newControl().code(`var \(@name) = function(`)

		for const variable, index in @variables {
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
	} // }}}
	type() => @type
}