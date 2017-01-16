class ConditionalExpression extends Expression {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._whenTrue = $compile.expression(this._data.whenTrue, this)
		this._whenFalse = $compile.expression(this._data.whenFalse, this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._whenTrue.fuse()
		this._whenFalse.fuse()
	} // }}}
	isComputed() => true
	toFragments(fragments, mode) { // {{{
		fragments
			.wrapBoolean(this._condition)
			.code(' ? ')
			.compile(this._whenTrue)
			.code(' : ')
			.compile(this._whenFalse)
	} // }}}
}