func $return(data?) { // {{{
	return {
		kind: Kind::ReturnStatement
		value: data
	}
} // }}}

class ArrayComprehensionForFrom extends Expression {
	private {
		_body
		_by			= null
		_from
		_to
		_variable
		_body
	}
	ArrayComprehensionForFrom(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		
		this._variable = $compile.expression(data.loop.variable, this)
		
		this._from = $compile.expression(data.loop.from, this)
		this._to = $compile.expression(data.loop.to ?? data.loop.til, this)
		this._by = $compile.expression(data.loop.by, this) if data.loop.by?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(this._from)
			.code($comma)
			.compile(this._to)
		
		if this._by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code($comma).compile(this._by)
		}
		
		fragments.code($comma, this._data.loop.from?, $comma, this._data.loop.to?, $comma)
		
		fragments
			.code('(')
			.compile(this._variable)
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayComprehensionForIn extends Expression {
	private {
		_body
		_index
		_value
		_variable
		_when
	}
	ArrayComprehensionForIn(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		$variable.define(this._scope, data.loop.index.name, VariableKind::Variable) if data.loop.index?
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._value = $compile.expression(data.loop.value, this)
		this._index = $compile.expression(data.loop.index, this) if data.loop.index?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._value.fuse()
		this._index.fuse() if this._index?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapArray(')
			.compile(this._value)
			.code(', ')
		
		fragments
			.code('(')
			.compile(this._variable)
		
		fragments.code($comma).compile(this._index) if this._index?
		
		fragments
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
			
			fragments.code($comma).compile(this._index) if this._index?
			
			fragments
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayComprehensionForOf extends Expression {
	private {
		_body
		_index
		_value
		_variable
		_when
	}
	ArrayComprehensionForOf(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		$variable.define(this._scope, data.loop.index.name, VariableKind::Variable) if data.loop.index?
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._value = $compile.expression(data.loop.value, this)
		this._index = $compile.expression(data.loop.index, this) if data.loop.index?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._value.fuse()
		this._index.fuse() if this._index?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapObject(')
			.compile(this._value)
			.code(', ')
		
		fragments
			.code('(')
			.compile(this._variable)
		
		fragments.code($comma).compile(this._index) if this._index?
		
		fragments
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
			
			fragments.code($comma).compile(this._index) if this._index?
			
			fragments
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}

class ArrayComprehensionForRange extends Expression {
	private {
		_body
		_by
		_from
		_to
		_variable
		_when
	}
	ArrayComprehensionForRange(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		$variable.define(this._scope, data.loop.variable.name, VariableKind::Variable)
		
		this._variable = $compile.expression(data.loop.variable, this)
		this._from = $compile.expression(data.loop.from, this)
		this._to = $compile.expression(data.loop.to, this)
		this._by = $compile.expression(data.loop.by, this) if data.loop.by?
		
		this._body = $compile.statement($return(data.body), this)
		this._body.analyse()
		
		if data.loop.when? {
			this._when = $compile.statement($return(data.loop.when), this)
			this._when.analyse()
		}
	} // }}}
	fuse() { // {{{
		this._variable.fuse()
		this._from.fuse()
		this._to.fuse()
		this._by.fuse() if this._by?
		this._body.fuse()
		this._when.fuse() if this._when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')
		
		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(this._from)
			.code($comma)
			.compile(this._to)
		
		if this._by? {
			fragments.code(', ').compile(this._by)
		}
		else {
			fragments.code(', 1')
		}
		
		fragments
			.code($comma)
			.code('(')
			.compile(this._variable)
			.code(') =>')
			.newBlock()
			.compile(this._body)
			.done()
		
		if this._when? {
			fragments
				.code($comma)
				.code('(')
				.compile(this._variable)
				.code(') =>')
				.newBlock()
				.compile(this._when)
				.done()
		}
		
		fragments.code(')')
	} // }}}
}