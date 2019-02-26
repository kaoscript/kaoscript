class ForOfStatement extends Statement {
	private {
		_body
		_defineKey: Boolean			= false
		_defineValue: Boolean		= false
		_expression
		_expressionName: String
		_key						= null
		_keyName: String
		_keyVariable: Variable
		_immutable: Boolean			= false
		_until
		_value						= null
		_valueVariable: Variable
		_when
		_while
	}
	constructor(data, parent) { // {{{
		super(data, parent, parent.newScope())
	} // }}}
	analyse() { // {{{
		let keyVariable = null
		let valueVariable = null

		@immutable = @data.declaration && !@data.rebindable

		if @data.key? {
			keyVariable = @scope.getVariable(@data.key.name)

			if @data.declaration || keyVariable == null {
				@keyVariable = @scope.define(@data.key.name, @immutable, @scope.reference('String'), this)

				@defineKey = true
			}
			else if keyVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.key.name, this)
			}

			@key = $compile.expression(@data.key, this)
			@key.analyse()
		}

		if @data.value? {
			valueVariable = @scope.getVariable(@data.value.name)

			if @data.declaration || valueVariable == null {
				@valueVariable = @scope.define(@data.value.name, @immutable, this)

				@defineValue = true
			}
			else if valueVariable.isImmutable() {
				ReferenceException.throwImmutable(@data.value.name, this)
			}

			@value = $compile.expression(@data.value, this)
			@value.analyse()
		}

		@expression = $compile.expression(@data.expression, this, @parent.scope())
		@expression.analyse()

		if @key != null && @expression.isUsingVariable(@data.key.name) {
			if @defineKey {
				@scope.rename(@data.key.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.key.name, this)
			}
		}
		if @value != null && @expression.isUsingVariable(@data.value.name) {
			if @defineValue {
				@scope.rename(@data.value.name)
			}
			else {
				SyntaxException.throwAlreadyDeclared(@data.value.name, this)
			}
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

		const type = @expression.type()
		if !(type.isAny() || type.isObject()) {
			TypeException.throwInvalidForOfExpression(this)
		}

		if @expression.isEntangled() {
			@expressionName = this.greatScope().acquireTempName()
		}

		if @defineValue {
			@valueVariable.type(type.parameter())
		}

		if @key? {
			@key.prepare()
		}
		else {
			@keyName = @scope.acquireTempName()
		}

		if @until? {
			@until.prepare()
		}
		else if @while? {
			@while.prepare()
		}

		@when.prepare() if @when?

		@body.prepare()

		this.greatScope().releaseTempName(@expressionName) if @expressionName?
		@scope.releaseTempName(@keyName) if @keyName?
	} // }}}
	translate() { // {{{
		@expression.translate()

		@key.translate() if @key?

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

		let ctrl = fragments.newControl().code('for(')

		if @key != null {
			if @data.declaration || @defineKey {
				if @options.format.variables == 'es5' {
					ctrl.code('var ')
				}
				else if @immutable {
					ctrl.code('const ')
				}
				else {
					ctrl.code('let ')
				}
			}

			ctrl.compile(@key)
		}
		else {
			ctrl.code($runtime.scope(this), @keyName)
		}

		ctrl.code(' in ').compile(@expressionName ?? @expression).code(')').step()

		if @value != null {
			let line = ctrl.newLine()

			if @data.declaration || @defineValue {
				if @options.format.variables == 'es5' {
					line.code('var ')
				}
				else if @immutable {
					line.code('const ')
				}
				else {
					line.code('let ')
				}
			}

			line.compile(@value).code($equals).compile(@expressionName ?? @expression).code('[').compile(@key ?? @keyName).code(']').done()
		}

		if @until? {
			ctrl
				.newControl()
				.code('if(')
				.compile(@until)
				.code(')')
				.step()
				.line('break')
				.done()
		}
		else if @while? {
			ctrl
				.newControl()
				.code('if(!(')
				.compile(@while)
				.code('))')
				.step()
				.line('break')
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