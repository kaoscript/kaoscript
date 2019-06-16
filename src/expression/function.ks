class FunctionExpression extends Expression {
	private {
		_awaiting: Boolean				= false
		_block: Block
		_exit: Boolean					= false
		_isObjectMember: Boolean		= false
		_parameters: Array<Parameter>
		_type: Type
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope, ScopeType::Block)
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, Type.Any, this)

		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))

			parameter.analyse()
		}

		@isObjectMember = @parent.parent() is ObjectExpression
	} // }}}
	prepare() { // {{{
		for parameter in @parameters {
			parameter.prepare()
		}

		@type = new FunctionType([parameter.type() for parameter in @parameters], @data, this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		@block = $compile.block($ast.body(@data), this)
		@block.analyse()

		@awaiting = @block.isAwait()

		@block.prepare()

		@block.translate()
	} // }}}
	isComputed() => true
	isConsumedError(error): Boolean => @type.isCatchingError(error)
	isInstanceMethod() => false
	isUsingVariable(name) => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		let surround

		if @options.format.functions == 'es5' {
			if @isObjectMember && !@parent.parent().hasComputedProperties() {
				surround = {
					beforeParameters: ': function('
					afterParameters: ')'
					footer: ''
				}
			}
			else {
				surround = {
					beforeParameters: 'function('
					afterParameters: ')'
					footer: ''
				}
			}
		}
		else {
			if @isObjectMember {
				surround = {
					beforeParameters: '('
					afterParameters: ')'
					footer: ''
				}
			}
			else {
				surround = {
					beforeParameters: 'function('
					afterParameters: ')'
					footer: ''
				}
			}
		}

		fragments.code(surround.beforeParameters)

		const block = Parameter.toFragments(this, fragments, ParameterMode::Default, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})

		block.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			block.line('__ks_cb()')
		}

		block.done()

		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
	type() => @type
}

class LambdaExpression extends Expression {
	private {
		_awaiting: Boolean		= false
		_block: Block
		_exit: Boolean			= false
		_parameters
		_type: Type
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, scope, ScopeType::Block)
	} // }}}
	analyse() { // {{{
		@block = $compile.block($ast.body(@data), this)

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
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}

		@block.analyse()
		@block.prepare()
		@block.translate()

		@awaiting = @block.isAwait()
		@exit = @block.isExit()
	} // }}}
	isComputed() => true
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
		let surround = $function.surround(this)

		fragments.code(surround.beforeParameters)

		let block = Parameter.toFragments(this, fragments, surround.arrow ? ParameterMode::ArrowFunction : ParameterMode::Default, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})

		block.compile(@block)

		if !@awaiting && !@exit && @type.isAsync() {
			block.line('__ks_cb()')
		}

		block.done()

		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
	type() => @type
}