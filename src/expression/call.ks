func $caller(data, node) { // {{{
	if data is IdentifierLiteral {
		return data
	}
	else if data is MemberExpression {
		return data._object
	}
	else {
		console.error(data)
		$throw('Not Implemented', node)
	}
} // }}}

class CallExpression extends Expression {
	private {
		_arguments		= []
		_callee
		_caller
		_callScope
		_list			= true
		_reusable		= false
		_reuseName		= null
		_tested			= false
		_type
	}
	analyse() { // {{{
		if this._data.callee.kind == Kind::Identifier {
			if variable ?= this._scope.getVariable(this._data.callee.name) {
				if variable.callable? {
					variable.callable(this._data)
				}
			}
			else {
				$throw(`Undefined variable \(this._data.callee.name) at line \(this._data.callee.start.line)`, this)
			}
		}
		
		if this._data.callee.kind == Kind::MemberExpression {
			this._callee = new MemberExpression(this._data.callee, this, this.scope())
			this._callee.analyse()
		}
		else {
			this._callee = $compile.expression(this._data.callee, this, false)
		}
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
		
		if this._data.scope.kind == ScopeModifier::Argument {
			this._callScope = $compile.expression(this._data.scope.value, this)
		}
		
		if !this._list {
			this._caller = $caller(this._callee, this)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if acquire {
			this._reuseName = this.statement().scope().acquireTempName(this.statement())
		}
		
		this._callee.acquireReusable(this._data.nullable || (!this._list && this._data.scope.kind == ScopeModifier::This))
	} // }}}
	releaseReusable() { // {{{
		this.statement().scope().releaseTempName(this._reuseName) if this._reuseName?
		
		this._callee.releaseReusable()
	} // }}}
	fuse() { // {{{
		this._callee.fuse()
		this._caller.fuse() if this._caller?
		this._callScope.fuse() if this._callScope?
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isCallable() => !this._reusable
	isNullable() { // {{{
		return this._data.nullable || this._callee.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			this.toCallFragments(fragments, mode)
			
			fragments.code(', ') if this._arguments.length
		}
		else {
			if this._reusable {
				fragments.code(this._reuseName)
			}
			else if this.isNullable() && !this._tested {
				fragments.wrapNullable(this).code(' ? ')
				
				this._tested = true
				
				this.toFragments(fragments, mode)
				
				fragments.code(' : undefined')
			}
			else {
				this.toCallFragments(fragments, mode)
				
				fragments.code(')')
			}
		}
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		let data = this._data
		
		if this._list {
			if data.scope.kind == ScopeModifier::This {
				fragments.compile(this._callee, mode).code('(')
				
				for argument, index in this._arguments {
					fragments.code($comma) if index
					
					fragments.compile(argument, mode)
				}
			}
			else if data.scope.kind == ScopeModifier::Null {
				fragments.compile(this._callee, mode).code('.call(null')
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument, mode)
				}
			}
			else {
				fragments.compile(this._callee, mode).code('.call(').compile(this._callScope, mode)
				
				for argument in this._arguments {
					fragments.code($comma).compile(argument, mode)
				}
			}
		}
		else {
			if data.scope.kind == ScopeModifier::Null {
				fragments
					.compile(this._callee, mode)
					.code('.apply(null')
			}
			else if data.scope.kind == ScopeModifier::This {
				fragments
					.compileReusable(this._callee)
					.code('.apply(')
					.compile(this._caller, mode)
			}
			else {
				fragments
					.compile(this._callee, mode)
					.code('.apply(')
					.compile(this._callScope, mode)
			}
			
			if this._arguments.length == 1 && $signature.type($type.type(this._data.arguments[0].argument, this._scope, this), this._scope) == 'Array' {
				fragments.code($comma).compile(this._arguments[0])
			}
			else {
				fragments.code(', [].concat(')
				
				for i from 0 til this._arguments.length {
					fragments.code($comma) if i != 0
					
					fragments.compile(this._arguments[i])
				}
				
				fragments.code(')')
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !this._tested {
			this._tested = true
			
			if this._data.nullable {
				if this._callee.isNullable() {
					fragments
						.wrapNullable(this._callee)
						.code(' && ')
				}
				
				fragments
					.code($runtime.type(this) + '.isFunction(')
					.compileReusable(this._callee)
					.code(')')
			}
			else if this._callee.isNullable() {
				fragments.compileNullable(this._callee)
			}
			else {
				fragments
					.code($runtime.type(this) + '.isValue(')
					.compileReusable(this)
					.code(')')
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(this._reuseName, $equals)
			.compile(this)
		
		this._reusable = true
	} // }}}
}

class CallSealedExpression extends Expression {
	private {
		_arguments	= []
		_callee
		_list		= true
		_object
		_tested		= false
	}
	CallSealedExpression(data, parent, scope, @callee) { // {{{
		super(data, parent, scope)
	} // }}}
	analyse() { // {{{
		this._object = $compile.expression(this._data.callee.object, this)
		
		for argument in this._data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				this._arguments.push($compile.expression(argument.argument, this))
				
				this._list = false
			}
			else {
				this._arguments.push($compile.expression(argument, this))
			}
		}
	} // }}}
	fuse() { // {{{
		this._object.fuse()
		
		for argument in this._arguments {
			argument.fuse()
		}
	} // }}}
	isComputed() => this._callee is Array
	isNullable() { // {{{
		return this._data.nullable || this._object.isNullable()
	} // }}}
	toFragments(fragments, mode) { // {{{
		if this._callee is Array {
			if this._callee.length == 2 {
				let data = this._data
				let callee = this._callee
				
				this.module().flag('Type')
				
				let name = null
				if data.callee.object.kind == Kind::Identifier {
					if tof = $runtime.typeof(callee[0].variable.name, this) {
						fragments.code(tof, '(').compile(this._object).code(')')
					}
					else {
						fragments.code($runtime.type(this), '.is(').compile(this._object).code(', ', callee[0].variable.name, ')')
					}
				}
				else {
					name = this._scope.acquireTempName()
					
					if tof = $runtime.typeof(callee[0].variable.name, this) {
						fragments.code(tof, '(', name, ' = ').compile(this._object).code(')')
					}
					else {
						fragments.code($runtime.type(this), '.is(', name, ' = ').compile(this._object).code(', ', callee[0].variable.name, ')')
					}
				}
				
				fragments.code(' ? ')
				
				fragments.code((callee[0].variable.accessPath || ''), callee[0].variable.sealed.name + '._im_' + data.callee.property.name + '(')
				
				if name? {
					fragments.code(name)
				}
				else {
					fragments.compile(this._object)
				}
				
				for argument in this._arguments {
					fragments.code(', ').compile(argument)
				}
				
				fragments.code(') : ')
				
				fragments.code((callee[1].variable.accessPath || ''), callee[1].variable.sealed.name + '._im_' + data.callee.property.name + '(')
				
				if name? {
					fragments.code(name)
				}
				else {
					fragments.compile(this._object)
				}
				
				for argument in this._arguments {
					fragments.code(', ').compile(argument)
				}
				
				fragments.code(')')
				
				this._scope.releaseTempName(name) if name?
			}
			else {
				$throw('Not Implemented', this)
			}
		}
		else {
			let path = this._callee.variable.accessPath? ? this._callee.variable.accessPath + this._callee.variable.sealed.name : this._callee.variable.sealed.name
			
			if this._callee.kind == CalleeKind::InstanceMethod {
				if this._list {
					fragments
						.code(`\(path)._im_\(this._data.callee.property.name)(`)
						.compile(this._object)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma).compile(this._arguments[i])
					}
					
					fragments.code(')')
				}
				else {
					fragments
						.code(`\(path)._im_\(this._data.callee.property.name).apply(\(path), [].concat(`)
						.compile(this._object)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma).compile(this._arguments[i])
					}
					
					fragments.code('))')
				}
			}
			else if this._callee.kind == CalleeKind::ClassMethod {
				if this._list {
					fragments.code(`\(path)._cm_\(this._data.callee.property.name)(`)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(this._arguments[i])
					}
					
					fragments.code(')')
				}
				else if this._arguments.length == 1 && $signature.type($type.type(this._data.arguments[0].argument, this._scope, this), this._scope) == 'Array' {
					fragments.code(`\(path)._cm_\(this._data.callee.property.name).apply(\(path), `).compile(this._arguments[0]).code(')')
				}
				else {
					fragments.code(`\(path)._cm_\(this._data.callee.property.name).apply(\(path), [].concat(`)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(this._arguments[i])
					}
					
					fragments.code('))')
				}
			}
			else {
				if this._list {
					fragments.code(`\(path).\(this._data.callee.property.name)(`)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(this._arguments[i])
					}
					
					fragments.code(')')
				}
				else if this._arguments.length == 1 && $signature.type($type.type(this._data.arguments[0].argument, this._scope, this), this._scope) == 'Array' {
					fragments.code(`\(path).\(this._data.callee.property.name).apply(\(path), `).compile(this._arguments[0]).code(')')
				}
				else {
					fragments.code(`\(path).\(this._data.callee.property.name).apply(\(path), [].concat(`)
					
					for i from 0 til this._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(this._arguments[i])
					}
					
					fragments.code('))')
				}
			}
		}
	} // }}}
}