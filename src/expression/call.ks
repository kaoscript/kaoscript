const $call = {
	caller(data, node) { // {{{
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
	filterMember(variable, name, data, node) { // {{{
		if variable.kind == VariableKind::Class {
			if variable.instanceMethods[name] is Array {
				let variables: Array = []
				
				for method in variable.instanceMethods[name] {
					if $signature.matchArguments(method, data.arguments) {
						variables.push(method)
					}
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else if variable.instanceVariables[name] is Object {
				$throw('Not implemented', node)
			}
		}
		else if variable.kind == VariableKind::Enum {
			$throw('Not implemented', node)
		}
		else if variable.kind == VariableKind::TypeAlias {
			$throw('Not implemented', node)
		}
		else if variable.kind == VariableKind::Variable {
			$throw('Not implemented', node)
		}
		else {
			$throw('Not implemented', node)
		}
		
		return null
	} // }}}
	filterType(variable, name, data, node) { // {{{
		if variable.type? {
			if variable.type.properties {
				return variable.type.properties[name] if variable.type.properties[name] is Object
			}
			else if variable.type.typeName {
				if variable ?= $variable.fromType(variable.type, node) {
					return $call.filterMember(variable, name, data, node)
				}
			}
			else if variable.type.types {
				let variables: Array = []
				
				for type in variable.type.types {
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $call.filterMember(v, name, data, node))
					
					$variable.push(variables, v)
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else {
				$throw('Not implemented', node)
			}
		}
		
		return null
	} // }}}
	variable(data, node) { // {{{
		if data.callee.kind == Kind::MemberExpression {
			if !data.callee.computed && (variable ?= $variable.fromAST(data.callee.object, node)) {
				if variable.kind == VariableKind::TypeAlias {
					variable = $variable.fromType($type.unalias(variable.type, node.scope()), node)
				}
				
				let name = data.callee.property.name
				
				if variable.kind == VariableKind::Class {
					if data.callee.object.kind == Kind::Identifier {
						if variable.classMethods[name]? {
							let variables: Array = []
							
							for method in variable.classMethods[name] {
								if $signature.matchArguments(method, data.arguments) {
									variables.push(method)
								}
							}
							
							return variables[0]	if variables.length == 1
							return variables	if variables.length > 0
						}
						else if variable.classVariables[name]? {
							$throw('Not implemented', node)
						}
					}
					else {
						$throw('Not implemented', node)
					}
				}
				else {
					return $call.filterType(variable, name, data, node)
				}
			}
			
			return null
		}
		else {
			return $variable.fromAST(data.callee, node)
		}
	} // }}}
}

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
		let callee = $variable.fromAST(@data.callee, this)
		if callee?.kind == VariableKind::Class {
			$throw(`A class is not a function, 'new' operator is required at line \(@data.callee.start.line)`, this)
		}
		
		if @data.callee.kind == Kind::Identifier {
			if callee? {
				callee.callable(@data) if callee.callable?
			}
			else {
				$throw(`Undefined variable '\(@data.callee.name)' at line \(@data.callee.start.line)`, this)
			}
		}
		else if @data.callee.kind == Kind::MemberExpression {
			if (variable ?= $variable.fromAST(@data.callee.object, this)) && variable.reduce? {
				variable.reduce(@data)
			}
		}
		
		if @data.callee.kind == Kind::MemberExpression {
			@callee = new MemberExpression(@data.callee, this, this.scope())
			@callee.analyse()
		}
		else if @data.callee.kind == Kind::ThisExpression {
			@callee = new ThisExpression(@data.callee, this, this.scope())
			@callee.isMethod(true).analyse()
		}
		else {
			@callee = $compile.expression(@data.callee, this, false)
		}
		
		for argument in @data.arguments {
			if argument.kind == Kind::UnaryExpression && argument.operator.kind == UnaryOperator::Spread {
				@arguments.push($compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push($compile.expression(argument, this))
			}
		}
		
		if @data.scope.kind == ScopeModifier::Argument {
			@callScope = $compile.expression(@data.scope.value, this)
		}
		
		if !@list {
			@caller = $call.caller(@callee, this)
		}
		
		if @options.error == 'fatal' && (variable ?= $call.variable(@data, this)) {
			if variable.throws?.length > 0 {
				for name in variable.throws {
					if (error ?= @scope.getVariable(name)) && !@parent.isConsumedError(name, error) {
						$throw(`The error '\(name)' is not consumed at line \(@data.start.line)`, this)
					}
				}
			}
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
	isComputed() => this.isNullable() && !this._tested
	isNullable() => this._data.nullable || this._callee.isNullable()
	isNullableComputed() => this._data.nullable && this._callee.isNullable()
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
	toBooleanFragments(fragments, mode) { // {{{
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
				
				fragments.code(' : false')
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
						.compileNullable(this._callee)
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
	$create(data, parent, scope, @callee) { // {{{
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
						.code(`\(path)._im_\(this._data.callee.property.name).apply(\(path), [`)
						.compile(this._object)
						.code(`].concat(`)
						
					
					for i from 0 til this._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(this._arguments[i])
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