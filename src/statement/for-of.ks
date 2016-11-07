class ForOfStatement extends Statement {
	private {
		_body
		_defineIndex	= false
		_defineVariable	= false
		_index
		_until
		_value
		_variable
		_when
		_while
	}
	ForOfStatement(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._value = $compile.expression(data.value, this)
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
			
			this._defineVariable = true
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			if data.index && (data.declaration || !this._scope.hasVariable(data.index.name)) {
				$variable.define(this._scope, data.index.name, $variable.kind(data.index.type), data.index.type)
				
				this._defineIndex = true
			}
			
			this._index = $compile.expression(data.index, this)
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
		
		if this._value.isEntangled() {
			this._valueName = this.greatScope().acquireTempName()
			
			this._scope.updateTempNames()
		}
		
		this._body = $compile.expression($block(data.body), this)
		
		this.greatScope().releaseTempName(this._valueName) if this._valueName?
	} // }}}
	fuse() { // {{{
		this._value.fuse()
		this._body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let data = this._data
		
		if this._valueName? {
			let line = fragments.newLine()
			
			if !this.greatScope().hasVariable(this._valueName) {
				line.code($variable.scope(this))
				
				$variable.define(this.greatScope(), this._valueName, VariableKind::Variable)
			}
			
			line.code(this._valueName, $equals).compile(this._value).done()
		}
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || this._defineVariable {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(this._variable).code(' in ').compile(this._valueName ?? this._value).code(')').step()
		
		if data.index {
			let line = ctrl.newLine()
			
			if data.declaration || this._defineIndex {
				line.code($variable.scope(this))
			}
			
			line.compile(this._index).code($equals).compile(this._valueName ?? this._value).code('[').compile(this._variable).code(']').done()
		}
		
		if data.until {
			ctrl
				.newControl()
				.code('if(')
				.compile(this._until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if data.while {
			ctrl
				.newControl()
				.code('if(!(')
				.compile(this._while)
				.code('))')
				.step()
				.line('break')
				.done()
		}
		
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