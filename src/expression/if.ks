class IfExpression extends Expression {
	private late {
		@bindingScope: Scope
		@cascade: Boolean								= false
		@condition
		@declaration: VariableDeclaration
		@declarator
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

			@operator = @data.declaration.operator.assignment

			@declaration = VariableDeclaration.new(@data.declaration, this, @bindingScope, @scope:!!!(Scope), true)
				..flagUseExpression()
				..initiate()
		}
	} # }}}
	override analyse() { # {{{
		@initiate()

		if !@cascade {
			if @data.whenTrue.kind == AstKind.Block {
				if @data.whenTrue.statements.length == @data.whenFalse.statements?.length == 1 {
					@inline = @data.whenTrue.statements[0].kind == @data.whenFalse.statements[0].kind == AstKind.SetStatement
				}
			}
			else {
				@inline = true
			}
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

			if @inline {
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
			@bindingScope = @newScope(@scope!?, if @inline set ScopeType.Hollow else ScopeType.Bleeding)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@scope.line(@data.whenTrue.start.line)
		@whenTrueScope = @newScope(@bindingScope, ScopeType.InlineBlock)
		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		@scope.line(@data.whenFalse.start.line)

		if @data.whenFalse.kind == AstKind.IfExpression {
			@whenFalseScope = @newScope(@bindingScope, ScopeType.Bleeding)

			@whenFalseExpression = $compile.expression(@data.whenFalse, this, @whenFalseScope)
			@whenFalseExpression.setCascade(true)
			@whenFalseExpression.analyse()
		}
		else {
			@whenFalseScope = @newScope(@bindingScope, ScopeType.InlineBlock)

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

			if var variable ?= @declaration.getIdentifierVariable() {
				variable.setRealType(variable.getRealType().setNullable(false))
			}

			if @cascade {
				var variables = @declaration.listAssignments([])

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
	addAssignments(variables) { # {{{
		@statement().addAssignments(variables)
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
	isInverted() => @inline && (@condition.isInverted() || @whenTrueExpression.isInverted() || @whenFalseExpression.isInverted())
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
				if @hasCondition {
					fragments.wrapCondition(@declaration.expression()).code(' && ').compileCondition(@condition, mode, Junction.AND)
				}
				else {
					fragments.wrapCondition(@declaration.expression())
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
			if @hasCondition {
				fragments.wrapCondition(@declaration.expression()).code(' && ').compileCondition(@condition, mode, Junction.AND)
			}
			else {
				fragments.compileCondition(@declaration.expression())
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
	toInvertedFragments(fragments, callback) { # {{{
		if @condition.isInverted() {
			@condition.toInvertedFragments(fragments, callback)
		}
		else if @whenTrueExpression.isInverted() {
			@whenTrueExpression.toInvertedFragments(fragments, callback)
		}
		else {
			@whenFalseExpression.toInvertedFragments(fragments, callback)
		}
	} # }}}
	toQuote() => `if \(if @hasDeclaration set @declaration.toQuote() else @condition.toQuote()) { ... }`
	toStatementFragments(fragments, mode) { # {{{
		if !@inline {
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
