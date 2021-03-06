class WhileStatement extends Statement {
	private lateinit {
		_bindingDeclaration: Boolean		= false
		_bindingScope: Scope
		_body								= null
		_bodyScope: Scope
		_condition: Expression
		_declared: Boolean					= false
		_declaration: VariableDeclaration
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = this.newScope(@scope, ScopeType::Bleeding)

			@bindingDeclaration = @data.condition.variables[0].name.kind != NodeKind::Identifier

			@declaration = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope, true)
			@declaration.analyse()

			if @bindingDeclaration {
				@condition = @declaration.init()
			}

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
				@bodyScope.updateInferable(name, data, this)
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		this.assignTempVariables(@scope)

		@scope.line(@data.body.start.line)

		@body.prepare()

		for const inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
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
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const ctrl = fragments.newControl().code('while(')

		if @declared {
			if @bindingDeclaration {
				ctrl
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(@condition)
					.code(')')

				ctrl.code(' ? (')

				@declaration.declarator().toAssignmentFragments(ctrl, @condition)

				ctrl.code(', true) : false')
			}
			else {
				let first = true

				@declaration.walk(name => {
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
			ctrl.compileBoolean(@condition)
		}

		ctrl.code(')').step().compile(@body).done()
	} // }}}
}