class CallExpression extends Expression {
	private {
		_arguments: Array				= []
		_await: Boolean					= false
		_callees: Array					= []
		_callScope
		_defaultCallee: DefaultCallee
		_hasDefaultCallee: Boolean		= false
		_list: Boolean					= true
		_nullable: Boolean				= false
		_nullableComputed: Boolean		= false
		_object
		_property: String
		_reusable: Boolean				= false
		_reuseName: String				= null
		_tested: Boolean				= false
		_type: Type
	}
	analyse() { // {{{
		for argument in @data.arguments {
			if argument.kind == NodeKind::UnaryExpression && argument.operator.kind == UnaryOperatorKind::Spread {
				@arguments.push(argument = $compile.expression(argument.argument, this))
				
				@list = false
			}
			else {
				@arguments.push(argument = $compile.expression(argument, this))
			}
			
			argument.analyse()
			
			if argument.isAwait() {
				@await = true
			}
		}
	} // }}}
	prepare() { // {{{
		for argument in @arguments {
			argument.prepare()
		}
		
		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.computed {
			@object = $compile.expression(@data.callee.object, this)
			@object.analyse()
			@object.prepare()
			
			@property = @data.callee.property.name
			
			this.makeMemberCallee(@object.type())
		}
		else {
			if @data.callee.kind == NodeKind::Identifier && (variable ?= @scope.getVariable(@data.callee.name)) {
				const type = variable.type()
				
				if type.isFunction() {
					if type.isAsync() {
						if @parent is VariableDeclaration {
							if !@parent.isAwait() {
								TypeException.throwNotSyncFunction(@data.callee.name, this)
							}
						}
						else if @parent is not AwaitExpression {
							TypeException.throwNotSyncFunction(@data.callee.name, this)
						}
					}
					else {
						if @parent is VariableDeclaration {
							if @parent.isAwait() {
								TypeException.throwNotAsyncFunction(@data.callee.name, this)
							}
						}
						else if @parent is AwaitExpression {
							TypeException.throwNotAsyncFunction(@data.callee.name, this)
						}
					}
				}
				
				if type is OverloadedFunctionType {
					this.makeCallee(type)
				}
				else {
					if substitute ?= variable.replaceCall?(@data, @arguments) {
						this.addCallee(new SubstituteCallee(@data, substitute, this))
					}
					else {
						this.addCallee(new DefaultCallee(@data, this))
					}
				}
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
		//console.log('-- callees --')
		//console.log(@callees)
		//console.log(@property)
		//console.log(@type)
	} // }}}
	translate() { // {{{
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
	acquireReusable(acquire) { // {{{
		if acquire {
			@reuseName = this.statement().scope().acquireTempName(this.statement())
		}
		
		if @callees.length == 1 {
			@callees[0].acquireReusable(acquire)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
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
	arguments() => @arguments
	isAwait() => @await
	isAwaiting() { // {{{
		for argument in @arguments {
			if argument.isAwaiting() {
				return true
			}
		}
		
		return false
	} // }}}
	isCallable() => !@reusable
	isComputed() => @nullable && !@tested
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	makeCallee(type) { // {{{
		switch type {
			is OverloadedFunctionType => {
				const args = [argument.type() for argument in @arguments]
				const matches = []
				
				for function in type.functions() {
					if function.matchArguments(args) {
						matches.push(function)
					}
				}
				
				if matches.length == 0 {
					TypeException.throwNoMatchingFunction(this)
				}
				else if matches.length == 1 {
					this.addCallee(new DefaultCallee(@data, matches[0], this))
				}
				else {
					const type = new UnionType()
					
					for function in matches {
						type.addType(function.returnType())
					}
					
					this.addCallee(new DefaultCallee(@data, @object, type.refine(), this))
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeMemberCallee(type) { // {{{
		//console.log('-- call.makeMemberCallee --')
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
					const args = [argument.type() for argument in @arguments]
					
					let type
					for method in methods {
						if method.isSealed() {
							sealed = true
						}
						
						if method.matchArguments(args) {
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
				this.makeMemberCalleeFromReference(@scope.reference('Function'))
			}
			is NamespaceType => {
				if property ?= type.getProperty(@property) {
					if property is FunctionType {
						if type.isSealedProperty(@property) {
							this.addCallee(new SealedFunctionCallee(@data, type, property, property.returnType(), this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, property, this))
						}
					}
					else if property is OverloadedFunctionType {
						this.makeCallee(property)
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, property, this))
					}
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, this))
				}
			}
			is ParameterType => {
				this.makeMemberCallee(type.type())
			}
			is ReferenceType => {
				this.makeMemberCalleeFromReference(type)
			}
			is UnionType => {
				for let type in type.types() {
					this.makeMemberCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeMemberCalleeFromReference(type) { // {{{
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
					this.makeMemberCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	releaseReusable() { // {{{
		this.statement().scope().releaseTempName(@reuseName) if @reuseName?
		
		if @callees.length == 1 {
			@callees[0].releaseReusable()
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	toFragments(fragments, mode) { // {{{
		if mode == Mode::Async {
			for argument in @arguments {
				if argument.isAwaiting() {
					return argument.toFragments(fragments, mode)
				}
			}
			
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
				for argument in @arguments {
					if argument.isAwaiting() {
						return argument.toFragments(fragments, mode)
					}
				}
				
				this.toCallFragments(fragments, mode)
				
				fragments.code(')')
			}
		}
	} // }}}
	toBooleanFragments(fragments, mode) { // {{{
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
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		if @callees.length == 1 {
			@callees[0].toFragments(fragments, mode, this)
		}
		else if @callees.length == 2 {
			this.module().flag('Type')
			
			@callees[0].toTestFragments(fragments, this)
			
			fragments.code(' ? ')
			
			@callees[0].toFragments(fragments, mode, this)
			
			fragments.code(') : ')
			
			@callees[1].toFragments(fragments, mode, this)
		}
		else {
			throw new NotImplementedException(this)
		}
	} // }}}
	toNullableFragments(fragments) { // {{{
		if !@tested {
			@tested = true
			
			if @callees.length == 1 {
				@callees[0].toNullableFragments(fragments, this)
			}
			else {
				throw new NotImplementedException(this)
			}
		}
	} // }}}
	toReusableFragments(fragments) { // {{{
		fragments
			.code(@reuseName, $equals)
			.compile(this)
		
		@reusable = true
	} // }}}
	type() => @type
}

abstract class Callee {
	abstract isNullable(): Boolean
	abstract isNullableComputed(): Boolean
	abstract toFragments(fragments, mode, node)
	abstract translate()
	abstract type(): Type
	acquireReusable(acquire)
	releaseReusable()
	validate(type: FunctionType, node) { // {{{
		for throw in type.throws() {
			Exception.validateReportedError(throw, node)
		}
	} // }}}
}

class DefaultCallee extends Callee {
	private {
		_data
		_expression
		_list: Boolean
		_nullable: Boolean
		_nullableComputed: Boolean
		_scope: ScopeKind
		_type: Type
	}
	constructor(@data, object = null, node) { // {{{
		super()
		
		if object == null {
			@expression = $compile.expression(data.callee, node)
		}
		else {
			@expression = new MemberExpression(data.callee, node, node.scope(), object)
		}
		
		@expression.analyse()
		@expression.prepare()
		
		@list = node._list
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind
		
		const type = @expression.type()
		
		if type is ClassType {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			this.validate(type, node)
			
			@type = type.returnType()
		}
		else {
			@type = Type.Any
		}
	} // }}}
	constructor(@data, object = null, type: Type, node) { // {{{
		super()
		
		if object == null {
			@expression = $compile.expression(data.callee, node)
		}
		else {
			@expression = new MemberExpression(data.callee, node, node.scope(), object)
		}
		
		@expression.analyse()
		@expression.prepare()
		
		@list = node._list
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind
		
		if type is ClassType {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			this.validate(type, node)
			
			@type = type.returnType()
		}
		else {
			@type = Type.Any
		}
	} // }}}
	constructor(@data, object, methods, @type, node) { // {{{
		super()
		
		@expression = new MemberExpression(data.callee, node, node.scope(), object)
		@expression.analyse()
		@expression.prepare()
		
		@list = node._list
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind
		
		for method in methods {
			this.validate(method, node)
		}
		
		if @type is ClassType {
			TypeException.throwConstructorWithoutNew(@type.name(), node)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@expression.acquireReusable(@data.nullable || (!@list && @scope == ScopeKind::This))
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	releaseReusable() { // {{{
		@expression.releaseReusable()
	} // }}}
	toFragments(fragments, mode, node) { // {{{
		if @list {
			switch @scope {
				ScopeKind::Argument => {
					fragments.wrap(@expression, mode).code('.call(').compile(node._callScope, mode)
					
					for argument in node._arguments {
						fragments.code($comma).compile(argument, mode)
					}
				}
				ScopeKind::Null => {
					fragments.wrap(@expression, mode).code('.call(null')
					
					for argument in node._arguments {
						fragments.code($comma).compile(argument, mode)
					}
				}
				ScopeKind::This => {
					fragments.wrap(@expression, mode).code('(')
					
					for argument, index in node._arguments {
						fragments.code($comma) if index
						
						fragments.compile(argument, mode)
					}
				}
			}
		}
		else {
			if @scope == ScopeKind::Argument {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(node._callScope, mode)
			}
			else if @scope == ScopeKind::Null || @expression is not MemberExpression {
				fragments
					.compileReusable(@expression)
					.code('.apply(null')
			}
			else {
				fragments
					.compileReusable(@expression)
					.code('.apply(')
					.compile(@expression.caller(), mode)
			}
			
			if node._arguments.length == 1 && node._arguments[0].type().isArray() {
				fragments.code($comma).compile(node._arguments[0])
			}
			else {
				fragments.code(', [].concat(')
				
				for i from 0 til node._arguments.length {
					fragments.code($comma) if i != 0
					
					fragments.compile(node._arguments[i])
				}
				
				fragments.code(')')
			}
		}
	} // }}}
	toCurryFragments(fragments, mode, node) { // {{{
		node.module().flag('Helper')
		
		const arguments = node._arguments
		
		if @list {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
					
					for argument in arguments {
						fragments.code($comma).compile(argument)
					}
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', null')
					
					for argument in arguments {
						fragments.code($comma).compile(argument)
					}
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', ')
						.compile(@expression.caller())
					
					for argument in arguments {
						fragments.code($comma).compile(argument, mode)
					}
				}
			}
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
						.code($comma)
					
					if arguments.length == 1 && arguments[0].type().isArray() {
						fragments.compile(arguments[0])
					}
					else {
						fragments.code('[].concat(')
						
						for i from 0 til arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(arguments[i])
						}
						
						fragments.code(')')
					}
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(', null, ')
					
					if arguments.length == 1 && arguments[0].type().isArray() {
						fragments.compile(arguments[0])
					}
					else {
						fragments.code('[].concat(')
						
						for i from 0 til arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(arguments[i])
						}
						
						fragments.code(')')
					}
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code($comma)
						.compile(@expression.caller())
						.code($comma)
					
					if arguments.length == 1 && arguments[0].type().isArray() {
						fragments.compile(arguments[0])
					}
					else {
						fragments.code('[].concat(')
						
						for i from 0 til arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(arguments[i])
						}
						
						fragments.code(')')
					}
				}
			}
		}
	} // }}}
	toNullableFragments(fragments, node) { // {{{
		if @data.nullable {
			if @expression.isNullable() {
				fragments
					.compileNullable(@expression)
					.code(' && ')
			}
			
			fragments
				.code($runtime.type(node) + '.isFunction(')
				.compileReusable(@expression)
				.code(')')
		}
		else if @expression.isNullable() {
			fragments.compileNullable(@expression)
		}
		else {
			fragments
				.code($runtime.type(node) + '.isValue(')
				.compileReusable(node)
				.code(')')
		}
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	type() => @type
	type(@type) => this
}

class SealedFunctionCallee extends Callee {
	private {
		_namespace: NamespaceType
		_nullable: Boolean
		_nullableComputed: Boolean
		_object
		_property: String
		_type: Type
	}
	constructor(data, @namespace, function, @type, node) { // {{{
		super()
		
		@object = node._object
		@property = node._property
		
		nullable = data.nullable || node._object.isNullable()
		nullableComputed = data.nullable && node._object.isNullable()
		
		this.validate(function, node)
	} // }}}
	translate() { // {{{
		@object.translate()
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	toFragments(fragments, mode, node) { // {{{
		if node._list {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					fragments.code(`\(@namespace.sealName()).\(@property)(`)
					
					for i from 0 til node._arguments.length {
						if i != 0 {
							fragments.code($comma)
						}
						
						fragments.compile(node._arguments[i])
					}
				}
			}
		}
		else {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					throw new NotImplementedException(node)
				}
			}
		}
	} // }}}
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, @object)
	} // }}}
	type() => @type
}

