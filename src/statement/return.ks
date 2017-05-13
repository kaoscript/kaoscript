class ReturnStatement extends Statement {
	private {
		_await: Boolean			= false
		_function				= null
		_exceptions: Boolean	= false
		_value					= null
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
	toAwaitStatementFragments(fragments, statements) { // {{{
		const line = fragments.newLine()
		
		const item = @value.toFragments(line, Mode::None)
		
		item([this])
		
		line.done()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @value.isAwaiting() {
			return this.toAwaitStatementFragments^@(fragments)
		}
		else if @function?.type().isAsync() {
			if @value != null {
				fragments
					.newLine()
					.code('return __ks_cb(null, ')
					.compile(@value)
					.code(')')
					.done()
			}
			else {
				fragments.line('return __ks_cb()')
			}
		}
		else {
			if @value != null {
				fragments
					.newLine()
					.code('return ')
					.compile(@value)
					.done()
			}
			else {
				fragments.line('return', @data)
			}
		}
	} // }}}
	type() => @value.type()
}