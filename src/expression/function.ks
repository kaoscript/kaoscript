class FunctionExpression extends Expression {
	private {
		_awaiting: Boolean				= false
		_exit: Boolean					= false
		_isObjectMember: Boolean		= false
		_parameters: Array<Parameter>
		_statements						= []
		_type: Type
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		@scope.define('this', true, this)
		
		@parameters = []
		for parameter in @data.parameters {
			@parameters.push(parameter = new Parameter(parameter, this))
			
			parameter.analyse()
		}
		
		@isObjectMember = @parent is ObjectMember
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
		
		@statements = []
		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@awaiting = true
			}
		}
		
		const rtype = @type.returnType()
		const na = !rtype.isAny()
		
		for statement in @statements {
			statement.prepare()
			
			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else if na && !statement.isReturning(rtype) {
				TypeException.throwUnexpectedReturnedType(rtype, statement)
			}
			else {
				@exit = statement.isExit()
			}
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isInstanceMethod() => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		let surround
		
		if @isObjectMember {
			if @options.format.functions == 'es5' {
				surround = {
					beforeParameters: ': function('
					afterParameters: ')'
					footer: ''
				}
			}
			else {
				surround = {
					beforeParameters: '('
					afterParameters: ')'
					footer: ''
				}
			}
		}
		else {
			surround = {
				beforeParameters: 'function('
				afterParameters: ')'
				footer: ''
			}
		}
		
		fragments.code(surround.beforeParameters)
		
		const block = Parameter.toFragments(this, fragments, ParameterMode::Default, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @awaiting {
			let index = -1
			let item
			
			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(block, Mode::None) {
					index = i
				}
			}
			
			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for statement in @statements {
				block.compile(statement)
			}
			
			if !@exit && @type.isAsync() {
				block.line('__ks_cb()')
			}
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
		_exit: Boolean			= false
		_parameters
		_statements				= []
		_type: Type
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
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
		
		@statements = []
		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@awaiting = true
			}
		}
		
		const rtype = @type.returnType()
		const na = !rtype.isAny()
		
		for statement in @statements {
			statement.prepare()
			
			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else if na && !statement.isReturning(rtype) {
				TypeException.throwUnexpectedReturnedType(rtype, statement)
			}
			else {
				@exit = statement.isExit()
			}
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isInstanceMethod() => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		let surround = $function.surround(this)
		
		fragments.code(surround.beforeParameters)
		
		let block = Parameter.toFragments(this, fragments, surround.arrow ? ParameterMode::ArrowFunction : ParameterMode::Default, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @awaiting {
			let index = -1
			let item
			
			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(block, Mode::None) {
					index = i
				}
			}
			
			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for statement in @statements {
				block.compile(statement)
			}
			
			if !@exit && @type.isAsync() {
				block.line('__ks_cb()')
			}
		}
		
		block.done()
		
		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
	type() => @type
}