class ForFromStatement extends Statement {
	private {
		_body
		_by
		_defineVariable	= false
		_til
		_to
		_until
		_variable
		_when
		_while
	}
	$create(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this, this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
			
			this._defineVariable = true
		}
		
		this._variable = $compile.expression(data.variable, this)
		this._from = $compile.expression(data.from, this)
		
		if data.til {
			this._til = $compile.expression(data.til, this)
			
			this._boundName = this._scope.acquireTempName() if this._til.isComposite()
		}
		else {
			this._to = $compile.expression(data.to, this)
			
			this._boundName = this._scope.acquireTempName() if this._to.isComposite()
		}
		
		if data.by {
			this._by = $compile.expression(data.by, this)
			
			this._byName = this._scope.acquireTempName() if this._by.isComposite()
		}
		
		if data.until {
			this._until = $compile.expression(data.until, this)
		}
		else if data.while {
			this._while = $compile.expression(data.while, this)
		}
		
		if data.when {
			this._when = $compile.expression(data.when, this)
		}
		
		this._body = $compile.expression($block(data.body), this)
		
		this._scope.releaseTempName(this._boundName) if ?this._boundName
		this._scope.releaseTempName(this._byName) if ?this._byName
	} // }}}
	fuse() { // {{{
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || this._defineVariable {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code($equals).compile(this._from)
		
		if this._boundName? {
			ctrl.code($comma, this._boundName, $equals).compile(this._til ?? this._to)
		}
		
		if this._byName? {
			ctrl.code($comma, this._byName, $equals).compile(this._by)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compileBoolean(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compileBoolean(this._while).code(' && ')
		}
		
		ctrl.compile(this._variable)
		
		let desc = (data.by && data.by.kind == Kind::NumericExpression && data.by.value < 0) || (data.from.kind == Kind::NumericExpression && ((data.to && data.to.kind == Kind::NumericExpression && data.from.value > data.to.value) || (data.til && data.til.kind == Kind::NumericExpression && data.from.value > data.til.value)))
		
		if data.til {
			if desc {
				ctrl.code(' > ')
			}
			else {
				ctrl.code(' < ')
			}
			
			ctrl.compile(this._boundName ?? this._til)
		}
		else {
			if desc {
				ctrl.code(' >= ')
			}
			else {
				ctrl.code(' <= ')
			}
			
			ctrl.compile(this._boundName ?? this._to)
		}
		
		ctrl.code('; ')
		
		if data.by {
			if data.by.kind == Kind::NumericExpression {
				if data.by.value == 1 {
					ctrl.code('++').compile(this._variable)
				}
				else if data.by.value == -1 {
					ctrl.code('--').compile(this._variable)
				}
				else if data.by.value >= 0 {
					ctrl.compile(this._variable).code(' += ').compile(this._by)
				}
				else {
					ctrl.compile(this._variable).code(' -= ', -data.by.value)
				}
			}
			else {
				ctrl.compile(this._variable).code(' += ').compile(this._byName ?? this._by)
			}
		}
		else if desc {
			ctrl.code('--').compile(this._variable)
		}
		else {
			ctrl.code('++').compile(this._variable)
		}
		
		ctrl.code(')').step()
		
		if data.when {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(this._when)
				.code(')')
				.step()
				.compile(this._body)
				.done()
		}
		else {
			ctrl.compile(this._body)
		}
		
		ctrl.done()
	} // }}}
}