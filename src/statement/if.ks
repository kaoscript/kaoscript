class IfStatement extends Statement {
	private {
		_bindingScope: Scope
		_condition
		_declared: Boolean				= false
		_variable
		_whenFalseExpression			= null
		_whenFalseScope: Scope?			= null
		_whenTrueExpression				= null
		_whenTrueScope: Scope?			= null
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@declared = true
			@bindingScope = this.newScope(@scope, ScopeType::Bleeding)

			@variable = new VariableDeclaration(@data.condition, this, @bindingScope, @scope:Scope)

			@whenTrueScope = this.newScope(@bindingScope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = this.newScope(@scope, ScopeType::Hollow)
			@whenTrueScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

			@condition = $compile.expression(@data.condition, this, @bindingScope)
		}

		if @declared {
			@variable.analyse()
		}
		else {
			@condition.analyse()
		}

		@scope.line(@data.whenTrue.start.line)

		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		if @data.whenFalse? {
			@whenFalseScope = this.newScope(@scope, ScopeType::InlineBlock)

			@scope.line(@data.whenFalse.start.line)

			if @data.whenFalse.kind == NodeKind::IfStatement {
				@whenFalseExpression = $compile.statement(@data.whenFalse, this, @whenFalseScope)
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
			@variable.prepare()

			// if const variable = @variable.getIdentifierVariable() {
			// 	variable.setRealType(variable.getRealType().setNullable(false))
			// }
		}
		else {
			@condition.prepare()

			for const data, name of @condition.inferTypes() {
				@whenTrueScope.updateInferable(name, data, this)
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
					for const data, name of @condition.inferContraryTypes() {
						@scope.updateInferable(name, data, this)
					}
				}
				else {
					const conditionInferables = @condition.inferContraryTypes()
					const trueInferables = @whenTrueScope.listUpdatedInferables()

					for const :name of trueInferables when conditionInferables[name]? {
						const trueType = trueInferables[name].type
						const conditionType = conditionInferables[name].type

						if trueType.equals(conditionType) {
							@scope.updateInferable(name, trueInferables[name], this)
						}
						else {
							@scope.updateInferable(name, {
								isVariable: trueInferables[name].isVariable
								type: Type.union(@scope, trueType, conditionType)
							}, this)
						}
					}
				}
			}
		}
		else {
			if !@declared {
				for const data, name of @condition.inferContraryTypes() {
					@whenFalseScope.updateInferable(name, data, this)
				}
			}

			@scope.line(@data.whenFalse.start.line)

			@whenFalseExpression.prepare()

			@scope.line(@data.end.line)

			if @whenTrueExpression.isExit() {
				for const data, name of @whenFalseScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else if @whenFalseExpression.isExit() {
				for const data, name of @whenTrueScope.listUpdatedInferables() {
					@scope.updateInferable(name, data, this)
				}
			}
			else {
				const trueInferables = @whenTrueScope.listUpdatedInferables()
				const falseInferables = @whenFalseScope.listUpdatedInferables()

				for const :name of trueInferables when falseInferables[name]? {
					const trueType = trueInferables[name].type
					const falseType = falseInferables[name].type

					if trueType.equals(falseType) {
						@scope.updateInferable(name, trueInferables[name], this)
					}
					else {
						@scope.updateInferable(name, {
							isVariable: trueInferables[name].isVariable
							type: Type.union(@scope, trueType, falseType)
						}, this)
					}
				}
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

		@whenTrueExpression.translate()
		@whenFalseExpression?.translate()
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
	isExit() => @whenFalseExpression? && @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
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

		if @whenTrueExpression.isUsingVariable(name) {
			return true
		}

		return @whenFalseExpression != null && @whenFalseExpression.isUsingVariable(name)
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @declared {
			fragments.compile(@variable)

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
			let first = true

			@variable.walk(name => {
				if first {
					first = false
				}
				else {
					fragments.code(' && ')
				}

				fragments.code($runtime.type(this) + '.isValue(', name, ')')
			})
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