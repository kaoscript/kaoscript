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

		@whenTrueExpression = $compile.block(@data.whenTrue, this, @whenTrueScope)
		@whenTrueExpression.analyse()

		if @data.whenFalse? {
			@whenFalseScope = this.newScope(@scope, ScopeType::InlineBlock)

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
		}
		else {
			@condition.prepare()

			for const type, name of @condition.reduceTypes() {
				@whenTrueScope.replaceVariable(name, type, this)
			}

			@condition.acquireReusable(false)
			@condition.releaseReusable()
		}

		this.assignTempVariables(@bindingScope)

		@whenTrueExpression.prepare()

		if @whenFalseExpression == null {
			if @whenTrueExpression.isExit() {
				if !@declared {
					for const type, name of @condition.reduceContraryTypes() {
						@scope.replaceVariable(name, type, this)
					}
				}
			}
		}
		else {
			if !@declared {
				for const type, name of @condition.reduceContraryTypes() {
					@whenFalseScope.replaceVariable(name, type, this)
				}
			}

			@whenFalseExpression.prepare()

			const trueVariables = @whenTrueScope.listReplacedVariables()
			const falseVariables = @whenFalseScope.listReplacedVariables()

			for const :name of trueVariables when falseVariables[name]? {
				const trueType = trueVariables[name].getRealType()
				const falseType = falseVariables[name].getRealType()

				if trueType.equals(falseType) {
					@scope.replaceVariable(name, trueType, this)
				}
				else {
					@scope.replaceVariable(name, Type.union(@scope, trueType, falseType), this)
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
	toStatementFragments(fragments, mode) { // {{{
		if @declared {
			fragments.compile(@variable)

			const ctrl = fragments.newControl()

			@toIfFragments(ctrl, mode)

			ctrl.done()
		}
		else {
			const ctrl = fragments.newControl()

			@toIfFragments(ctrl, mode)

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