func $return(data = null) { // {{{
	return {
		kind: NodeKind::ReturnStatement
		value: data
	}
} // }}}

class ArrayComprehensionForFrom extends Expression {
	private {
		_bindingScope
		_body
		_bodyScope
		_by			= null
		_from
		_to
		_variable
		_when
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@bindingScope.define(@data.loop.variable.name, false, @scope.reference('Number'), this)

		@variable = $compile.expression(@data.loop.variable, this, @bindingScope)
		@variable.analyse()

		@from = $compile.expression(@data.loop.from, this, @scope)
		@from.analyse()

		@to = $compile.expression(@data.loop.to ?? @data.loop.til, this, @scope)
		@to.analyse()

		if @data.loop.by? {
			@by = $compile.expression(@data.loop.by, this, @scope)
			@by.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.analyse()

		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.analyse()
		}
	} // }}}
	prepare() { // {{{
		@variable.prepare()
		@from.prepare()
		@to.prepare()
		@by.prepare() if @by?
		@body.prepare()
		@when.prepare() if @when?
	} // }}}
	translate() { // {{{
		@variable.translate()
		@from.translate()
		@to.translate()
		@by.translate() if @by?
		@body.translate()
		@when.translate() if @when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')

		let surround = $function.surround(this)

		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if @by == null {
			fragments.code(', 1')
		}
		else {
			fragments.code($comma).compile(@by)
		}

		fragments.code($comma, @data.loop.from?, $comma, @data.loop.to?, $comma)

		fragments
			.code(surround.beforeParameters)
			.compile(@variable)
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if @when? {
			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@variable)
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} // }}}
	type() => @scope.reference('Array')
}

class ArrayComprehensionForIn extends Expression {
	private {
		_bindingScope
		_body
		_bodyScope
		_expression
		_index
		_indexVariable: Variable
		_type: Type
		_value
		_valueName: String
		_valueVariable: Variable
		_when
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@expression = $compile.expression(@data.loop.expression, this, @scope)
		@expression.analyse()

		if @data.loop.value? {
			@valueVariable = @bindingScope.define(@data.loop.value.name, false, this)

			@value = $compile.expression(@data.loop.value, this, @bindingScope)
			@value.analyse()
		}
		else {
			@valueName = @bindingScope.acquireTempName()
		}

		if @data.loop.index? {
			@indexVariable = @bindingScope.define(@data.loop.index.name, false, @bindingScope.reference('Number'), this)

			@index = $compile.expression(@data.loop.index, this, @bindingScope)
			@index.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.analyse()

		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.analyse()
		}

		@bindingScope.releaseTempName(@valueName) if @valueName?
	} // }}}
	prepare() { // {{{
		@expression.prepare()

		if @value? {
			@valueVariable.type(@expression.type().parameter())

			@value.prepare()
		}

		if @index? {
			@index.prepare()
		}

		@body.prepare()

		if @body.type().isAny() {
			@type = @scope.reference('Array')
		}
		else {
			@type = Type.arrayOf(@body.type(), @scope)
		}

		if @when? {
			@when.prepare()
		}
	} // }}}
	translate() { // {{{
		@expression.translate()
		@value.translate() if @value?
		@index.translate() if @index?
		@body.translate()
		@when.translate() if @when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')

		let surround = $function.surround(this)

		fragments
			.code($runtime.helper(this), '.mapArray(')
			.compile(@expression)
			.code(', ')

		fragments
			.code(surround.beforeParameters)
			.compile(@value ?? @valueName)

		fragments.code($comma).compile(@index) if @index?

		fragments
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if @when? {
			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@value ?? @valueName)

			fragments.code($comma).compile(@index) if @index?

			fragments
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} // }}}
	type() => @type
}

