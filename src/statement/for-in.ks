class ForInStatement extends Statement {
	private {
		_body
		_boundName: String
		_defineIndex: Boolean	= false
		_defineValue: Boolean	= false
		_expression
		_expressionName: String
		_from
		_index
		_indexName: String
		_indexVariable: Variable
		_until
		_value
		_valueVariable: Variable
		_when
		_while
		_til
		_to
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
		
		if @data.from? {
			@from = $compile.expression(@data.from, this)
			@from.analyse()
		}
		
		if @data.til? {
			@til = $compile.expression(@data.til, this)
			@til.analyse()
		}
		else if @data.to? {
			@to = $compile.expression(@data.to, this)
			@to.analyse()
		}
		
		if @data.until? {
			@until = $compile.expression(@data.until, this)
			@until.analyse()
		}
		else if @data.while? {
			@while = $compile.expression(@data.while, this)
			@while.analyse()
		}
		
		if @data.when? {
			@when = $compile.expression(@data.when, this)
			@when.analyse()
		}
		
		@body = $compile.expression($ast.block(@data.body), this)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()
		
		const type = @expression.type()
		if !(type.isAny() || type.isArray()) {
			TypeException.throwInvalidForInExpression(this)
		}
		
		if @expression.isEntangled() {
			@expressionName = this.greatScope().acquireTempName()
			
			@scope.updateTempNames()
		}
		
		if @defineValue {
			@valueVariable.type(type.parameter())
		}
		
		if !?@index && !(@data.index? && !@data.declaration && this.greatScope().hasVariable(@data.index.name)) {
			@indexName = @scope.acquireTempName()
		}
		
		@boundName = @scope.acquireTempName()
		
		if @from? {
			@from.prepare()
		}
		
		if @til? {
			@til.prepare()
		}
		else if @to? {
			@to.prepare()
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
		@scope.releaseTempName(@boundName)
	} // }}}
	translate() { // {{{
		@expression.translate()
		
		if @value? {
			@value.translate()
		}
		
		if @from? {
			@from.translate()
		}
		
		if @til? {
			@til.translate()
		}
		else if @to? {
			@to.translate()
		}
		
		if @until? {
			@until.translate()
		}
		else if @while? {
			@while.translate()
		}
		
		if @when? {
			@when.translate()
		}
		
		@body.translate()
	} // }}}
	toBoundFragments(fragments) { // {{{
		if @data.desc {
			if @from? {
				if @from is NumberLiteral && @from.value() < 0 {
					fragments
						.code('Math.max(0, ')
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@from.value()))`)
				}
				else {
					fragments.compile(@from)
				}
			}
			else {
				fragments.code('0')
			}
		}
		else {
			if @til? {
				if @til is NumberLiteral && @til.value() < 0 {
					fragments
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@til.value())`)
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@til)
						.code(')')
				}
			}
			else if @to? {
				if @to is NumberLiteral {
					if @to.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(-@to.value() - 1)`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length, \(@to.value() + 1))`)
					}
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@to)
						.code(' + 1)')
				}
			}
			else {
				fragments
					.compile(@expressionName ?? @expression)
					.code('.length')
			}
		}
	} // }}}
	toFromFragments(fragments) { // {{{
		if @data.desc {
			if @til? {
				if @til is NumberLiteral && @til.value() < 0 {
					fragments
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@til.value() + 1)`)
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@til)
						.code(') - 1')
				}
			}
			else if @to? {
				if @to is NumberLiteral {
					if @to.value() < 0 {
						fragments
							.compile(@expressionName ?? @expression)
							.code(`.length - \(-@to.value())`)
					}
					else {
						fragments
							.code('Math.min(')
							.compile(@expressionName ?? @expression)
							.code(`.length, \(@to.value()))`)
					}
				}
				else {
					fragments
						.code('Math.min(')
						.compile(@expressionName ?? @expression)
						.code('.length, ')
						.compile(@to)
						.code(')')
				}
			}
			else {
				fragments
					.compile(@expressionName ?? @expression)
					.code('.length - 1')
			}
		}
		else {
			if @from? {
				if @from is NumberLiteral && @from.value() < 0 {
					fragments
						.code('Math.max(0, ')
						.compile(@expressionName ?? @expression)
						.code(`.length - \(-@from.value()))`)
				}
				else {
					fragments.compile(@from)
				}
			}
			else {
				fragments.code('0')
			}
		}
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
		
		if @index && !@data.declaration && !@defineIndex {
			const line = fragments
				.newLine()
				.compile(@index)
				.code($equals)
			
			this.toFromFragments(line)
			
			line.done()
			
			ctrl = fragments
				.newControl()
				.code('for(', $runtime.scope(this))
		}
		else {
			ctrl = fragments
				.newControl()
				.code('for(', $runtime.scope(this))
				.compile(@indexName ?? @index)
				.code($equals)
			
			this.toFromFragments(ctrl)
			
			ctrl.code($comma)
		}
		
		ctrl.code(@boundName, $equals)
		
		this.toBoundFragments(ctrl)
		
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
				.code(' >= ' + @boundName + '; --')
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