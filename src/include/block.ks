class Block extends AbstractNode {
	private {
		_awaiting: Boolean	= false
		_empty: Boolean		= false
		_exit: Boolean		= false
		_statements: Array	= []
		_type: Type?		= null
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget::Statement, this.file())

		if !?@data.statements {
			@data.statements = []
		}

		@empty = @data.statements.length == 0
	} # }}}
	analyse() { # {{{
		for statement in @data.statements {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.initiate()
			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} # }}}
	prepare() { # {{{
		if @type != null && !@type.isAny() {
			for const statement in @statements {
				@scope.line(statement.line())

				if @exit {
					SyntaxException.throwDeadCode(statement)
				}

				statement.setExpectedType(@type)

				statement.prepare()

				statement.checkReturnType(@type)

				@exit = statement.isExit()
			}
		}
		else {
			for const statement in @statements {
				@scope.line(statement.line())

				if @exit {
					SyntaxException.throwDeadCode(statement)
				}

				statement.prepare()

				@exit = statement.isExit()
			}
		}

		this.checkExit()
	} # }}}
	translate() { # {{{
		for statement in @statements {
			@scope.line(statement.line())

			statement.translate()
		}
	} # }}}
	addInitializableVariable(variable, node) { # {{{
		if !@scope.hasDeclaredVariable(variable.name()) {
			@parent.addInitializableVariable(variable, this)
		}
	} # }}}
	addStatement(statement) { # {{{
		@data.statements.push(statement)
	} # }}}
	analyse(from: Number, to: Number = @data.statements.length:Number + 1) { # {{{
		for statement in @data.statements from from to to {
			@scope.line(statement.start.line)

			@statements.push(statement = $compile.statement(statement, this))

			statement.initiate()
			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} # }}}
	analyse(statements: Array<AbstractNode>) { # {{{
		for statement in statements {
			@statements.push(statement)

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} # }}}
	checkExit() { # {{{
		if !@exit && @type != null && !@type.isVoid() {
			if @type.isNever() {
				TypeException.throwExpectedThrownError(this)
			}
			else if @type.isAny() && !@type.isExplicit() {
				// do nothing
			}
			else if @statements.length == 0 || !@statements.last().isExit() {
				TypeException.throwExpectedReturnedValue(@type, this)
			}
		}
	} # }}}
	checkReturnType(type: Type) { # {{{
		for const statement in @statements {
			statement.checkReturnType(type)
		}
	} # }}}
	getUnpreparedType() { # {{{
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
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		if !@scope.hasDeclaredVariable(variable.name) {
			if variable.lateInit && !@parent.isLateInitializable() {
				SyntaxException.throwInvalidLateInitAssignment(variable.name, this)
			}
			else {
				@parent.initializeVariable(variable, expression, this)
			}
		}
	} # }}}
	isAwait() => @awaiting
	isEmpty() => @empty
	isExit() => @exit
	isInitializingInstanceVariable(name) { # {{{
		for const statement in @statements {
			if statement.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isJumpable() => @parent.isJumpable()
	isLoop() => @parent.isLoop()
	isUsingVariable(name) { # {{{
		for const statement in @statements {
			if statement.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingInstanceVariableBefore(name: String, stmt: Statement): Boolean { # {{{
		const line = stmt.line()

		for const statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { # {{{
		const line = stmt.line()

		for const statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		for const statement in @statements {
			statement.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	statements() => @data.statements
	toFragments(fragments, mode) { # {{{
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
	} # }}}
	toRangeFragments(fragments, from: Number, to: Number = @statements.length + 1) { # {{{
		for statement in @statements from from to to {
			statement.toFragments(fragments, Mode::None)
		}
	} # }}}
	type() { # {{{
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
	} # }}}
	type(@type) => this
}

class FunctionBlock extends Block {
	private {
		@return: Expression		= null
	}
	addReturn(@return)
	override checkExit() { # {{{
		if @return != null {
			auto toAdd = false

			if const statement = @statements.last() {
				toAdd = !statement.isExit()
			}
			else {
				toAdd = true
			}

			if toAdd {
				const statement = new ReturnStatement(@return, this)

				statement.analyse()
				statement.prepare()

				@statements.push(statement)
			}
		}

		super()
	} # }}}
	isInitializedVariable(name: String): Boolean => true
}

class ConstructorBlock extends FunctionBlock {
	private {
		@initializedVariables: Dictionary<Boolean>		= {}
	}
	override initializeVariable(variable, expression, node) { # {{{
		lateinit const name

		if variable.instance {
			name = `this.\(variable.name)`

			this.parent().type().addInitializingInstanceVariable(variable.name)
		}
		else {
			name = variable.name
		}

		if @initializedVariables[name] {
			if variable.immutable {
				ReferenceException.throwImmutable(name, expression)
			}
		}
		else {
			@initializedVariables[name] = true
		}
	} # }}}
	isInitializedVariable(name: String): Boolean => @initializedVariables[name]
	isInitializingInstanceVariable(name: String): Boolean { # {{{
		if @initializedVariables[`this.\(name)`] {
			return true
		}

		for const statement in @statements {
			if statement.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
}

class MethodBlock extends FunctionBlock {
	override initializeVariable(variable, expression, node) { # {{{
		if variable.instance {
			 this.parent().type().addInitializingInstanceVariable(variable.name)
		}
		else {
			super(variable, expression, node)
		}
	} # }}}
}
