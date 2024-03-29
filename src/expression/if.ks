class IfExpression extends Expression {
	private late {
		@bindingScope: Scope
		@bindingVariable: Expression?
		@cascade: Boolean								= false
		@condition
		@declaration: VariableDeclaration
		@declarator
		@hasBinding: Boolean							= false
		@hasCondition: Boolean							= true
		@hasDeclaration: Boolean						= false
		@inline: Boolean								= false
		@insitu: Boolean								= false
		@label: String
		@operator
		@type: Type
		@useLabel: Boolean								= false
		@valueName: String?								= null
		@whenFalseExpression: Block | IfExpression
		@whenFalseScope: Scope
		@whenTrueExpression: Block
		@whenTrueScope: Scope
	}
	initiate() { # {{{
		if ?@data.declaration {
			@hasDeclaration = true
			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@hasBinding = @data.declaration.variables[0].name.kind != NodeKind.Identifier
			@operator = @data.declaration.operator.assignment

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:!(Scope), @hasBinding)
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

		unless @whenTrueExpression.isExit(.Expression + .Statement + .Always) {
			SyntaxException.throwDoNoExit(@whenTrueExpression)
		}

		@scope.line(@data.whenFalse.start.line)
		@whenFalseExpression.prepare(target, targetMode)

		unless @whenFalseExpression.isExit(.Expression + .Statement + .Always) {
			SyntaxException.throwDoNoExit(@whenFalseExpression)
		}

		var trueType = @whenTrueExpression.type()
		var falseType = @whenFalseExpression.type()

		@type = Type.union(@scope, trueType, falseType)

		if !@whenTrueExpression.isExit(.Expression + .Continuity) || !@whenFalseExpression.isExit(.Expression + .Continuity) {
			@useLabel = true
			@label = @scope.acquireNewLabel()

			@whenTrueExpression.setExitLabel(@label)
			@whenFalseExpression.setExitLabel(@label)

			if @inline {
				@inline = false

				if @insitu {
					@valueName = @declarator.variable().getSecureName()
				}
				else {
					var statement = @statement()

					@valueName = statement.scope().acquireTempName()

					statement.assignTempVariables(statement.scope())
				}
			}
		}
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
	override isExit(mode) { # {{{
		if mode ~~ .Always {
			return @whenTrueExpression.isExit(mode) && @whenFalseExpression.isExit(mode)
		}
		else {
			return @whenTrueExpression.isExit(mode) || @whenFalseExpression.isExit(mode)
		}
	} # }}}
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

				@declaration.walkVariable((name, type) => {
					if first {
						first = false
					}
					else {
						fragments.code(' && ')
					}

					match @operator {
						OperatorKind.Existential {
							fragments.code(`\($runtime.type(this)).isValue(\(name))`)
						}
						OperatorKind.Finite {
							fragments.code(`\($runtime.type(this)).isFinite(\(name), \(type.isNumber() && !type.isNullable() ? '0' : '1'))`)
						}
						OperatorKind.NonEmpty {
							fragments.code(`\($runtime.type(this)).isNotEmpty(\(name))`)
						}
						OperatorKind.VariantYes {
							var root = type.discard()

							fragments.code(`\(name).\(root.getVariantName())`)
						}
					}
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

				match @operator {
					OperatorKind.Existential {
						fragments.code(`\($runtime.type(this)).isValue(`)

						declarator.toAssignmentFragments(fragments, @bindingVariable)

						fragments.code(')')
					}
					OperatorKind.Finite {
						var type = @declaration.type()

						fragments.code(`\($runtime.type(this)).isFinite(`)

						declarator.toAssignmentFragments(fragments, @bindingVariable)

						fragments.code(`, \(type.isNumber() && !type.isNullable() ? '0' : '1'))`)
					}
					OperatorKind.NonEmpty {
						fragments.code(`\($runtime.type(this)).isNotEmpty(`)

						declarator.toAssignmentFragments(fragments, @bindingVariable)

						fragments.code(')')
					}
					OperatorKind.VariantYes {
						var root = @declaration.type().discard()

						declarator.toAssignmentFragments(fragments, @bindingVariable)

						fragments.code(`.\(root.getVariantName())`)
					}
				}
			}
			else {
				if @hasBinding {
					match @operator {
						OperatorKind.Existential {
							fragments
								.code(`\($runtime.type(this)).isValue(`)
								.compileReusable(@bindingVariable)
								.code(')')
						}
						OperatorKind.Finite {
							var type = @declaration.type()

							fragments
								.code(`\($runtime.type(this)).isFinite(`)
								.compileReusable(@bindingVariable)
								.code(`, \(type.isNumber() && !type.isNullable() ? '0' : '1'))`)
						}
						OperatorKind.NonEmpty {
							fragments
								.code(`\($runtime.type(this)).isNotEmpty(`)
								.compileReusable(@bindingVariable)
								.code(')')
						}
						OperatorKind.VariantYes {
							var root = @declaration.type().discard()

							fragments.compileReusable(@bindingVariable).code(`.\(root.getVariantName())`)
						}
					}

					fragments.code(' ? (')

					var declarator = @declaration.declarator()

					declarator.toAssertFragments(fragments, @bindingVariable)
					declarator.toAssignmentFragments(fragments, @bindingVariable)

					fragments.code(', true) : false')
				}
				else {
					var mut first = true

					@declaration.walkVariable((name, type) => {
						if first {
							first = false
						}
						else {
							fragments.code(' && ')
						}

						match @operator {
							OperatorKind.Existential {
								fragments.code(`\($runtime.type(this)).isValue(\(name))`)
							}
							OperatorKind.Finite {
								fragments.code(`\($runtime.type(this)).isFinite(\(name), \(type.isNumber() && !type.isNullable() ? '0' : '1'))`)
							}
							OperatorKind.NonEmpty {
								fragments.code(`\($runtime.type(this)).isNotEmpty(\(name))`)
							}
							OperatorKind.VariantYes {
								var root = type.discard()

								fragments.code(`\(name).\(root.getVariantName())`)
							}
						}
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
			}

			var ctrl = fragments.newControl()

			if @useLabel {
				ctrl.code(`\(@label): `)
			}

			@toIfFragments(ctrl, mode)

			ctrl.done()
		}
	} # }}}
	type() => @type
}
