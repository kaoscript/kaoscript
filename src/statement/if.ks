class IfStatement extends Statement {
	private lateinit {
		_analyzeStep: Boolean								= true
		_assignedInstanceVariables							= {}
		_bindingDeclaration: Boolean						= false
		_bindingScope: Scope
		_cascade: Boolean									= false
		_condition: Expression
		_declaration: VariableDeclaration
		_declared: Boolean									= false
		_initializedVariables: Dictionary					= {}
		_lateInitVariables									= {}
		_hasWhenFalse: Boolean								= false
		_whenFalseExpression								= null
		_whenFalseScope: Scope?								= null
		_whenTrueExpression									= null
		_whenTrueScope: Scope?								= null
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = this.newScope(@scope, ScopeType::Bleeding)

			@bindingDeclaration = @data.condition.variables[0].name.kind != NodeKind::Identifier

			@declaration = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope, @cascade || @bindingDeclaration)
			@declaration.analyse()

			if @bindingDeclaration {
				@condition = @declaration.init()
			}

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
			@declaration.prepare()

			if @bindingDeclaration {
				@condition.acquireReusable(true)
				@condition.releaseReusable()
			}

			if const variable = @declaration.getIdentifierVariable() {
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

					for const inferable, name of trueInferables {
						const trueType = inferable.type

						if conditionInferables[name]? {
							const conditionType = conditionInferables[name].type

							if trueType.equals(conditionType) {
								@scope.updateInferable(name, inferable, this)
							}
							else {
								@scope.updateInferable(name, {
									isVariable: inferable.isVariable
									type: Type.union(@scope, trueType, conditionType)
								}, this)
							}
						}
						else if inferable.isVariable {
							if const variable = @scope.getVariable(name) {
								@scope.updateInferable(name, {
									isVariable: true
									type: @scope.inferVariableType(variable, trueType)
								}, this)
							}
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
				for const data, name of @initializedVariables when data.false.initializable {
					data.variable.type = data.false.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for const map, name of @lateInitVariables {
					if map.false.initializable {
						@parent.initializeVariable(VariableBrief(name, type: map.false.type), this, this)
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
				for const data, name of @initializedVariables when data.true.initializable {
					data.variable.type = data.true.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for const map, name of @lateInitVariables {
					if map.true.initializable {
						@parent.initializeVariable(VariableBrief(name, type: map.true.type), this, this)
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
				for const data, name of @initializedVariables {
					if data.true.initializable && data.false.initializable {
						data.variable.type = Type.union(@scope, data.true.type, data.false.type)

						@parent.initializeVariable(data.variable, this, this)
					}
				}

				for const map, name of @lateInitVariables {
					lateinit const type: Type

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

					@parent.initializeVariable(VariableBrief(name, type), this, this)
				}

				const trueInferables = @whenTrueScope.listUpdatedInferables()
				const falseInferables = @whenFalseScope.listUpdatedInferables()

				for const inferable, name of trueInferables {
					const trueType = inferable.type

					if falseInferables[name]? {
						const falseType = falseInferables[name].type

						if trueType.equals(falseType) {
							@scope.updateInferable(name, inferable, this)
						}
						else {
							@scope.updateInferable(name, {
								isVariable: inferable.isVariable
								type: Type.union(@scope, trueType, falseType)
							}, this)
						}
					}
					else if inferable.isVariable {
						if const variable = @scope.getVariable(name) {
							@scope.updateInferable(name, {
								isVariable: true
								type: Type.union(@scope, trueType, variable.getRealType())
							}, this)
						}
					}
				}

				for const inferable, name of falseInferables when inferable.isVariable && !?trueInferables[name] {
					if const variable = @scope.getVariable(name) {
						@scope.updateInferable(name, {
							isVariable: true
							type: Type.union(@scope, inferable.type, variable.getRealType())
						}, this)
					}
				}
			}
		}
	} // }}}
	translate() { // {{{
		if @declared {
			@declaration.translate()
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
		else if @declared && !@bindingDeclaration {
			for const variable in variables {
				if !@declaration.isDeclararingVariable(variable) {
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
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { // {{{
		const {name, type} = variable
		const whenTrue = node == @whenTrueExpression

		if const map = @lateInitVariables[name] {
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

			const clone = node.scope().getVariable(name).clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			node.scope().replaceVariable(name, clone)
		}
		else if const map = @initializedVariables[name] {
			if map[whenTrue].type != null {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !variable.type.matchContentOf(map[whenTrue].type) {
					TypeException.throwInvalidAssignement(name, map[whenTrue].type, variable.type, expression)
				}
			}
			else {
				map[whenTrue].initializable = true
				map[whenTrue].type = variable.type
			}

			node.scope().updateInferable(name, variable, expression)
		}
		else {
			@initializedVariables[name] = {
				variable
				[whenTrue]: {
					initializable: true
					type: variable.type
				}
				[!whenTrue]: {
					initializable: false
					type: null
				}
			}
		}
	} // }}}
	isCascade() => @cascade
	isExit() => @whenFalseExpression? && @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
	isInitializingInstanceVariable(name) { // {{{
		if @condition.isInitializingInstanceVariable(name) {
			return true
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingInstanceVariable(name) && @whenFalseExpression.isInitializingInstanceVariable(name)
		}
		else {
			return false
		}
	} // }}}
	isInitializingStaticVariable(name) { // {{{
		if @condition.isInitializingStaticVariable(name) {
			return true
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingStaticVariable(name) && @whenFalseExpression.isInitializingStaticVariable(name)
		}
		else {
			return false
		}
	} // }}}
	isJumpable() => true
	isLateInitializable() => true
	isUsingVariable(name) { // {{{
		if @declared {
			if @declaration.isUsingVariable(name) {
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
		if @declared && !@bindingDeclaration {
			fragments.compile(@declaration)

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
			if @bindingDeclaration {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(@condition)
					.code(')')

				fragments.code(' ? (')

				@declaration.declarator().toAssignmentFragments(fragments, @condition)

				fragments.code(', true) : false')
			}
			else {
				if @cascade {
					let first = true

					@declaration.walk(name => {
						if first {
							fragments.code($runtime.type(this) + '.isValue((')

							@declaration.toInlineFragments(fragments, mode)

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

					@declaration.walk(name => {
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