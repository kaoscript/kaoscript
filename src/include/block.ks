class Block extends AbstractNode {
	private {
		@awaiting: Boolean	= false
		@empty: Boolean		= false
		@exit: Boolean		= false
		@length: Number		= 0
		@offset: Number		= 0
		@statements: Array	= []
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget.Statement, @file())

		if !?@data.statements {
			@data.statements = []
		}

		@length = @data.statements.length
		@empty = @length == 0
		@offset = @scope.getLineOffset()
	} # }}}
	analyse() { # {{{
		@scope.setLineOffset(@offset)

		for var data in @data.statements {
			@scope.line(data.start.line)

			var statement = $compile.statement(data, this)

			statement.initiate()

			@statements.push(statement)
		}

		@scope.setLineOffset(@offset)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}

		@scope.setLineOffset(@offset)

		for var statement in @statements {
			@scope.line(statement.line())

			statement.enhance()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@scope.setLineOffset(@offset)

		for var statement, index in @statements {
			@scope.line(statement.line())

			if @exit {
				SyntaxException.throwDeadCode(statement)
			}

			statement.prepare(target, index, @length)

			@exit = statement.isExit()
		}

		@checkExit(target)
	} # }}}
	translate() { # {{{
		@scope.setLineOffset(@offset)

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
	addDataStatement(statement) { # {{{
		@data.statements.push(statement)
	} # }}}
	analyse(from: Number, to: Number = @data.statements.length:Number + 1) { # {{{
		@scope.setLineOffset(@offset)

		for var data in @data.statements from from to to {
			@scope.line(data.start.line)

			var statement = $compile.statement(data, this)

			statement.initiate()
			statement.analyse()

			@statements.push(statement)

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} # }}}
	analyse(statements: Array<AbstractNode>) { # {{{
		@scope.setLineOffset(@offset)

		for statement in statements {
			@scope.line(statement.line())

			@statements.push(statement)

			statement.analyse()

			if statement.isAwait() {
				@awaiting = true
			}
		}
	} # }}}
	checkExit(target?)
	getDataStatements() => @data.statements
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
	length() => @length
	listNonLocalVariables(scope: Scope, variables: Array) { # {{{
		for var statement in @statements {
			statement.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	statements() => @statements
	toFragments(fragments, mode) { # {{{
		if @awaiting {
			var mut index = -1
			var dyn item

			for statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(fragments, Mode.None) {
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
			statement.toFragments(fragments, Mode.None)
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
	walkNode(fn) { # {{{
		return false unless fn(this)

		for var statement in @statements {
			return false unless statement.walkNode(fn)
		}

		return true
	} # }}}
}

class FunctionBlock extends Block {
	private {
		@return: Expression?		= null
	}
	addReturn(@return)
	override checkExit(target?) { # {{{
		if @return != null {
			var mut toAdd = true

			if var statement ?= @statements.last() {
				toAdd = !statement.isExit()
			}

			if toAdd {
				var statement = new ReturnStatement(@return, this)

				statement.analyse()
				statement.prepare(target)

				@statements.push(statement)
			}
		}

		if !@exit && ?target && !target.isVoid() {
			if target.isNever() {
				TypeException.throwExpectedThrownError(this)
			}
			else if target.isAny() && !target.isExplicit() {
				pass
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
		@initializedVariables: Object<Boolean>		= {}
	}
	override initializeVariable(variable, expression, node) { # {{{
		var late name

		if variable.instance {
			name = `this.\(variable.name)`

			@parent().type().flagInitializingInstanceVariable(variable.name)
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
			@parent().type().flagInitializingInstanceVariable(variable.name)
		}
		else {
			super(variable, expression, node)
		}
	} # }}}
}
