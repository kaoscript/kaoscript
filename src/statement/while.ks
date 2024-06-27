class WhileStatement extends Statement {
	private late {
		@bindingScope: Scope
		@body								= null
		@bodyScope: Scope
		@condition: Expression
		@declared: Boolean					= false
		@declaration: VariableDeclaration
	}
	initiate() { # {{{
		if @data.condition.kind == AstKind.VariableDeclaration {
			@declared = true
			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@declaration = VariableDeclaration.new(@data.condition, this, @bindingScope, @scope:!!!(Scope), true)
				..flagUseExpression()
				..initiate()
		}
	} # }}}
	analyse() { # {{{
		if @declared {
			@declaration.analyse()

			@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)
		}
		else {
			@bindingScope = @newScope(@scope!?, ScopeType.Hollow)
			@bodyScope = @newScope(@bindingScope, ScopeType.InlineBlock)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@scope.line(@data.body.start.line)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @declared {
			@declaration.prepare(AnyType.NullableUnexplicit)

			if var variable ?= @declaration.getIdentifierVariable() {
				variable.setRealType(variable.getRealType().setNullable(false))
			}
		}
		else {
			@condition.prepare(@scope.reference('Boolean'), TargetMode.Permissive)

			unless @condition.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@condition, this)
			}

			for var data, name of @condition.inferWhenTrueTypes({}) {
				@bodyScope.updateInferable(name, data, this)
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		@assignTempVariables(@scope!?)

		@scope.line(@data.body.start.line)

		@body.prepare(target)

		for var { isVariable, type }, name of @bodyScope.listUpdatedInferables() {
			if isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, type, true, false, this)
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

		@body.translate()
	} # }}}
	isCascade() => @declared
	override isInitializingVariableAfter(name, statement) => @body.isInitializingVariableAfter(name, statement)
	isJumpable() => true
	isLoop() => true
	override isUsingVariable(name, bleeding) { # {{{
		return false if bleeding

		if @declared {
			if @declaration.isDeclararingVariable(name) {
				return false
			}
			else if @declaration.isUsingVariable(name) {
				return true
			}
		}
		else {
			if @condition.isUsingVariable(name) {
				return true
			}
		}

		return @body.isUsingVariable(name)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl().code('while(')

		if @declared {
			ctrl.compileCondition(@declaration.expression())
		}
		else {
			ctrl.compileCondition(@condition)
		}

		ctrl.code(')').step().compile(@body).done()
	} # }}}
}
