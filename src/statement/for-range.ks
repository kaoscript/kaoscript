class ForRangeStatement extends Statement {
	private {
		@bindingScope
		@bodyScope
		@body
		@boundName
		@declaration: Boolean		= false
		@defineVariable: Boolean	= false
		@from
		@immutable: Boolean			= false
		@step
		@stepName
		@to
		@until
		@value
		@when
		@while
	}
	analyse() { # {{{
		@bindingScope = @newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		var variable = @scope.getVariable(@data.value.name)
		if @declaration || variable == null {
			@bindingScope.define(@data.value.name, @immutable, @bindingScope.reference('Number'), true, this)

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

		if ?@data.step {
			@step = $compile.expression(@data.step, this, @scope)
			@step.analyse()
		}

		if ?@data.until {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()
		}
		else if ?@data.while {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()
		}

		if ?@data.when {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.block(@data.body, this, @bodyScope)
		@body.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		unless @defineVariable {
			@bindingScope.replaceVariable(@data.value.name, @bindingScope.reference('Number'), this)
		}

		@value.prepare()
		@from.prepare(@scope.reference('Number'))
		@to.prepare(@scope.reference('Number'))

		@boundName = @bindingScope.acquireTempName() if @to.isComposite()

		if ?@step {
			@step.prepare(@scope.reference('Number'))

			@stepName = @bindingScope.acquireTempName() if @step.isComposite()
		}

		if ?@until {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}
		}
		else if ?@while {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}
		}

		@body.prepare(target)

		@bindingScope.releaseTempName(@boundName) if ?@boundName
		@bindingScope.releaseTempName(@stepName) if ?@stepName

		for var inferable, name of @bodyScope.listUpdatedInferables() {
			if inferable.isVariable && @scope.hasVariable(name) {
				@scope.replaceVariable(name, inferable.type, true, false, this)
			}
		}
	} # }}}
	translate() { # {{{
		@value.translate()
		@from.translate()
		@to.translate()

		@step.translate() if ?@step

		if ?@until {
			@until.translate()
		}
		else if ?@while {
			@while.translate()
		}

		@when.translate() if ?@when

		@body.translate()
	} # }}}
	isJumpable() => true
	isLoop() => true
	isUsingVariable(name) => # {{{
			@from.isUsingVariable(name)
		||	@to.isUsingVariable(name)
		||	@step?.isUsingVariable(name)
		||	@until?.isUsingVariable(name)
		||	@while?.isUsingVariable(name)
		||	@when?.isUsingVariable(name)
		||	@body.isUsingVariable(name)
	# }}}
	toStatementFragments(fragments, mode) { # {{{
		var mut ctrl = fragments.newControl().code('for(')

		if @defineVariable {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@value).code($equals).compile(@from)

		if ?@boundName {
			ctrl.code(@boundName, $equals).compile(@to)
		}

		if ?@stepName {
			ctrl.code($comma, @stepName, $equals).compile(@step)
		}

		ctrl.code('; ').compile(@value).code(' <= ').compile(@boundName ?? @to)

		if ?@until {
			ctrl.code(' && !(').compileCondition(@until).code(')')
		}
		else if ?@while {
			ctrl.code(' && ').wrapCondition(@while, Mode::None, Junction::AND)
		}

		ctrl.code('; ')

		if ?@data.step {
			if @data.step.kind == NodeKind::NumericExpression {
				if @data.step.value == 1 {
					ctrl.code('++').compile(@value)
				}
				else {
					ctrl.compile(@value).code(' += ').compile(@step)
				}
			}
			else {
				ctrl.compile(@value).code(' += ').compile(@stepName ?? @step)
			}
		}
		else {
			ctrl.code('++').compile(@value)
		}

		ctrl.code(')').step()

		if ?@when {
			ctrl
				.newControl()
				.code('if(')
				.compileCondition(@when)
				.code(')')
				.step()
				.compile(@body)
				.done()
		}
		else {
			ctrl.compile(@body)
		}

		ctrl.done()
	} # }}}
}
