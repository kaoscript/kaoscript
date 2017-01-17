class IfStatement extends Statement {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		let scope = @scope
		
		@condition = $compile.expression(@data.condition, this)
		
		@scope = this.newScope(scope)
		
		@whenTrue = $compile.expression($block(@data.whenTrue), this)
		
		if @data.whenFalse? {
			if @data.whenFalse.kind == NodeKind::IfStatement {
				@scope = scope
				
				@whenFalse = $compile.statement(@data.whenFalse, this)
				@whenFalse.analyse()
			}
			else {
				@scope = this.newScope(scope)
				
				@whenFalse = $compile.expression($block(@data.whenFalse), this)
			}
		}
		
		@scope = scope
	} // }}}
	fuse() { // {{{
		@condition.fuse()
		@whenTrue.fuse()
		@whenFalse.fuse() if @whenFalse?
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
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