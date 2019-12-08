class ReturnStatement extends Statement {
	private {
		_await: Boolean			= false
		_async: Boolean			= false
		_function				= null
		_exceptions: Boolean	= false
		_value					= null
		_temp: String?			= null
		_type: Type				= Type.Any
	}
	constructor(@data, @parent, @scope) { // {{{
		super(data, parent, scope)

		while parent? && !(parent is AnonymousFunctionExpression || parent is ArrowFunctionExpression || parent is FunctionDeclarator || parent is ClassMethodDeclaration || parent is ImplementClassMethodDeclaration || parent is ImplementNamespaceFunctionDeclaration) {
			parent = parent.parent()
		}

		if parent? {
			@function = parent
		}
	} // }}}
	constructor(@value, @parent) { // {{{
		super(value.data(), parent, parent.scope())
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

			@value.acquireReusable(false)
			@value.releaseReusable()

			if @afterwards.length != 0 {
				@temp = @scope.acquireTempName(this)
			}

			this.assignTempVariables(@scope)

			@type = @value.type()
		}

		if @function? {
			@async = @function.type().isAsync()
		}
	} // }}}
	translate() { // {{{
		if @value != null {
			@value.translate()
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @value != null {
			@value.acquireReusable(acquire)
		}
	} // }}}
	checkReturnType(type: Type) { // {{{
		if type.isNever() {
			TypeException.throwUnexpectedReturnedValue(this)
		}
		else if @value == null {
			if !type.isVoid() {
				TypeException.throwExpectedReturnedValue(this)
			}
		}
		else {
			if type.isVoid() {
				TypeException.throwUnexpectedReturnedValue(this)
			}
			else if !@value.isMatchingType(type) {
				TypeException.throwUnexpectedReturnType(type, @value.type(), this)
			}
		}
	} // }}}
	hasExceptions() => @exceptions
	getUnpreparedType() => @value.getUnpreparedType()
	isAwait() => @await
	isExit() => true
	isExpectingType() => true
	isUsingVariable(name) => @value != null && @value.isUsingVariable(name)
	reference() => @temp
	releaseReusable() { // {{{
		if @value != null {
			@value.releaseReusable()
		}
	} // }}}
	toAwaitStatementFragments(fragments, statements) { // {{{
		const line = fragments.newLine()

		const item = @value.toFragments(line, Mode::None)

		item([this])

		line.done()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @value == null {
			if @async {
				fragments.line('return __ks_cb()')
			}
			else {
				fragments.line('return', @data)
			}
		}
		else if @temp == null {
			if @assignments.length != 0 {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if @value.isAwaiting() {
				return this.toAwaitStatementFragments^@(fragments)
			}
			else {
				if @async {
					fragments
						.newLine()
						.code('return __ks_cb(null, ')
						.compile(@value)
						.code(')')
						.done()
				}
				else {
					fragments
						.newLine()
						.code('return ')
						.compile(@value)
						.done()
				}
			}
		}
		else {
			if @value.isAwaiting() {
				throw new NotImplementedException(this)
			}
			else {
				@assignments.remove(@temp)

				if @assignments.length != 0 {
					fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
				}

				fragments
					.newLine()
					.code(`\($runtime.scope(this))\(@temp) = `)
					.compile(@value)
					.done()

				for afterward in @afterwards {
					afterward.toAfterwardFragments(fragments)
				}

				if @async {
					fragments.line(`return __ks_cb(null, \(@temp))`)
				}
				else {
					fragments.line(`return \(@temp)`)
				}
			}
		}
	} // }}}
	type() => @value.type()
}