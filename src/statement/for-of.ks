class ForOfStatement extends Statement {
	private {
		_body
		_defineKey: Boolean		= false
		_defineValue: Boolean	= false
		_expression
		_expressionName: String
		_key
		_keyName: String
		_keyVariable: Variable
		_until
		_value
		_valueVariable: Variable
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
				@keyVariable = @scope.define(@data.key.name, false, @scope.reference('String'), this)
				
				@defineKey = true
			}
			
			@key = $compile.expression(@data.key, this)
			@key.analyse()
		}
		
		if @data.value? {
			if @data.declaration || !@scope.hasVariable(@data.value.name) {
				@valueVariable = @scope.define(@data.value.name, false, this)
				
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
		
		@body = $compile.expression($ast.block(@data.body), this)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()
		
		const type = @expression.type()
		if !(type.isAny() || type.isObject()) {
			TypeException.throwInvalidForOfExpression(this)
		}
		
		if @expression.isEntangled() {
			@expressionName = this.greatScope().acquireTempName()
			
			@scope.updateTempNames()
		}
		
		if @defineValue {
			@valueVariable.type(type.parameter())
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
				line.code($runtime.scope(this))
				
				this.greatScope().define(@expressionName, false, this)
			}
			
			line.code(@expressionName, $equals).compile(@expression).done()
		}
		
		let ctrl = fragments.newControl().code('for(')
		
		if @key? {
			if @data.declaration || @defineKey {
				ctrl.code($runtime.scope(this))
			}
			
			ctrl.compile(@key)
		}
		else {
			ctrl.code($runtime.scope(this), @keyName)
		}
		
		ctrl.code(' in ').compile(@expressionName ?? @expression).code(')').step()
		
		if @value? {
			let line = ctrl.newLine()
			
			if @data.declaration || @defineValue {
				line.code($runtime.scope(this))
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