class CallExpression extends Expression {
	private {
		_arguments: Array				= []
		_await: Boolean					= false
		_callees: Array					= []
		_callScope
		_defaultCallee: DefaultCallee
		_flatten: Boolean				= false
		_hasDefaultCallee: Boolean		= false
		_nullable: Boolean				= false
		_nullableComputed: Boolean		= false
		_object							= null
		_property: String
		_reusable: Boolean				= false
		_reuseName: String?				= null
		_tested: Boolean				= false
		_type: Type
	}
	static {
		toFlattenArgumentsFragments(fragments, arguments, prefill = null) { // {{{
			if arguments.length == 1 && prefill == null && arguments[0].argument().type().isArray() {
				fragments.compile(arguments[0].argument())
			}
			else {
				if prefill == null {
					fragments.code('[].concat(')
				}
				else {
					fragments.code('[').compile(prefill).code('].concat(')
				}

				let opened = false

				for argument, index in arguments {
					if argument is UnaryOperatorSpread {
						if opened {
							fragments.code('], ')

							opened = false
						}
						else if index != 0 {
							fragments.code($comma)
						}

						fragments.compile(argument.argument())
					}
					else {
						if index != 0 {
							fragments.code($comma)
						}

						if !opened {
							fragments.code('[')

							opened = true
						}

						fragments.compile(argument)
					}
				}

				if opened {
					fragments.code(']')
				}

				fragments.code(')')
			}
		} // }}}
	}
	analyse() { // {{{
		if @data.arguments.length == 1 {
			@arguments.push(argument = $compile.expression(@data.arguments[0], this))

			argument.analyse()

			if argument.isAwait() {
				@await = true
			}
		}
		else {
			const es5 = @options.format.spreads == 'es5'

			for argument in @data.arguments {
				@arguments.push(argument = $compile.expression(argument, this))

				argument.analyse()

				if es5 && argument is UnaryOperatorSpread {
					@flatten = true
				}
				else if argument.isAwait() {
					@await = true
				}
			}
		}

		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.computed {
			@object = $compile.expression(@data.callee.object, this)
			@object.analyse()
		}
	} // }}}
	prepare() { // {{{
		for const argument in @arguments {
			argument.prepare()
		}

		if @options.format.spreads == 'es5' {
			for const argument in @arguments until @flatten {
				if argument is UnaryOperatorSpread {
					@flatten = true
				}
			}
		}
		else {
			for const argument in @arguments until @flatten {
				if argument is UnaryOperatorSpread && !argument.argument().type().isArray() {
					@flatten = true
				}
			}
		}

		if @object != null {
			@object.prepare()

			@property = @data.callee.property.name

			this.makeMemberCallee(@object.type())
		}
		else {
			if @data.callee.kind == NodeKind::Identifier && (variable ?= @scope.getVariable(@data.callee.name)) {
				const type = variable.getRealType()

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

				if type is FunctionType {
					this.makeCallee(type, variable.name())
				}
				else if type is OverloadedFunctionType {
					this.makeCallee(type, variable.name())
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

			@type = Type.union(this.scope(), ...types)

		}
		// console.log('-- callees --')
		// console.log(@callees)
		// console.log(@property)
		// console.log(@type)
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
			@reuseName = @scope.acquireTempName()
		}

		for callee in @callees {
			callee.acquireReusable(acquire)
		}

		for argument in @arguments {
			argument.acquireReusable(acquire)
		}
	} // }}}
	addCallee(callee: Callee) { // {{{
		if callee is DefaultCallee {
			if @hasDefaultCallee {
				const t1 = @defaultCallee.type()
				if !t1.isAny() {
					const t2 = callee.type()

					if t2.isAny() {
						@defaultCallee = callee
					}
					else if t1 is UnionType {
						t1.addType(t2)
					}
					else if t2 is UnionType {
						t2.addType(t1)

						@defaultCallee = callee
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
	inferTypes() { // {{{
		if @object == null {
			return {}
		}

		const inferables = @object.inferTypes()

		if @nullable && @object.isInferable() {
			inferables[@object.path()] = {
				isVariable: @object is IdentifierLiteral
				type: @object.type().setNullable(false)
			}
		}

		return inferables
	} // }}}
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
	isComposite() => !@reusable
	isComputed() => (@nullable || @callees.length > 1) && !@tested
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	isUsingVariable(name) { // {{{
		if @object != null {
			if @object.isUsingVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind::Identifier && @data.callee.name == name {
			return true
		}

		for const argument in @arguments {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	makeCallee(type, name) { // {{{
		switch type {
			is FunctionType => {
				const arguments = [argument.type() for argument in @arguments]

				if type.isExhaustive(this) && !type.matchArguments(arguments) {
					ReferenceException.throwNoMatchingFunction(name, arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, type, this))
				}
			}
			is OverloadedFunctionType => {
				const arguments = [argument.type() for argument in @arguments]

				const matches = Router.matchArguments(type.assessment(), arguments)

				if matches.length == 0 {
					if type.isExhaustive(this) {
						ReferenceException.throwNoMatchingFunction(name, arguments, this)
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, this))
					}
				}
				else if matches.length == 1 {
					this.addCallee(new DefaultCallee(@data, matches[0], this))
				}
				else {
					const union = new UnionType(this.scope())

					for const function in matches {
						union.addType(function.returnType())
					}

					this.addCallee(new DefaultCallee(@data, @object, union.type(), this))
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeMemberCallee(value, name: NamedType = null) { // {{{
		// console.log('-- call.makeMemberCallee --')
		// console.log(value)
		// console.log(@property)

		switch value {
			is AliasType => {
				throw new NotImplementedException(this)
			}
			is ClassVariableType => {
				this.makeMemberCalleeFromReference(value.type())
			}
			is ClassType => {
				if value.hasClassMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getClassAssessment(@property)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())
					let sealed = false

					for const method in methods {
						if method.isSealed() {
							sealed = true
						}

						union.addType(method.returnType())
					}

					name = name as NamedType

					if union.length() == 0 {
						if value.isExhaustiveClassMethod(@property, this) {
							ReferenceException.throwNoMatchingMethod(@property, name:NamedType.name(), arguments, this)
						}
						else if sealed {
							this.addCallee(new SealedMethodCallee(@data, name, false, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, this))
						}
					}
					else {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, name, false, methods, union.type(), this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, methods, union.type(), this))
						}
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotFoundMethod(@property, name:NamedType.name(), this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, this))
				}
			}
			is FunctionType => {
				this.makeMemberCalleeFromReference(@scope.reference('Function'))
			}
			is NamedType => {
				this.makeMemberCallee(value.type(), value)
			}
			is NamespaceType => {
				if const property = value.getProperty(@property) {
					if property is SealableType {
						this.makeNamespaceCallee(property.type(), property.isSealed(), name)
					}
					else {
						this.makeNamespaceCallee(property, value.isSealedProperty(@property), name)
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotDefinedProperty(@property, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, this))
				}
			}
			is ObjectType => {
				if const property = value.getProperty(@property) {
					if property is FunctionType {
						this.makeCallee(property, @property)
					}
					else if property is OverloadedFunctionType {
						this.makeCallee(property, @property)
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
				this.makeMemberCallee(value.type(), name)
			}
			is ReferenceType => {
				if value.isNullable() && !@data.callee.nullable && !this._options.rules.ignoreMisfit {
					TypeException.throwNullableCaller(@property, this)
				}

				this.makeMemberCalleeFromReference(value)
			}
			is SealableType => {
				this.makeMemberCallee(value.type(), name)
			}
			is UnionType => {
				for const type in value.types() {
					this.makeMemberCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeMemberCalleeFromReference(value, reference: ReferenceType = value) { // {{{
		// console.log('-- call.makeMemberCalleeFromReference --')
		// console.log(value)
		// console.log(@property)

		switch value {
			is AliasType => {
				this.makeMemberCalleeFromReference(value.type())
			}
			is ClassType => {
				if value.hasInstanceMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getInstanceAssessment(@property)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())
					let sealed = false

					for const method in methods {
						if method.isSealed() {
							sealed = true
						}

						union.addType(method.returnType())
					}

					if union.length() == 0 {
						if value.isExhaustiveInstanceMethod(@property, this) {
							ReferenceException.throwNoMatchingMethod(@property, reference.name(), arguments, this)
						}
						else if sealed {
							this.addCallee(new SealedMethodCallee(@data, reference.type(), true, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, this))
						}
					}
					else {
						if sealed {
							this.addCallee(new SealedMethodCallee(@data, reference.type(), true, methods, union.type(), this))
						}
						else if	@data.callee.object.kind == NodeKind::Identifier &&
								(callee ?= @scope.getVariable(@data.callee.object.name)) &&
								(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
						{
							this.addCallee(new SubstituteCallee(@data, substitute, union.type(), this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, methods, union.type(), this))
						}
					}
				}
				else if	@data.callee.object.kind == NodeKind::Identifier &&
						(callee ?= @scope.getVariable(@data.callee.object.name)) &&
						(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
				{
					this.addCallee(new SubstituteCallee(@data, substitute, Type.Any, this))
				}
				else {
					const arguments = [argument.type() for const argument in @arguments]

					if value.getAbstractMethod(@property, arguments) {
						this.addCallee(new DefaultCallee(@data, @object, this))
					}
					else if reference.isExhaustive(this) {
						ReferenceException.throwNotFoundMethod(@property, reference.name(), this)
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, this))
					}
				}
			}
			is FunctionType => {
				throw new NotImplementedException(this)
			}
			is NamedType => {
				this.makeMemberCalleeFromReference(value.type(), reference)
			}
			is ParameterType => {
				throw new NotImplementedException(this)
			}
			is ReferenceType => {
				this.makeMemberCalleeFromReference(value.type(), value)
			}
			is UnionType => {
				for const type in value.types() {
					this.makeMemberCallee(type)
				}
			}
			=> {
				this.addCallee(new DefaultCallee(@data, @object, this))
			}
		}
	} // }}}
	makeNamespaceCallee(property, sealed, name) { // {{{
		if property is FunctionType {
			if sealed {
				this.addCallee(new SealedFunctionCallee(@data, name, property, property.returnType(), this))
			}
			else {
				this.makeCallee(property, @property)
			}
		}
		else if property is OverloadedFunctionType {
			this.makeCallee(property, @property)
		}
		else {
			this.addCallee(new DefaultCallee(@data, @object, property, this))
		}
	} // }}}
	releaseReusable() { // {{{
		if @reuseName? {
			@scope.releaseTempName(@reuseName)
		}

		for callee in @callees {
			callee.releaseReusable()
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
			Exception.validateReportedError(throw.discardReference(), node)
		}
	} // }}}
}

class DefaultCallee extends Callee {
	private {
		_data
		_expression
		_flatten: Boolean
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

		@flatten = node._flatten
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind

		const type = @expression.type()

		if type.isClass() {
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

		@flatten = node._flatten
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind

		if type.isClass() {
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

		@flatten = node._flatten
		@nullable = data.nullable || @expression.isNullable()
		@nullableComputed = data.nullable && @expression.isNullable()
		@scope = data.scope.kind

		for method in methods {
			this.validate(method, node)
		}

		if @type.isClass() {
			TypeException.throwConstructorWithoutNew(@type.name(), node)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@expression.acquireReusable(@data.nullable || (@flatten && @scope == ScopeKind::This))
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	releaseReusable() { // {{{
		@expression.releaseReusable()
	} // }}}
	toFragments(fragments, mode, node) { // {{{
		if @flatten {
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

			CallExpression.toFlattenArgumentsFragments(fragments.code($comma), node._arguments)
		}
		else {
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
	} // }}}
	toCurryFragments(fragments, mode, node) { // {{{
		node.module().flag('Helper')

		const arguments = node._arguments

		if @flatten {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
						.code($comma)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code(', null, ')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.curry(')
						.compile(@expression)
						.code($comma)
						.compile(@expression.caller())
						.code($comma)
				}
			}

			CallExpression.toFlattenArgumentsFragments(fragments, arguments)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code($comma)
						.compile(node._callScope)
				}
				ScopeKind::Null => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', null')
				}
				ScopeKind::This => {
					fragments
						.code($runtime.helper(node), '.vcurry(')
						.compile(@expression)
						.code(', ')
						.compile(@expression.caller())
				}
			}

			for argument in arguments {
				fragments.code($comma).compile(argument)
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
		_nullable: Boolean
		_nullableComputed: Boolean
		_object
		_property: String
		_type: Type
		_variable: NamedType<NamespaceType>
	}
	constructor(data, @variable, function, @type, node) { // {{{
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
		if node._flatten {
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
					fragments.code(`\(@variable.getSealedName()).\(@property)(`)

					for i from 0 til node._arguments.length {
						if i != 0 {
							fragments.code($comma)
						}

						fragments.compile(node._arguments[i])
					}
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
		_instance: Boolean
		_node
		_nullable: Boolean
		_nullableComputed: Boolean
		_object
		_property: String
		_type: Type
		_variable: NamedType<ClassType>
	}
	constructor(data, @variable, @instance, methods = [], @type = Type.Any, @node) { // {{{
		super()

		@object = node._object
		@property = node._property

		@nullable = data.nullable || data.callee.nullable
		@nullableComputed = data.nullable && data.callee.nullable

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
		if node._flatten {
			switch node._data.scope.kind {
				ScopeKind::Argument => {
					throw new NotImplementedException(node)
				}
				ScopeKind::Null => {
					throw new NotImplementedException(node)
				}
				ScopeKind::This => {
					if @instance {
						fragments.code(`\(@variable.getSealedPath())._im_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments, @object)
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._cm_\(@property).apply(null, `)

						CallExpression.toFlattenArgumentsFragments(fragments, node._arguments)
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
					if @instance {
						fragments
							.code(`\(@variable.getSealedPath())._im_\(@property)(`)
							.compile(@object)

						for i from 0 til node._arguments.length {
							fragments.code($comma).compile(node._arguments[i])
						}
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._cm_\(@property)(`)

						for i from 0 til node._arguments.length {
							fragments.code($comma) if i != 0

							fragments.compile(node._arguments[i])
						}
					}
				}
			}
		}
	} // }}}
	toNullableFragments(fragments, node) { // {{{
		fragments
			.code($runtime.type(node) + '.isValue(')
			.compile(@object)
			.code(')')
	} // }}}
	toTestFragments(fragments, node) { // {{{
		@node.scope().reference(@variable).toTestFragments(fragments, @object)
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