class ArrayComprehensionForOf extends Expression {
	private {
		_bindingScope
		_body
		_bodyScope
		_expression
		_key
		_keyName
		_value
		_when
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@expression = $compile.expression(@data.loop.expression, this, @scope)
		@expression.analyse()

		if @data.loop.key? {
			@bindingScope.define(@data.loop.key.name, false, @bindingScope.reference('String'), this)

			@key = $compile.expression(@data.loop.key, this, @bindingScope)
			@key.analyse()
		}
		else {
			@keyName = @bindingScope.acquireTempName()
		}

		if @data.loop.value? {
			@bindingScope.define(@data.loop.value.name, false, this)

			@value = $compile.expression(@data.loop.value, this, @bindingScope)
			@value.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.analyse()

		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.analyse()
		}

		@bindingScope.releaseTempName(@keyName) if @keyName?
	} // }}}
	prepare() { // {{{
		@expression.prepare()
		@key.prepare() if @key?
		@value.prepare() if @value?
		@body.prepare()
		@when.prepare() if @when?
	} // }}}
	translate() { // {{{
		@expression.translate()
		@key.translate() if @key?
		@value.translate() if @value?
		@body.translate()
		@when.translate() if @when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')

		let surround = $function.surround(this)

		fragments
			.code($runtime.helper(this), '.mapObject(')
			.compile(@expression)
			.code(', ')

		fragments
			.code(surround.beforeParameters)
			.compile(@key ?? @keyName)

		fragments.code($comma).compile(@value) if @value?

		fragments
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if @when? {
			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@key ?? @keyName)

			fragments.code($comma).compile(@value) if @value?

			fragments
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} // }}}
	type() => @scope.reference('Array')
}

class ArrayComprehensionForRange extends Expression {
	private {
		_bindingScope
		_body
		_bodyScope
		_by
		_from
		_to
		_value
		_when
	}
	analyse() { // {{{
		@bindingScope = this.newScope(@scope, ScopeType::InlineBlock)
		@bodyScope = this.newScope(@bindingScope, ScopeType::InlineBlock)

		@bindingScope.define(@data.loop.value.name, false, @scope.reference('Number'), this)

		@value = $compile.expression(@data.loop.value, this, @bindingScope)
		@value.analyse()

		@from = $compile.expression(@data.loop.from, this, @scope)
		@from.analyse()

		@to = $compile.expression(@data.loop.to, this, @scope)
		@to.analyse()

		if @data.loop.by? {
			@by = $compile.expression(@data.loop.by, this, @scope)
			@body.analyse()
		}

		@body = $compile.statement($return(@data.body), this, @bodyScope)
		@body.analyse()

		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this, @bodyScope)
			@when.analyse()
		}
	} // }}}
	prepare() { // {{{
		@value.prepare()
		@from.prepare()
		@to.prepare()
		@by.prepare() if @by?
		@body.prepare()
		@when.prepare() if @when?
	} // }}}
	translate() { // {{{
		@value.translate()
		@from.translate()
		@to.translate()
		@by.translate() if @by?
		@body.translate()
		@when.translate() if @when?
	} // }}}
	toFragments(fragments, mode) { // {{{
		this.module().flag('Helper')

		let surround = $function.surround(this)

		fragments
			.code($runtime.helper(this), '.mapRange(')
			.compile(@from)
			.code($comma)
			.compile(@to)

		if @by? {
			fragments.code(', ').compile(@by)
		}
		else {
			fragments.code(', 1')
		}

		fragments
			.code($comma, 'true', $comma, 'true', $comma)
			.code(surround.beforeParameters)
			.compile(@value)
			.code(surround.afterParameters)
			.newBlock()
			.compile(@body)
			.done()

		fragments.code(surround.footer)

		if @when? {
			fragments
				.code($comma)
				.code(surround.beforeParameters)
				.compile(@value)
				.code(surround.afterParameters)
				.newBlock()
				.compile(@when)
				.done()

			fragments.code(surround.footer)
		}

		fragments.code(')')
	} // }}}
	type() => @scope.reference('Array')
}