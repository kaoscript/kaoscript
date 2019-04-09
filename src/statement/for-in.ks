class ForInStatement extends Statement {
	private {
		_bindingScope
		_body
		_bodyScope
		_boundName: String
		_conditionalTempVariables: Array	= []
		_declared: Boolean					= false
		_declareIndex: Boolean				= false
		_declareValue: Boolean				= false
		_expression
		_expressionName: String
		_from
		_immutable: Boolean					= false
		_index								= null
		_indexName: String
		_indexVariable: Variable
		_loopTempVariables: Array			= []
		_until
		_useBreak: Boolean					= false
		_value								= null
		_valueVariable: Variable
		_when
		_while
		_til
		_to
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		let indexVariable = null
		let valueVariable = null

		@immutable = @data.declaration && !@data.rebindable

		if @data.index? {
			indexVariable = @bindingScope.getVariable(@data.index.name)

			if @data.declaration || indexVariable == null {
				@indexVariable = @bindingScope.define(@data.index.name, @immutable, @bindingScope.reference('Number'), this)

				@declareIndex = true
			}
			else if indexVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.index.name, this)
			}

			@index = $compile.expression(@data.index, this, @bindingScope)
			@index.analyse()
		}

		if @data.value? {
			valueVariable = @bindingScope.getVariable(@data.value.name)

			if @data.declaration || valueVariable == null {
				@valueVariable = @bindingScope.define(@data.value.name, @immutable, this)

				@declareValue = true
			}
			else if valueVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.value.name, this)
			}

			@value = $compile.expression(@data.value, this, @bindingScope)
			@value.analyse()
		}

		let renameIndex = false
		let renameValue = false

		@expression = $compile.expression(@data.expression, this, @scope)
		@expression.analyse()

		if @index != null && @expression.isUsingVariable(@data.index.name) {
			if @declareIndex {
				renameIndex = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.index.name, this)
			}
		}
		if @value != null && @expression.isUsingVariable(@data.value.name) {
			if @declareValue {
				renameValue = true
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.value.name, this)
			}
		}

		if @data.from? {
			@from = $compile.expression(@data.from, this, @scope)
			@from.analyse()

			if @index != null && @from.isUsingVariable(@data.index.name) {
				if @declareIndex {
					renameIndex = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.index.name, this)
				}
			}
			if @value != null && @from.isUsingVariable(@data.value.name) {
				if @declareValue {
					renameValue = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.value.name, this)
				}
			}
		}

		if @data.til? {
			@til = $compile.expression(@data.til, this, @scope)
			@til.analyse()

			if @index != null && @til.isUsingVariable(@data.index.name) {
				if @declareIndex {
					renameIndex = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.index.name, this)
				}
			}
			if @value != null && @til.isUsingVariable(@data.value.name) {
				if @declareValue {
					renameValue = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.value.name, this)
				}
			}
		}
		else if @data.to? {
			@to = $compile.expression(@data.to, this, @scope)
			@to.analyse()

			if @index != null && @to.isUsingVariable(@data.index.name) {
				if @declareIndex {
					renameIndex = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.index.name, this)
				}
			}
			if @value != null && @to.isUsingVariable(@data.value.name) {
				if @declareValue {
					renameValue = true
				}
				else {
					SyntaxException.throwAlreadyDeclared(@data.value.name, this)
				}
			}
		}

		if renameIndex {
			@bindingScope.rename(@data.index.name)
		}
		if renameValue {
			@bindingScope.rename(@data.value.name)
		}

		if @data.until? {
			@until = $compile.expression(@data.until, this, @bodyScope)
			@until.analyse()

			@useBreak = @value? && @until.isUsingVariable(@data.value.name)
		}
		else if @data.while? {
			@while = $compile.expression(@data.while, this, @bodyScope)
			@while.analyse()

			@useBreak = @value? && @while.isUsingVariable(@data.value.name)
		}

		if @data.when? {
			@when = $compile.expression(@data.when, this, @bodyScope)
			@when.analyse()
		}

		@body = $compile.expression($ast.block(@data.body), this, @bodyScope)
		@body.analyse()
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		const type = @expression.type()
		if !(type.isAny() || type.isArray()) {
			TypeException.throwInvalidForInExpression(this)
		}

		if @declareValue {
			@valueVariable.type(type.parameter())
		}

		if !?@index && !(@data.index? && !@data.declaration && @scope.hasVariable(@data.index.name)) {
			@indexName = @bindingScope.acquireTempName(false)
		}

		if @expression.isEntangled() {
			@expressionName = @bindingScope.acquireTempName(false)
		}

		@boundName = @bindingScope.acquireTempName(false)

		if @from? {
			@from.prepare()
		}

		if @til? {
			@til.prepare()
		}
		else if @to? {
			@to.prepare()
		}

		this.assignTempVariables(@bindingScope)

		if @until? {
			@until.prepare()

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				this.assignTempVariables(@bodyScope)
			}
		}
		else if @while? {
			@while.prepare()

			if @useBreak {
				@bodyScope.commitTempVariables(@loopTempVariables)
			}
			else {
				this.assignTempVariables(@bodyScope)
			}
		}

		if @when? {
			@when.prepare()

			@when.acquireReusable(false)
			@when.releaseReusable()

			@bodyScope.commitTempVariables(@conditionalTempVariables)
		}

		@body.prepare()

		@bindingScope.releaseTempName(@expressionName) if @expressionName?
		@bindingScope.releaseTempName(@indexName) if @indexName?
		@bindingScope.releaseTempName(@boundName)
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
		let ctrl

		if @index != null && !@data.declaration && !@declareIndex {
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

		if @expressionName? {
			ctrl.code(@expressionName, $equals).compile(@expression).code($comma)
		}

		ctrl.code(@boundName, $equals)

		this.toBoundFragments(ctrl)

		if @declareValue {
			ctrl.code($comma).compile(@value)
		}

		ctrl.code('; ')

		if @data.desc {
			ctrl
				.compile(@indexName ?? @index)
				.code(' >= ' + @boundName)
		}
		else {
			ctrl
				.compile(@indexName ?? @index)
				.code(' < ' + @boundName)
		}

		if !@useBreak {
			if @until? {
				ctrl.code(' && !(').compileBoolean(@until).code(')')
			}
			else if @while? {
				ctrl.code(' && ').compileBoolean(@while)
			}
		}

		if @data.desc {
			ctrl
				.code('; --')
				.compile(@indexName ?? @index)
		}
		else {
			ctrl
				.code('; ++')
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

			if @useBreak {
				if @until? {
					this.toDeclarationFragments(@loopTempVariables, ctrl)

					ctrl
						.newControl()
						.code('if(')
						.compileBoolean(@until)
						.code(')')
						.step()
						.line('break')
						.done()
				}
				else if @while? {
					this.toDeclarationFragments(@loopTempVariables, ctrl)

					ctrl
						.newControl()
						.code('if(!(')
						.compileBoolean(@while)
						.code('))')
						.step()
						.line('break')
						.done()
				}
			}
		}

		if @when? {
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