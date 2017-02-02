func $return(data?) { // {{{
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
		$variable.define(this, @scope, @data.loop.variable.name, VariableKind::Variable)
		
		@variable = $compile.expression(@data.loop.variable, this)
		
		@from = $compile.expression(@data.loop.from, this)
		@to = $compile.expression(@data.loop.to ?? @data.loop.til, this)
		@by = $compile.expression(@data.loop.by, this) if @data.loop.by?
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
	} // }}}
	fuse() { // {{{
		@body.fuse()
		@when.fuse() if @when?
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
		
		if @data.loop.value? {
			if (variable ?= $variable.fromAST(@data.loop.expression, this)) && variable.type?.typeName?.name == 'Array' && variable.type.typeParameters?.length == 1 {
				$variable.define(this, @scope, @data.loop.value.name, $variable.kind(variable.type.typeParameters[0]), variable.type.typeParameters[0])
			}
			else {
				$variable.define(this, @scope, @data.loop.value.name, VariableKind::Variable)
			}
			
			@value = $compile.expression(@data.loop.value, this)
		}
		else {
			@valueName = @scope.acquireTempName()
		}
		
		if @data.loop.index? {
			$variable.define(this, @scope, @data.loop.index.name, VariableKind::Variable)
			
			@index = $compile.expression(@data.loop.index, this)
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
		
		@scope.releaseTempName(@valueName) if @valueName?
	} // }}}
	fuse() { // {{{
		@expression.fuse()
		@value.fuse() if @value?
		@index.fuse() if @index?
		@body.fuse()
		@when.fuse() if @when?
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
		
		if @data.loop.key? {
			$variable.define(this, @scope, @data.loop.key.name, VariableKind::Variable)
			
			@key = $compile.expression(@data.loop.key, this)
		}
		else {
			@keyName = @scope.acquireTempName()
		}
		
		if @data.loop.value? {
			$variable.define(this, @scope, @data.loop.value.name, VariableKind::Variable)
			
			@value = $compile.expression(@data.loop.value, this)
		}
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
		
		@scope.releaseTempName(@keyName) if @keyName?
	} // }}}
	fuse() { // {{{
		@expression.fuse()
		@key.fuse() if @key?
		@value.fuse() if @value?
		@body.fuse()
		@when.fuse() if @when?
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
		$variable.define(this, @scope, @data.loop.value.name, VariableKind::Variable)
		
		@value = $compile.expression(@data.loop.value, this)
		@from = $compile.expression(@data.loop.from, this)
		@to = $compile.expression(@data.loop.to, this)
		@by = $compile.expression(@data.loop.by, this) if @data.loop.by?
		
		@body = $compile.statement($return(@data.body), this)
		@body.analyse()
		
		if @data.loop.when? {
			@when = $compile.statement($return(@data.loop.when), this)
			@when.analyse()
		}
	} // }}}
	fuse() { // {{{
		@value.fuse()
		@from.fuse()
		@to.fuse()
		@by.fuse() if @by?
		@body.fuse()
		@when.fuse() if @when?
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
}