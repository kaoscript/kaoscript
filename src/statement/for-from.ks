class ForFromStatement extends Statement {
	private {
		_bindingScope
		_body
		_bodyScope
		_boundName: String
		_by
		_byName: String
		_conditionalTempVariables: Array	= []
		_declaration: Boolean				= false
		_declared: Boolean					= false
		_from
		_immutable: Boolean					= false
		_til
		_to
		_until
		_variable
		_variableVariable: Variable
		_when
		_while
	}
	analyse() { // {{{
		let rename = false
		const variable = @scope.getVariable(@data.variable.name)

		for const modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		@declared = @declaration || variable == null

		if @declared {
			@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = @scope
		}

		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@from = $compile.expression(@data.from, this, @scope)
		@from.analyse()

		if @from.isUsingVariable(@data.variable.name) {
			if @declared {
				rename = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
			}
		}

		if @data.til? {
			@til = $compile.expression(@data.til, this, @scope)
			@til.analyse()

			if @til.isUsingVariable(@data.variable.name) {
				if @declared {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}
		else {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			if @to.isUsingVariable(@data.variable.name) {
				if @declared {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @data.by? {
			@by = $compile.expression(@data.by, this, @scope)
			@by.analyse()

			if @by.isUsingVariable(@data.variable.name) {
				if @declared {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @declared {
			@variableVariable = @bindingScope.define(@data.variable.name, @immutable, @bindingScope.reference('Number'), this)

			if rename {
				@bindingScope.rename(@data.variable.name)
			}
		}
		else if variable.isImmutable() {
			ReferenceException.throwImmutable(@data.variable.name, this)
		}

		@variable = $compile.expression(@data.variable, this, @bindingScope)
		@variable.analyse()

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
		@variable.prepare()

		@from.prepare()

		if @til? {
			@til.prepare()

			@boundName = @bindingScope.acquireTempName(!@declared) if @til.isComposite()
		}
		else {
			@to.prepare()

			@boundName = @bindingScope.acquireTempName(!@declared) if @to.isComposite()
		}

		if @by? {
			@by.prepare()

			@byName = @bindingScope.acquireTempName(!@declared) if @by.isComposite()
		}

		this.assignTempVariables(@bindingScope)

		if @until? {
			@until.prepare()

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			this.assignTempVariables(@bodyScope)
		}
		else if @while? {
			@while.prepare()

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			this.assignTempVariables(@bodyScope)
		}

		if @when? {
			@when.prepare()

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}

		@body.prepare()

		@bindingScope.releaseTempName(@boundName) if ?@boundName
		@bindingScope.releaseTempName(@byName) if ?@byName
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
	checkReturnType(type: Type) { // {{{
		@body.checkReturnType(type)
	} // }}}
	isUsingVariable(name) => // {{{
			@from.isUsingVariable(name)
		||	@til?.isUsingVariable(name)
		||	@to?.isUsingVariable(name)
		||	@by?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	// }}}
	toStatementFragments(fragments, mode) { // {{{
		let ctrl = fragments.newControl().code('for(')

		if @declared {
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

		ctrl.compile(@variable)

		let desc = (@data.by?.kind == NodeKind::NumericExpression && @data.by.value < 0) || (@data.from.kind == NodeKind::NumericExpression && ((@data.to?.kind == NodeKind::NumericExpression && @data.from.value > @data.to.value) || (@data.til?.kind == NodeKind::NumericExpression && @data.from.value > @data.til.value)))

		if @data.til? {
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

		if @data.when? {
			this.toDeclarationFragments(@conditionalTempVariables, ctrl)

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