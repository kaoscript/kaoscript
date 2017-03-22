class ArrayExpression extends Expression {
	private {
		_values
	}
	analyse() { // {{{
		@values = []
		for value in @data.values {
			@values.push(value = $compile.expression(value, this))
			
			value.analyse()
		}
	} // }}}
	prepare() { // {{{
		for value in @values {
			value.prepare()
		}
	} // }}}
	translate() { // {{{
		for value in @values {
			value.translate()
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
		@from.analyse()
		
		@to = $compile.expression(@data.to ?? @data.til, this)
		@to.analyse()
		
		if @data.by? {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
		}
	} // }}}
	prepare() { // {{{
		@from.prepare()
		@to.prepare()
		@by.prepare() if @by?
	} // }}}
	translate() { // {{{
		@from.translate()
		@to.translate()
		@by.translate() if @by?
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