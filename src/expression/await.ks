class AwaitExpression extends Expression {
	private {
		@awaiting: Boolean		= true
		@function
		@operation
		@reuseName: String?		= null
		@try
	}
	constructor(@data, @parent, @scope = null) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ?ancestor && ancestor is not AnonymousFunctionExpression & ArrowFunctionExpression & FunctionDeclarator & ClassMethodDeclaration & ImplementClassMethodDeclaration & ImplementNamespaceFunctionDeclaration {
			if ancestor is TryStatement {
				@try = ancestor
			}

			ancestor = ancestor.parent()
		}

		if ?ancestor {
			@function = ancestor
		}
		else if !@module().isBinary() {
			SyntaxException.throwInvalidAwait(this)
		}
	} # }}}
	analyse() { # {{{
		@operation = $compile.expression(@data.operation, this)
		@operation.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@operation.prepare(target, targetMode)

		@reuseName = @scope.acquireTempName(false)
	} # }}}
	translate() { # {{{
		@operation.translate()
	} # }}}
	isAwait() => true
	isAwaiting() => @awaiting
	isUsingVariable(name) => @operation.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @operation.listNonLocalVariables(scope, variables)
	toAwaitExpressionFragments(fragments, statements) { # {{{
		fragments.code(`(__ks_e, \(@reuseName)) =>`)

		var block = fragments.newBlock()

		var mut index = -1
		var dyn item

		for statement, i in statements while index == -1 {
			if item ?= statement.toFragments(block, Mode::None) {
				index = i
			}
		}

		if index != -1 {
			item(statements.slice(index + 1))
		}

		block.done()

		fragments.code(')').done()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @awaiting {
			if var item ?= @operation.toFragments(fragments, Mode::Async) {
				return item
			}
			else {
				@awaiting = false

				if ?@try {
					return @try.toAwaitExpressionFragments^@(fragments, [new Literal(@reuseName!?, this)])
				}
				else if @function?.type().isAsync() {
					return @function.toAwaitExpressionFragments^@(fragments, [new Literal(@reuseName!?, this)])
				}
				else {
					return this.toAwaitExpressionFragments^@(fragments)
				}
			}
		}
		else {
			fragments.code(@reuseName)
		}
	} # }}}
	type() => @operation.type()
}
