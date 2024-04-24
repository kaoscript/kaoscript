class ReturnStatement extends Statement {
	private {
		@assert: Boolean		= false
		@async: Boolean			= false
		@await: Boolean			= false
		@exceptions: Boolean	= false
		@function				= null
		@inline: Boolean		= false
		@value					= null
		@target: Type?			= null
		@temp: String?			= null
		@type: Type				= Type.Void
	}
	constructor(@data, @parent, @scope) { # {{{
		super(data, parent, scope)

		var mut ancestor = parent

		while ?ancestor {
			if ancestor is IfExpression | MatchExpression {
				@inline = true
			}
			else if ancestor is ArrayComprehension | ObjectComprehension {
				break
			}
			else if ancestor is AnonymousFunctionExpression | ArrowFunctionExpression | FunctionDeclarator | ClassMethodDeclaration | ImplementDividedClassMethodDeclaration | ImplementNamespaceFunctionDeclaration {
				@function = ancestor

				break
			}

			ancestor = ancestor.parent()
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

			if ?#@afterwards {
				@temp = @scope.acquireTempName(this)
			}

			@assignTempVariables(@scope!?)

			@type = @value.type().discardValue().asReference()

			if @type == target {
				pass
			}
			else if target.isVoid() {
				TypeException.throwUnexpectedReturnedValue(this) unless @type.isVoid()
			}
			else if target.isValueOf() && target.isThisReference() {
				if @value.toQuote() != 'this' {
					TypeException.throwUnexpectedReturnType(target, @type, this)
				}
			}
			else if target.isAny() && target.isNullable() {
				pass
			}
			else if @value is UnaryOperatorTypeFitting && @value.isForced() {
				pass
			}
			else {
				if @type.isAny() && !@type.isExplicit() {
					pass
				}
				else if @type.isSubsetOf(target, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
					pass
				}
				else if !target.isDeferred() && @type.isAssignableToVariable(target, true, false, false) {
					pass
				}
				else {
					TypeException.throwUnexpectedReturnType(target, @type, this)
				}

				if !@isMisfit() && !target.isDeferred() && !@type.isFunction() && !@type.isAssignableToVariable(target, false, false, false) {
					@assert = true
					@target = target
				}
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
	isContinuousInlineReturn() => true
	override isExit(mode) => mode ~~ .Statement
	isExpectingType() => true
	override isUsingVariable(name, _) => @value?.isUsingVariable(name)
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
		fragments.compile(@value)
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
			if ?#@assignments {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if ?#@beforehands {
				for var beforehand in @beforehands {
					beforehand.toBeforehandFragments(fragments, mode)
				}
			}

			if @value.isAwaiting() {
				return @toAwaitStatementFragments^^(fragments, ^)
			}
			else {
				var line = fragments.newLine().code('return ')

				if @assert {
					if @async {
						line.code('__ks_cb(null, ')

						@target.toAssertFragments(@value, line, this)

						line.code(')')
					}
					else {
						@target.toAssertFragments(@value, line, this)
					}
				}
				else {
					if @async {
						line.code('__ks_cb(null, ').compile(@value).code(')')
					}
					else {
						line.compile(@value)
					}
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

				if ?#@assignments {
					fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
				}

				if ?#@beforehands {
					for var beforehand in @beforehands {
						beforehand.toBeforehandFragments(fragments, mode)
					}
				}

				fragments.newLine().code(`\($runtime.scope(this))\(@temp) = `).compile(@value).done()

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
