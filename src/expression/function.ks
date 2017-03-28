class FunctionExpression extends Expression {
	private {
		_await: Boolean		= false
		_isObjectMember		= false
		_parameters
		_signature
		_statements
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this, @scope, {
			kind: NodeKind::Identifier,
			name: 'this'
		}, true, VariableKind::Variable)
		
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
		
		@statements = []
		for statement in $body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@await = true
			}
		}
		
		for statement in @statements {
			statement.prepare()
		}
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isMethod() => false
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
		
		let block = $function.parameters(this, fragments, false, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @await {
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
	type() => Type.Any
}

class LambdaExpression extends Expression {
	private {
		_await: Boolean		= false
		_parameters
		_signature
		_statements
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
		
		@statements = []
		for statement in $body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))
			
			statement.analyse()
			
			if statement.isAwait() {
				@await = true
			}
		}
		
		for statement in @statements {
			statement.prepare()
		}
		
		@signature = Signature.fromNode(this)
	} // }}}
	translate() { // {{{
		for parameter in @parameters {
			parameter.translate()
		}
		
		for statement in @statements {
			statement.translate()
		}
	} // }}}
	isMethod() => false
	toFragments(fragments, mode) { // {{{
		let surround = $function.surround(this)
		
		fragments.code(surround.beforeParameters)
		
		let block = $function.parameters(this, fragments, surround.arrow, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
		})
		
		if @await {
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
	type() => Type.Any
}