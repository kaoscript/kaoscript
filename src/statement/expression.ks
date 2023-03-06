class ExpressionStatement extends Statement {
	private late {
		@declaration: Boolean	= false
		@expression: Expression
		@ignorable: Boolean		= false
		@variable				= null
	}
	analyse() { # {{{
		@expression = $compile.expression(@data, this)
		@expression.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(Type.Void)

		for var data, name of @expression.inferTypes({}) {
			@scope.updateInferable(name, data, this)
		}

		@ignorable = @expression.isIgnorable()

		if !@ignorable {
			@expression.acquireReusable(false)
			@expression.releaseReusable()
		}

		@assignTempVariables(@scope!?)
	} # }}}
	translate() { # {{{
		@expression.translate()
	} # }}}
	defineVariables(left: AbstractNode, names: Array<String>, scope: Scope, expression? = null, leftMost: Boolean = false) { # {{{
		var assignments = []
		var mut variable = null

		var mut declaration = names.length != 0

		for var name in names {
			if var variable ?= scope.getVariable(name) {
				if variable.isLateInit() {
					@parent.addInitializableVariable(variable, this)
				}
				else if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}

				declaration = false
			}
			else if @options.rules.noUndefined {
				ReferenceException.throwNotDefined(name, this)
			}
			else {
				assignments.push(name)

				@scope.define(name, false, AnyType.NullableUnexplicit, this)
			}
		}

		if declaration && @expression.isDeclarable() {
			@declaration = true

			if leftMost {
				left.setAssignment(AssignmentType.Declaration)
			}
			else {
				@assignments.push(...assignments)
			}
		}
		else {
			@assignments.push(...assignments)
		}
	} # }}}
	hasExceptions() => @expression.hasExceptions()
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
	isAwait() => @expression.isAwait()
	isExit() => @expression.isExit()
	isInitializingInstanceVariable(name: String): Boolean => @expression.isInitializingInstanceVariable(name)
	isJumpable() => true
	isLateInitializable() => true
	isUsingVariable(name) => @expression.isUsingVariable(name)
	isUsingInstanceVariable(name) => @expression.isUsingInstanceVariable(name)
	isUsingStaticVariable(class, varname) => @expression.isUsingStaticVariable(class, varname)
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		@expression.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		var line = fragments.newLine()

		var item = @expression.toFragments(line, Mode.None)

		statements.unshift(this)

		item(statements)

		line.done()
	} # }}}
	toFragments(fragments, mode) { # {{{
		return if @ignorable

		if @expression.isSkippable() {
			pass
		}
		else if @expression.isAwaiting() {
			return this.toAwaitStatementFragments^^(fragments, ^)
		}
		else if @expression.isDeclarable() {
			if #@assignments {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if #@beforehands {
				for var beforehand in @beforehands {
					beforehand.toBeforehandFragments(fragments, mode)
				}
			}

			var mut line = fragments.newLine()

			if @declaration {
				line.code($runtime.scope(this))
			}

			if ?@expression.toAssignmentFragments {
				@expression.toAssignmentFragments(line)
			}
			else {
				@expression.toFragments(line, Mode.None)
			}

			line.done()
		}
		else {
			if #@assignments {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if #@beforehands {
				for var beforehand in @beforehands {
					beforehand.toBeforehandFragments(fragments, mode)
				}
			}

			if ?@expression.toStatementFragments {
				@expression.toStatementFragments(fragments, Mode.None)
			}
			else {
				fragments
					.newLine()
					.compile(@expression, Mode.None)
					.done()
			}
		}

		for var afterward in @afterwards {
			afterward.toAfterwardFragments(fragments, mode)
		}
	} # }}}
	walkNode(fn) => fn(this) && @expression.walkNode(fn)
}
