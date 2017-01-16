class IfExpression extends Expression {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._whenTrue = $compile.expression(this._data.whenTrue, this)
		this._whenFalse = $compile.expression(this._data.whenFalse, this) if this._data.whenFalse?
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._whenTrue.fuse()
		this._whenFalse.fuse() if this._whenFalse?
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		if this._whenFalse? {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._whenTrue)
				.code(' : ')
				.compile(this._whenFalse)
		}
		else {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._whenTrue)
				.code(' : undefined')
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		ctrl.code('if(')
		
		if this._condition.isAssignable() {
			ctrl.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			ctrl.compileBoolean(this._condition)
		}
		
		ctrl.code(')').step().line(this._whenTrue).done()
	} // }}}
}