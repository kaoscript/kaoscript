class FunctionExpression extends Expression {
	private {
		_async			= false
		_isObjectMember	= false
		_parameters
		_statements
	}
	$create(data, parent, scope) { // {{{
		super(data, parent, new Scope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this, this._scope, {
			kind: Kind::Identifier,
			name: 'this'
		}, VariableKind::Variable)
		
		this._parameters = [new Parameter(parameter, this) for parameter in this._data.parameters]
		
		this._statements = [$compile.statement(statement, this) for statement in $body(this._data.body)]
		
		this._isObjectMember = this._parent is ObjectMember
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
		let surround
		
		if this._isObjectMember {
			if this._options.format.functions == 'es5' {
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
		
		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
}

class LambdaExpression extends Expression {
	private {
		_async			= false
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
		let surround = $function.surround(this)
		
		fragments.code(surround.beforeParameters)
		
		let block = $function.parameters(this, fragments, func(fragments) {
			return fragments.code(surround.afterParameters).newBlock()
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
		
		if surround.footer.length > 0 {
			fragments.code(surround.footer)
		}
	} // }}}
}