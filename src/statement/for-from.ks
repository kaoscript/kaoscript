class ForFromStatement extends Statement {
	private {
		_body
		_boundName
		_by
		_byName
		_defineVariable	= false
		_from
		_til
		_to
		_until
		_variable
		_when
		_while
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		if !@scope.hasVariable(@data.variable.name) {
			$variable.define(this, @scope, @data.variable.name, $variable.kind(@data.variable.type), @data.variable.type)
			
			@defineVariable = true
		}
		
		@variable = $compile.expression(@data.variable, this)
		@variable.analyse()
		
		@from = $compile.expression(@data.from, this)
		@from.analyse()
		
		if @data.til {
			@til = $compile.expression(@data.til, this)
			@til.analyse()
		}
		else {
			@to = $compile.expression(@data.to, this)
			@to.analyse()
		}
		
		if @data.by {
			@by = $compile.expression(@data.by, this)
			@by.analyse()
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
		@from.prepare()
		
		let context = @defineVariable ? null : this
		
		if @til? {
			@til.prepare()
			
			@boundName = @scope.acquireTempName(context) if @til.isComposite()
		}
		else {
			@to.prepare()
			
			@boundName = @scope.acquireTempName(context) if @to.isComposite()
		}
		
		if @by? {
			@by.prepare()
			
			@byName = @scope.acquireTempName(context) if @by.isComposite()
		}
		
		if @until? {
			@until.prepare()
		}
		else if @while? {
			@while.prepare()
		}
		
		@when.prepare() if @when?
		
		@body.prepare()
		
		@scope.releaseTempName(@boundName) if ?@boundName
		@scope.releaseTempName(@byName) if ?@byName
	} // }}}
	translate() { // {{{
		@from.translate()
		
		if @til? {
			@til.translate()
		}
		else {
			@to.translate()
		}
		
		@by.translate() if @by?
		
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
		let data = @data
		
		let ctrl = fragments.newControl().code('for(')
		
		if data.declaration || @defineVariable {
			ctrl.code($variable.scope(this))
		}
		ctrl.compile(@variable).code($equals).compile(@from)
		
		if @boundName? {
			ctrl.code($comma, @boundName, $equals).compile(@til ?? @to)
		}
		
		if @byName? {
			ctrl.code($comma, @byName, $equals).compile(@by)
		}
		
		ctrl.code('; ')
		
		if data.until {
			ctrl.code('!(').compileBoolean(@until).code(') && ')
		}
		else if data.while {
			ctrl.compileBoolean(@while).code(' && ')
		}
		
		ctrl.compile(@variable)
		
		let desc = (data.by && data.by.kind == NodeKind::NumericExpression && data.by.value < 0) || (data.from.kind == NodeKind::NumericExpression && ((data.to && data.to.kind == NodeKind::NumericExpression && data.from.value > data.to.value) || (data.til && data.til.kind == NodeKind::NumericExpression && data.from.value > data.til.value)))
		
		if data.til {
			if desc {
				ctrl.code(' > ')
			}
			else {
				ctrl.code(' < ')
			}
			
			ctrl.compile(@boundName ?? @til)
		}
		else {
			if desc {
				ctrl.code(' >= ')
			}
			else {
				ctrl.code(' <= ')
			}
			
			ctrl.compile(@boundName ?? @to)
		}
		
		ctrl.code('; ')
		
		if data.by {
			if data.by.kind == NodeKind::NumericExpression {
				if data.by.value == 1 {
					ctrl.code('++').compile(@variable)
				}
				else if data.by.value == -1 {
					ctrl.code('--').compile(@variable)
				}
				else if data.by.value >= 0 {
					ctrl.compile(@variable).code(' += ').compile(@by)
				}
				else {
					ctrl.compile(@variable).code(' -= ', -data.by.value)
				}
			}
			else {
				ctrl.compile(@variable).code(' += ').compile(@byName ?? @by)
			}
		}
		else if desc {
			ctrl.code('--').compile(@variable)
		}
		else {
			ctrl.code('++').compile(@variable)
		}
		
		ctrl.code(')').step()
		
		if data.when {
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