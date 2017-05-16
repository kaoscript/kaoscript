class ThrowStatement extends Statement {
	private {
		_function	= null
		_inSource: Boolean	= true
		_value		= null
	}
	constructor(@data, @parent) { // {{{
		super(data, parent)
		
		do {
			if	parent is FunctionExpression ||
				parent is LambdaExpression ||
				parent is FunctionDeclaration ||
				parent is ClassMethodDeclaration ||
				parent is ImplementClassMethodDeclaration ||
				parent is ImplementNamespaceFunctionDeclaration
			{
				@function = parent
				@inSource = false
				break
			}
			else if	parent is ClassConstructorDeclaration ||
					parent is ClassDestructorDeclaration
			{
				@inSource = false
				break
			}
		}
		while parent ?= parent.parent()
	} // }}}
	analyse() { // {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
		
		if type !?= @value.type().dereference() {
			TypeException.throwRequireClass(this)
		}
		else if type is ClassType {
			Exception.validateReportedError(type, this)
		}
		else if !type.isAny() {
			TypeException.throwRequireClass(this)
		}
		else if @inSource && !this.module().isBinary() {
			SyntaxException.throwUnreportedError(this)
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