class IfStatement extends Statement {
	private late {
		@analyzeStep: Boolean								= true
		@assignedInstanceVariables							= {}
		@bindingScope: Scope
		@cascade: Boolean									= false
		@conditions: Expression[]							= []
		@declarations										= []
		@initializedVariables: Object						= {}
		@lateInitVariables									= {}
		@hasCondition: Boolean								= true
		@hasDeclaration: Boolean							= false
		@hasWhenFalse: Boolean								= false
		@whenFalseExpression: Block | IfStatement | Null	= null
		@whenFalseScope: Scope?								= null
		@whenTrueExpression: Block
		@whenTrueScope: Scope?								= null
	}
	override initiate() { # {{{
		if ?@data.declarations {
			@hasDeclaration = true

			var mut bindingScope = @scope!?
			var mut previousScope = @scope!?

			for var data in @data.declarations {
				var declarationData = if data[0].kind == AstKind.VariableDeclaration set data[0] else data[1]
				var conditionData = if data[0].kind != AstKind.VariableDeclaration set data[0] else if ?data[1] && data[1].kind != AstKind.VariableDeclaration set data[1] else null

				bindingScope = @newScope(bindingScope, ScopeType.Bleeding)

				var declaration = VariableDeclaration.new(declarationData, this, bindingScope, previousScope, true)
					..flagUseExpression()

				@declarations.push({
					declaration
					declarationData
					declarationFirst: data[0].kind == AstKind.VariableDeclaration
					bindingScope
					operator: declarationData.operator.assignment
					hasCondition: ?conditionData
					conditionData
				})

				previousScope = bindingScope
			}

			for var { declaration } in @declarations {
				declaration.initiate()
			}
		}
	} # }}}
	override analyse() { # {{{
		@hasWhenFalse = ?@data.whenFalse

		if @hasDeclaration {
			var conditions = 0

			for var decl in @declarations {
				var { declaration, declarationData, declarationFirst, bindingScope, hasCondition, conditionData? } = decl

				if hasCondition && !declarationFirst {
					var condition = $compile.expression(conditionData, this, bindingScope)
						..analyse()

					@conditions.push(condition)

					decl.condition = condition
				}

				bindingScope.line(declarationData.start.line)

				declaration.analyse()

				if hasCondition && declarationFirst {
					var condition = $compile.expression(conditionData, this, bindingScope)
						..analyse()

					@conditions.push(condition)

					decl.condition = condition
				}
			}

			@whenTrueScope = @newScope(@declarations.last().bindingScope, ScopeType.InlineBlock)
		}
		else {
			@bindingScope = @newScope(@scope!?, ScopeType.Hollow)
			@whenTrueScope = @newScope(@bindingScope, ScopeType.InlineBlock)

			var condition = $compile.expression(@data.condition, this, @bindingScope)
				..analyse()

			@conditions.push(condition)
		}

		@hasCondition = ?#@conditions

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
			..analyse()

		if @hasWhenFalse {
			@whenFalseScope = @newScope(@scope!?, ScopeType.InlineBlock)

			@scope.line(@data.whenFalse.start.line)

			if @data.whenFalse.kind == AstKind.IfStatement {
				@whenFalseExpression = $compile.statement(@data.whenFalse, this, @whenFalseScope)
					..setCascade(true)
					..initiate()
					..analyse()
			}
			else {
				@whenFalseExpression = $compile.block(@data.whenFalse, this, @whenFalseScope)
					..analyse()
			}
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @hasDeclaration {
			for var { declaration, bindingVariable?, operator } in @declarations {
				declaration.prepare(AnyType.NullableUnexplicit)
			}
		}

		if @hasCondition {
			for var condition in @conditions {
				condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

				var conditionType = condition.type()

				unless conditionType.canBeBoolean() {
					TypeException.throwInvalidCondition(condition, this)
				}

				// TODO
				// if conditionType is ValueType && conditionType.type().isBoolean() && !@hasLoopAncestor() {
				// 	TypeException.throwUnnecessaryCondition(condition, this)
				// }

				for var data, name of condition.inferWhenTrueTypes({}) {
					@whenTrueScope.updateInferable(name, data, this)
				}

				if ?@whenFalseExpression {
					for var data, name of condition.inferWhenFalseTypes({}) {
						@whenFalseScope.updateInferable(name, data, this)
					}
				}

				condition
					..acquireReusable(false)
					..releaseReusable()
			}
		}

		if @hasDeclaration {
			for var { bindingScope } in @declarations {
				@assignTempVariables(bindingScope)
			}
		}
		else {
			@assignTempVariables(@bindingScope)
		}

		@scope.line(@data.whenTrue.start.line)
		@whenTrueExpression.prepare(target)

		if !@hasWhenFalse {
			@scope.line(@data.end.line)

			if !@hasDeclaration {
				if @whenTrueExpression.isExit(.Expression + .Statement + .Always) {
					for var map, name of @lateInitVariables {
						if map.false.initializable {
							@parent.initializeVariable(VariableBrief.new(name, type: map.false.type), this, this)
						}
						else {
							SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
						}
					}

					var conditionInferables = @conditions[0].inferWhenFalseTypes({})
					var trueInferables = @whenTrueScope.listUpdatedInferables()

					for var data, name of conditionInferables {
						@scope.updateInferable(name, data, this)
					}

					for var {isVariable, type}, name of trueInferables {
						if isVariable && !?conditionInferables[name] && @scope.hasVariable(name) {
							@scope.replaceVariable(name, type, true, false, this)
						}
					}
				}
				else {
					for var map, name of @lateInitVariables {
						if map.true.initializable {
							if map.false.initializable {
								var type = Type.union(@scope, map.true.type, map.false.type)

								@parent.initializeVariable(VariableBrief.new(name, type), this, this)
							}
							else {
								SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
							}
						}
						else {
							SyntaxException.throwMissingAssignmentIfTrue(name, @whenTrueExpression)
						}
					}

					var conditionInferables = @conditions[0].inferWhenFalseTypes({})
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

			@whenFalseExpression!?.prepare(target)

			@scope.line(@data.end.line)

			if @whenTrueExpression.isExit(.Expression + .Statement + .Always) {
				for var data, name of @initializedVariables when data.false.initializable {
					data.variable.type = data.false.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for var map, name of @lateInitVariables {
					if map.false.initializable {
						@parent.initializeVariable(VariableBrief.new(name, type: map.false.type), this, this)
					}
					else {
						SyntaxException.throwMissingAssignmentIfFalse(name, @whenFalseExpression)
					}
				}

				for var data, name of @whenFalseScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else if @whenFalseExpression!?.isExit(.Expression + .Statement + .Always) {
				for var data, name of @initializedVariables when data.true.initializable {
					data.variable.type = data.true.type

					@parent.initializeVariable(data.variable, this, this)
				}

				for var map, name of @lateInitVariables {
					if map.true.initializable {
						@parent.initializeVariable(VariableBrief.new(name, type: map.true.type), this, this)
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

					@parent.initializeVariable(VariableBrief.new(name, type), this, this)
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
						@scope.replaceVariable(name, trueType, true, false, this)
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
		if @hasDeclaration {
			for var { declaration } in @declarations {
				declaration.translate()
			}
		}
		if @hasCondition {
			for var condition in @conditions {
				condition.translate()
			}
		}

		@whenTrueExpression.translate()
		@whenFalseExpression?.translate()
	} # }}}
	addAssignments(variables) { # {{{
		if @cascade {
			@parent.addAssignments(variables)
		}
		else if @hasDeclaration {
			for var { declaration } in @declarations {
				for var variable in variables {
					if !declaration.isDeclararingVariable(variable) {
						@assignments.pushUniq(variable)
					}
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
			return [...@assignments, ...@whenFalseExpression.assignments()!?]
		}
		else {
			return @assignments
		}
	} # }}}
	getWhenFalseScope(): valueof @whenFalseScope
	getWhenTrueScope(): valueof @whenTrueScope
	initializeLateVariable(name: String, type: Type, whenTrue: Boolean) { # {{{
		if var map ?= @lateInitVariables[name] {
			map[whenTrue].type = type
		}
		else {
			throw NotSupportedException.new(this)

		}
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode) { # {{{
		@initializeVariable(variable, expression, @whenTrueExpression)
	} # }}}
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode) { # {{{
		var {name, type} = variable
		var whenTrue = node == @whenTrueExpression

		if var map ?= @lateInitVariables[name] {
			if ?map[whenTrue].type {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !type.matchContentOf(map[whenTrue].type) {
					TypeException.throwInvalidAssignment(name, map[whenTrue].type, type, expression)
				}
			}
			else {
				map[whenTrue]
					..initializable = true
					..type = type
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
		else if var map ?= @initializedVariables[name] {
			if map[whenTrue].type != null {
				if variable.immutable {
					ReferenceException.throwImmutable(name, expression)
				}
				else if !variable.type.matchContentOf(map[whenTrue].type) {
					TypeException.throwInvalidAssignment(name, map[whenTrue].type, variable.type, expression)
				}
			}
			else {
				map[whenTrue]
					..initializable = true
					..type = variable.type
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
	override isExit(mode) { # {{{
		if mode ~~ .Always {
			return @hasWhenFalse && @whenTrueExpression.isExit(mode) && @whenFalseExpression.isExit(mode)
		}
		else {
			return @whenTrueExpression.isExit(mode) || (@hasWhenFalse && @whenFalseExpression.isExit(mode))
		}
	} # }}}
	isInitializingInstanceVariable(name) { # {{{
		for var condition in @conditions {
			if condition.isInitializingInstanceVariable(name) {
				return true
			}
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingInstanceVariable(name) && @whenFalseExpression.isInitializingInstanceVariable(name)
		}
		else {
			return false
		}
	} # }}}
	isInitializingStaticVariable(name) { # {{{
		for var condition in @conditions {
			if condition.isInitializingStaticVariable(name) {
				return true
			}
		}

		if @hasWhenFalse {
			return @whenTrueExpression.isInitializingStaticVariable(name) && @whenFalseExpression.isInitializingStaticVariable(name)
		}
		else {
			return false
		}
	} # }}}
	override isInitializingVariableAfter(name, statement) { # {{{
		// TODO!
		// return @whenTrueExpression.isInitializingVariableAfter(name, statement) || @whenFalseExpression?.isInitializingVariableAfter(name, statement)
		return @whenTrueExpression.isInitializingVariableAfter(name, statement) || (@hasWhenFalse && @whenFalseExpression.isInitializingVariableAfter(name, statement))
	} # }}}
	isJumpable() => true
	isLateInitializable() => true
	override isUsingVariable(name, bleeding) { # {{{
		if @hasDeclaration {
			for var { declaration } in @declarations {
				if declaration.isDeclararingVariable(name) {
					return false
				}
				else if declaration.isUsingVariable(name) {
					return true
				}
			}
		}
		else {
			if @conditions[0].isUsingVariable(name) {
				return true
			}
		}

		return false if bleeding

		if @whenTrueExpression.isUsingVariable(name) {
			return true
		}

		return @hasWhenFalse && @whenFalseExpression.isUsingVariable(name)
	} # }}}
	override isUsingVariableBefore(name) { # {{{
		if @parent is IfStatement {
			return @parent.isUsingVariableBefore(name)
		}
		else {
			return @parent.isUsingVariableBefore(name, this)
		}
	} # }}}
	override isUsingVariableBefore(name, statement) { # {{{
		if @parent.isUsingVariableBefore(name, this) || @whenTrueExpression?.isUsingVariableBefore(name, statement) {
			return true
		}

		// TODO!
		// return @whenFalseExpression?.isUsingVariableBefore(name, statement)
		return ?@whenFalseExpression && @whenFalseExpression.isUsingVariableBefore(name, statement)
	} # }}}
	setCascade(@cascade)
	override setExitLabel(label) { # {{{
		@whenTrueExpression.setExitLabel(label)

		if @hasWhenFalse {
			@whenFalseExpression.setExitLabel(label)
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl()

		@toIfFragments(ctrl, mode)

		ctrl.done()
	} # }}}
	toIfFragments(fragments, mode) { # {{{
		fragments.code('if(')

		if @hasDeclaration {
			for var { declaration, declarationFirst, operator, bindingVariable?, hasCondition, condition? }, index in @declarations {
				fragments.code(' && ') if index > 0

				if hasCondition && !declarationFirst {
					fragments.compileCondition(condition, mode, Junction.AND).code(' && ')
				}

				fragments.wrapCondition(declaration.expression())

				if hasCondition && declarationFirst {
					fragments.code(' && ').compileCondition(condition, mode, Junction.AND)
				}
			}
		}
		else {
			fragments.compileCondition(@conditions[0])
		}

		fragments
			.code(')').step()
			.compile(@whenTrueExpression, mode)

		if @hasWhenFalse {
			if @whenFalseExpression is IfStatement {
				fragments.step().code('else ')

				@whenFalseExpression.toIfFragments(fragments, mode)
			}
			else {
				fragments
					.step().code('else').step()
					.compile(@whenFalseExpression, mode)
			}
		}
	} # }}}
	type() { # {{{
		if @hasWhenFalse {
			var trueType = @whenTrueExpression.type()
			var falseType = @whenFalseExpression.type()

			return Type.union(@scope, trueType, falseType)
		}
		else {
			return Type.Void
		}
	} # }}}
}