class SealedMethodCallee extends Callee {
	private {
		_class: ClassType
		_instance: Boolean
		_nullable: Boolean
		_nullableComputed: Boolean
		_object
		_property: String
		_type: Type
	}
	constructor(data, @class, @instance, methods = [], @type = Type.Any, node) { // {{{
		super()
		
		@object = node._object
		@property = node._property
		
		nullable = data.nullable || node._object.isNullable()
		nullableComputed = data.nullable && node._object.isNullable()
		
		for method in methods {
			this.validate(method, node)
		}
	} // }}}
	translate() { // {{{
		@object.translate()
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	toFragments(fragments, mode, node) { // {{{
		if node._list {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @instance {
						fragments
							.code(`\(@class.getSealedPath())._im_\(@property)(`)
							.compile(@object)
						
						for i from 0 til node._arguments.length {
							fragments.code($comma).compile(node._arguments[i])
						}
					}
					else {
						fragments.code(`\(@class.getSealedPath())._cm_\(@property)(`)
						
						for i from 0 til node._arguments.length {
							fragments.code($comma) if i != 0
							
							fragments.compile(node._arguments[i])
						}
					}
				}
			}
		}
		else if node._arguments.length == 1 && node._arguments[0].type().isArray() {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					throw new NotImplementedException(node)
				}
			}
		}
		else {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @instance {
						fragments
							.code(`\(@class.getSealedPath())._im_\(@property).apply(\(@class.getSealedPath()), [`)
							.compile(@object)
							.code(`].concat(`)
					}
					else {
						fragments
							.code(`\(@class.getSealedPath())._cm_\(@property).apply(\(@class.getSealedPath()), [].concat(`)
					}
					
					for i from 0 til node._arguments.length {
						fragments.code($comma) if i != 0
						
						fragments.compile(node._arguments[i])
					}
					
					fragments.code(')')
				}
			}
		}
	} // }}}
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, @object)
	} // }}}
	type() => @type
}

class SubstituteCallee extends Callee {
	private {
		_substitute
		_nullable: Boolean
		_nullableComputed: Boolean
		_type: Type
	}
	constructor(data, @substitute, node) { // {{{
		super()
		
		@nullable = data.nullable || substitute.isNullable()
		@nullableComputed = data.nullable && substitute.isNullable()
		
		@type = @substitute.type()
	} // }}}
	constructor(data, @substitute, @type, node) { // {{{
		super()
		
		@nullable = data.nullable || substitute.isNullable()
		@nullableComputed = data.nullable && substitute.isNullable()
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	toFragments(fragments, mode, node) { // {{{
		@substitute.toFragments(fragments, mode)
	} // }}}
	translate()
	type() => @type
}