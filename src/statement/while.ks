class WhileStatement extends Statement {
	private lateinit {
		_bindingScope: Scope
		_body					= null
		_bodyScope: Scope
		_condition
		_declared: Boolean		= false
		_variable
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = this.newScope(@scope, ScopeType::Bleeding)

			@variable = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope)
			@variable.analyse()

			@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = this.newScope(@scope, ScopeType::Hollow)
			@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
			@condition.analyse()
		}

		@scope.line(@data.body.start.line)

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		if @declared {
			@variable.prepare()
		}
		else {
			@condition.prepare()

			unless @condition.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@condition, this)
			}

			for const data, name of @condition.inferWhenTrueTypes({}) {
				@bodyScope.updateInferable(name, data, this)
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		this.assignTempVariables(@scope)

		@scope.line(@data.body.start.line)

		@body.prepare()

		for const inferable, name of @bodyScope.listUpdatedInferables() when inferable.isVariable {
			if const variable = @scope.getVariable(name) {
				@scope.updateInferable(name, {
					isVariable: true
					type: @scope.inferVariableType(variable, inferable.type)
				}, this)
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

		@body.translate()
	} // }}}
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isCascade() => @declared
	isJumpable() => true
	isLoop() => true
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

		return @body.isUsingVariable(name)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const ctrl = fragments.newControl().code('while(')

		if @declared {
			let first = true

			@variable.walk(name => {
				if first {
					ctrl.code($runtime.type(this) + '.isValue(')

					@variable.toInlineFragments(ctrl, mode)

					ctrl.code(')')

					first = false
				}
				else {
					ctrl.code(' && ' + $runtime.type(this) + '.isValue(', name, ')')
				}
			})
		}
		else {
			ctrl.compileBoolean(@condition)
		}

		ctrl.code(')').step().compile(@body).done()
	} // }}}
}