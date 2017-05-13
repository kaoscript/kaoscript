class ThrowStatement extends Statement {
	private {
		_function	= null
		_value		= null
	}
	constructor(@data, @parent) {
		super(data, parent)
		
		while parent? && !(parent is FunctionExpression || parent is LambdaExpression || parent is FunctionDeclaration || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
			parent = parent.parent()
		}
		
		if parent? {
			@function = parent
		}
	}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
		
		if (type ?= @value.type().unalias()) && type is ClassType {
			Exception.validateReportedError(type, this)
		}
	} // }}}
	isExit() => true
	translate() { // {{{
		@value.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @function?.type().isAsync() {
			fragments
				.newLine()
				.code('return __ks_cb(')
				.compile(@value)
				.code(')')
				.done()
		}
		else {
			fragments
				.newLine()
				.code('throw ')
				.compile(@value)
				.done()
		}
	} // }}}
}