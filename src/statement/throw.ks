class ThrowStatement extends Statement {
	private {
		_function	= null
		_inSource: Boolean	= true
		_value		= null
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)

		do {
			if	parent is AnonymousFunctionExpression ||
				parent is ArrowFunctionExpression ||
				parent is FunctionDeclarator ||
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

		if type !?= @value.type().discardReference() {
			TypeException.throwRequireClass(this)
		}
		else if type.isNamed() && type.type() is ClassType {
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
	isUsingVariable(name) => @value.isUsingVariable(name)
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