class ForOfStatement extends Statement {
	private {
		_body
		_defineKey		= false
		_defineValue	= false
		_expression
		_expressionName
		_key
		_keyName
		_until
		_value
		_when
		_while
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		@expression = $compile.expression(@data.expression, this)
		@expression.analyse()
		
		if @data.key? {
			if @data.declaration || !@scope.hasVariable(@data.key.name) {
				$variable.define(this, @scope, @data.key.name, false, $variable.kind(@data.key.type), @data.key.type)
				
				@defineKey = true
			}
			
			@key = $compile.expression(@data.key, this)
			@key.analyse()
		}
		
		if @data.value? {
			if @data.declaration || !@scope.hasVariable(@data.value.name) {
				$variable.define(this, @scope, @data.value.name, false, $variable.kind(@data.value.type), @data.value.type)
				
				@defineValue = true
			}
		
			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}
		
		if @data.until {
			@until = $compile.expression(@data.until, this)
			@until.analyse()
		}
		else if @data.while {
			@while = $compile.expression(@data.while, this)
			@while.analyse()
		}
		
		if @data.when {
			@when = $compile.expression(@data.when, this)
			@when.analyse()
		}
		
		@body = $compile.expression($block(@data.body), this)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()
		
		if @expression.isEntangled() {
			@expressionName = this.greatScope().acquireTempName()
			
			@scope.updateTempNames()
		}
		
		if @key? {
			@key.prepare()
		}
		else {
			@keyName = @scope.acquireTempName()
		}
		
		if @until? {
			@until.prepare()
		}
		else if @while? {
			@while.prepare()
		}
		
		@when.prepare() if @when?
		
		@body.prepare()
		
		this.greatScope().releaseTempName(@expressionName) if @expressionName?
		@scope.releaseTempName(@keyName) if @keyName?
	} // }}}
	translate() { // {{{
		@expression.translate()
		
		@key.translate() if @key?
		
		if @until? {
			@until.translate()
		}
		else if @while? {
			@while.translate()
		}
		
		@when.translate() if @when?
		
		@body.translate()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		if @expressionName? {
			let line = fragments.newLine()
			
			if !this.greatScope().hasVariable(@expressionName) {
				line.code($variable.scope(this))
				
				$variable.define(this, this.greatScope(), @expressionName, false, VariableKind::Variable)
			}
			
			line.code(@expressionName, $equals).compile(@expression).done()
		}
		
		let ctrl = fragments.newControl().code('for(')
		
		if @key? {
			if @data.declaration || @defineKey {
				ctrl.code($variable.scope(this))
			}
			
			ctrl.compile(@key)
		}
		else {
			ctrl.code($variable.scope(this), @keyName)
		}
		
		ctrl.code(' in ').compile(@expressionName ?? @expression).code(')').step()
		
		if @value? {
			let line = ctrl.newLine()
			
			if @data.declaration || @defineValue {
				line.code($variable.scope(this))
			}
			
			line.compile(@value).code($equals).compile(@expressionName ?? @expression).code('[').compile(@key ?? @keyName).code(']').done()
		}
		
		if @until? {
			ctrl
				.newControl()
				.code('if(')
				.compile(@until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if @while? {
			ctrl
				.newControl()
				.code('if(!(')
				.compile(@while)
				.code('))')
				.step()
				.line('break')
				.done()
		}
		
		if @when? {
			ctrl
				.newControl()
				.code('if(')
				.compileBoolean(@when)
				.code(')')
				.step()
				.compile(@body)
				.done()
		}
		else {
			ctrl.compile(@body)
		}
		
		ctrl.done()
	} // }}}
}