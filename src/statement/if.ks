class IfStatement extends Statement {
	private {
		_condition
		_whenFalse
		_whenTrue
	}
	analyse() { // {{{
		let scope = @scope
		
		@condition = $compile.expression(@data.condition, this)
		
		@scope = this.newScope()
		
		@whenTrue = $compile.expression($block(@data.whenTrue), this)
		
		if @data.whenFalse? {
			@scope = this.newScope()
			
			if @data.whenFalse.kind == NodeKind::IfStatement {
				@whenFalse = $compile.statement(@data.whenFalse, this)
				@whenFalse.analyse()
			}
			else {
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
}
/* class IfStatement extends Statement {
	private {
		_items	= []
	}
	analyse() { // {{{
		let data = this._data
		
		this._items.push(new IfClause(data, this))
		
		/* for elseif in data.elseifs {
			this._items.push(new IfElseClause(elseif, this))
		} */
		
		this._items.push(new ElseClause(data.whenFalse, this)) if data.whenFalse?
	} // }}}
	fuse() { // {{{
		for item in this._items {
			item.fuse()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl()
		
		for item, index in this._items {
			ctrl.step() if index
			
			item.toFragments(ctrl, mode)
		}
		
		ctrl.done()
	} // }}}
}

class IfClause extends AbstractNode {
	private {
		_condition
		_body
	}
	$create(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression($block(this._data.whenTrue), this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('if(')
		
		if this._condition.isAssignable() {
			fragments.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			fragments.compileBoolean(this._condition)
		}
		
		fragments.code(')').step().compile(this._body, mode)
	} // }}}
}

/* class IfElseClause extends AbstractNode {
	private {
		_condition
		_body
	}
	$create(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._condition = $compile.expression(this._data.condition, this)
		this._body = $compile.expression($block(this._data.body), this)
	} // }}}
	fuse() { // {{{
		this._condition.fuse()
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('else if(')
		
		if this._condition.isAssignable() {
			fragments.code('(').compileBoolean(this._condition).code(')')
		}
		else {
			fragments.compileBoolean(this._condition)
		}
		
		fragments.code(')').step().compile(this._body)
	} // }}}
} */

class ElseClause extends AbstractNode {
	private {
		_condition
		_body
	}
	$create(data, parent) { // {{{
		super(data, parent, parent.newScope())
		
		this.analyse()
	} // }}}
	analyse() { // {{{
		this._body = $compile.expression($block(this._data), this)
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('else').step().compile(this._body)
	} // }}}
} */