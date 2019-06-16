class Block extends AbstractNode {
	private {
		_awaiting: Boolean	= false
		_empty: Boolean		= false
		_exit: Boolean		= false
		_statements: Array	= []
		_type: Type			= null
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, true, AttributeTarget::Statement)

		if !?@data.statements {
			@data.statements = []
		}

		@empty = @data.statements.length == 0
	} // }}}
	analyse() { // {{{
		for statement in @data.statements {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} // }}}
	analyse(from: Number, to: Number = @data.statements.length + 1) { // {{{
		for statement in @data.statements from from to to {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} // }}}
	analyse(statements: Array<AbstractNode>) { // {{{
		for statement in statements {
			@statements.push(statement)

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} // }}}
	prepare() { // {{{
		const na = @type != null && !@type.isAny()

		for statement in @statements {
			@scope.line(statement.line())

			statement.prepare()

			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else if na && !statement.isReturning(@type) {
				TypeException.throwUnexpectedReturnedType(@type, statement)
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
	addStatement(statement) { // {{{
		@data.statements.push(statement)
	} // }}}
	isAwait() => @awaiting
	isEmpty() => @empty
	isExit() => @exit
	isUsingVariable(name) { // {{{
		for statement in @statements {
			if statement.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	isReturning(type: Type) { // {{{
		for statement in @statements {
			if !statement.isReturning(type) {
				return false
			}
		}

		return true
	} // }}}
	statements() => @data.statements
	toFragments(fragments, mode) { // {{{
		if @awaiting {
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
	toRangeFragments(fragments, from: Number, to: Number = @statements.length + 1) { // {{{
		for statement in @statements from from to to {
			statement.toFragments(fragments, Mode::None)
		}
	} // }}}
	type(@type) => this
}