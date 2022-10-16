class IfStatement extends Statement {
	private late {
		@analyzeStep: Boolean								= true
		@assignedInstanceVariables							= {}
		@bindingDeclaration: Boolean						= false
		@bindingScope: Scope
		@cascade: Boolean									= false
		@condition: Expression
		@declaration: VariableDeclaration
		@declared: Boolean									= false
		@existential: Boolean								= false
		@initializedVariables: Dictionary					= {}
		@lateInitVariables									= {}
		@hasWhenFalse: Boolean								= false
		@whenFalseExpression								= null
		@whenFalseScope: Scope?								= null
		@whenTrueExpression									= null
		@whenTrueScope: Scope?								= null
	}
	override initiate() { # {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = @newScope(@scope, ScopeType::Bleeding)

			@bindingDeclaration = @data.condition.variables[0].name.kind != NodeKind::Identifier

			@existential =  @data.condition.operator.assignment == AssignmentOperatorKind::Existential

			@declaration = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope, @cascade || @bindingDeclaration)
			@declaration.initiate()
		}
	} # }}}
	override analyse() { # {{{
		@hasWhenFalse = ?@data.whenFalse

		if @declared {
			@declaration.analyse()

			if @bindingDeclaration {
				@condition = @declaration.value()
			}

			@whenTrueScope = @newScope(@bindingScope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = @newScope(@scope, ScopeType::Hollow)
			@whenTrueScope = @newScope(@bindingScope, ScopeType::InlineBlock)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		if @hasWhenFalse {
			@whenFalseScope = @newScope(@scope, ScopeType::InlineBlock)

			@scope.line(@data.whenFalse.start.line)

			if @data.whenFalse.kind == NodeKind::IfStatement {
				@whenFalseExpression = $compile.statement(@data.whenFalse, this, @whenFalseScope)
				@whenFalseExpression.setCascade(true)
				@whenFalseExpression.initiate()
				@whenFalseExpression.analyse()
			}
			else {
				@whenFalseExpression = $compile.block(@data.whenFalse, this, @whenFalseScope)
				@whenFalseExpression.analyse()
			}
		}
	} # }}}
	override prepare(target) { # {{{
		if @declared {
			@declaration.prepare(AnyType.NullableUnexplicit)

			if @bindingDeclaration {
				@condition.acquireReusable(true)
				@condition.releaseReusable()
			}

			if var variable ?= @declaration.getIdentifierVariable() {
				variable.setRealType(variable.getRealType().setNullable(false))
			}
		}
		else {
			@condition.prepare(@scope.reference('Boolean'))

			unless @condition.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@condition, this)
			}

			for var data, name of @condition.inferWhenTrueTypes({}) {
				@whenTrueScope.updateInferable(name, data, this)
			}

			if @whenFalseExpression != null {
				for var data, name of @condition.inferWhenFalseTypes({}) {
					@whenFalseScope.updateInferable(name, data, this)
				}
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		@assignTempVariables(@bindingScope)

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression.prepare(target)

		if @whenFalseExpression == null {
			@scope.line(@data.end.line)

			if !@declared {
				if @whenTrueExpression.isExit() {
					for var map, name of @lateInitVariables {
						if map.false.initializable {
							@parent.initializeVariable(VariableBrief(name, type: map.false.type), this, this)
						}
						else {
							SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
						}
					}

					for var data, name of @condition.inferWhenFalseTypes({}) {
						@scope.updateInferable(name, data, this)
					}
				}
				else {
					for var map, name of @lateInitVariables {
						var mut type: Type

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

					var conditionInferables = @condition.inferWhenFalseTypes({})
					var trueInferables = @whenTrueScope.listUpdatedInferables()

					for var inferable, name of trueInferables {
						var trueType = inferable.type

						if ?conditionInferables[name] {
							var conditionType = conditionInferables[name].type

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
						else if inferable.isVariable && @scope.hasVariable(name) {
							@scope.replaceVariable(name, trueType, true, false, this)
						}
					}
				}
			}
		}
		else {
			@scope.line(@data.whenFalse.start.line)

			@whenFalseExpression.prepare(target)

			@scope.line(@data.end.line)

			if @whenTrueExpression.isExit() {
				for var data, name of @initializedVariables when data.false.initializable {
					data.variable.type = data.false.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for var map, name of @lateInitVariables {
					if map.false.initializable {
						@parent.initializeVariable(VariableBrief(name, type: map.false.type), this, this)
					}
					else {
						SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
					}
				}

				for var data, name of @whenFalseScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else if @whenFalseExpression.isExit() {
				for var data, name of @initializedVariables when data.true.initializable {
					data.variable.type = data.true.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for var map, name of @lateInitVariables {
					if map.true.initializable {
						@parent.initializeVariable(VariableBrief(name, type: map.true.type), this, this)
					}
					else {
						SyntaxException.throwMissingAssignmentIfTrue(name, @whenTrueExpression)
					}
				}

				for var data, name of @whenTrueScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else {
				for var data, name of @initializedVariables {
					if data.true.initializable && data.false.initializable {
						data.variable.type = Type.union(@scope, data.true.type, data.false.type)

						@parent.initializeVariable(data.variable, this, this)
					}
				}

				for var map, name of @lateInitVariables {
					var late type: Type

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

				var trueInferables = @whenTrueScope.listUpdatedInferables()
				var falseInferables = @whenFalseScope.listUpdatedInferables()

				for var inferable, name of trueInferables {
					var trueType = inferable.type

					if ?falseInferables[name] {
						var falseType = falseInferables[name].type

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
					else if inferable.isVariable && @scope.hasVariable(name) {
						@scope.replaceVariable(name, inferable.type, true, false, this)
					}
				}

				for var inferable, name of falseInferables when !?trueInferables[name] {
					if inferable.isVariable && @scope.hasVariable(name) {
						@scope.replaceVariable(name, inferable.type, true, false, this)
					}
				}
			}
		}
	} # }}}
	translate() { # {{{
		if @declared {
			@declaration.translate()
		}
		else {
			@condition.translate()
		}

		@whenTrueExpression.translate()
		@whenFalseExpression?.translate()
	} # }}}
	addAssignments(variables) { # {{{
		if @cascade {
			@parent.addAssignments(variables)
		}
		else if @declared && !@bindingDeclaration {
			for var variable in variables {
				if !@declaration.isDeclararingVariable(variable) {
					@assignments.pushUniq(variable)
				}
			}
		}
		else {
			@assignments.pushUniq(...variables)
		}
	} # }}}
	addInitializableVariable(variable: Variable, node) { # {{{
		var name = variable.name()
		var whenTrue = node == @whenTrueExpression

		if var map ?= @lateInitVariables[name] {
			if whenTrue {
				if map[!whenTrue].initializable {
					map[whenTrue].initializable = true
				}
				else if !@hasWhenFalse {
					SyntaxException.throwMissingAssignmentIfNoElse(name, this)
				}
			}
			else {
				map[whenTrue].initializable = true
			}
		}
		else if !@hasWhenFalse {
			SyntaxException.throwMissingAssignmentIfNoElse(name, this)
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
	} # }}}
	addInitializableVariable(variable: Variable, whenTrue: Boolean, node) { # {{{
		var name = variable.name()

		if var map ?= @lateInitVariables[name] {
			map[whenTrue].initializable = true
		}
		else if !@hasWhenFalse && whenTrue {
			SyntaxException.throwMissingAssignmentIfNoElse(name, this)
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
	} # }}}
	assignments() { # {{{
		if @whenFalseExpression is IfStatement {
			return [].concat(@assignments, @whenFalseExpression.assignments())
		}
		else {
			return @assignments
		}
	} # }}}
	getWhenFalseScope(): @whenFalseScope
	getWhenTrueScope(): @whenTrueScope
	initializeLateVariable(name: String, type: Type, whenTrue: Boolean) { # {{{
		if var map ?= @lateInitVariables[name] {
			map[whenTrue].type = type
		}
		else {
			throw new NotSupportedException(this)

		}
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		var {name, type} = variable
		var whenTrue = node == @whenTrueExpression

		if var map ?= @lateInitVariables[name] {
			if map[whenTrue].type != null {
				if variable.isImmutable() {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(map[whenTrue].type) {
					TypeException.throwInvalidAssignement(name, map[whenTrue].type, type, expression)
				}
			}
			else {
				map[whenTrue].initializable = true
				map[whenTrue].type = type
			}

			var clone = node.scope().getVariable(name).clone()

			if clone.isDefinitive() {
				clone.setRealType(type)
			}
			else {
				clone.setDeclaredType(type, true).flagDefinitive()
			}

			node.scope().replaceVariable(name, clone)
		}
		else if var map ?= @initializedVariables[name] {
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
	} # }}}
	isCascade() => @cascade
	isExit() => ?@whenFalseExpression && @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
	isInitializingInstanceVariable(name) { # {{{
		if @condition.isInitializingInstanceVariable(name) {
			return true
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingInstanceVariable(name) && @whenFalseExpression.isInitializingInstanceVariable(name)
		}
		else {
			return false
		}
	} # }}}
	isInitializingStaticVariable(name) { # {{{
		if @condition.isInitializingStaticVariable(name) {
			return true
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingStaticVariable(name) && @whenFalseExpression.isInitializingStaticVariable(name)
		}
		else {
			return false
		}
	} # }}}
	isJumpable() => true
	isLateInitializable() => true
	isUsingVariable(name) { # {{{
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
	} # }}}
	setCascade(@cascade)
	toStatementFragments(fragments, mode) { # {{{
		if @declared && !@bindingDeclaration {
			fragments.compile(@declaration)

			var ctrl = fragments.newControl()

			@toIfFragments(ctrl, mode)

			ctrl.done()
		}
		else {
			var ctrl = fragments.newControl()

			@toIfFragments(ctrl, mode)

			ctrl.done()
		}
	} # }}}
	toIfFragments(fragments, mode) { # {{{
		fragments.code('if(')

		if @declared {
			if @bindingDeclaration {
				fragments
					.code($runtime.type(this), @existential ? '.isValue(' : '.isNotEmpty(')
					.compileReusable(@condition)
					.code(')')

				fragments.code(' ? (')

				@declaration.declarator().toAssignmentFragments(fragments, @condition)

				fragments.code(', true) : false')
			}
			else {
				if @cascade {
					var mut first = true

					@declaration.walkVariable((name, _) => {
						if first {
							fragments.code($runtime.type(this), @existential ? '.isValue((' : '.isNotEmpty((')

							@declaration.toInlineFragments(fragments, mode)

							fragments.code('))')

							first = false
						}
						else {
							fragments.code(' && ', $runtime.type(this), @existential ? '.isValue(' : '.isNotEmpty(', name, ')')
						}
					})
				}
				else {
					var mut first = true

					@declaration.walkVariable((name, _) => {
						if first {
							first = false
						}
						else {
							fragments.code(' && ')
						}

						fragments.code($runtime.type(this), @existential ? '.isValue(' : '.isNotEmpty(', name, ')')
					})
				}
			}
		}
		else {
			fragments.compileCondition(@condition)
		}

		fragments.code(')').step()

		fragments.compile(@whenTrueExpression, mode)

		if ?@whenFalseExpression {
			if @whenFalseExpression is IfStatement {
				fragments.step().code('else ')

				@whenFalseExpression.toIfFragments(fragments, mode)
			}
			else {
				fragments.step().code('else').step()

				fragments.compile(@whenFalseExpression, mode)
			}
		}
	} # }}}
}
