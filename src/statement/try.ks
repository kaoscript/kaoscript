enum TryState {
	Body
	Catch
	Finally
}

class TryStatement extends Statement {
	private {
		_await: Boolean				= false
		_catchVarname: String
		_catchClause
		_catchClauses: Array		= []
		_continueVarname: String
		_exit: Boolean				= false
		_finalizer
		_finallyVarname: String
		_hasCatch: Boolean			= false
		_hasFinally: Boolean		= false
		_state: TryState
		_statements: Array			= []
	}
	analyse() { // {{{
		let scope = @scope

		if @data.catchClauses? {
			let variable, body, type
			for clause in @data.catchClauses {
				if variable !?= scope.getVariable(clause.type.name) {
					ReferenceException.throwNotDefined(clause.type.name, this)
				}

				if clause.binding? {
					@scope = new Scope(scope)

					@scope.define(clause.binding.name, false, this)
				}

				body = $compile.expression(clause.body, this)
				body.analyse()

				type = $compile.expression(clause.type, this)
				type.analyse()

				@catchClauses.push({
					body: body
					type: type
				})
			}
		}

		if @data.catchClause? {
			if @data.catchClause.binding? {
				@scope = new Scope(scope)
				@scope.define(@data.catchClause.binding.name, false, this)
			}

			@catchClause = $compile.expression(@data.catchClause.body, this)
			@catchClause.analyse()
		}

		@scope = scope

		for statement in $ast.body(@data.body) {
			@statements.push(statement = $compile.statement(statement, this))

			statement.analyse()

			if statement.isAwait() {
				@await = true
			}
		}

		if @data.finalizer? {
			@finalizer = $compile.expression(@data.finalizer, this)
			@finalizer.analyse()
		}
	} // }}}
	prepare() { // {{{
		let exit = false
		for statement in @statements {
			statement.prepare()

			if exit {
				SyntaxException.throwDeadCode(statement)
			}
			else {
				exit = statement.isExit()
			}
		}

		@hasCatch = @catchClauses.length != 0

		for clause in @catchClauses {
			clause.body.prepare()
			clause.type.prepare()

			exit = exit && clause.body.isExit()
		}

		if @catchClause? {
			@catchClause.prepare()

			@hasCatch = true
			@exit = exit && @catchClause.isExit()
		}

		if @finalizer? {
			@finalizer.prepare()

			@hasFinally = true

			if @finalizer.isExit() {
				@exit = true
			}
		}
	} // }}}
	translate() { // {{{
		for statement in @statements {
			statement.translate()
		}

		for clause in @catchClauses {
			clause.body.translate()
			clause.type.translate()
		}

		@catchClause.translate() if @catchClause?
		@finalizer.translate() if @finalizer?
	} // }}}
	getErrorVarname() { // {{{
		if @catchClauses.length == 0 && @data.catchClause?.binding? {
			return @data.catchClause.binding.name
		}
		else {
			return @scope.acquireTempName()
		}
	} // }}}
	isAwait() => @await
	isConsumedError(error): Boolean { // {{{
		if @catchClauses.length > 0 {
			for clause in @catchClauses {
				if error.matchInheritanceOf(clause.type.type()) {
					return true
				}
			}

			return false
		}
		else {
			return true
		}
	} // }}}
	isExit() => @exit
	isReturning(type: Type) { // {{{
		for statement in @statements {
			if !statement.isReturning(type) {
				return false
			}
		}

		return true
	} // }}}
	toAwaitStatementFragments(fragments, statements) { // {{{
		if statements.length != 0 {
			@continueVarname = @scope.acquireTempName()

			const line = fragments
				.newLine()
				.code($runtime.scope(this), @continueVarname, ` = () =>`)

			const block = line.newBlock()

			let index = -1
			let item

			for statement, i in statements while index == -1 {
				if item ?= statement.toFragments(block, Mode::None) {
					index = i
				}
			}

			if index != -1 {
				item(statements.slice(index + 1))
			}

			block.done()
			line.done()
		}

		if @finalizer? {
			@state = TryState::Finally

			@finallyVarname = @scope.acquireTempName()

			const line = fragments
				.newLine()
				.code($runtime.scope(this), @finallyVarname, ' = () =>')

			line
				.newBlock()
				.compile(@finalizer)
				.done()

			line.done()
		}

		if @catchClauses.length != 0 || @catchClause? {
			@state = TryState::Catch

			@catchVarname = @scope.acquireTempName()

			const error = this.getErrorVarname()

			const line = fragments
				.newLine()
				.code($runtime.scope(this), @catchVarname, ` = (\(error)) =>`)

			const block = line.newBlock()

			this.toCatchFragments(block, error)

			@scope.releaseTempName(error)

			block.done()
			line.done()
		}

		@state = TryState::Body

		const ctrl = fragments
			.newControl()
			.code('try')
			.step()

		let index = -1
		let item

		for statement, i in @statements while index == -1 {
			if item ?= statement.toFragments(ctrl, Mode::None) {
				index = i
			}
		}

		if index != -1 {
			item(@statements.slice(index + 1))
		}

		ctrl
			.step()
			.code(`catch(__ks_e)`)
			.step()

		if @catchVarname? {
			ctrl.line(`\(@catchVarname)(__ks_e)`)
		}
		else if @finallyVarname? {
			ctrl.line(`\(@finallyVarname)()`)
		}
		else if @continueVarname? {
			ctrl.line(`\(@continueVarname)()`)
		}

		ctrl.done()
	} // }}}
	toAwaitExpressionFragments(fragments, parameters, statements) { // {{{
		fragments.code('(__ks_e')

		for parameter in parameters {
			fragments.code($comma).compile(parameter)
		}

		fragments.code(') =>')

		const block = fragments.newBlock()

		const ctrl = block
			.newControl()
			.code('if(__ks_e)')
			.step()

		if @state == TryState::Body {
			if @catchVarname? {
				ctrl.line(`\(@catchVarname)(__ks_e)`)
			}
			else if @finallyVarname? {
				ctrl.line(`\(@finallyVarname)()`)
			}
			else if @continueVarname? {
				ctrl.line(`\(@continueVarname)()`)
			}
		}
		else if @state == TryState::Catch {
			if @finallyVarname? {
				ctrl.line(`\(@finallyVarname)()`)
			}
			else if @continueVarname? {
				ctrl.line(`\(@continueVarname)()`)
			}
		}
		else if @state == TryState::Finally {
			if @continueVarname? {
				ctrl.line(`\(@continueVarname)()`)
			}
		}

		ctrl
			.step()
			.code('else')
			.step()

		const statement = statements[statements.length - 1]

		if @state == TryState::Body {
			if statements.length == 1 && !statement.hasExceptions() {
				ctrl.compile(statement)

				if statement is not ReturnStatement {
					if @finallyVarname? {
						ctrl.line(`\(@finallyVarname)()`)
					}
					else if @continueVarname? {
						ctrl.line(`\(@continueVarname)()`)
					}
				}
			}
			else {
				const returnOutside = statement is ReturnStatement && statement.hasExceptions()

				if returnOutside {
					statement.toDeclareReusableFragments(ctrl)
				}

				const ctrl2 = ctrl
					.newControl()
					.code('try')
					.step()

				let index = -1
				let item

				for i from 0 til statements.length - 1 while index == -1 {
					if item ?= statements[i].toFragments(ctrl2, Mode::None) {
						index = i
					}
				}

				if index != -1 {
					item(statements.slice(index + 1))
				}
				else {
					if returnOutside {
						statement.toReusableFragments(ctrl2)
					}
					else {
						if item ?= statement.toFragments(ctrl2, Mode::None) {
							item([])
						}
					}
				}

				ctrl2
					.step()
					.code(`catch(__ks_e)`)
					.step()

				if @catchVarname? {
					ctrl2.line(`return \(@catchVarname)(__ks_e)`)
				}

				ctrl2.done()

				if !?item {
					if returnOutside {
						ctrl.compile(statement)
					}
					else if statement is not ReturnStatement {
						if @finallyVarname? {
							ctrl.line(`\(@finallyVarname)()`)
						}
						else if @continueVarname? {
							ctrl.line(`\(@continueVarname)()`)
						}
					}
				}
			}
		}
		else {
			let index = -1
			let item

			for i from 0 til statements.length while index == -1 {
				if item ?= statements[i].toFragments(ctrl, Mode::None) {
					index = i
				}
			}

			if index != -1 {
				item(statements.slice(index + 1))
			}

			if @state == TryState::Catch {
				if @finallyVarname? {
					ctrl.line(`\(@finallyVarname)()`)
				}
				else if @continueVarname? {
					ctrl.line(`\(@continueVarname)()`)
				}
			}
			else if @state == TryState::Finally {
				if @continueVarname? {
					ctrl.line(`\(@continueVarname)()`)
				}
			}
		}

		ctrl.done()

		block.done()

		fragments.code(')').done()
	} // }}}
	toCatchFragments(fragments, error) { // {{{
		let async = false

		if @catchClauses.length != 0 {
			this.module().flag('Type')

			let ifs = fragments.newControl()

			for clause, i in @data.catchClauses {
				ifs.step().code('else ') if i

				ifs
					.code('if(', $runtime.type(this), '.is(', error, ', ')
					.compile(@catchClauses[i].type)
					.code('))')
					.step()

				if clause.binding? {
					ifs.line($runtime.scope(this), clause.binding.name, ' = ', error)
				}

				ifs.compile(@catchClauses[i].body)

				if !@catchClauses[i].body.isAwait() && @continueVarname? {
					ifs.line(`\(@continueVarname)()`)
				}
			}

			if @catchClause? {
				ifs.step().code('else').step()

				if @data.catchClause.binding? {
					ifs.line($runtime.scope(this), @data.catchClause.binding.name, ' = ', error)
				}

				ifs.compile(@catchClause)

				if !@catchClause.isAwait() && @continueVarname? {
					ifs.line(`\(@continueVarname)()`)
				}
			}
			else if @continueVarname? {
				ifs.step().code('else').step()

				ifs.line(`\(@continueVarname)()`)
			}

			ifs.done()
		}
		else if @catchClause? {
			fragments.compile(@catchClause)

			if !@catchClause.isAwait() {
				if @finallyVarname? {
					fragments.line(`\(@finallyVarname)()`)
				}
				else if @continueVarname? {
					fragments.line(`\(@continueVarname)()`)
				}
			}
		}
		else if @finallyVarname? {
			fragments.line(`\(@finallyVarname)()`)
		}
		else if @continueVarname? {
			fragments.line(`\(@continueVarname)()`)
		}
	} // }}}
	toFinallyFragments(fragments) { // {{{
		fragments.code('finally').step().compile(@finalizer)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @await {
			return this.toAwaitStatementFragments^@(fragments)
		}
		else {
			const ctrl = fragments
				.newControl()
				.code('try')
				.step()

			for statement in @statements {
				ctrl.compile(statement, Mode::None)
			}

			if @finallyVarname? {
				ctrl.line(`\(@finallyVarname)()`)
			}

			ctrl.step()

			const error = this.getErrorVarname()

			if @hasCatch {
				ctrl.code(`catch(\(error))`).step()

				this.toCatchFragments(ctrl, error)

				if @hasFinally {
					ctrl.step()

					this.toFinallyFragments(ctrl)
				}
			}
			else if @hasFinally {
				this.toFinallyFragments(ctrl)
			}
			else {
				ctrl.code(`catch(\(error))`).step()
			}

			@scope.releaseTempName(error)

			ctrl.done()
		}
	} // }}}
}