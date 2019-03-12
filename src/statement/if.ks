class IfStatement extends Statement {
	private {
		_bindingScope
		_condition
		_whenFalseExpression
		_whenFalseScope: AbstractScope
		_whenTrueExpression
		_whenTrueScope: AbstractScope
	}
	analyse() { // {{{
		if @data.condition.kind == NodeKind::VariableDeclaration {
			@bindingScope = new BleedingScope(this)

			@condition = new IfVariableDeclarationExpression(@data.condition, this, @bindingScope)

			@whenTrueScope = this.newScope(@bindingScope)
		}
		else {
			@whenTrueScope = this.newScope(@scope)
			@bindingScope = @whenTrueScope

			@condition = $compile.expression(@data.condition, this)
		}

		@condition.analyse()

		@whenTrueExpression = $compile.expression($ast.block(@data.whenTrue), this, @whenTrueScope)
		@whenTrueExpression.analyse()

		if @data.whenFalse? {
			if @data.whenFalse.kind == NodeKind::IfStatement {
				@whenFalseExpression = $compile.statement(@data.whenFalse, this)
				@whenFalseExpression.analyse()
			}
			else {
				@whenFalseScope = this.newScope(@scope)

				@whenFalseExpression = $compile.expression($ast.block(@data.whenFalse), this, @whenFalseScope)
				@whenFalseExpression.analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		@condition.prepare()

		for name, type of @condition.reduceTypes() {
			@whenTrueScope.define(name, true, type, this)
		}

		@condition.acquireReusable(false)
		@condition.releaseReusable()

		@whenTrueExpression.prepare()
		@whenFalseExpression.prepare() if @whenFalseExpression?
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenTrueExpression.translate()
		@whenFalseExpression.translate() if @whenFalseExpression?
	} // }}}
	assignments() { // {{{
		if @whenFalseExpression is IfStatement {
			return [].concat(@assignments, @whenFalseExpression.assignments())
		}
		else {
			return @assignments
		}
	} // }}}
	bindingScope() => @bindingScope
	declareVariable(name: String) { // {{{
		@assignments.push(name)
	} // }}}
	isExit() => @whenFalseExpression? && @whenTrueExpression.isExit() && @whenFalseExpression.isExit()
	isReturning(type: Type) { // {{{
		if @whenFalseExpression {
			return @whenTrueExpression.isReturning(type) && @whenFalseExpression.isReturning(type)
		}
		else {
			return @whenTrueExpression.isReturning(type)
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		const ctrl = fragments.newControl()

		@toIfFragments(ctrl, mode)

		ctrl.done()
	} // }}}
	toIfFragments(fragments, mode) { // {{{
		fragments.code('if(')

		if @condition.isAssignable() {
			fragments.code('(').compileBoolean(@condition).code(')')
		}
		else {
			fragments.compileBoolean(@condition)
		}

		fragments.code(')').step().compile(@whenTrueExpression, mode)

		if @whenFalseExpression? {
			if @whenFalseExpression is IfStatement {
				fragments.step().code('else ')

				@whenFalseExpression.toIfFragments(fragments, mode)
			}
			else {
				fragments.step().code('else').step().compile(@whenFalseExpression, mode)
			}
		}
	} // }}}
}