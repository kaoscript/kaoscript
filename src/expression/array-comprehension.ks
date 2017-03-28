func $return(data = null) { // {{{
	return {
		kind: NodeKind::ReturnStatement
		value: data
	}
} // }}}

class ArrayComprehensionForFrom extends Expression {
	private {
		_body
		_by			= null
		_from
		_to
		_variable
		_when
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this, @scope, @data.loop.variable.name, false, VariableKind::Variable)
		
		@variable = $compile.expression(@data.loop.variable, this)
		@variable.analyse()
		
		@from = $compile.expression(@data.loop.from, this)
		@from.analyse()
		
		@to = $compile.expression(@data.loop.to ?? @data.loop.til, this)
		@to.analyse()
		
		if @data.loop.by? {
			@by = $compile.expression(@data.loop.by, this)
			@by.analyse()
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
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
	type() => Type.Array
}

class ArrayComprehensionForIn extends Expression {
	private {
		_body
		_expression
		_index
		_value
		_valueName
		_when
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		@expression = $compile.expression(@data.loop.expression, this)
		@expression.analyse()
		
		if @data.loop.value? {
			if (variable ?= $variable.fromAST(@data.loop.expression, this)) && variable.type? {
				if variable.type.typeName? {
					if variable.type.typeName.name == 'Array' && variable.type.typeParameters?.length == 1 {
						$variable.define(this, @scope, @data.loop.value.name, false, $variable.kind(variable.type.typeParameters[0]), variable.type.typeParameters[0])
					}
					else {
						$variable.define(this, @scope, @data.loop.value.name, false, VariableKind::Variable)
					}
				}
				else if variable.type.name == 'Array' && variable.type.parameters?.length == 1 {
					$variable.define(this, @scope, @data.loop.value.name, false, $variable.kind(variable.type.parameters[0]), variable.type.parameters[0])
				}
				else {
					$variable.define(this, @scope, @data.loop.value.name, false, VariableKind::Variable)
				}
			}
			else {
				$variable.define(this, @scope, @data.loop.value.name, false, VariableKind::Variable)
			}
			
			@value = $compile.expression(@data.loop.value, this)
			@value.analyse()
		}
		else {
			@valueName = @scope.acquireTempName()
		}
		
		if @data.loop.index? {
			$variable.define(this, @scope, @data.loop.index.name, false, VariableKind::Variable)
			
			@index = $compile.expression(@data.loop.index, this)
			@index.analyse()
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
		
		@scope.releaseTempName(@valueName) if @valueName?
	} // }}}
	prepare() { // {{{
		@expression.prepare()
		@value.prepare() if @value?
		@index.prepare() if @index?
		@body.prepare()
		@when.prepare() if @when?
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
	type() => Type.Array
}

class ArrayComprehensionForOf extends Expression {
	private {
		_body
		_expression
		_key
		_keyName
		_value
		_when
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		@expression = $compile.expression(@data.loop.expression, this)
		@expression.analyse()
		
		if @data.loop.key? {
			$variable.define(this, @scope, @data.loop.key.name, false, VariableKind::Variable)
			
			@key = $compile.expression(@data.loop.key, this)
			@key.analyse()
		}
		else {
			@keyName = @scope.acquireTempName()
		}
		
		if @data.loop.value? {
			$variable.define(this, @scope, @data.loop.value.name, false, VariableKind::Variable)
			
			@value = $compile.expression(@data.loop.value, this)
			@value.analyse()
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
		
		@scope.releaseTempName(@keyName) if @keyName?
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
	type() => Type.Array
}

class ArrayComprehensionForRange extends Expression {
	private {
		_body
		_by
		_from
		_to
		_value
		_when
	}
	constructor(data, parent, scope) { // {{{
		super(data, parent, parent.newScope(scope))
	} // }}}
	analyse() { // {{{
		$variable.define(this, @scope, @data.loop.value.name, false, VariableKind::Variable)
		
		@value = $compile.expression(@data.loop.value, this)
		@value.analyse()
		
		@from = $compile.expression(@data.loop.from, this)
		@from.analyse()
		
		@to = $compile.expression(@data.loop.to, this)
		@to.analyse()
		
		if @data.loop.by? {
			@by = $compile.expression(@data.loop.by, this)
			@body.analyse()
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
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
	type() => Type.Array
}