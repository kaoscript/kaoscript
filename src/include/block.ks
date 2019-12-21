class Block extends AbstractNode {
	private {
		_awaiting: Boolean	= false
		_empty: Boolean		= false
		_exit: Boolean		= false
		_statements: Array	= []
		_type: Type?		= null
	}
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget::Statement, this.file())

		if !?@data.statements {
			@data.statements = []
		}

		@empty = @data.statements.length == 0
	} // }}}
	addInitializableVariable(variable, node) { // {{{
		if !@scope.hasDeclaredVariable(variable.name()) {
			@parent.addInitializableVariable(variable, this)
		}
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
		const notAny = @type != null && !@type.isAny()

		for const statement in @statements {
			@scope.line(statement.line())

			statement.prepare()

			if @exit {
				SyntaxException.throwDeadCode(statement)
			}
			else {
				if notAny {
					statement.checkReturnType(@type)
				}

				@exit = statement.isExit()
			}
		}

		if !@exit && @type != null && !@type.isVoid() {
			if @type.isNever() {
				TypeException.throwExpectedThrownError(this)
			}
			else if @type.isAny() && !@type.isExplicit() {
				// do nothing
			}
			else if @statements.length == 0 {
				TypeException.throwExpectedReturnedValue(this)
			}
			else {
				@statements[@statements.length - 1].checkReturnType(@type)
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
	checkReturnType(type: Type) { // {{{
		for const statement in @statements {
			statement.checkReturnType(type)
		}
	} // }}}
	getUnpreparedType() { // {{{
		const types = []

		for const statement in @statements {
			if statement.isExit() {
				types.push(statement.getUnpreparedType())
			}
		}

		if types.length == 0 {
			return Type.Never
		}
		else {
			return Type.union(@scope, ...types)
		}
	} // }}}
	initializeVariable(variable, type, expression, node) { // {{{
		if !@scope.hasDeclaredVariable(variable.name()) {
			if variable.isInitialized() || @parent.isLateInitializable() {
				@parent.initializeVariable(variable, type, expression, this)
			}
			else {
				SyntaxException.throwInvalidLateInitAssignment(variable.name(), this)
			}
		}
	} // }}}
	isAwait() => @awaiting
	isEmpty() => @empty
	isExit() => @exit
	isJumpable() => @parent.isJumpable()
	isLoop() => @parent.isLoop()
	isUsingVariable(name) { // {{{
		for statement in @statements {
			if statement.isUsingVariable(name) {
				return true
			}
		}

		return false
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
	type() { // {{{
		if @type == null {
			if @exit {
				const types = []

				for const statement in @statements {
					if statement.isExit() {
						types.push(statement.type())
					}
				}

				@type = Type.union(@scope, ...types)
			}
			else {
				@type = Type.Never
			}
		}

		return @type
	} // }}}
	type(@type) => this
}

class FunctionBlock extends Block {
	private {
		_initializableVariables		= {}
	}
	addInitializableVariable(variable, node) { // {{{
		@initializableVariables[variable.name()] = true
	} // }}}
	addReturn(value: Expression) { // {{{
		if !@exit || !@statements.last().isExit() {
			@statements.push(new ReturnStatement(value, this))
		}
	} // }}}
	initializeVariable(variable, type, expression, node) { // {{{
		const name = variable.name()

		if variable.isInitialized() {
			if variable.isImmutable() {
				ReferenceException.throwImmutable(name, expression)
			}
			else if !type.matchContentOf(variable.getDeclaredType()) {
				TypeException.throwInvalidAssignement(name, variable.getDeclaredType(), type, expression)
			}
		}
		else if @initializableVariables[name] {
			if variable.isDefinitive() {
				variable.setRealType(type)
			}
			else {
				variable.setDeclaredType(type, true).flagDefinitive()
			}

			delete @initializableVariables[name]
		}
		else {
			ReferenceException.throwImmutable(name, expression)
		}
	} // }}}
}