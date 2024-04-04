class TryExpression extends Expression {
	private late {
		@argument: Expression
		@defaultValue: Expression?		= null
		@reusable: Boolean				= false
		@reuseName: String?				= null
		@unwrap: Boolean				= false
	}
	analyse() { # {{{
		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Disabled {
				@unwrap = true
			}
		}

		@argument = $compile.expression(@data.argument, this)
		@argument.analyse()

		if ?@data.defaultValue {
			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@argument.prepare(target)

		if @unwrap && @argument.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		@defaultValue?.prepare(target)
	} # }}}
	translate() { # {{{
		@argument.translate()

		if @defaultValue != null {
			@defaultValue.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} # }}}
	isComputed() => true
	isConsumedError(error) => true
	isUsingVariable(name) => @argument.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @argument.listNonLocalVariables(scope, variables)
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if @unwrap {
			fragments.compile(@argument)
		}
		else {
			fragments.code($runtime.helper(this), '.try(')

			if @options.format.functions == 'es5' {
				fragments.code('function(){return ').compile(@argument).code(';}')
			}
			else {
				fragments.code('() => ').compile(@argument)
			}

			fragments.code(', ')

			if @defaultValue == null {
				fragments.code('null')
			}
			else {
				fragments.compile(@defaultValue)
			}

			fragments.code(')')
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if @unwrap {
			fragments.compileCondition(@argument)
		}
		else if @defaultValue == null {
			fragments.code($runtime.helper(this), '.tryTest(')

			if @options.format.functions == 'es5' {
				fragments.code('function(){return ').compile(@argument).code(';}')
			}
			else {
				fragments.code('() => ').compile(@argument)
			}

			fragments.code(')')
		}
		else {
			this.toFragments(fragments, mode)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} # }}}
	toQuote() { # {{{
		if ?@defaultValue {
			return `try \(@argument.toQuote()) ~ \(@defaultValue.toQuote())`
		}
		else {
			return `try \(@argument.toQuote())`
		}
	} # }}}
	type() => @argument.type()
}
