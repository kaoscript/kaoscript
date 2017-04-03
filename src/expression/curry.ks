class CurryExpression extends Expression {
	private {
		_arguments: Array	= []
		_callee
		_callScope
		_list: Boolean		= true
		_tested: Boolean		= false
	}
	analyse() { // {{{
		@callee = $compile.expression(@data.callee, this)
		@callee.analyse()
		
		for argument in @data.arguments {
			if argument.kind == NodeKind::UnaryExpression && argument.operator.kind == UnaryOperatorKind::Spread {
				@arguments.push(argument = $compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push(argument = $compile.expression(argument, this))
			}
			
			argument.analyse()
		}
	} // }}}
	prepare() { // {{{
		@callee.prepare()
		
		for argument in @arguments {
			argument.prepare()
		}
	} // }}}
	translate() { // {{{
		@callee.translate()
		
		if @data.scope.kind == ScopeKind::Argument {
			@callScope = $compile.expression(@data.scope.value, this)
			@callScope.analyse()
			@callScope.prepare()
			@callScope.translate()
		}
		
		for argument in @arguments {
			argument.translate()
		}
	} // }}}
	isNullable() { // {{{
		return @data.nullable || @callee.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ')
			
			@tested = true
			
			this.toFragments(fragments)
			
			fragments.code(' : undefined')
		}
		else if @list {
			this.module().flag('Helper')
			
			let kind = @data.scope.kind
			
			if kind == ScopeKind::This {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code(', ')
					.compile(@callee.caller())
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else if kind == ScopeKind::Null {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code(', null')
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code($comma)
					.compile(@callScope)
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
		}
		else {
			this.module().flag('Helper')
			
			let kind = @data.scope.kind
			
			if kind == ScopeKind::This {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code($comma)
					.compile(@callee.caller())
					.code($comma)
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
					
				fragments.code(')')
			}
			else if kind == ScopeKind::Null {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code(', null, ')
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code($comma)
					.compile(@callScope)
					.code($comma)
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
				
				fragments.code(')')
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			@tested = true
			
			if @data.nullable {
				if @callee.isNullable() {
					fragments
						.wrapNullable(@callee)
						.code(' && ')
				}
				
				fragments
					.code($runtime.type(this) + '.isFunction(')
					.compileReusable(@callee)
					.code(')')
			}
			else {
				if @callee.isNullable() {
					fragments.compileNullable(@callee)
				}
			}
		}
	} // }}}
	type() => @scope.reference('Function')
}