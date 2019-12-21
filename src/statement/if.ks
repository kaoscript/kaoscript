class IfStatement extends Statement {
	private {
		_bindingScope: Scope
		_cascade: Boolean				= false
		_condition
		_declared: Boolean				= false
		_lateInitVariables				= {}
		_hasWhenFalse: Boolean			= false
		_variable
		_whenFalseExpression			= null
		_whenFalseScope: Scope?			= null
		_whenTrueExpression				= null
		_whenTrueScope: Scope?			= null
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = this.newScope(@scope, ScopeType::Bleeding)

			@variable = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope)
			@variable.analyse()

			@whenTrueScope = this.newScope(@bindingScope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = this.newScope(@scope, ScopeType::Hollow)
			@whenTrueScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@hasWhenFalse = @data.whenFalse?

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		if @hasWhenFalse {
			@whenFalseScope = this.newScope(@scope, ScopeType::InlineBlock)

			@scope.line(@data.whenFalse.start.line)

			if @data.whenFalse.kind == NodeKind::IfStatement {
				@whenFalseExpression = $compile.statement(@data.whenFalse, this, @whenFalseScope)
				@whenFalseExpression.setCascade(true)
				@whenFalseExpression.analyse()
			}
			else {
				@whenFalseExpression = $compile.block(@data.whenFalse, this, @whenFalseScope)
				@whenFalseExpression.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		if @declared {
			@variable.prepare()

			if const variable = @variable.getIdentifierVariable() {
				variable.setRealType(variable.getRealType().setNullable(false))
			}
		}
		else {
			@condition.prepare()

			unless @condition.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@condition, this)
			}

			for const data, name of @condition.inferWhenTrueTypes({}) {
				@whenTrueScope.updateInferable(name, data, this)
			}

			if @whenFalseExpression != null {
				for const data, name of @condition.inferWhenFalseTypes({}) {
					@whenFalseScope.updateInferable(name, data, this)
				}
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		this.assignTempVariables(@bindingScope)

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression.prepare()

		if @whenFalseExpression == null {
			@scope.line(@data.end.line)

			if !@declared {
				if @whenTrueExpression.isExit() {
					for const data, name of @condition.inferWhenFalseTypes({}) {
						@scope.updateInferable(name, data, this)
					}
				}
				else {
					const conditionInferables = @condition.inferWhenFalseTypes({})
					const trueInferables = @whenTrueScope.listUpdatedInferables()

					for const _, name of trueInferables when conditionInferables[name]? {
						const conditionType = conditionInferables[name].type
						const trueType = trueInferables[name].type

						if trueType.equals(conditionType) {
							@scope.updateInferable(name, trueInferables[name], this)
						}
						else {
							@scope.updateInferable(name, {
								isVariable: trueInferables[name].isVariable
								type: Type.union(@scope, trueType, conditionType)
							}, this)
						}
					}
				}
			}
		}
		else {
			if !@declared {
				for const data, name of @condition.inferWhenFalseTypes({}) {
					@whenFalseScope.updateInferable(name, data, this)
				}
			}

			@scope.line(@data.whenFalse.start.line)

			@whenFalseExpression.prepare()

			@scope.line(@data.end.line)

			if @whenTrueExpression.isExit() {
				for const map, name of @lateInitVariables {
					if map.false.initializable {
						@parent.initializeVariable(map.variable, map.false.type, this, this)
					}
					else {
						SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
					}
				}

				for const data, name of @whenFalseScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else if @whenFalseExpression.isExit() {
				for const map, name of @lateInitVariables {
					if map.true.initializable {
						@parent.initializeVariable(map.variable, map.true.type, this, this)
					}
					else {
						SyntaxException.throwMissingAssignmentIfTrue(name, @whenTrueExpression)
					}
				}

				for const data, name of @whenTrueScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else {
				for const map, name of @lateInitVariables {
					let type

					if map.true.initializable {
						if map.false.initializable {
							type = Type.union(@scope, map.true.type, map.false.type)
						}
						else {
							SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
						}
					}
					else {
						SyntaxException.throwMissingAssignmentIfTrue(name, @whenTrueExpression)
					}

					@parent.initializeVariable(map.variable, type, this, this)
				}

				const trueInferables = @whenTrueScope.listUpdatedInferables()
				const falseInferables = @whenFalseScope.listUpdatedInferables()

				for const _, name of trueInferables when falseInferables[name]? {
					const trueType = trueInferables[name].type
					const falseType = falseInferables[name].type

					if trueType.equals(falseType) {
						@scope.updateInferable(name, trueInferables[name], this)
					}
					else {
						@scope.updateInferable(name, {
							isVariable: trueInferables[name].isVariable
							type: Type.union(@scope, trueType, falseType)
						}, this)
					}
				}
			}
		}
	} // }}}
	translate() { // {{{
		if @declared {
			@variable.translate()
		}
		else {
			@condition.translate()
		}

		@whenTrueExpression.translate()
		@whenFalseExpression?.translate()
	} // }}}
	addAssignments(variables) { // {{{
		if @cascade {
			@parent.addAssignments(variables)
		}
		else if @declared {
			for const variable in variables {
				if !@variable.isDeclararingVariable(variable) {
					@assignments.pushUniq(variable)
				}
			}
		}
		else {
			@assignments.pushUniq(...variables)
		}
	} // }}}
	addInitializableVariable(variable, node) { // {{{
		const name = variable.name()
		const whenTrue = node == @whenTrueExpression

		if !@hasWhenFalse {
			SyntaxException.throwMissingAssignmentIfNoElse(name, this)
		}
		else if const map = @lateInitVariables[name] {
			map[whenTrue].initializable = true
		}
		else {
			@lateInitVariables[name] = {
				variable
				[whenTrue]: {
					initializable: true
					type: null
				}
				[!whenTrue]: {
					initializable: false
					type: null
				}
			}
		}

		@parent.addInitializableVariable(variable, node)
	} // }}}
	assignments() { // {{{
		if @whenFalseExpression is IfStatement {
			return [].concat(@assignments, @whenFalseExpression.assignments())
		}
		else {
			return @assignments
		}
	} // }}}
	checkReturnType(type: Type) { // {{{
		@whenTrueExpression.checkReturnType(type)
		@whenFalseExpression?.checkReturnType(type)
	} // }}}
	initializeVariable(variable, type, expression, node) { // {{{
		const name = variable.name()

		if variable.isInitialized() {
			if variable.isImmutable() {
				ReferenceException.throwImmutable(name, expression)
			}
		}
		else if const map = @lateInitVariables[name] {
			const whenTrue = node == @whenTrueExpression

			if map[whenTrue].type != null {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(map[whenTrue].type) {
					TypeException.throwInvalidAssignement(name, map[whenTrue].type, type, expression)
				}
			}
			else {
				map[whenTrue].type = type
			}

			const clone = variable.clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			node.scope().replaceVariable(name, clone)
		}
		else {
			ReferenceException.throwImmutable(name, expression)
		}
	} // }}}
	isCascade() => @cascade
	isExit() => @whenFalseExpression? && @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
	isJumpable() => true
	isLateInitializable() => true
	isUsingVariable(name) { // {{{
		if @declared {
			if @variable.isUsingVariable(name) {
				return true
			}
		}
		else {
			if @condition.isUsingVariable(name) {
				return true
			}
		}

		if @whenTrueExpression.isUsingVariable(name) {
			return true
		}

		return @whenFalseExpression != null && @whenFalseExpression.isUsingVariable(name)
	} // }}}
	setCascade(@cascade)
	toStatementFragments(fragments, mode) { // {{{
		if @declared {
			fragments.compile(@variable)

			const ctrl = fragments.newControl()

			this.toIfFragments(ctrl, mode)

			ctrl.done()
		}
		else {
			const ctrl = fragments.newControl()

			this.toIfFragments(ctrl, mode)

			ctrl.done()
		}
	} // }}}
	toIfFragments(fragments, mode) { // {{{
		fragments.code('if(')

		if @declared {
			if @cascade {
				let first = true

				@variable.walk(name => {
					if first {
						fragments.code($runtime.type(this) + '.isValue((')

						@variable.toInlineFragments(fragments, mode)

						fragments.code('))')

						first = false
					}
					else {
						fragments.code(' && ' + $runtime.type(this) + '.isValue(', name, ')')
					}
				})
			}
			else {
				let first = true

				@variable.walk(name => {
					if first {
						first = false
					}
					else {
						fragments.code(' && ')
					}

					fragments.code($runtime.type(this) + '.isValue(', name, ')')
				})
			}
		}
		else {
			fragments.compileBoolean(@condition)
		}

		fragments.code(')').step()

		fragments.compile(@whenTrueExpression, mode)

		if @whenFalseExpression? {
			if @whenFalseExpression is IfStatement {
				fragments.step().code('else ')

				@whenFalseExpression.toIfFragments(fragments, mode)
			}
			else {
				fragments.step().code('else').step()

				fragments.compile(@whenFalseExpression, mode)
			}
		}
	} // }}}
}