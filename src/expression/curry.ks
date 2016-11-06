class CurryExpression extends Expression {
	private {
		_arguments	= []
		_callee
		_caller
		_callScope
		_list		= true
		_tested		= false
	}
	CurryExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._callee = $compile.expression(this._data.callee, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
		
		if !this._list && this._arguments.length != 1 {
			throw new Error(`Invalid curry syntax at line \(this._data.start.line)`)
		}
		
		if this._data.scope.kind == ScopeModifier::This {
			this._caller = $caller(this._callee, this)
		}
		else if this._data.scope.kind == ScopeModifier::Argument {
			this._callScope = $compile.expression(this._data.scope.value, this)
		}
	} // }}}
	fuse() { // {{{
		this._callee.fuse()
		this._caller.fuse() if this._caller?
		this._callScope.fuse() if this._callScope?
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !this._tested {
			fragments.wrapNullable(this).code(' ? ')
			
			this._tested = true
			
			this.toFragments(fragments)
			
			fragments.code(' : undefined')
		}
		else if this._list {
			this.module().flag('Helper')
			
			let kind = this._data.scope.kind
			
			if kind == ScopeModifier::This {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code(', ')
				
				if this._caller? {
					fragments.compile(this._caller)
				}
				else {
					fragments.code('null')
				}
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else if kind == ScopeModifier::Null {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code(', null')
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(this._callee)
					.code($comma)
					.compile(this._callScope)
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
		}
		else {
			this.module().flag('Helper')
			
			let kind = this._data.scope.kind
			
			if kind == ScopeModifier::This {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code($comma)
				
				if this._caller? {
					fragments.compile(this._caller)
				}
				else {
					fragments.code('null')
				}
				
				fragments
					.code($comma)
					.compile(this._arguments[0])
					.code(')')
			}
			else if kind == ScopeModifier::Null {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code(', null, ')
					.compile(this._arguments[0])
					.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(this._callee)
					.code($comma)
					.compile(this._callScope)
					.code($comma)
					.compile(this._arguments[0])
					.code(')')
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			this._tested = true
			
			if this._data.nullable {
				if this._callee.isNullable() {
					fragments
						.wrapNullable(this._callee)
						.code(' && ')
				}
				
				fragments
					.code($runtime.type(this) + '.isFunction(')
					.compileReusable(this._callee)
					.code(')')
			}
			else {
				if this._callee.isNullable() {
					fragments.compileNullable(this._callee)
				}
			}
		}
	} // }}}
}