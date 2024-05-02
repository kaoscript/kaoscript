enum TryState {
	Body
	Catch
	Finally
}

class TryStatement extends Statement {
	private late {
		@await: Boolean				= false
		@body: Block
		@bodyScope: Scope
		@catchVarname: String
		@clauses: Array				= []
		@continueVarname: String
		@defaultClause: Block?		= null
		@errorVarname: String
		@finally: Block?			= null
		@finallyVarname: String
		@hasClauses: Boolean		= false
		@hasDefaultClause: Boolean	= false
		@hasFinally: Boolean		= false
		@initLateVariables			= {}
		@initVariables: Object		= {}
		@state: TryState
	}
	analyse() { # {{{
		@hasDefaultClause = ?@data.catchClause
		@hasClauses = @hasDefaultClause
		@hasFinally = ?@data.finalizer

		if ?@data.catchClauses {
			@hasClauses ||= ?#@data.catchClauses

			var dyn variable, scope, body, type

			for var clause in @data.catchClauses {
				if variable !?= @scope.getVariable(clause.type.name) {
					ReferenceException.throwNotDefined(clause.type.name, this)
				}

				scope = @newScope(@scope!?, ScopeType.InlineBlock)

				if ?clause.binding {
					scope.define(clause.binding.name, false, Type.Any, this)
				}

				body = $compile.block(clause.body, this, scope)
				body.analyse()

				type = $compile.expression(clause.type, this, scope)
				type.analyse()

				@clauses.push({
					body
					type
				})
			}
		}

		if @hasDefaultClause {
			var scope = @newScope(@scope!?, ScopeType.InlineBlock)

			if ?@data.catchClause.binding {
				scope.define(@data.catchClause.binding.name, false, Type.Any, this)
			}

			@defaultClause = $compile.block(@data.catchClause.body, this, scope)
			@defaultClause.analyse()
		}

		@bodyScope = @newScope(@scope!?, ScopeType.InlineBlock)

		@body = $compile.block($ast.body(@data), this, @bodyScope)
		@body.analyse()

		@await = @body.isAwait()

		if @hasFinally {
			var scope = @newScope(@scope!?, ScopeType.InlineBlock)

			@finally = $compile.block(@data.finalizer, this, scope)
			@finally.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		NotSupportedException.throw(this)
	} # }}}
	override prepare(target, index, length) { # {{{
		if @await {
			if index + 1 < length {
				@continueVarname = @scope.acquireTempName(false)
			}

			if @hasClauses {
				@catchVarname = @scope.acquireTempName(false)
			}

			if @hasFinally {
				@finallyVarname = @scope.acquireTempName(false)
			}
		}

		if !@await || @hasClauses {
			if !?#@clauses && ?@data.catchClause?.binding {
				@errorVarname = @data.catchClause.binding.name
			}
			else {
				@errorVarname = @scope.acquireTempName(false)
			}
		}

		var mut maxInferables = 1 + @clauses.length + (@hasDefaultClause ? 1 : 0)
		var inferables = {}

		for var clause in @clauses {
			clause.body.prepare(target)
			clause.type.prepare()

			if clause.body:!!!(Block).isExit(.Statement + .Always) {
				maxInferables -= 1
			}
			else {
				for var data, name of clause.body.scope().listUpdatedInferables() {
					if ?inferables[name] {
						if inferables[name].union {
							inferables[name].data.type.addType(data.type)
						}
						else if !data.type.equals(inferables[name].data.type) {
							inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
							inferables[name].union = inferables[name].data.type.isUnion()
						}

						inferables[name].count += 1
					}
					else {
						inferables[name] = {
							count: 1
							union: false
							data
						}
					}
				}
			}
		}

		@body.prepare(target)

		if @body.isExit(.Statement + .Always) {
			maxInferables -= 1
		}
		else {
			for var data, name of @bodyScope.listUpdatedInferables() {
				if ?inferables[name] {
					if inferables[name].union {
						inferables[name].data.type.addType(data.type)
					}
					else if !data.type.equals(inferables[name].data.type) {
						inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
						inferables[name].union = inferables[name].data.type.isUnion()
					}

					inferables[name].count += 1
				}
				else {
					inferables[name] = {
						count: 1
						union: false
						data
					}
				}
			}
		}

		if @hasDefaultClause {
			@defaultClause.prepare(target)

			if @defaultClause.isExit(.Statement + .Always) {
				maxInferables -= 1
			}
			else {
				for var data, name of @defaultClause.scope().listUpdatedInferables() {
					if ?inferables[name] {
						if inferables[name].union {
							inferables[name].data.type.addType(data.type)
						}
						else if !data.type.equals(inferables[name].data.type) {
							inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
							inferables[name].union = inferables[name].data.type.isUnion()
						}

						inferables[name].count += 1
					}
					else {
						inferables[name] = {
							count: 1
							union: false
							data
						}
					}
				}
			}
		}

		if @hasFinally {
			@finally.prepare(target)

			if @finally.isExit(.Expression + .Statement) {
				SyntaxException.throwInvalidFinallyReturn(this)
			}
			else {
				for var data, name of @finally.scope().listUpdatedInferables() {
					if ?inferables[name] {
						if inferables[name].union {
							inferables[name].data.type.addType(data.type)
						}
						else if !data.type.equals(inferables[name].data.type) {
							inferables[name].data.type = Type.union(@scope, inferables[name].data.type, data.type)
							inferables[name].union = inferables[name].data.type.isUnion()
						}

						inferables[name].count = maxInferables
					}
					else {
						inferables[name] = {
							count: maxInferables
							union: false
							data
						}
					}
				}
			}
		}

		return if maxInferables == 0 && @hasDefaultClause

		for var data, name of @initVariables {
			var types = []
			var mut initializable = true
			var clauses = [data.body, ...data.clauses!?]
			clauses.push(data.defaultClause) if ?data.defaultClause

			if @hasFinally && data.finally.initializable {
				for var clause in clauses {
					if clause.initializable {
						types.push(clause.type)
					}
				}

				types.push(data.finally.type)
			}
			else {
				for var clause in clauses {
					if clause.initializable {
						types.push(clause.type)
					}
					else if !clause.body:!!!(Block).isExit(.Expression + .Statement + .Always) {
						initializable = false

						break
					}
				}
			}

			if initializable {
				data.variable.type = Type.union(@scope, ...types)

				@parent.initializeVariable(data.variable, this, this)
			}
		}

		for var data, name of @initLateVariables {
			var types = []
			var clauses = [data.body, ...data.clauses!?]
			clauses.push(data.defaultClause) if ?data.defaultClause

			if @hasFinally && data.finally.initializable {
				for var clause in clauses {
					if clause.initializable {
						types.push(clause.type)
					}
				}

				types.push(data.finally.type)
			}
			else {
				for var clause in clauses {
					if clause.initializable {
						types.push(clause.type)
					}
					else if !clause.body:!!!(Block).isExit(.Expression + .Statement + .Always) {
						SyntaxException.throwMissingAssignmentTryClause(name, clause.body)
					}
				}
			}

			var type = Type.union(@scope, ...types)

			@parent.initializeVariable(VariableBrief.new(name, type), this, this)
		}

		for var inferable, name of inferables {
			if inferable.count == maxInferables {
				@scope.updateInferable(name, inferable.data, this)
			}
			else if inferable.data.isVariable {
				@scope.replaceVariable(name, inferable.data.type, true, false, this)
			}
		}
	} # }}}
	translate() { # {{{
		@body.translate()

		for var clause in @clauses {
			clause.body.translate()
			clause.type.translate()
		}

		@defaultClause.translate() if ?@defaultClause
		@finally.translate() if ?@finally
	} # }}}
	addInitializableVariable(variable: Variable, node) { # {{{
		var name = variable.name()

		unless @hasDefaultClause || @hasFinally {
			SyntaxException.throwMissingAssignmentTryClause(name, node)
		}

		if var map ?= @initLateVariables[name] {
			if @body == node {
				map.body.initializable = true
			}
			else if @hasDefaultClause && @defaultClause == node {
				map.defaultClause.initializable = true
			}
			else if @hasFinally && @finally == node {
				map.finally.initializable = true
			}
			else {
				for var clause, index in @clauses {
					if clause.body == node {
						map.clauses[index].initializable = true

						break
					}
				}
			}
		}
		else {
			var map = {
				variable
				body: {
					body: @body
					initializable: @body == node
					type: null
				}
				clauses: []
				defaultClause: null
				finally: null
			}

			for var clause, index in @clauses {
				if clause.body == node {
					map.clauses.push({
						body: clause.body
						initializable: true
						type: null
					})
				}
				else {
					map.clauses.push({
						body: clause.body
						initializable: false
						type: null
					})
				}
			}

			if @hasDefaultClause {
				map.defaultClause = {
					body: @defaultClause
					initializable: @defaultClause == node
					type: null
				}
			}
			if @hasFinally {
				map.finally = {
					body: @finally
					initializable: @finally == node
					type: null
				}
			}

			@initLateVariables[name] = map
		}

		@parent.addInitializableVariable(variable, node)
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		var {name, type} = variable

		if var map ?= @initLateVariables[name] {
			var mut branch = null

			if @body == node {
				branch = map.body
			}
			else if @hasDefaultClause && @defaultClause == node {
				branch = map.defaultClause
			}
			else if @hasFinally && @finally == node {
				branch = map.finally
			}
			else {
				for var clause, index in @clauses {
					if clause.body == node {
						branch = map.clauses[index]

						break
					}
				}
			}

			return unless ?branch

			if ?branch.type {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(branch.type) {
					TypeException.throwInvalidAssignment(name, branch.type, type, expression)
				}
			}
			else {
				branch.type = type
			}

			var clone = node.scope().getVariable(name).clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			var var = node.scope().replaceVariable(name, clone)

			return var.getRealType()
		}
		else if var map ?= @initVariables[name] {
			var mut branch = null

			if @body == node {
				branch = map.body
			}
			else if @hasDefaultClause && @defaultClause.body == node {
				branch = map.defaultClause
			}
			else if @hasFinally && @finally.body == node {
				branch = map.finally
			}
			else {
				for var clause, index in @clauses {
					if clause.body == node {
						branch = map.clauses[index]

						break
					}
				}
			}

			return unless ?branch

			if ?branch.type {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(branch.type) {
					TypeException.throwInvalidAssignment(name, branch.type, type, expression)
				}
			}
			else {
				branch.type = type
			}

			node.scope().updateInferable(name, variable, expression)
		}
		else {
			var map = {
				variable
				body: {
					body: @body
					initializable: @body == node
					type: null
				}
				clauses: []
				defaultClause: null
				finally: null
			}

			for var clause, index in @clauses {
				if clause.body == node {
					map.clauses.push({
						body: clause.body
						initializable: true
						type: null
					})
				}
				else {
					map.clauses.push({
						body: clause.body
						initializable: false
						type: null
					})
				}
			}

			if @hasDefaultClause {
				map.defaultClause = {
					body: @defaultClause
					initializable: @defaultClause == node
					type: null
				}
			}
			if @hasFinally {
				map.finally = {
					body: @finally
					initializable: @finally == node
					type: null
				}
			}

			@initVariables[name] = map
		}
	} # }}}
	isAwait() => @await
	isConsumedError(error): Boolean { # {{{
		if @hasClauses && !@hasDefaultClause {
			for var clause in @clauses {
				if error.isAssignableToVariable(clause.type.type(), false, false, false) {
					return true
				}
			}

			return false
		}
		else {
			return true
		}
	} # }}}
	override isExit(mode) { # {{{
		if mode ~~ .Always {
			return false unless @hasDefaultClause
			return false unless @body.isExit(mode)
			return false unless @defaultClause.isExit(mode)

			for var clause in @clauses {
				return false unless clause.body:!!!(Block).isExit(mode)
			}

			return true
		}
		else {
			return true if @body.isExit(mode)
			return true if @hasDefaultClause && @defaultClause.isExit(mode)

			for var clause in @clauses {
				return true if clause.body:!!!(Block).isExit(mode)
			}

			return false
		}
	} # }}}
	override isInitializingVariableAfter(name, statement) => @body.isInitializingVariableAfter(name, statement)
	isJumpable() => true
	isLateInitializable() => true
	override isUsingVariable(name, bleeding) { # {{{
		return false if bleeding

		if @body.isUsingVariable(name) {
			return true
		}

		for var clause in @clauses {
			if clause.body.isUsingVariable(name) {
				return true
			}
		}

		if @defaultClause != null && @defaultClause.isUsingVariable(name) {
			return true
		}

		return @hasFinally && @finally.isUsingVariable(name)
	} # }}}
	toAwaitStatementFragments(fragments, statements) { # {{{
		if statements.length != 0 {
			var line = fragments
				.newLine()
				.code($runtime.scope(this), @continueVarname, ` = () =>`)

			var block = line.newBlock()

			var mut index = -1
			var mut item = null

			for var statement, i in statements while index == -1 {
				if item ?= statement.toFragments(block, Mode.None) {
					index = i
				}
			}

			if index != -1 {
				item(statements.slice(index + 1))
			}

			block.done()
			line.done()
		}

		if @hasFinally {
			@state = TryState.Finally

			var line = fragments
				.newLine()
				.code($runtime.scope(this), @finallyVarname, ' = () =>')

			line
				.newBlock()
				.compile(@finally)
				.done()

			line.done()
		}

		if @hasClauses {
			@state = TryState.Catch

			var line = fragments
				.newLine()
				.code($runtime.scope(this), @catchVarname, ` = (\(@errorVarname)) =>`)

			var block = line.newBlock()

			@toCatchFragments(block, @errorVarname)

			block.done()
			line.done()
		}

		@state = TryState.Body

		var ctrl = fragments
			.newControl()
			.code('try')
			.step()

		ctrl.compile(@body, Mode.None)

		ctrl
			.step()
			.code(`catch(__ks_e)`)
			.step()

		if ?@catchVarname {
			ctrl.line(`\(@catchVarname)(__ks_e)`)
		}
		else if ?@finallyVarname {
			ctrl.line(`\(@finallyVarname)()`)
		}
		else if ?@continueVarname {
			ctrl.line(`\(@continueVarname)()`)
		}

		ctrl.done()
	} # }}}
	toAwaitExpressionFragments(fragments, parameters, statements) { # {{{
		fragments.code('(__ks_e')

		for var parameter in parameters {
			fragments.code($comma).compile(parameter)
		}

		fragments.code(') =>')

		var block = fragments.newBlock()

		var ctrl = block
			.newControl()
			.code('if(__ks_e)')
			.step()

		if @state == TryState.Body {
			if ?@catchVarname {
				ctrl.line(`\(@catchVarname)(__ks_e)`)
			}
			else if ?@finallyVarname {
				ctrl.line(`\(@finallyVarname)()`)
			}
			else if ?@continueVarname {
				ctrl.line(`\(@continueVarname)()`)
			}
		}
		else if @state == TryState.Catch {
			if ?@finallyVarname {
				ctrl.line(`\(@finallyVarname)()`)
			}
			else if ?@continueVarname {
				ctrl.line(`\(@continueVarname)()`)
			}
		}
		else if @state == TryState.Finally {
			if ?@continueVarname {
				ctrl.line(`\(@continueVarname)()`)
			}
		}

		ctrl
			.step()
			.code('else')
			.step()

		var statement = statements[statements.length - 1]

		if @state == TryState.Body {
			if !statement.hasExceptions() && (statements.length == 1 || (statements.length == 2 && statements[0] is VariableDeclaration && statements[0].isAwait())) {
				if statements.length == 2 {
					ctrl.compile(statements[0])
				}

				ctrl.compile(statement)

				if statement is not ReturnStatement {
					if ?@finallyVarname {
						ctrl.line(`\(@finallyVarname)()`)
					}
					else if ?@continueVarname {
						ctrl.line(`\(@continueVarname)()`)
					}
				}
			}
			else {
				var returnOutside = statement is ReturnStatement && statement.hasExceptions()

				if returnOutside {
					statement.toDeclareReusableFragments(ctrl)
				}

				var ctrl2 = ctrl
					.newControl()
					.code('try')
					.step()

				var mut index = -1
				var mut item = null

				for var i from 0 to~ statements.length - 1 while index == -1 {
					if item ?= statements[i].toFragments(ctrl2, Mode.None) {
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
						if item ?= statement.toFragments(ctrl2, Mode.None) {
							item([])
						}
					}
				}

				ctrl2
					.step()
					.code(`catch(__ks_e)`)
					.step()

				if ?@catchVarname {
					ctrl2.line(`return \(@catchVarname)(__ks_e)`)
				}

				ctrl2.done()

				if !?item {
					if returnOutside {
						ctrl.compile(statement)
					}
					else if statement is not ReturnStatement {
						if ?@finallyVarname {
							ctrl.line(`\(@finallyVarname)()`)
						}
						else if ?@continueVarname {
							ctrl.line(`\(@continueVarname)()`)
						}
					}
				}
			}
		}
		else {
			var mut index = -1
			var mut item = null

			for var i from 0 to~ statements.length while index == -1 {
				if item ?= statements[i].toFragments(ctrl, Mode.None) {
					index = i
				}
			}

			if index != -1 {
				item(statements.slice(index + 1))
			}

			if @state == TryState.Catch {
				if ?@finallyVarname {
					ctrl.line(`\(@finallyVarname)()`)
				}
				else if ?@continueVarname {
					ctrl.line(`\(@continueVarname)()`)
				}
			}
			else if @state == TryState.Finally {
				if ?@continueVarname {
					ctrl.line(`\(@continueVarname)()`)
				}
			}
		}

		ctrl.done()

		block.done()

		fragments.code(')').done()
	} # }}}
	toCatchFragments(fragments, error) { # {{{
		var mut async = false

		if @clauses.length != 0 {
			@module().flag('Type')

			var mut ifs = fragments.newControl()

			for var clause, i in @data.catchClauses {
				ifs.step().code('else ') if i != 0

				ifs
					.code('if(', $runtime.type(this), '.isClassInstance(', error, ', ')
					.compile(@clauses[i].type)
					.code('))')
					.step()

				if ?clause.binding {
					ifs.line($runtime.scope(this), clause.binding.name, ' = ', error)
				}

				ifs.compile(@clauses[i].body)

				if !@clauses[i].body.isAwait() && ?@continueVarname {
					ifs.line(`\(@continueVarname)()`)
				}
			}

			if ?@defaultClause {
				ifs.step().code('else').step()

				if ?@data.catchClause.binding {
					ifs.line($runtime.scope(this), @data.catchClause.binding.name, ' = ', error)
				}

				ifs.compile(@defaultClause)

				if !@defaultClause.isAwait() && ?@continueVarname {
					ifs.line(`\(@continueVarname)()`)
				}
			}
			else if ?@continueVarname {
				ifs.step().code('else').step()

				ifs.line(`\(@continueVarname)()`)
			}

			ifs.done()
		}
		else if ?@defaultClause {
			fragments.compile(@defaultClause)

			if !@defaultClause.isAwait() {
				if ?@finallyVarname {
					fragments.line(`\(@finallyVarname)()`)
				}
				else if ?@continueVarname {
					fragments.line(`\(@continueVarname)()`)
				}
			}
		}
		else if ?@finallyVarname {
			fragments.line(`\(@finallyVarname)()`)
		}
		else if ?@continueVarname {
			fragments.line(`\(@continueVarname)()`)
		}
	} # }}}
	toFinallyFragments(fragments) { # {{{
		fragments.code('finally').step().compile(@finally)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		if @await {
			return this.toAwaitStatementFragments^^(fragments, ^)
		}
		else {
			var ctrl = fragments
				.newControl()
				.code('try')
				.step()

			ctrl.compile(@body, Mode.None)

			if ?@finallyVarname {
				ctrl.line(`\(@finallyVarname)()`)
			}

			ctrl.step()

			if @hasClauses {
				ctrl.code(`catch(\(@errorVarname))`).step()

				@toCatchFragments(ctrl, @errorVarname)

				if @hasFinally {
					ctrl.step()

					@toFinallyFragments(ctrl)
				}
			}
			else if @hasFinally {
				@toFinallyFragments(ctrl)
			}
			else {
				ctrl.code(`catch(\(@errorVarname))`).step()
			}

			ctrl.done()
		}
	} # }}}
}
