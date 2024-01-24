class WhileStatement extends Statement {
	private late {
		@bindingDeclaration: Boolean		= false
		@bindingScope: Scope
		@body								= null
		@bodyScope: Scope
		@condition: Expression
		@declared: Boolean					= false
		@declaration: VariableDeclaration
	}
	initiate() { # {{{
		if @data.condition.kind == NodeKind.VariableDeclaration {
			@declared = true
			@bindingScope = @newScope(@scope!?, ScopeType.Bleeding)

			@bindingDeclaration = @data.condition.variables[0].name.kind != NodeKind.Identifier

			@declaration = VariableDeclaration.new(@data.condition, this, @bindingScope, @scope:!(Scope), true)
			@declaration.initiate()
		}
	} # }}}
	analyse() { # {{{
		if @declared {
			@declaration.analyse()

			if @bindingDeclaration {
				@condition = @declaration.value()
			}

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

			if @bindingDeclaration {
				@condition.acquireReusable(true)
				@condition.releaseReusable()
			}

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
	isJumpable() => true
	isLoop() => true
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

		return @body.isUsingVariable(name)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		var ctrl = fragments.newControl().code('while(')

		if @declared {
			if @bindingDeclaration {
				ctrl
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(@condition)
					.code(')')

				ctrl.code(' ? (')

				var declarator = @declaration.declarator()

				declarator.toAssertFragments(ctrl, @condition)
				declarator.toAssignmentFragments(ctrl, @condition)

				ctrl.code(', true) : false')
			}
			else {
				var mut first = true

				@declaration.walkVariable((name, _) => {
					if first {
						ctrl.code($runtime.type(this) + '.isValue(')

						@declaration.toInlineFragments(ctrl, mode)

						ctrl.code(')')

						first = false
					}
					else {
						ctrl.code(' && ' + $runtime.type(this) + '.isValue(', name, ')')
					}
				})
			}
		}
		else {
			ctrl.compileCondition(@condition)
		}

		ctrl.code(')').step().compile(@body).done()
	} # }}}
}
