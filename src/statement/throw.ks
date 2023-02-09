class ThrowStatement extends Statement {
	private {
		@function	= null
		@inSource: Boolean	= true
		@value		= null
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		do {
			if	ancestor is AnonymousFunctionExpression ||
				ancestor is ArrowFunctionExpression ||
				ancestor is FunctionDeclarator ||
				ancestor is ClassMethodDeclaration ||
				ancestor is ImplementClassMethodDeclaration ||
				ancestor is ImplementNamespaceFunctionDeclaration
			{
				@function = ancestor
				@inSource = false
				break
			}
			else if	ancestor is ClassConstructorDeclaration | ClassDestructorDeclaration
			{
				@inSource = false
				break
			}
		}
		while ancestor ?= ancestor.parent()
	} # }}}
	analyse() { # {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(AnyType.NullableUnexplicit)

		if type !?= @value.type().discardReference() {
			TypeException.throwRequireClass(this)
		}
		else if type.isNamed() && type.type() is ClassType {
			Exception.validateReportedError(type, this)
		}
		else if !type.isAny() {
			TypeException.throwRequireClass(this)
		}
		else if @inSource && !@module().isBinary() {
			SyntaxException.throwUnreportedError(this)
		}
	} # }}}
	isExit() => true
	isUsingVariable(name) => @value.isUsingVariable(name)
	translate() { # {{{
		@value.translate()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
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
	} # }}}
	type() => Type.Never
}
