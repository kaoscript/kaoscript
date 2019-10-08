class ForRangeStatement extends Statement {
	private {
		_bindingScope
		_bodyScope
		_body
		_boundName
		_by
		_byName
		_declaration: Boolean		= false
		_defineVariable: Boolean	= false
		_from
		_immutable: Boolean			= false
		_til
		_to
		_until
		_value
		_valueVariable: Variable
		_when
		_while
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		const variable = @scope.getVariable(@data.value.name)
		if @declaration || variable == null {
			@valueVariable = @bindingScope.define(@data.value.name, @immutable, @bindingScope.reference('Number'), true, this)

			@defineVariable = true
		}
		else if variable.isImmutable() {
			ReferenceException.throwImmutable(@data.value.name, this)
		}

		@value = $compile.expression(@data.value, this, @bindingScope)
		@value.analyse()

		@from = $compile.expression(@data.from, this, @scope)
		@from.analyse()

		@to = $compile.expression(@data.to, this, @scope)
		@to.analyse()

		if @data.by? {
			@by = $compile.expression(@data.by, this, @scope)
			@by.analyse()
		}

		if @data.until? {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()
		}
		else if @data.while? {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()
		}

		if @data.when? {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
		@from.prepare()
		@to.prepare()

		@boundName = @bindingScope.acquireTempName() if @to.isComposite()

		if @by? {
			@by.prepare()

			@byName = @bindingScope.acquireTempName() if @by.isComposite()
		}

		if @until? {
			@until.prepare()

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}
		}
		else if @while? {
			@while.prepare()

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}
		}

		if @when? {
			@when.prepare()

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}
		}

		@body.prepare()

		@bindingScope.releaseTempName(@boundName) if @boundName?
		@bindingScope.releaseTempName(@byName) if @byName?
	} // }}}
	translate() { // {{{
		@value.translate()
		@from.translate()
		@to.translate()

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
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isUsingVariable(name) => // {{{
			@from.isUsingVariable(name)
		||	@to.isUsingVariable(name)
		||	@by?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	// }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl().code('for(')

		if @defineVariable {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@value).code($equals).compile(@from)

		if @boundName? {
			ctrl.code(@boundName, $equals).compile(@to)
		}

		if @byName? {
			ctrl.code($comma, @byName, $equals).compile(@by)
		}

		ctrl.code('; ').compile(@value).code(' <= ').compile(@boundName ?? @to)

		if @until? {
			ctrl.code(' && !(').compileBoolean(@until).code(')')
		}
		else if @while? {
			ctrl.code(' && ').wrapBoolean(@while)
		}

		ctrl.code('; ')

		if @data.by? {
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