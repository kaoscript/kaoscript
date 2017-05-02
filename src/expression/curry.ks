/* class CurryExpression extends Expression {
	private {
		_arguments: Array	= []
		/* _callee */
		_callScope
		_list: Boolean		= true
		_tested: Boolean		= false
		
		_callees: Array					= []
		_defaultCallee: DefaultCallee
		_hasDefaultCallee: Boolean		= false
		_nullable: Boolean				= false
		_nullableComputed: Boolean		= false
		_object
		_property: String
		_reusable: Boolean				= false
		_reuseName: String				= null
		_type: Type
	}
	analyse() { // {{{
		/* @callee = $compile.expression(@data.callee, this)
		@callee.analyse() */
		
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
	} // }}}
	prepare() { // {{{
		/* @callee.prepare() */
		
		for argument in @arguments {
			argument.prepare()
		}
		
		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.computed {
			@object = $compile.expression(@data.callee.object, this)
			@object.analyse()
			@object.prepare()
			
			@property = @data.callee.property.name
			
			this.makeCallee(@object.type())
		}
		else {
			if 	@data.callee.kind == NodeKind::Identifier &&
				(variable ?= @scope.getVariable(@data.callee.name)) &&
				(substitute ?= variable.replaceCall?(@data, @arguments))
			{
				this.addCallee(new SubstituteCallee(@data, substitute, this))
			}
			else {
				this.addCallee(new DefaultCallee(@data, this))
			}
		}
		
		if @hasDefaultCallee {
			@callees.push(@defaultCallee)
		}
		
		if @callees.length == 1 {
			@nullable = @callees[0].isNullable()
			@nullableComputed = @callees[0].isNullableComputed()
			
			@type = @callees[0].type()
		}
		else {
			@nullable = @callees[0].isNullable()
			@nullableComputed = @callees[0].isNullableComputed()
			
			const types = [@callees[0].type()]
			
			let type
			for i from 1 til @callees.length {
				type = @callees[i].type()
				
				if !types.any(item => type.equals(item)) {
					types.push(type)
				}
				
				if @callees[i].isNullable() {
					@nullable = true
				}
				if @callees[i].isNullableComputed() {
					@nullableComputed = true
				}
			}
			
			if types.length == 1 {
				@type = types[0]
			}
			else {
				@type = new UnionType(types)
			}
		}
		console.log('-- callees --')
		console.log(@callees)
		console.log(@property)
		console.log(@type)
	} // }}}
	translate() { // {{{
		/* @callee.translate()
		
		if @data.scope.kind == ScopeKind::Argument {
			@callScope = $compile.expression(@data.scope.value, this)
			@callScope.analyse()
			@callScope.prepare()
			@callScope.translate()
		}
		
		for argument in @arguments {
			argument.translate()
		} */
		for argument in @arguments {
			argument.translate()
		}
		
		for callee in @callees {
			callee.translate()
		}
		
		if @data.scope.kind == ScopeKind::Argument {
			@callScope = $compile.expression(@data.scope.value, this)
			@callScope.analyse()
			@callScope.prepare()
			@callScope.translate()
		}
	} // }}}
	/* isNullable() { // {{{
		return @data.nullable || @callee.isNullable()
	} // }}} */
	isComputed() => @nullable && !@tested
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	addCallee(callee: Callee) { // {{{
		if callee is DefaultCallee {
			if @hasDefaultCallee {
				const t1 = @defaultCallee.type()
				if !t1.isAny() {
					const t2 = callee.type()
					
					if t2.isAny() {
						@defaultCallee = t2
					}
					else if t1 is UnionType {
						t1.addType(t2)
					}
					else if t2 is UnionType {
						t2.addType(t1)
						
						@defaultCallee = t2
					}
					else if t1.isInstanceOf(t2, this) {
						@defaultCallee = t2
					}
					else if !t2.isInstanceOf(t1, this) {
						@defaultCallee.type(new UnionType([t1, t2]))
					}
				}
			}
			else {
				@defaultCallee = callee
				@hasDefaultCallee = true
			}
		}
		else {
			@callees.push(callee)
		}
	} // }}}
	makeCallee(type) { // {{{
		//console.log('-- call.makeCallee --')
		//console.log(type)
		//console.log(@property)
		
		switch type {
			is AliasType => {
				throw new NotImplementedException(this)
			}
			is ClassType => {
				const class = type
				
				if methods ?= class.getClassMethods(@property) {
					let sealed = false
					const types = []
					const m = []
					
					let type
					for method in methods {
						if method.isSealed() {
							sealed = true
						}
						
						if method.matchArguments([argument.type() for argument in @arguments]) {
							m.push(method)
							
							type = method.returnType()
							
							if !type.isContainedIn(types) {
								types.push(type)
							}
						}
					}
					
					if types.length == 0 {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, class, false, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, this))
						}
					}
					else if types.length == 1 {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, class, false, m, types[0], this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, m, types[0], this))
						}
					}
					else {
						throw new NotImplementedException(this)
					}
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, this))
				}
			}
			is FunctionType => {
				this.makeCalleeFromReference(@scope.reference('Function'))
			}
			is NamespaceType => {
				if (fn ?= type.getProperty(@property)) && fn is FunctionType {
					if type.isSealedProperty(@property) {
						this.addCallee(new SealedFunctionCallee(@data, type, fn, fn.returnType(), this))
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, fn, fn.returnType(), this))
					}
				}
				else {
					this.makeCalleeFromReference(@scope.reference('Object'))
				}
			}
			/* is ObjectType => {
				if (fn ?= type.getProperty(@property)) && fn is FunctionType {
					if type.isSealedProperty(@property) {
						this.addCallee(new SealedFunctionCallee(@data, type, fn, fn.returnType(), this))
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, fn, fn.returnType(), this))
					}
				}
				else {
					this.makeCalleeFromReference(@scope.reference('Object'))
				}
			} */
			is ParameterType => {
				this.makeCallee(type.type())
			}
			is ReferenceType => {
				this.makeCalleeFromReference(type)
			}
			is UnionType => {
				for let type in type.types() {
					this.makeCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeCalleeFromReference(type) { // {{{
		//console.log('-- call.filterReference --')
		//console.log(type)
		
		const value = type.unalias()
		//console.log(value)
		//console.log(@property)
		
		switch value {
			is ClassType => {
				if methods ?= value.getInstanceMethods(@property) {
					let sealed = false
					const types = []
					const m = []
					
					let type
					for method in methods {
						if method.isSealed() {
							sealed = true
						}
						
						if method.matchArguments([argument.type() for argument in @arguments]) {
							m.push(method)
							
							type = method.returnType()
							
							if !type.isContainedIn(types) {
								types.push(type)
							}
						}
					}
					
					if types.length == 0 {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, value, true, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, this))
						}
					}
					else if types.length == 1 {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, value, true, m, types[0], this))
						}
						else if	@data.callee.object.kind == NodeKind::Identifier &&
								(variable ?= @scope.getVariable(@data.callee.object.name)) &&
								(substitute ?= variable.replaceMemberCall?(@property, @arguments))
						{
							this.addCallee(new SubstituteCallee(@data, substitute, types[0], this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, m, types[0], this))
						}
					}
					else {
						throw new NotImplementedException(this)
					}
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, this))
				}
			}
			is FunctionType => {
				throw new NotImplementedException(this)
			}
			is ParameterType => {
				throw new NotImplementedException(this)
			}
			is UnionType => {
				for let type in value.types() {
					this.makeCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	/* toFragments(fragments, mode) { // {{{
		if this.isNullable() && !@tested {
			fragments.wrapNullable(this).code(' ? ')
			
			@tested = true
			
			this.toFragments(fragments)
			
			fragments.code(' : undefined')
		}
		else if @list {
			this.module().flag('Helper')
			
			let kind = @data.scope.kind
			
			if kind == ScopeKind::This {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code(', ')
					.compile(@callee.caller())
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else if kind == ScopeKind::Null {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code(', null')
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.vcurry(')
					.compile(@callee)
					.code($comma)
					.compile(@callScope)
				
				for argument in @arguments {
					fragments.code($comma).compile(argument)
				}
				
				fragments.code(')')
			}
		}
		else {
			this.module().flag('Helper')
			
			let kind = @data.scope.kind
			
			if kind == ScopeKind::This {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code($comma)
					.compile(@callee.caller())
					.code($comma)
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
					
				fragments.code(')')
			}
			else if kind == ScopeKind::Null {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code(', null, ')
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
				
				fragments.code(')')
			}
			else {
				fragments
					.code($runtime.helper(this), '.curry(')
					.compile(@callee)
					.code($comma)
					.compile(@callScope)
					.code($comma)
				
				if @arguments.length == 1 && @arguments[0].type().isArray() {
					fragments.compile(@arguments[0])
				}
				else {
					fragments.code('[].concat(')
					
					for i from 0 til @arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(@arguments[i])
					}
					
					fragments.code(')')
				}
				
				fragments.code(')')
			}
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			@tested = true
			
			if @data.nullable {
				if @callee.isNullable() {
					fragments
						.wrapNullable(@callee)
						.code(' && ')
				}
				
				fragments
					.code($runtime.type(this) + '.isFunction(')
					.compileReusable(@callee)
					.code(')')
			}
			else {
				if @callee.isNullable() {
					fragments.compileNullable(@callee)
				}
			}
		}
	} // }}} */
	toFragments(fragments, mode) { // {{{
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
	} // }}}
	type() => @scope.reference('Function')
} */
class CurryExpression extends CallExpression {
	toCallFragments(fragments, mode) { // {{{
		if @callees.length == 1 {
			@callees[0].toCurryFragments(fragments, mode, this)
		}
		else if @callees.length == 2 {
			this.module().flag('Type')
			
			@callees[0].toTestFragments(fragments, this)
			
			fragments.code(' ? ')
			
			@callees[0].toCurryFragments(fragments, mode, this)
			
			fragments.code(') : ')
			
			@callees[1].toCurryFragments(fragments, mode, this)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
}