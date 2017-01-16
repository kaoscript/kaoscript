class ArrayExpression extends Expression {
	private {
		_values
	}
	analyse() { // {{{
		@values = [$compile.expression(value, this) for value in @data.values]
	} // }}}
	fuse() { // {{{
		for value in @values {
			value.fuse()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('[')
		
		for value, index in @values {
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
		@from = $compile.expression(@data.from ?? @data.then, this)
		@to = $compile.expression(@data.to ?? @data.til, this)
		@by = $compile.expression(@data.by, this) if @data.by?
	} // }}}
	fuse() { // {{{
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.newArrayRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)
		
		if @by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code(', ').compile(@by)
		}
		
		fragments.code($comma, @data.from?, $comma, @data.to?, ')')
	} // }}}
}