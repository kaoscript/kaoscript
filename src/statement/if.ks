class IfStatement extends Statement {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		const scope = @scope
		
		@condition = $compile.expression(@data.condition, this)
		@condition.analyse()
		
		@scope = this.newScope(scope)
		
		@whenTrue = $compile.expression($ast.block(@data.whenTrue), this)
		@whenTrue.analyse()
		
		if @data.whenFalse? {
			if @data.whenFalse.kind == NodeKind::IfStatement {
				@scope = scope
				
				@whenFalse = $compile.statement(@data.whenFalse, this)
				@whenFalse.analyse()
			}
			else {
				@scope = this.newScope(scope)
				
				@whenFalse = $compile.expression($ast.block(@data.whenFalse), this)
				@whenFalse.analyse()
			}
		}
		
		@scope = scope
	} // }}}
	prepare() { // {{{
		@condition.prepare()
		
		@condition.acquireReusable(false)
		@condition.releaseReusable()
		
		@whenTrue.prepare()
		@whenFalse.prepare() if @whenFalse?
	} // }}}
	translate() { // {{{
		@condition.translate()
		@whenTrue.translate()
		@whenFalse.translate() if @whenFalse?
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
		
		fragments.code(')').step().compile(@whenTrue, mode)
		
		if @whenFalse? {
			if @whenFalse is IfStatement {
				fragments.step().code('else ')
				
				@whenFalse.toIfFragments(fragments, mode)
			}
			else {
				fragments.step().code('else').step().compile(@whenFalse, mode)
			}
		}
	} // }}}
	variables() { // {{{
		if @whenFalse is IfStatement {
			return [].concat(@variables, @whenFalse.variables())
		}
		else {
			return @variables
		}
	} // }}}
}