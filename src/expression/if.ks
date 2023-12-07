class IfExpression extends Expression {
	private late {
		@bindingScope: Scope
		@bindingVariable: Expression?
		@cascade: Boolean						= false
		@condition
		@declaration: VariableDeclaration
		@declarator
		@existential: Boolean					= false
		@hasBinding: Boolean					= false
		@hasCondition: Boolean					= true
		@hasDeclaration: Boolean				= false
		@inline: Boolean						= false
		@insitu: Boolean						= false
		@type: Type
		@valueName: String?						= null
		@whenFalseExpression
		@whenFalseScope: Scope
		@whenTrueExpression
		@whenTrueScope: Scope
	}
	initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true
			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@hasBinding = @data.declaration.variables[0].name.kind != NodeKind.Identifier

			@existential =  @data.declaration.operator.assignment == AssignmentOperatorKind.Existential

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:Scope, @hasBinding)
			@declaration.initiate()
		}
	} # }}}
	override analyse() { # {{{
		@initiate()

		if !@cascade && @data.whenTrue.statements.length == @data.whenFalse.statements?.length == 1 {
			@inline = @data.whenTrue.statements[0].kind == @data.whenFalse.statements[0].kind == NodeKind.SetStatement
		}

		if !@inline {
			var mut statement = @parent
			var mut declaration = null

			while statement is not Statement {
				if statement is VariableDeclaration {
					declaration = statement
				}

				statement = statement.parent()
			}

			if ?declaration {
				var declarators = declaration.declarators()
				var declarator = declarators[0]

				if declarators.length == 1 && declarator is VariableIdentifierDeclarator {
					@declarator = declarator
					@insitu = true
				}
			}

			if !@cascade {
				if @insitu {
					statement.addAfterward(this)
				}
				else {
					statement.addBeforehand(this)
				}
			}
		}

		if @hasDeclaration {
			@declaration.analyse()

			if @hasBinding {
				@bindingVariable = @declaration.value()
			}
			else if @inline {
				@statement().addBeforehand(this)
			}

			if ?@data.condition {
				@condition = $compile.expression(@data.condition, this, @bindingScope)
				@condition.analyse()
			}
			else {
				@hasCondition = false
			}
		}
		else {
			@bindingScope = @newScope(@scope!?, @inline ? ScopeType.Hollow : ScopeType.Bleeding)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@scope.line(@data.whenTrue.start.line)
		@whenTrueScope = @newScope(@bindingScope, ScopeType.InlineBlock)
		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		@scope.line(@data.whenFalse.start.line)
		@whenFalseScope = @newScope(@bindingScope, ScopeType.InlineBlock)

		if @data.whenFalse.kind == NodeKind.IfExpression {
			@whenFalseExpression = $compile.expression(@data.whenFalse, this, @whenFalseScope)
			@whenFalseExpression.setCascade(true)
			@whenFalseExpression.analyse()
		}
		else {
			@whenFalseExpression = $compile.block(@data.whenFalse, this, @whenFalseScope)
			@whenFalseExpression.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if !@inline {
			if @insitu {
				@valueName = @declarator.variable().getSecureName()
			}
			else {
				var statement = @statement()

				@valueName = statement.scope().acquireTempName()

				statement.assignTempVariables(statement.scope())
			}
		}

		if @hasDeclaration {
			@declaration.prepare(AnyType.NullableUnexplicit)

			if @hasBinding {
				@bindingVariable.acquireReusable(true)
				@bindingVariable.releaseReusable()
			}

			if var variable ?= @declaration.getIdentifierVariable() {
				variable.setRealType(variable.getRealType().setNullable(false))
			}

			if @cascade {
				var variables = @declaration.listAssignments([])

				if @hasBinding {
					@bindingVariable.listAssignments(variables)
				}

				@statement().addAssignments(variables.map(func({name}, ...) => name))
			}
		}

		if @hasCondition {
			@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

			for var data, name of @condition.inferWhenTrueTypes({}) {
				@whenTrueScope.updateInferable(name, data, this)
			}

			for var data, name of @condition.inferWhenFalseTypes({}) {
				@whenFalseScope.updateInferable(name, data, this)
			}

			@condition
				..acquireReusable(false)
				..releaseReusable()
		}

		@statement().assignTempVariables(@bindingScope)

		@scope.line(@data.whenTrue.start.line)
		@whenTrueExpression.prepare(target, targetMode)

		unless @whenTrueExpression.isExit() {
			SyntaxException.throwDoNoExit(@whenTrueExpression)
		}

		@scope.line(@data.whenFalse.start.line)
		@whenFalseExpression.prepare(target, targetMode)

		unless @whenFalseExpression.isExit() {
			SyntaxException.throwDoNoExit(@whenFalseExpression)
		}

		var trueType = @whenTrueExpression.type()
		var falseType = @whenFalseExpression.type()

		@type = Type.union(@scope, trueType, falseType)
	} # }}}
	override translate() { # {{{
		if @hasDeclaration {
			@declaration.translate()
		}
		if @hasCondition {
			@condition.translate()
		}

		@whenTrueExpression.translate()
		@whenFalseExpression.translate()
	} # }}}
	assignTempVariables(scope: Scope) => @statement().assignTempVariables(scope)
	getValueName() => @valueName
	initializeVariable(variable: VariableBrief, expression: AbstractNode, node: AbstractNode)
	isComputed() => true
	isExit() => @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
	isInline() => @inline
	isInSituStatement() => @insitu
	isUsingVariable(name) => @condition?.isUsingVariable(name) || @whenTrueExpression.isUsingVariable(name) || @whenFalseExpression.isUsingVariable(name)
	override listNonLocalVariables(scope, variables) { # {{{
		@condition?.listNonLocalVariables(scope, variables)
		@whenTrueExpression.listNonLocalVariables(scope, variables)
		@whenFalseExpression.listNonLocalVariables(scope, variables)

		return variables
	} # }}}
	setCascade(@cascade)
	toFragments(fragments, mode) { # {{{
		if @inline {
			if @hasDeclaration {
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

				if @hasCondition {
					fragments.code(' && ').compileCondition(@condition, mode, Junction.AND)
				}
			}
			else {
				fragments.wrapCondition(@condition)
			}

			fragments
				.code(' ? ')
				.compile(@whenTrueExpression)
				.code(' : ')
				.compile(@whenFalseExpression)
		}
		else {
			fragments.code(@valueName)
		}
	} # }}}
	toAfterwardFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toBeforehandFragments(fragments, mode) { # {{{
		@toStatementFragments(fragments, mode)
	} # }}}
	toIfFragments(fragments, mode) { # {{{
		fragments.code('if(')

		if @hasDeclaration {
			if @cascade {
				var declarator = @declaration.declarator()

				fragments.code($runtime.type(this), @existential ? '.isValue(' : '.isNotEmpty(')

				declarator.toAssignmentFragments(fragments, @bindingVariable)

				fragments.code(')')
			}
			else {
				if @hasBinding {
					fragments
						.code($runtime.type(this), @existential ? '.isValue(' : '.isNotEmpty(')
						.compileReusable(@bindingVariable)
						.code(')')

					fragments.code(' ? (')

					var declarator = @declaration.declarator()

					declarator.toAssertFragments(fragments, @bindingVariable)
					declarator.toAssignmentFragments(fragments, @bindingVariable)

					fragments.code(', true) : false')
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

			if @hasCondition {
				fragments.code(' && ').compileCondition(@condition, mode, Junction.AND)
			}
		}
		else {
			fragments.compileCondition(@condition)
		}

		fragments.code(')').step()

		fragments.compile(@whenTrueExpression, mode)

		if @whenFalseExpression is IfExpression {
			fragments.step().code('else ')

			@whenFalseExpression.toIfFragments(fragments, mode)
		}
		else {
			fragments.step().code('else').step()

			fragments.compile(@whenFalseExpression, mode)
		}
	} # }}}
	toQuote() => `if \(@hasDeclaration ? @declaration.toQuote() : @condition.toQuote()) { ... }`
	toStatementFragments(fragments, mode) { # {{{
		if @inline {
			if @hasDeclaration && !@hasBinding {
				fragments.compile(@declaration)
			}
		}
		else {
			if @hasDeclaration && !@hasBinding {
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
		}
	} # }}}
	type() => @type
}
