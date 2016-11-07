class ArrayExpression extends Expression {
	private {
		_values
	}
	analyse() { // {{{
		this._values = [$compile.expression(value, this) for value in this._data.values]
	} // }}}
	fuse() { // {{{
		for value in this._values {
			value.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('[')
		
		for value, index in this._values {
			fragments.code($comma) if index
			
			fragments.compile(value)
		}
		
		fragments.code(']')
	} // }}}
}

class ArrayRange extends Expression {
	private {
		_by = null
		_from
		_to
	}
	analyse() { // {{{
		let data = this._data
		
		this._from = $compile.expression(data.from ?? data.then, this)
		this._to = $compile.expression(data.to ?? data.til, this)
		this._by = $compile.expression(data.by, this) if data.by?
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.newArrayRange(')
			.compile(this._from)
			.code(', ')
			.compile(this._to)
		
		if this._by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code(', ').compile(this._by)
		}
		
		fragments.code(', ', !!this._data.from, ', ', !!this._data.to, ')')
	} // }}}
}