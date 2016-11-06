class TernaryConditionalExpression extends Expression {
	private {
		_condition
		_else
		_then
	}
	TernaryConditionalExpression(data, parent) { // {{{
		super(data, parent)
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._then = $compile.expression(this._data.then, this)
		this._else = $compile.expression(this._data.else, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._then.fuse()
		this._else.fuse()
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(this._condition)
			.code(' ? ')
			.compile(this._then)
			.code(' : ')
			.compile(this._else)
	} // }}}
}