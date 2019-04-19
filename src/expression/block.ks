class BlockExpression extends Expression {
	private {
		_await: Boolean		= false
		_exit: Boolean		= false
		_statements: Array	= []
	}
	analyse() { // {{{
		if @data.statements {
			for statement in @data.statements {
				@scope.line(statement.start.line)

				@statements.push(statement = $compile.statement(statement, this))

				statement.analyse()

				if statement.isAwait() {
					@await = true
				}
			}
		}
	} // }}}
	prepare() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.prepare()

			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else {
				@exit = statement.isExit()
			}
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} // }}}
	isAwait() => @await
	isExit() => @exit
	isReturning(type: Type) { // {{{
		for statement in @statements {
			if !statement.isReturning(type) {
				return false
			}
		}

		return true
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @await {
			let index = -1
			let item

			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(fragments, Mode::None) {
					index = i
				}
			}

			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for statement in @statements {
				statement.toFragments(fragments, mode)
			}
		}
	} // }}}
}