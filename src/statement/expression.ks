class ExpressionStatement extends Statement {
	private {
		_declaration: Boolean	= false
		_expression
		_ignorable: Boolean		= false
		_variable				= null
	}
	analyse() { // {{{
		@expression = $compile.expression(@data, this)
		@expression.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		for const data, name of @expression.inferTypes({}) {
			@scope.updateInferable(name, data, this)
		}

		@ignorable = @expression.isIgnorable()

		if !@ignorable {
			@expression.acquireReusable(false)
			@expression.releaseReusable()
		}

		this.assignTempVariables(@scope)
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	defineVariables(left, scope, expression, leftMost) { // {{{
		const assignments = []
		let variable = null

		const variables = left.listAssignments([])
		let declaration = variables.length != 0

		for const name in variables {
			if const variable = scope.getVariable(name) {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, this)
				}

				declaration = false
			}
			else if @options.rules.noUndefined {
				ReferenceException.throwNotDefined(name, this)
			}
			else {
				assignments.push(name)

				@scope.define(name, false, this)
			}
		}

		if declaration && @expression.isDeclarable() {
			@declaration = true

			if leftMost {
				left.setAssignment(AssignmentType::Declaration)
			}
			else {
				@assignments.push(...assignments)
			}
		}
		else {
			@assignments.push(...assignments)
		}
	} // }}}
	hasExceptions() => @expression.hasExceptions()
	isAwait() => @expression.isAwait()
	isExit() => @expression.isExit()
	isJumpable() => true
	isUsingVariable(name) => @expression.isUsingVariable(name)
	toAwaitStatementFragments(fragments, statements) { // {{{
		const line = fragments.newLine()

		const item = @expression.toFragments(line, Mode::None)

		statements.unshift(this)

		item(statements)

		line.done()
	} // }}}
	toFragments(fragments, mode) { // {{{
		return if @ignorable

		if @expression.isAwaiting() {
			return this.toAwaitStatementFragments^@(fragments)
		}
		else if @expression.isDeclarable() {
			if @assignments.length != 0 {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			let line = fragments.newLine()

			if @declaration {
				line.code($runtime.scope(this))
			}

			if @expression.toAssignmentFragments? {
				@expression.toAssignmentFragments(line)
			}
			else {
				@expression.toFragments(line, Mode::None)
			}

			line.done()
		}
		else {
			if @assignments.length != 0 {
				fragments.newLine().code($runtime.scope(this) + @assignments.join(', ')).done()
			}

			if @expression.toStatementFragments? {
				@expression.toStatementFragments(fragments, Mode::None)
			}
			else {
				fragments
					.newLine()
					.compile(@expression, Mode::None)
					.done()
			}
		}

		for afterward in @afterwards {
			afterward.toAfterwardFragments(fragments)
		}
	} // }}}
}