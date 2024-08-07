class Block extends AbstractNode {
	private {
		@awaiting: Boolean			= false
		@empty: Boolean				= false
		@exit: Boolean				= false
		@length: Number				= 0
		@offset: Number				= 0
		@statements: Statement[]	= []
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
	override analyse() { # {{{
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

			@awaiting ||= statement.isAwait()
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

			@exit ||= statement.isExit(.Expression + .Statement + .Always)
		}

		@checkExit(target)
	} # }}}
	translate() { # {{{
		@scope.setLineOffset(@offset)

		for var statement in @statements {
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
	analyse(from: Number, to: Number = @data.statements.length:!!!(Number) + 1) { # {{{
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

		for var statement in statements {
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
	getLoopAncestorWithoutNew(name: String, before): Statement? { # {{{
		for var statement in @statements while statement != before {
			if statement.isDeclararingVariable(name) {
				return null
			}
		}

		return @parent.getLoopAncestorWithoutNew(name, this)
	} # }}}
	getUnpreparedType() { # {{{
		var types = []

		for var statement in @statements {
			if statement.isExit(.Statement) {
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
		if @scope.hasDeclaredVariable(variable.name) {
			if var var ?= @scope.getDefinedVariable(variable.name) ;; !var.isInitialized() {
				var.setDeclaredType(variable.type)

				return var.getRealType()
			}
		}
		else {
			if variable.lateInit && !@parent.isLateInitializable() {
				SyntaxException.throwInvalidLateInitAssignment(variable.name, this)
			}
			else {
				return @parent.initializeVariable(variable, expression, this)
			}
		}
	} # }}}
	isAwait() => @awaiting
	isEmpty() => @empty
	isExit(mode: ExitMode): Boolean { # {{{
		if mode ~~ .Expression + .Continuity {
			var mut set = true

			for var statement in @statements {
				if set {
					if statement.isExit(.Expression) {
						set = false
					}
				}
				else {
					if !statement.isExit(.Statement + .Always) {
						return false
					}
				}
			}

			return true
		}
		else {
			for var statement, index in @statements {
				return true if statement.isExit(mode)
			}

			return false
		}
	} # }}}
	isInitializingInstanceVariable(name) { # {{{
		for var statement in @statements {
			if statement.isInitializingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isInitializingVariableAfter(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		if @statements[0].line() > line {
			for var stmt in @statements {
				if stmt.isDeclararingVariable(name) {
					return false
				}

				if stmt.isInitializingVariableAfter(name, statement) {
					return true
				}
			}
		}
		else {
			var last = #@statements - 1

			for var index from 0 to~ last {
				if @statements[index].isDeclararingVariable(name) {
					return false
				}

				if @statements[index + 1].line() > line && @statements[index].isInitializingVariableAfter(name, statement) {
					return true
				}
			}

			if @statements[last].isDeclararingVariable(name) {
				return false
			}

			if @statements[last].isInitializingVariableAfter(name, statement) {
				return true
			}
		}

		return false
	} # }}}
	isJumpable() => @parent.isJumpable()
	isLoop() => @parent.isLoop()
	isUsingInstanceVariableBefore(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	isUsingStaticVariableBefore(class: String, varname: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariable(name) { # {{{
		for var statement in @statements {
			if statement.isUsingVariable(name) {
				return true
			}

			if statement is VariableStatement && statement.isDeclararingVariable(name) {
				return false
			}
		}

		return false
	} # }}}
	isUsingVariableBefore(name: String, statement: Statement): Boolean { # {{{
		var line = statement.line()

		for var stmt in @statements while stmt.line() < line && statement != stmt {
			if stmt.isUsingVariable(name, true) {
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
	recipient() => null
	setExitLabel(label: String) { # {{{
		if @parent is Expression {
			for var statement in @statements to~ -1 {
				statement.setExitLabel(label)
			}
		}
		else {
			for var statement in @statements {
				statement.setExitLabel(label)
			}
		}
	} # }}}
	statements() => @statements
	toFragments(fragments, mode) { # {{{
		if @awaiting {
			var mut index = -1
			var dyn item

			for var statement, i in @statements while index == -1 {
				if item ?= statement.toFragments(fragments, Mode.None) {
					index = i
				}
			}

			if index != -1 {
				item(@statements.slice(index + 1))
			}
		}
		else {
			for var statement in @statements {
				statement.toFragments(fragments, mode)
			}
		}
	} # }}}
	toRangeFragments(fragments, from: Number, to: Number = @statements.length + 1) { # {{{
		for var statement in @statements from from to to {
			statement.toFragments(fragments, Mode.None)
		}
	} # }}}
	type() { # {{{
		if @exit {
			var types = []

			for var statement in @statements {
				if statement.isExit(.Expression + .Statement + .Always) {
					types.push(statement.type())
				}
			}

			return Type.union(@scope, ...types)
		}
		else {
			return Type.Void
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
		if ?@return {
			var toAdd =
				if var statement ?= @statements.last() {
					set !statement:!!!(Statement).isExit(.Expression + .Statement + .Always)
				}
				else {
					set true
				}

			if toAdd {
				var statement = ReturnStatement.new(@return, this)

				statement
					..analyse()
					..prepare(target)

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
			else if !?#@statements || !@statements.last():!!!(Statement).isExit(.Expression + .Statement + .Always) {
				TypeException.throwExpectedReturnedValue(target, this)
			}
		}
	} # }}}
	override getLoopAncestorWithoutNew(_, _) => null
	isInitializingVariable(name: String): Boolean => true
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

			if !variable.instance {
				return super(variable, expression, node)
			}
		}
	} # }}}
	isInitializingVariable(name: String): Boolean => @initializedVariables[name]
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
			return super(variable, expression, node)
		}
	} # }}}
}
