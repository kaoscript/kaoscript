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
			if ancestor is AnonymousFunctionExpression | ArrowFunctionExpression | FunctionDeclarator | ClassMethodDeclaration | ImplementDividedClassMethodDeclaration | ImplementNamespaceFunctionDeclaration {
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

		var type = @value.type().discardReference()

		if !?type {
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
	override isExit(mode) => mode ~~ .Statement
	override isUsingVariable(name, _) => @value.isUsingVariable(name)
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
