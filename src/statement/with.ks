class WithStatement extends Statement {
	private late {
		@body: Block
		@bodyScope: Scope
		@declarations			= []
		@exit: Boolean			= false
		@expressions			= []
		@finally: Block
		@hasFinally: Boolean	= false
		@returnValue			= null
		@returnVarname: String?	= null
		@useTry: Boolean		= false
		@variables				= []
	}
	// TODO
	// constructor(@data, @parent, @scope = @parent.scope()) { # {{{
	constructor(@data, @parent, scope: Scope = @parent.scope()) { # {{{
		super(data, parent, scope!?, ScopeType::Bleeding)
	} # }}}
	override initiate() { # {{{
		@hasFinally = ?@data.finalizer

		for var data in @data.variables {
			if data.kind == NodeKind::VariableDeclaration {
				var declaration = new VariableDeclaration(data, this, @scope, @scope, false)

				declaration.initiate()

				@declarations.push(declaration)
			}
			else {
				var expression = $compile.expression(data, this, @scope)

				@expressions.push(expression)
			}
		}
	} # }}}
	override analyse() { # {{{
		for var declaration in @declarations {
			declaration.analyse()
		}

		for var expression in @expressions {
			expression.analyse()

			@variables.push({
				name: expression.left()
				temp: @scope.acquireTempName(false)
			})
		}

		@bodyScope = @newScope(@scope, ScopeType::InlineBlock)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()

		if @hasFinally {
			@finally = $compile.block(@data.finalizer, this, @bodyScope)
			@finally.analyse()
		}
	} # }}}
	override prepare(target) { # {{{
		for var declaration in @declarations {
			declaration.prepare(target)
		}

		for var expression in @expressions {
			expression.prepare(target)
		}

		@body.prepare(target)

		@exit = @body.isExit()

		if @hasFinally {
			@finally.prepare(target)

			if @finally.isExit() {
				SyntaxException.throwInvalidFinallyReturn(this)
			}
		}

		if @hasFinally || #@variables {
			if @exit {
				for var statement in @body.statements() {
					if statement.isExit() {
						if statement is ReturnStatement {
							@returnValue = statement.value()
						}
						else {
							@useTry = true
						}

						break
					}
				}

				if !@useTry && ?@returnValue {
					@returnVarname = @scope.acquireTempName(false)
				}
			}
		}
	} # }}}
	override translate() { # {{{
		for var declaration in @declarations {
			declaration.translate()
		}

		for var expression in @expressions {
			expression.translate()
		}

		@body.translate()

		@finally.translate() if @hasFinally
	} # }}}
	override isExit() => @exit
	override isInitializingInstanceVariable(name) { # {{{
		if @hasFinally {
			return @body.isInitializingInstanceVariable(name) || @finally.isInitializingInstanceVariable(name)
		}
		else {
			return @body.isInitializingInstanceVariable(name)
		}
	} # }}}
	override isUsingVariable(name) { # {{{
		if @hasFinally {
			return @body.isUsingVariable(name) || @finally.isUsingVariable(name)
		}
		else {
			return @body.isUsingVariable(name)
		}
	} # }}}
	override isUsingInstanceVariable(name) { # {{{
		if @hasFinally {
			return @body.isUsingInstanceVariable(name) || @finally.isUsingInstanceVariable(name)
		}
		else {
			return @body.isUsingInstanceVariable(name)
		}
	} # }}}
	override isUsingStaticVariable(class, varname) { # {{{
		if @hasFinally {
			return @body.isUsingStaticVariable(class, varname) || @finally.isUsingStaticVariable(class, varname)
		}
		else {
			return @body.isUsingStaticVariable(class, varname)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for var { name, temp } in @variables {
			fragments.newLine().code($runtime.scope(this), temp, $equals).compile(name).done()
		}

		for var declaration in @declarations {
			fragments.compile(declaration)
		}

		for var expression in @expressions {
			fragments.newLine().compile(expression).done()
		}

		if @useTry {
			var ctrl = fragments.newControl().code('try').step()

			ctrl.compile(@body)

			ctrl.step().code('finally').step()

			if @hasFinally {
				ctrl.compile(@finally)
			}

			for var { name, temp } in @variables {
				ctrl.newLine().compile(name).code($equals, temp).done()
			}

			ctrl.done()
		}
		else if @exit {
			var statements = @body.statements()

			for var statement in statements to statements.length - 2 {
				fragments.compile(statement)
			}

			if ?@returnVarname {
				fragments.newLine().code($runtime.scope(this), @returnVarname, $equals).compile(@returnValue).done()
			}

			if @hasFinally {
				fragments.compile(@finally)
			}

			for var { name, temp } in @variables {
				fragments.newLine().compile(name).code($equals, temp).done()
			}

			if ?@returnVarname {
				fragments.line(`return \(@returnVarname)`)
			}
		}
		else {
			fragments.compile(@body)

			if @hasFinally {
				fragments.compile(@finally)
			}

			for var { name, temp } in @variables {
				fragments.newLine().compile(name).code($equals, temp).done()
			}
		}
	} # }}}
}
