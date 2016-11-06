class UnlessExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	UnlessExpression(data, parent) { // {{{
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
				.compile(this._else)
				.code(' : ')
				.compile(this._then)
		}
		else {
			fragments
				.wrapBoolean(this._condition)
				.code(' ? undefined : ')
				.compile(this._then)
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		fragments
			.newControl()
			.code('if(!')
			.wrapBoolean(this._condition)
			.code(')')
			.step()
			.line(this._then)
			.done()
	} // }}}
}