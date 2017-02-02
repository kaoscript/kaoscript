class ForRangeStatement extends Statement {
	private {
		_body
		_boundName
		_by
		_byName
		_defineValue	= false
		_from
		_til
		_to
		_until
		_value
		_when
		_while
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		if !@scope.hasVariable(@data.value.name) {
			$variable.define(this, @scope, @data.value.name, $variable.kind(@data.value.type), @data.value.type)
			
			@defineValue = true
		}
		
		@value = $compile.expression(@data.value, this)
		@from = $compile.expression(@data.from, this)
		
		@to = $compile.expression(@data.to, this)
		@boundName = @scope.acquireTempName() if @to.isComposite()
		
		if @data.by {
			@by = $compile.expression(@data.by, this)
			
			@byName = @scope.acquireTempName() if @by.isComposite()
		}
		
		if @data.until {
			@until = $compile.expression(@data.until, this)
		}
		else if @data.while {
			@while = $compile.expression(@data.while, this)
		}
		
		if @data.when {
			@when = $compile.expression(@data.when, this)
		}
		
		@body = $compile.expression($block(@data.body), this)
		
		@scope.releaseTempName(@boundName) if @boundName?
		@scope.releaseTempName(@byName) if @byName?
	} // }}}
	fuse() { // {{{
		@body.fuse()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl().code('for(')
		if @data.declaration || @defineValue {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(@value).code($equals).compile(@from)
		
		if @boundName? {
			ctrl.code(@boundName, $equals).compile(@to)
		}
		
		if @byName? {
			ctrl.code($comma, @byName, $equals).compile(@by)
		}
		
		ctrl.code('; ')
		
		if @data.until {
			ctrl.code('!(').compile(@until).code(') && ')
		}
		else if @data.while {
			ctrl.compile(@while).code(' && ')
		}
		
		ctrl.compile(@value).code(' <= ').compile(@boundName ?? @to).code('; ')
		
		if @data.by {
			if @data.by.kind == NodeKind::NumericExpression {
				if @data.by.value == 1 {
					ctrl.code('++').compile(@value)
				}
				else {
					ctrl.compile(@value).code(' += ').compile(@by)
				}
			}
			else {
				ctrl.compile(@value).code(' += ').compile(@byName ?? @by)
			}
		}
		else {
			ctrl.code('++').compile(@value)
		}
		
		ctrl.code(')').step()
		
		if @data.when {
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