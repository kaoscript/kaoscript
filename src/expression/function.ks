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
		}, VariableKind::Variable)
		
		@parameters = [new Parameter(parameter, this) for parameter in @data.parameters]
		
		@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
		
		@isObjectMember = @parent is ObjectMember
	} // }}}
	fuse() { // {{{
		for parameter in @parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in @statements {
			statement.analyse()
			statement.fuse()
			
			if !@await {
				@await = statement.isAwait()
			}
		}
		
		@signature = new Signature(this)
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
		
		let block = $function.parameters(this, fragments, func(fragments) {
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
		@parameters = [new Parameter(parameter, this) for parameter in @data.parameters]
		
		@statements = [$compile.statement(statement, this) for statement in $body(@data.body)]
	} // }}}
	fuse() { // {{{
		for parameter in @parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in @statements {
			statement.analyse()
			statement.fuse()
			
			if !@await {
				@await = statement.isAwait()
			}
		}
		
		@signature = new Signature(this)
	} // }}}
	isMethod() => false
	toFragments(fragments, mode) { // {{{
		let surround = $function.surround(this)
		
		fragments.code(surround.beforeParameters)
		
		let block = $function.parameters(this, fragments, func(fragments) {
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
}