class Block extends AbstractNode {
	private {
		_awaiting: Boolean	= false
		_empty: Boolean		= false
		_exit: Boolean		= false
		_statements: Array	= []
		// _type: Type?		= null
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
	override prepare(target) { # {{{
		if target? && !target.isAny() {
			for var statement in @statements {
				@scope.line(statement.line())

				if @exit {
					SyntaxException.throwDeadCode(statement)
				}

				// statement.setExpectedType(@type)

				statement.prepare(target)

				// statement.checkReturnType(@type)

				@exit = statement.isExit()
			}
		}
		else {
			for var statement in @statements {
				@scope.line(statement.line())

				if @exit {
					SyntaxException.throwDeadCode(statement)
				}

				statement.prepare(target)

				@exit = statement.isExit()
			}
		}

		@checkExit(target)
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
	checkExit(target?) { # {{{
		// if !@exit && target? && !target.isVoid() {
		// 	if target.isNever() {
		// 		TypeException.throwExpectedThrownError(this)
		// 	}
		// 	else if target.isAny() && !target.isExplicit() {
		// 		// do nothing
		// 	}
		// 	else if @statements.length == 0 || !@statements.last().isExit() {
		// 		TypeException.throwExpectedReturnedValue(target, this)
		// 	}
		// }
	} # }}}
	// checkReturnType(type: Type) { # {{{
	// 	for var statement in @statements {
	// 		statement.checkReturnType(type)
	// 	}
	// } # }}}
	getUnpreparedType() { # {{{
		var types = []

		for var statement in @statements {
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
		for var statement in @statements {
			if statement.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isJumpable() => @parent.isJumpable()
	isLoop() => @parent.isLoop()
	isUsingVariable(name) { # {{{
		for var statement in @statements {
			if statement.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingInstanceVariableBefore(name: String, stmt: Statement): Boolean { # {{{
		var line = stmt.line()

		for var statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingStaticVariableBefore(class: String, varname: String, stmt: Statement): Boolean { # {{{
		var line = stmt.line()

		for var statement in @statements while statement.line() < line && statement != stmt {
			if statement.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		for var statement in @statements {
			statement.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	statements() => @data.statements
	toFragments(fragments, mode) { # {{{
		if @awaiting {
			var mut index = -1
			var dyn item

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
		if @exit {
			var types = []

			for var statement in @statements {
				if statement.isExit() {
					types.push(statement.type())
				}
			}

			return Type.union(@scope, ...types)
		}
		else {
			return Type.Never
		}
	} # }}}
	// type(@type) => this
}

class FunctionBlock extends Block {
	private {
		@return: Expression		= null
	}
	addReturn(@return)
	override checkExit(target?) { # {{{
		if @return != null {
			var mut toAdd = true

			if var statement = @statements.last() {
				toAdd = !statement.isExit()
			}

			if toAdd {
				var statement = new ReturnStatement(@return, this)

				statement.analyse()
				statement.prepare(target)

				@statements.push(statement)
			}
		}

		if !@exit && target? && !target.isVoid() {
			if target.isNever() {
				TypeException.throwExpectedThrownError(this)
			}
			else if target.isAny() && !target.isExplicit() {
				// do nothing
			}
			else if @statements.length == 0 || !@statements.last().isExit() {
				TypeException.throwExpectedReturnedValue(target, this)
			}
		}
	} # }}}
	isInitializedVariable(name: String): Boolean => true
}

class ConstructorBlock extends FunctionBlock {
	private {
		@initializedVariables: Dictionary<Boolean>		= {}
	}
	override initializeVariable(variable, expression, node) { # {{{
		var late name

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

		for var statement in @statements {
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
