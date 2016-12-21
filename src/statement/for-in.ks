class ForInStatement extends Statement {
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
	$create(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let data = this._data
		
		this._value = $compile.expression(data.value, this)
		
		if !this._scope.hasVariable(data.variable.name) {
			$variable.define(this, this._scope, data.variable.name, $variable.kind(data.variable.type), data.variable.type)
			
			this._defineVariable = true
		}
		
		this._variable = $compile.expression(data.variable, this)
		
		if data.index {
			if data.index && (data.declaration || !this._scope.hasVariable(data.index.name)) {
				$variable.define(this, this._scope, data.index.name, $variable.kind(data.index.type), data.index.type)
				
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
		
		if !?this._index && !(data.index && !data.declaration && this.greatScope().hasVariable(data.index.name)) {
			this._indexName = this._scope.acquireTempName()
		}
		
		if !data.desc {
			this._boundName = this._scope.acquireTempName()
		}
		
		this._body = $compile.expression($block(data.body), this)
		
		this.greatScope().releaseTempName(this._valueName) if this._valueName?
		this._scope.releaseTempName(this._indexName) if this._indexName?
		this._scope.releaseTempName(this._boundName) if this._boundName?
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
				
				$variable.define(this, this.greatScope(), this._valueName, VariableKind::Variable)
			}
			
			line.code(this._valueName, $equals).compile(this._value).done()
		}
		
		let ctrl
		
		if data.desc {
			if data.index && !data.declaration && !this._defineIndex {
				fragments
					.newLine()
					.compile(this._index)
					.code($equals)
					.compile(this._valueName ?? this._value)
					.code('.length - 1')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(')
			}
			else {
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(this._indexName ?? this._index)
					.code($equals)
					.compile(this._valueName ?? this._value)
					.code('.length - 1')
			}
		}
		else {
			if data.index && !data.declaration && !this._defineIndex {
				fragments
					.newLine()
					.compile(this._index)
					.code(' = 0')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
			}
			else {
				ctrl = fragments
					.newControl()
					.code('for(', $variable.scope(this))
					.compile(this._indexName ?? this._index)
					.code(' = 0, ')
			}
			
			ctrl
				.code(this._boundName, $equals)
				.compile(this._valueName ?? this._value)
				.code('.length')
		}
		
		if data.declaration || this._defineVariable {
			ctrl.code($comma, data.variable.name)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compile(this._until).code(') && ')
		}
		else if data.while {
			ctrl.compile(this._while).code(' && ')
		}
		
		if data.desc {
			ctrl
				.compile(this._indexName ?? this._index)
				.code(' >= 0; --')
				.compile(this._indexName ?? this._index)
		}
		else {
			ctrl
				.compile(this._indexName ?? this._index)
				.code(' < ' + this._boundName + '; ++')
				.compile(this._indexName ?? this._index)
		}
		
		ctrl.code(')').step()
		
		ctrl
			.newLine()
			.compile(this._variable)
			.code($equals)
			.compile(this._valueName ?? this._value)
			.code('[')
			.compile(this._indexName ?? this._index)
			.code(']')
			.done()
		
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