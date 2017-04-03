class FunctionExpression extends Expression {
	private {
		_awaiting: Boolean					= false
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
		
		for statement in @statements {
			statement.prepare()
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isMethod() => false
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
		
		const block = Parameter.toFragments(this, fragments, false, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @awaiting {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in @statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in @statements {
				block.compile(statement)
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
		_parameters
		_statements			= []
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
		
		for statement in @statements {
			statement.prepare()
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isMethod() => false
	parameters() => @parameters
	toFragments(fragments, mode) { // {{{
		let surround = $function.surround(this)
		
		fragments.code(surround.beforeParameters)
		
		let block = Parameter.toFragments(this, fragments, surround.arrow, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @awaiting {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in @statements {
				if item ?= statement.toFragments(f, m) {
					f = item.fragments
					m = item.mode
					
					stack.push(item)
				}
			}
			
			for item in stack {
				item.done(item.fragments)
			}
		}
		else {
			for statement in @statements {
				block.compile(statement)
			}
		}
		
		block.done()
		
		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
	type() => @type
}