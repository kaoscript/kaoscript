class IfExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	IfExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
		this._else = $compile.expression(this._data.else, this) if this._data.else?
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
		this._else.fuse() if this._else?
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		if this._else? {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._then)
				.code(' : ')
				.compile(this._else)
		}
		else {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? ')
				.compile(this._then)
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
		
		ctrl.code(')').step().line(this._then).done()
	} // }}}
}