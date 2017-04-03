class ForInStatement extends Statement {
	private {
		_body
		_boundName: String
		_defineIndex: Boolean	= false
		_defineValue: Boolean	= false
		_expression
		_expressionName: String
		_index
		_indexName: String
		_indexVariable: Variable
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
		
		if @data.value? {
			if @data.declaration || !@scope.hasVariable(@data.value.name) {
				@valueVariable = @scope.define(@data.value.name, false, this)
				
				@defineValue = true
			}
			
			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}
		
		if @data.index? {
			if @data.declaration || !@scope.hasVariable(@data.index.name) {
				@indexVariable = @scope.define(@data.index.name, false, @scope.reference('Number'), this)
				
				@defineIndex = true
			}
			
			@index = $compile.expression(@data.index, this)
			@index.analyse()
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
		
		if @expression.isEntangled() {
			@expressionName = this.greatScope().acquireTempName()
			
			@scope.updateTempNames()
		}
		
		if @defineValue {
			@valueVariable.type(@expression.type().parameter())
		}
		
		if !?@index && !(@data.index? && !@data.declaration && this.greatScope().hasVariable(@data.index.name)) {
			@indexName = @scope.acquireTempName()
		}
		
		if !@data.desc {
			@boundName = @scope.acquireTempName()
		}
		
		if @until? {
			@until.prepare()
		}
		else if @while? {
			@while.prepare()
		}
		
		if @when? {
			@when.prepare()
			
			@when.acquireReusable(false)
			@when.releaseReusable()
		}
		
		@body.prepare()
		
		this.greatScope().releaseTempName(@expressionName) if @expressionName?
		@scope.releaseTempName(@indexName) if @indexName?
		@scope.releaseTempName(@boundName) if @boundName?
	} // }}}
	translate() { // {{{
		@expression.translate()
		
		@value.translate() if @value?
		
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
		
		let ctrl
		
		if @data.desc {
			if @index? && !@data.declaration && !@defineIndex {
				fragments
					.newLine()
					.compile(@index)
					.code($equals)
					.compile(@expressionName ?? @expression)
					.code('.length - 1')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(')
			}
			else {
				ctrl = fragments
					.newControl()
					.code('for(', $runtime.scope(this))
					.compile(@indexName ?? @index)
					.code($equals)
					.compile(@expressionName ?? @expression)
					.code('.length - 1')
			}
		}
		else {
			if @index && !@data.declaration && !@defineIndex {
				fragments
					.newLine()
					.compile(@index)
					.code(' = 0')
					.done()
				
				ctrl = fragments
					.newControl()
					.code('for(', $runtime.scope(this))
			}
			else {
				ctrl = fragments
					.newControl()
					.code('for(', $runtime.scope(this))
					.compile(@indexName ?? @index)
					.code(' = 0, ')
			}
			
			ctrl
				.code(@boundName, $equals)
				.compile(@expressionName ?? @expression)
				.code('.length')
		}
		
		if @data.declaration || @defineValue {
			ctrl.code($comma).compile(@value)
		}
		
		ctrl.code('; ')
		
		if @until? {
			ctrl.code('!(').compile(@until).code(') && ')
		}
		else if @while? {
			ctrl.compile(@while).code(' && ')
		}
		
		if @data.desc {
			ctrl
				.compile(@indexName ?? @index)
				.code(' >= 0; --')
				.compile(@indexName ?? @index)
		}
		else {
			ctrl
				.compile(@indexName ?? @index)
				.code(' < ' + @boundName + '; ++')
				.compile(@indexName ?? @index)
		}
		
		ctrl.code(')').step()
		
		if @value? {
			ctrl
				.newLine()
				.compile(@value)
				.code($equals)
				.compile(@expressionName ?? @expression)
				.code('[')
				.compile(@indexName ?? @index)
				.code(']')
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