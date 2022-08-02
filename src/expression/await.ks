class AwaitExpression extends Expression {
	private {
		_awaiting: Boolean		= true
		_function
		_operation
		_reuseName: String?		= null
		_try
	}
	constructor(@data, @parent, @scope = null) { # {{{
		super(data, parent, scope)

		while parent? && !(parent is AnonymousFunctionExpression || parent is ArrowFunctionExpression || parent is FunctionDeclarator || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
			if parent is TryStatement {
				@try = parent
			}

			parent = parent.parent()
		}

		if parent? {
			@function = parent
		}
		else if !this.module().isBinary() {
			SyntaxException.throwInvalidAwait(this)
		}
	} # }}}
	analyse() { # {{{
		@operation = $compile.expression(@data.operation, this)
		@operation.analyse()
	} # }}}
	prepare() { # {{{
		@operation.prepare()

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
			if item ?= @operation.toFragments(fragments, Mode::Async) {
				return item
			}
			else {
				@awaiting = false

				if @try? {
					return @try.toAwaitExpressionFragments^@(fragments, [new Literal(@reuseName:String, this)])
				}
				else if @function?.type().isAsync() {
					return @function.toAwaitExpressionFragments^@(fragments, [new Literal(@reuseName:String, this)])
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
