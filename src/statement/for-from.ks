class ForFromStatement extends Statement {
	private late {
		@bindingScope
		@body
		@bodyScope
		@boundName: String
		@conditionalTempVariables: Array	= []
		@declaration: Boolean				= false
		@declared: Boolean					= false
		@from
		@immutable: Boolean					= false
		@step
		@stepName: String
		@to
		@until
		@variable
		@when
		@while
	}
	analyse() { # {{{
		var mut rename = false
		var variable = @scope.getVariable(@data.variable.name)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Declarative {
				@declaration = true
			}
			else if modifier.kind == ModifierKind::Immutable {
				@immutable = true
			}
		}

		@declared = @declaration || variable == null

		if @declared {
			@bindingScope = @newScope(@scope, ScopeType::InlineBlock)
		}
		else {
			@bindingScope = @scope
		}

		@bodyScope = @newScope(@bindingScope, ScopeType::InlineBlock)

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

		if ?@data.step {
			@step = $compile.expression(@data.step, this, @scope)
			@step.analyse()

			if @step.isUsingVariable(@data.variable.name) {
				if @declared {
					rename = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.variable.name, this)
				}
			}
		}

		if @declared {
			@bindingScope.define(@data.variable.name, @immutable, @bindingScope.reference('Number'), true, this)

			if rename {
				@bindingScope.rename(@data.variable.name)
			}
		}
		else if variable.isImmutable() {
			ReferenceException.throwImmutable(@data.variable.name, this)
		}

		@variable = $compile.expression(@data.variable, this, @bindingScope)
		@variable.analyse()

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
		unless @declared {
			@bindingScope.replaceVariable(@data.variable.name, @bindingScope.reference('Number'), this)
		}

		@variable.prepare()

		@from.prepare(@scope.reference('Number'))

		@to.prepare(@scope.reference('Number'))

		@boundName = @bindingScope.acquireTempName(!@declared) if @to.isComposite()

		if ?@step {
			@step.prepare(@scope.reference('Number'))

			@stepName = @bindingScope.acquireTempName(!@declared) if @step.isComposite()
		}

		@assignTempVariables(@bindingScope)

		if ?@until {
			@until.prepare(@scope.reference('Boolean'))

			unless @until.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@until, this)
			}

			@assignTempVariables(@bodyScope)
		}
		else if ?@while {
			@while.prepare(@scope.reference('Boolean'))

			unless @while.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@while, this)
			}

			@assignTempVariables(@bodyScope)
		}

		if ?@when {
			@when.prepare(@scope.reference('Boolean'))

			unless @when.type().canBeBoolean() {
				TypeException.throwInvalidCondition(@when, this)
			}

			@bodyScope.commitTempVariables(@conditionalTempVariables)
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
		@variable.translate()
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

		if @declared {
			ctrl.code($runtime.scope(this))
		}

		ctrl.compile(@variable).code($equals).compile(@from)

		if ?@boundName {
			ctrl.code($comma, @boundName, $equals).compile(@to)
		}

		if ?@stepName {
			ctrl.code($comma, @stepName, $equals).compile(@step)
		}

		ctrl.code('; ')

		ctrl.compile(@variable)

		var mut desc = (@data.step?.kind == NodeKind::NumericExpression && @data.step.value < 0) || (@data.from.kind == NodeKind::NumericExpression && @data.to.kind == NodeKind::NumericExpression && @data.from.value > @data.to.value)

		if $ast.hasModifier(@data.to, ModifierKind::Ballpark) {
			ctrl.code(desc ? ' > ' : ' < ')
		}
		else {
			ctrl.code(desc ? ' >= ' : ' <= ')
		}

		ctrl.compile(@boundName ?? @to)

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
					ctrl.code('++').compile(@variable)
				}
				else if @data.step.value == -1 {
					ctrl.code('--').compile(@variable)
				}
				else if @data.step.value >= 0 {
					ctrl.compile(@variable).code(' += ').compile(@step)
				}
				else {
					ctrl.compile(@variable).code(' -= ', -@data.step.value)
				}
			}
			else {
				ctrl.compile(@variable).code(' += ').compile(@stepName ?? @step)
			}
		}
		else if desc {
			ctrl.code('--').compile(@variable)
		}
		else {
			ctrl.code('++').compile(@variable)
		}

		ctrl.code(')').step()

		if ?@data.when {
			@toDeclarationFragments(@conditionalTempVariables, ctrl)

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
