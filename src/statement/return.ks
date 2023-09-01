class ReturnStatement extends Statement {
	private {
		@await: Boolean			= false
		@async: Boolean			= false
		@enumCasting: Boolean	= false
		@exceptions: Boolean	= false
		@function				= null
		@inline: Boolean		= false
		@value					= null
		@temp: String?			= null
		@type: Type				= Type.Void
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ?ancestor && ancestor is not AnonymousFunctionExpression & ArrowFunctionExpression & FunctionDeclarator & ClassMethodDeclaration & ImplementDividedClassMethodDeclaration & ImplementNamespaceFunctionDeclaration {
			if ancestor is IfExpression | MatchExpression {
				@inline = true
			}

			ancestor = ancestor.parent()
		}

		if ?ancestor {
			@function = ancestor
		}
	} # }}}
	constructor(@value, @parent) { # {{{
		super(value.data(), parent, parent.scope())
	} # }}}
	analyse() { # {{{
		if !?@value && ?@data.value {
			@value = $compile.expression(@data.value, this)

			@value.analyse()

			@await = @value.isAwait()
			@exceptions = @value.hasExceptions()
		}
	} # }}}
	override prepare(mut target, targetMode) { # {{{
		if @inline && ?@function {
			target = @function.type().getReturnType()
		}

		if target.isNever() {
			TypeException.throwUnexpectedReturnedValue(this)
		}

		if ?@value {
			@value.prepare(target, TargetMode.Permissive)

			@value.acquireReusable(false)
			@value.releaseReusable()

			if #@afterwards {
				@temp = @scope.acquireTempName(this)
			}

			@assignTempVariables(@scope!?)

			@type = @value.type().asReference()

			if @type == target {
				pass
			}
			else if target.isVoid() {
				TypeException.throwUnexpectedReturnedValue(this) unless @type.isVoid()
			}
			else if !@type.isExplicit() && @type.isAny() {
				pass
			}
			else if target.isValueOf() && target.isThisReference() {
				if @value.toQuote() != 'this' {
					TypeException.throwUnexpectedReturnType(target, @type, this)
				}
			}
			else if @type.isSubsetOf(target, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
				pass
			}
			else if @type.isEnum() && @type.isSubsetOf(target, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast) {
				@type = target!?
				@enumCasting = true
			}
			else if @type.isUnion() {
				var mut cast = false

				for var tt in @type.types() {
					if tt.isSubsetOf(target, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
						pass
					}
					else if tt.isEnum() && tt.discard().type().isSubsetOf(target, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
						cast = true
					}
					else if tt.isAssignableToVariable(target, true, false, false) {
						pass
					}
					else {
						TypeException.throwUnexpectedReturnType(target, @type, this)
					}
				}

				if cast {
					@type = target!?
					@enumCasting = true
				}
			}
			else if @type.isAssignableToVariable(target, true, false, false) {
				pass
			}
			else {
				TypeException.throwUnexpectedReturnType(target, @type, this)
			}
		}
		else {
			TypeException.throwExpectedReturnedValue(target, this) unless target.isNullable() || target.isVoid()
		}

		if ?@function {
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
	toAwaitStatementFragments(fragments, statements) { # {{{
		var line = fragments.newLine()

		var item = @value.toFragments(line, Mode.None)

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
		if !?@value {
			if @async {
				fragments.line('return __ks_cb()')
			}
			else {
				fragments.line('return', @data)
			}
		}
		else if !?@temp {
			if #@assignments {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if #@beforehands {
				for var beforehand in @beforehands {
					beforehand.toBeforehandFragments(fragments, mode)
				}
			}

			if @value.isAwaiting() {
				return this.toAwaitStatementFragments^^(fragments, ^)
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
				throw NotImplementedException.new(this)
			}
			else {
				@assignments.remove(@temp)

				if #@assignments {
					fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
				}

				if #@beforehands {
					for var beforehand in @beforehands {
						beforehand.toBeforehandFragments(fragments, mode)
					}
				}

				var line = fragments.newLine().code(`\($runtime.scope(this))\(@temp) = `)

				@toCastingFragments(line, mode)

				line.done()

				for var afterward in @afterwards {
					afterward.toAfterwardFragments(fragments, mode)
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
	type() => @inline ? Type.Never : @type
	value() => @value
}
