class FunctionExpression extends Expression {
	private {
		_async		= false
		_parameters
		_statements
	}
	$create(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $body(this._data.body)]
	} // }}}
	fuse() { // {{{
		for parameter in this._parameters {
			parameter.analyse()
			parameter.fuse()
		}
		
		for statement in this._statements {
			statement.analyse()
			
			this._async = statement.isAsync() if !this._async
		}
		
		for statement in this._statements {
			statement.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('function(')
		
		let block = $function.parameters(this, fragments, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		if this._async {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in this._statements {
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
			for statement in this._statements {
				block.compile(statement)
			}
		}
		
		block.done()
	} // }}}
	toShorthandFragments(fragments) { // {{{
		fragments.code('(')
		
		let block = $function.parameters(this, fragments, func(fragments) {
			return fragments.code(')').newBlock()
		})
		
		if this._async {
			let stack = []
			
			let f = block
			let m = Mode::None
			
			let item
			for statement in this._statements {
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
			for statement in this._statements {
				block.compile(statement)
			}
		}
		
		block.done()
	} // }}}
}