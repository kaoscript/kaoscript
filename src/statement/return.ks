class ReturnStatement extends Statement {
	private {
		_await: Boolean			= false
		_async: Boolean			= false
		_enumCasting: Boolean	= false
		_exceptions: Boolean	= false
		_function				= null
		_value					= null
		_temp: String?			= null
		_type: Type				= Type.Any
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ancestor? && !(
			ancestor is AnonymousFunctionExpression ||
			ancestor is ArrowFunctionExpression ||
			ancestor is FunctionDeclarator ||
			ancestor is ClassMethodDeclaration ||
			ancestor is ImplementClassMethodDeclaration ||
			ancestor is ImplementNamespaceFunctionDeclaration
		) {
			ancestor = ancestor.parent()
		}

		if ancestor? {
			@function = ancestor
		}
	} # }}}
	constructor(@value, @parent) { # {{{
		super(value.data(), parent, parent.scope())
	} # }}}
	analyse() { # {{{
		if @data.value? {
			@value = $compile.expression(@data.value, this)

			@value.analyse()

			@await = @value.isAwait()
			@exceptions = @value.hasExceptions()
		}
	} # }}}
	prepare() { # {{{
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
	} # }}}
	translate() { # {{{
		if @value != null {
			@value.translate()
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if @value != null {
			@value.acquireReusable(acquire)
		}
	} # }}}
	checkReturnType(type: Type) { # {{{
		if ?@value {
			if @value is UnaryOperatorForcedTypeCasting {
				@type = type
			}
			else if !@type.isExplicit() && @type.isAny() {
				// do nothing
			}
			else if @type.isSubsetOf(type, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass) {
				// do nothing
			}
			else if @type.isEnum() && @type.isSubsetOf(type, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass + MatchingMode::AutoCast) {
				@type = type
				@enumCasting = true
			}
			else if @type.isUnion() {
				var mut cast = false

				for var tt in @type.types() {
					if tt.isSubsetOf(type, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass) {
						// do nothing
					}
					else if tt.isEnum() && tt.discard().type().isSubsetOf(type, MatchingMode::Exact + MatchingMode::NonNullToNull + MatchingMode::Subclass) {
						cast = true
					}
					else {
						TypeException.throwUnexpectedReturnType(type, @type, this)
					}
				}

				if cast {
					@type = type
					@enumCasting = true
				}
			}
			else {
				TypeException.throwUnexpectedReturnType(type, @type, this)
			}
		}
	} # }}}
	hasExceptions() => @exceptions
	getUnpreparedType() => @value.getUnpreparedType()
	initializeVariable(variable: VariableBrief, expression: Expression) { # {{{
		if variable.instance {
			if variable.immutable && @parent.isInitializedVariable(`this.\(variable.name)`) {
				ReferenceException.throwImmutableField(`\(variable.name)`, this)
			}

			if !@parent.isUsingInstanceVariableBefore(variable.name, this) {
				@parent.initializeVariable(variable, expression, this)
			}
		}
		else if variable.static {
			if !@parent.isUsingStaticVariableBefore(variable.class, variable.name, this) {
				@parent.initializeVariable(variable, expression, this)
			}
		}
		else {
			@parent.initializeVariable(variable, expression, this)
		}
	} # }}}
	isAwait() => @await
	isExit() => true
	isExpectingType() => true
	isUsingVariable(name) => @value != null && @value.isUsingVariable(name)
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		if @value != null {
			@value.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	reference() => @temp
	releaseReusable() { # {{{
		if @value != null {
			@value.releaseReusable()
		}
	} # }}}
	override setExpectedType(type) { # {{{
		if type.isNever() {
			TypeException.throwUnexpectedReturnedValue(this)
		}
		else if type.isVoid() {
			if @value != null {
				TypeException.throwUnexpectedReturnedValue(this)
			}
		}
		else {
			if @value == null {
				TypeException.throwExpectedReturnedValue(type, this)
			}
			else {
				@value.setExpectedType(type)
			}
		}
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		var line = fragments.newLine()

		var item = @value.toFragments(line, Mode::None)

		item([this])

		line.done()
	} # }}}
	toCastingFragments(fragments, mode) { # {{{
		if @enumCasting {
			@value.toCastingFragments(fragments, mode)
		}
		else {
			fragments.compile(@value)
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
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
				var line = fragments.newLine().code('return ')

				if @async {
					line.code('__ks_cb(null, ')

					@toCastingFragments(line, mode)

					line.code(')')
				}
				else {
					@toCastingFragments(line, mode)
				}

				line.done()
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

				var line = fragments.newLine().code(`\($runtime.scope(this))\(@temp) = `)

				@toCastingFragments(line, mode)

				line.done()

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
	} # }}}
	type() => @type
}
