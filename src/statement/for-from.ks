class ForFromStatement extends Statement {
	private {
		_body
		_boundName: String
		_by
		_byName: String
		_defineVariable: Boolean		= false
		_from
		_immutableVariable: Boolean		= false
		_til
		_to
		_until
		_variable
		_variableVariable: Variable
		_when
		_while
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let rename = false
		const variable = @scope.getVariable(@data.variable.name)

		@defineVariable = @data.declaration || variable == null
		@immutableVariable = @data.declaration && !@data.rebindable

		@from = $compile.expression(@data.from, this, @parent.scope())
		@from.analyse()

		if @from.isUsingVariable(@data.variable.name) {
			if @defineVariable {
				rename = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
			}
		}

		if @data.til {
			@til = $compile.expression(@data.til, this, @parent.scope())
			@til.analyse()

			if @til.isUsingVariable(@data.variable.name) {
				if @defineVariable {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}
		else {
			@to = $compile.expression(@data.to, this, @parent.scope())
			@to.analyse()

			if @to.isUsingVariable(@data.variable.name) {
				if @defineVariable {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @data.by {
			@by = $compile.expression(@data.by, this, @parent.scope())
			@by.analyse()

			if @by.isUsingVariable(@data.variable.name) {
				if @defineVariable {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @defineVariable {
			@variableVariable = @scope.define(@data.variable.name, @immutableVariable, @scope.reference('Number'), this)

			if rename {
				@scope.rename(@data.variable.name)
			}
		}
		else if variable.isImmutable() {
			ReferenceException.throwImmutable(@data.variable.name, this)
		}

		@variable = $compile.expression(@data.variable, this)
		@variable.analyse()

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
		@variable.prepare()

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
		@variable.translate()
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
		let ctrl = fragments.newControl().code('for(')

		if @defineVariable {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@variable).code($equals).compile(@from)

		if @boundName? {
			ctrl.code($comma, @boundName, $equals).compile(@til ?? @to)
		}

		if @byName? {
			ctrl.code($comma, @byName, $equals).compile(@by)
		}

		ctrl.code('; ')

		if @data.until {
			ctrl.code('!(').compileBoolean(@until).code(') && ')
		}
		else if @data.while {
			ctrl.compileBoolean(@while).code(' && ')
		}

		ctrl.compile(@variable)

		let desc = (@data.by && @data.by.kind == NodeKind::NumericExpression && @data.by.value < 0) || (@data.from.kind == NodeKind::NumericExpression && ((@data.to && @data.to.kind == NodeKind::NumericExpression && @data.from.value > @data.to.value) || (@data.til && @data.til.kind == NodeKind::NumericExpression && @data.from.value > @data.til.value)))

		if @data.til {
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

		if @data.by {
			if @data.by.kind == NodeKind::NumericExpression {
				if @data.by.value == 1 {
					ctrl.code('++').compile(@variable)
				}
				else if @data.by.value == -1 {
					ctrl.code('--').compile(@variable)
				}
				else if @data.by.value >= 0 {
					ctrl.compile(@variable).code(' += ').compile(@by)
				}
				else {
					ctrl.compile(@variable).code(' -= ', -@data.by.value)
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