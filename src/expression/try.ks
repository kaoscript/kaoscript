class TryExpression extends Expression {
	private lateinit {
		_argument: Expression
		_defaultValue: Expression?		= null
		_reusable: Boolean				= false
		_reuseName: String?				= null
		_unwrap: Boolean				= false
	}
	analyse() { // {{{
		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Disabled {
				@unwrap = true
			}
		}

		@argument = $compile.expression(@data.argument, this)
		@argument.analyse()

		if @data.defaultValue? {
			@defaultValue = $compile.expression(@data.defaultValue, this)
			@defaultValue.analyse()
		}
	} // }}}
	prepare() { // {{{
		@argument.prepare()

		if @unwrap && @argument.type().isInoperative() {
			TypeException.throwUnexpectedInoperative(@argument, this)
		}

		if @defaultValue != null {
			@defaultValue.prepare()
		}
	} // }}}
	translate() { // {{{
		@argument.translate()

		if @defaultValue != null {
			@defaultValue.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}
	} // }}}
	isComputed() => true
	isConsumedError(error) => true
	isUsingVariable(name) => @argument.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) => @argument.listNonLocalVariables(scope, variables)
	releaseReusable() { // {{{
		if @reuseName != null {
			@scope.releaseTempName(@reuseName)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if @unwrap {
			fragments.compileBoolean(@argument)
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
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)

		@reusable = true
	} // }}}
	type() => @argument.type()
}