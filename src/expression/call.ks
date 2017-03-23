const $call = {
	caller(data, node) { // {{{
		if data is IdentifierLiteral {
			return data
		}
		else if data is MemberExpression {
			return data._object
		}
		else {
			throw new NotImplementedException(node)
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
				throw new NotImplementedException(node)
			}
		}
		else if variable.kind == VariableKind::Enum {
			throw new NotImplementedException(node)
		}
		else if variable.kind == VariableKind::TypeAlias {
			throw new NotImplementedException(node)
		}
		else if variable.kind == VariableKind::Variable {
			throw new NotImplementedException(node)
		}
		else {
			throw new NotImplementedException(node)
		}
		
		return null
	} // }}}
	filterType(variable, name, data, node) { // {{{
		if variable.type? {
			if variable.type is String {
				if variable ?= $variable.fromType({typeName: $identifier(variable.type)}, node) {
					return $call.filterMember(variable, name, data, node)
				}
			}
			else if variable.type.properties? {
				return variable.type.properties[name] if variable.type.properties[name] is Object
			}
			else if variable.type.typeName? {
				if variable ?= $variable.fromType(variable.type, node) {
					return $call.filterMember(variable, name, data, node)
				}
			}
			else if variable.type.types? {
				let variables: Array = []
				
				for type in variable.type.types {
					return null unless (v ?= $variable.fromType(type, node)) && (v ?= $call.filterMember(v, name, data, node))
					
					$variable.push(variables, v)
				}
				
				return variables[0]	if variables.length == 1
				return variables	if variables.length > 0
			}
			else if variable.type.parameters? {
				if variable ?= $variable.fromType({typeName: $identifier(variable.type.name)}, node) {
					return $call.filterMember(variable, name, data, node)
				}
			}
			else {
				throw new NotImplementedException(node)
			}
		}
		
		return null
	} // }}}
	variable(data, node) { // {{{
		if data.callee.kind == NodeKind::MemberExpression {
			if !data.callee.computed && (variable ?= $variable.fromAST(data.callee.object, node)) {
				if variable.kind == VariableKind::TypeAlias {
					variable = $variable.fromType($type.unalias(variable.type, node.scope()), node)
				}
				
				let name = data.callee.property.name
				
				if variable.kind == VariableKind::Class {
					if data.callee.object.kind == NodeKind::Identifier {
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
							throw new NotImplementedException(node)
						}
					}
					else {
						throw new NotImplementedException(node)
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
		_object
		_reusable		= false
		_reuseName		= null
		_sealed			= false
		_tested			= false
		_type
	}
	analyse() { // {{{
		for argument in @data.arguments {
			if argument.kind == NodeKind::UnaryExpression && argument.operator.kind == UnaryOperatorKind::Spread {
				$compile.expression(argument.argument, this).analyse()
			}
			else {
				$compile.expression(argument, this).analyse()
			}
		}
	} // }}}
	prepare() { // {{{
		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.computed && (@callee = $sealed.callee(@data.callee, @parent)) != false {
			@sealed = true
			
			@object = $compile.expression(@data.callee.object, this)
		
			@object.analyse()
			
			@object.prepare()
		}
		else {
			let callee = $variable.fromAST(@data.callee, this)
			if callee?.kind == VariableKind::Class {
				TypeException.throwConstructorWithoutNew(callee.name.name, this)
			}
			
			if @data.callee.kind == NodeKind::Identifier {
				if callee? {
					callee.callable(@data) if callee.callable?
				}
				else {
					ReferenceException.throwNotDefined(@data.callee.name, this)
				}
			}
			else if @data.callee.kind == NodeKind::MemberExpression {
				if (variable ?= $variable.fromAST(@data.callee.object, this)) && variable.reduce? {
					variable.reduce(@data)
				}
			}
			
			if @data.callee.kind == NodeKind::MemberExpression {
				@callee = new MemberExpression(@data.callee, this, this.scope())
			}
			else if @data.callee.kind == NodeKind::ThisExpression {
				@callee = new ThisExpression(@data.callee, this, this.scope())
				@callee.isMethod(true)
			}
			else {
				@callee = $compile.expression(@data.callee, this)
			}
			
			@callee.analyse()
			
			@callee.prepare()
			
			if (variable ?= $call.variable(@data, this)) && variable.throws?.length > 0 {
				for name in variable.throws {
					if error ?= @scope.getVariable(name) {
						Exception.validateReportedError(error, this)
					}
				}
			}
		}
		
		for argument in @data.arguments {
			if argument.kind == NodeKind::UnaryExpression && argument.operator.kind == UnaryOperatorKind::Spread {
				@arguments.push(argument = $compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push(argument = $compile.expression(argument, this))
			}
			
			argument.analyse()
		}
		
		for argument in @arguments {
			argument.prepare()
		}
	} // }}}
	translate() { // {{{
		for argument in @arguments {
			argument.translate()
		}
		
		if @sealed {
			@object.translate()
		}
		else {
			@callee.translate()
			
			if @data.scope.kind == ScopeKind::Argument {
				@callScope = $compile.expression(@data.scope.value, this)
				
				@callScope.analyse()
				
				@callScope.prepare()
				
				@callScope.translate()
			}
			
			if !@list {
				@caller = $call.caller(@callee, this)
				
				@caller.analyse()
				
				@caller.prepare()
				
				@caller.translate()
			}
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		if @sealed {
			if acquire {
				throw new NotImplementedException(this)
			}
		}
		else {
			if acquire {
				@reuseName = this.statement().scope().acquireTempName(this.statement())
			}
			
			@callee.acquireReusable(@data.nullable || (!@list && @data.scope.kind == ScopeKind::This))
		}
	} // }}}
	isCallable() => !@reusable
	isComputed() => @sealed ? @callee is Array : (@data.nullable || @callee.isNullable()) && !@tested
	isNullable() => @data.nullable || (@sealed ? @object.isNullable() : @callee.isNullable())
	isNullableComputed() => @sealed ? @callee is Array : this._data.nullable && this._callee.isNullable()
	releaseReusable() { // {{{
		if !@sealed {
			this.statement().scope().releaseTempName(@reuseName) if @reuseName?
			
			@callee.releaseReusable()
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if @sealed {
			if @callee is Array {
				if @callee.length == 2 {
					this.module().flag('Type')
					
					let name = null
					if @data.callee.object.kind == NodeKind::Identifier {
						if tof = $runtime.typeof(@callee[0].variable.name, this) {
							fragments.code(tof, '(').compile(@object).code(')')
						}
						else {
							fragments.code($runtime.type(this), '.is(').compile(@object).code(', ', @callee[0].variable.name, ')')
						}
					}
					else {
						name = @scope.acquireTempName()
						
						if tof = $runtime.typeof(@callee[0].variable.name, this) {
							fragments.code(tof, '(', name, ' = ').compile(@object).code(')')
						}
						else {
							fragments.code($runtime.type(this), '.is(', name, ' = ').compile(@object).code(', ', @callee[0].variable.name, ')')
						}
					}
					
					fragments.code(' ? ')
					
					fragments.code((@callee[0].variable.accessPath || ''), @callee[0].variable.sealed.name + '._im_' + @data.callee.property.name + '(')
					
					if name? {
						fragments.code(name)
					}
					else {
						fragments.compile(@object)
					}
					
					for argument in @arguments {
						fragments.code(', ').compile(argument)
					}
					
					fragments.code(') : ')
					
					fragments.code((@callee[1].variable.accessPath || ''), @callee[1].variable.sealed.name + '._im_' + @data.callee.property.name + '(')
					
					if name? {
						fragments.code(name)
					}
					else {
						fragments.compile(@object)
					}
					
					for argument in @arguments {
						fragments.code(', ').compile(argument)
					}
					
					fragments.code(')')
					
					@scope.releaseTempName(name) if name?
				}
				else {
					throw new NotImplementedException(this)
				}
			}
			else {
				let path = @callee.variable.accessPath? ? @callee.variable.accessPath + @callee.variable.sealed.name : @callee.variable.sealed.name
				
				if @callee.kind == CalleeKind::InstanceMethod {
					if @list {
						fragments
							.code(`\(path)._im_\(this._data.callee.property.name)(`)
							.compile(@object)
						
						for i from 0 til @arguments.length {
							fragments.code($comma).compile(@arguments[i])
						}
						
						fragments.code(')')
					}
					else {
						fragments
							.code(`\(path)._im_\(this._data.callee.property.name).apply(\(path), [`)
							.compile(@object)
							.code(`].concat(`)
							
						
						for i from 0 til @arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(@arguments[i])
						}
						
						fragments.code('))')
					}
				}
				else if @callee.kind == CalleeKind::ClassMethod {
					if @list {
						fragments.code(`\(path)._cm_\(this._data.callee.property.name)(`)
						
						for i from 0 til @arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(@arguments[i])
						}
						
						fragments.code(')')
					}
					else if @arguments.length == 1 && $signature.type($type.type(@data.arguments[0].argument, @scope, this), @scope) == 'Array' {
						fragments.code(`\(path)._cm_\(this._data.callee.property.name).apply(\(path), `).compile(@arguments[0]).code(')')
					}
					else {
						fragments.code(`\(path)._cm_\(this._data.callee.property.name).apply(\(path), [].concat(`)
						
						for i from 0 til @arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(@arguments[i])
						}
						
						fragments.code('))')
					}
				}
				else {
					if @list {
						fragments.code(`\(path).\(this._data.callee.property.name)(`)
						
						for i from 0 til @arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(@arguments[i])
						}
						
						fragments.code(')')
					}
					else if @arguments.length == 1 && $signature.type($type.type(@data.arguments[0].argument, @scope, this), @scope) == 'Array' {
						fragments.code(`\(path).\(this._data.callee.property.name).apply(\(path), `).compile(@arguments[0]).code(')')
					}
					else {
						fragments.code(`\(path).\(this._data.callee.property.name).apply(\(path), [].concat(`)
						
						for i from 0 til @arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(@arguments[i])
						}
						
						fragments.code('))')
					}
				}
			}
		}
		else {
			if mode == Mode::Async {
				this.toCallFragments(fragments, mode)
				
				fragments.code(', ') if @arguments.length
			}
			else {
				if @reusable {
					fragments.code(this._reuseName)
				}
				else if this.isNullable() && !@tested {
					fragments.wrapNullable(this).code(' ? ')
					
					@tested = true
					
					this.toFragments(fragments, mode)
					
					fragments.code(' : undefined')
				}
				else {
					this.toCallFragments(fragments, mode)
					
					fragments.code(')')
				}
			}
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
		if @sealed {
			this.toFragments(fragments, mode)
		}
		else {
			if mode == Mode::Async {
				this.toCallFragments(fragments, mode)
				
				fragments.code(', ') if @arguments.length
			}
			else {
				if @reusable {
					fragments.code(@reuseName)
				}
				else if this.isNullable() && !@tested {
					fragments.wrapNullable(this).code(' ? ')
					
					@tested = true
					
					this.toFragments(fragments, mode)
					
					fragments.code(' : false')
				}
				else {
					this.toCallFragments(fragments, mode)
					
					fragments.code(')')
				}
			}
		}
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
			if @list {
				if @data.scope.kind == ScopeKind::This {
					fragments.wrap(@callee, mode).code('(')
					
					for argument, index in @arguments {
						fragments.code($comma) if index
						
						fragments.compile(argument, mode)
					}
				}
				else if @data.scope.kind == ScopeKind::Null {
					fragments.wrap(@callee, mode).code('.call(null')
					
					for argument in @arguments {
						fragments.code($comma).compile(argument, mode)
					}
				}
				else {
					fragments.wrap(@callee, mode).code('.call(').compile(@callScope, mode)
					
					for argument in @arguments {
						fragments.code($comma).compile(argument, mode)
					}
				}
			}
			else {
				if @data.scope.kind == ScopeKind::Null {
					fragments
						.wrap(@callee, mode)
						.code('.apply(null')
				}
				else if @data.scope.kind == ScopeKind::This {
					fragments
						.compileReusable(@callee)
						.code('.apply(')
						.compile(@caller, mode)
				}
				else {
					fragments
						.wrap(@callee, mode)
						.code('.apply(')
						.compile(@callScope, mode)
				}
				
				if @arguments.length == 1 && $signature.type($type.type(@data.arguments[0].argument, @scope, this), @scope) == 'Array' {
					fragments.code($comma).compile(@arguments[0])
				}
				else {
					fragments.code(', [].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
			if !@tested {
				@tested = true
				
				if @data.nullable {
					if @callee.isNullable() {
						fragments
							.compileNullable(@callee)
							.code(' && ')
					}
					
					fragments
						.code($runtime.type(this) + '.isFunction(')
						.compileReusable(@callee)
						.code(')')
				}
				else if @callee.isNullable() {
					fragments.compileNullable(@callee)
				}
				else {
					fragments
						.code($runtime.type(this) + '.isValue(')
						.compileReusable(this)
						.code(')')
				}
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		if @sealed {
			throw new NotImplementedException(this)
		}
		else {
			fragments
				.code(@reuseName, $equals)
				.compile(this)
			
			@reusable = true
		}
	} // }}}
}