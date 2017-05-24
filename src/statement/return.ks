class ReturnStatement extends Statement {
	private {
		_await: Boolean			= false
		_function				= null
		_exceptions: Boolean	= false
		_value					= null
		_temp: String			= null
	}
	constructor(@data, @parent) { // {{{
		super(data, parent)
		
		while parent? && !(parent is FunctionExpression || parent is LambdaExpression || parent is FunctionDeclaration || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
			parent = parent.parent()
		}
		
		if parent? {
			@function = parent
		}
	} // }}}
	analyse() { // {{{
		if @data.value? {
			@value = $compile.expression(@data.value, this)
			
			@value.analyse()
			
			@await = @value.isAwait()
			@exceptions = @value.hasExceptions()
		}
	} // }}}
	prepare() { // {{{
		if @value != null {
			@value.prepare()
			
			if @afterwards.length != 0 {
				@temp = @scope.acquireTempName(this)
			}
		}
	} // }}}
	translate() { // {{{
		if @value != null {
			@value.translate()
		}
	} // }}}
	hasExceptions() => @exceptions
	isAwait() => @await
	isExit() => true
	isReturning(type: Type) => @value.type().isInstanceOf(type)
	reference() => @temp
	toAwaitStatementFragments(fragments, statements) { // {{{
		const line = fragments.newLine()
		
		const item = @value.toFragments(line, Mode::None)
		
		item([this])
		
		line.done()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @value == null {
			if @function?.type().isAsync() {
				fragments.line('return __ks_cb()')
			}
			else {
				fragments.line('return', @data)
			}
		}
		else if @temp == null {
			if @variables.length != 0 {
				fragments.newLine().code($runtime.scope(this) + @variables.join(', ')).done()
			}
			
			if @value.isAwaiting() {
				return this.toAwaitStatementFragments^@(fragments)
			}
			else {
				if @function?.type().isAsync() {
					fragments
						.newLine()
						.code('return __ks_cb(null, ')
						.compile(@value)
						.code(')')
						.done()
				}
				else {
					fragments
						.newLine()
						.code('return ')
						.compile(@value)
						.done()
				}
			}
		}
		else {
			if @value.isAwaiting() {
				throw new NotImplementedException(this)
			}
			else {
				@variables.remove(@temp)
				
				if @variables.length != 0 {
					fragments.newLine().code($runtime.scope(this) + @variables.join(', ')).done()
				}
				
				fragments
					.newLine()
					.code(`\($runtime.scope(this))\(@temp) = `)
					.compile(@value)
					.done()
				
				for afterward in @afterwards {
					afterward.toAfterwardFragments(fragments)
				}
				
				if @function?.type().isAsync() {
					fragments.line(`return __ks_cb(null, \(@temp))`)
				}
				else {
					fragments.line(`return \(@temp)`)
				}
			}
		}
	} // }}}
	type() => @value.type()
}