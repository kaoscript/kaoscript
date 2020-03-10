class CallExpression extends Expression {
	private lateinit {
		_arguments: Array				= []
		_await: Boolean					= false
		_callees: Array					= []
		_callScope
		_defaultCallee: DefaultCallee
		_flatten: Boolean				= false
		_hasDefaultCallee: Boolean		= false
		_named: Boolean					= false
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
				arguments[0].argument().toArgumentFragments(fragments)
			}
			else {
				if prefill == null {
					fragments.code('[].concat(')
				}
				else {
					fragments.code('[').compile(prefill).code('].concat(')
				}

				let opened = false

				for const argument, index in arguments {
					if argument is UnaryOperatorSpread {
						if opened {
							fragments.code('], ')

							opened = false
						}
						else if index != 0 {
							fragments.code($comma)
						}

						argument.argument().toArgumentFragments(fragments)
					}
					else {
						if index != 0 {
							fragments.code($comma)
						}

						if !opened {
							fragments.code('[')

							opened = true
						}

						argument.toArgumentFragments(fragments)
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
		const es5 = @data.arguments.length != 1 && @options.format.spreads == 'es5'

		for const data in @data.arguments {
			const argument = $compile.expression(data, this)

			argument.analyse()

			if es5 && argument is UnaryOperatorSpread {
				@flatten = true
			}
			else if argument.isAwait() {
				@await = true
			}

			if argument is NamedArgument {
				@named = true
			}

			@arguments.push(argument)
		}

		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.modifiers.some(modifier => modifier.kind == ModifierKind::Computed) {
			@object = $compile.expression(@data.callee.object, this)
			@object.analyse()
		}
	} // }}}
	prepare() { // {{{
		for const argument in @arguments {
			argument.prepare()

			if argument.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(argument, this)
			}
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
			if @named {
				NotImplementedException.throw(this)
			}

			@object.prepare()

			@property = @data.callee.property.name

			this.makeMemberCallee(@object.type())
		}
		else {
			if @data.callee.kind == NodeKind::Identifier {
				if const variable = @scope.getVariable(@data.callee.name) {
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

					if const substitute = variable.replaceCall?(@data, @arguments) {
						this.addCallee(new SubstituteCallee(@data, substitute, this))
					}
					else {
						this.makeCallee(type, variable.name())
					}

					if @named {
						if type.isStruct() || type.isTuple() {
							@arguments = type.discard().sortArguments(@arguments, this)
						}
						else {
							NotImplementedException.throw(this)
						}
					}
				}
				else {
					ReferenceException.throwUndefinedFunction(@data.callee.name, this)
				}
			}
			else {
				if @named {
					NotImplementedException.throw(this)
				}

				this.addCallee(new DefaultCallee(@data, null, null, this))
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
		for const argument in @arguments {
			argument.translate()
		}

		for const callee in @callees {
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
	inferTypes(inferables) { // {{{
		if @object != null {
			@object.inferTypes(inferables)

			if @nullable && @object.isInferable() {
				inferables[@object.path()] = {
					isVariable: @object is IdentifierLiteral
					type: @object.type().setNullable(false)
				}
			}
		}

		for const argument in @arguments {
			argument.inferTypes(inferables)
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
	isExit() => @type.isNever()
	isExpectingType() => true
	override isInitializingInstanceVariable(name) { // {{{
		for const argument in @arguments {
			if argument.isInitializingInstanceVariable(name) {
				return true
			}
		}

		for const callee in @callees {
			if !callee.isInitializingInstanceVariable(name) {
				return false
			}
		}

		return true
	} // }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	isUsingInstanceVariable(name) { // {{{
		if @object != null {
			if @object.isUsingInstanceVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind::Identifier && @data.callee.name == name {
			return true
		}

		for const argument in @arguments {
			if argument.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} // }}}
	override isUsingNonLocalVariables(scope) { // {{{
		if @object != null {
			return true if @object.isUsingNonLocalVariables(scope)
		}
		else if @data.callee.kind == NodeKind::Identifier {
			const variable = @scope.getVariable(@data.callee.name)

			if !scope.hasDeclaredVariable(variable.name()) {
				return true
			}
		}

		for const argument in @arguments {
			return true if argument.isUsingNonLocalVariables(scope)
		}

		return false
	} // }}}
	isUsingStaticVariable(class, varname) { // {{{
		if @object != null {
			if @object.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		for const argument in @arguments {
			if argument.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} // }}}
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
	override listLocalVariables(scope, variables) { // {{{
		if @object != null {
			@object.listLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind::Identifier {
			const variable = @scope.getVariable(@data.callee.name)

			if scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for const argument in @arguments {
			argument.listLocalVariables(scope, variables)
		}

		return variables
	} // }}}
	override listNonLocalVariables(scope, variables) { // {{{
		if @object != null {
			@object.listNonLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind::Identifier {
			const variable = @scope.getVariable(@data.callee.name)

			if !variable.isModule() && !scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for const argument in @arguments {
			argument.listNonLocalVariables(scope, variables)
		}

		return variables
	} // }}}
	makeCallee(type: Type, name: String?) { // {{{
		if type is FunctionType {
			if type.isExhaustive(this) && !type.matchArguments(@arguments) {
				ReferenceException.throwNoMatchingFunction(name, @arguments, this)
			}
			else {
				this.addCallee(new DefaultCallee(@data, @object, type, this))
			}
		}
		else if type is OverloadedFunctionType {
			const arguments = [argument.type() for argument in @arguments]

			const matches = Router.matchArguments(type.assessment(name!!, this), arguments)

			if matches.length == 0 {
				if type.isExhaustive(this) {
					ReferenceException.throwNoMatchingFunction(name, @arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			else if matches.length == 1 {
				this.addCallee(new DefaultCallee(@data, @object, matches[0], this))
			}
			else {
				const union = new UnionType(this.scope())

				for const function in matches {
					union.addType(function.getReturnType())
				}

				this.addCallee(new DefaultCallee(@data, @object, union.type(), this))
			}
		}
		else if type.isStruct() || type.isTuple() {
			type.isExhaustive(this) && type.type().matchArguments(name, @arguments, this)

			this.addCallee(new DefaultCallee(@data, @object, type, this))
		}
		else {
			this.addCallee(new DefaultCallee(@data, @object, null, this))
		}
	} // }}}
	makeMemberCallee(value, name: NamedType = null) { // {{{
		// console.log('-- call.makeMemberCallee --')
		// console.log(value)
		// console.log(@property)

		switch value {
			is AliasType => {
				this.makeMemberCallee(value.type(), name)
			}
			is ClassVariableType => {
				this.makeMemberCalleeFromReference(value.type())
			}
			is ClassType => {
				name = name as NamedType

				if value.hasClassMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getClassAssessment(@property, this)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())
					let sealed = false

					for const method in methods {
						if method.isSealed() {
							sealed = true
						}

						union.addType(method.getReturnType())
					}

					if union.length() == 0 {
						if value.isExhaustiveClassMethod(@property, this) {
							ReferenceException.throwNoMatchingClassMethod(@property, name.name(), arguments, this)
						}
						else if sealed {
							this.addCallee(new SealedMethodCallee(@data, name, false, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
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
					ReferenceException.throwNotFoundClassMethod(@property, name.name(), this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is DictionaryType => {
				if const property = value.getProperty(@property) {
					this.makeCallee(property, @property)
				}
				else {
					this.makeMemberCalleeFromReference(@scope.reference('Dictionary'))
				}
			}
			is EnumType => {
				name = name as NamedType

				if value.hasStaticMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getStaticAssessment(@property, this)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())

					for const method in methods {
						union.addType(method.getReturnType())
					}

					if union.length() == 0 {
						if value.isExhaustiveStaticMethod(@property, this) {
							ReferenceException.throwNoMatchingEnumMethod(@property, name.name(), arguments, this)
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
						}
					}
					else {
						this.addCallee(new DefaultCallee(@data, @object, methods, union.type(), this))
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotFoundEnumMethod(@property, name.name(), this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is ExclusionType => {
				this.makeMemberCallee(value.getMainType())
			}
			is FunctionType => {
				this.makeMemberCalleeFromReference(@scope.reference('Function'))
			}
			is NamedType => {
				this.makeMemberCallee(value.type(), value)
			}
			is NamespaceType => {
				if const property = value.getProperty(@property) {
					if property is FunctionType || property is OverloadedFunctionType {
						if property.isExhaustive(this) && !property.matchArguments(@arguments) {
							ReferenceException.throwNoMatchingFunctionInNamespace(@property, name, @arguments, this)
						}
					}

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
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is ParameterType => {
				this.makeMemberCallee(value.type(), name)
			}
			is ReferenceType => {
				if value.isNullable() && !@options.rules.ignoreMisfit {
					unless @data.callee.modifiers.some(modifier => modifier.kind == ModifierKind::Nullable) {
						TypeException.throwNullableCaller(@property, this)
					}
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
				this.addCallee(new DefaultCallee(@data, @object, null, this))
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
				if value.hasInstantiableMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getInstantiableAssessment(@property, this)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())
					let sealed = false

					for const method in methods {
						if method.isSealed() {
							sealed = true
						}

						union.addType(method.getReturnType())
					}

					if union.length() == 0 {
						if value.isExhaustiveInstanceMethod(@property, this) {
							ReferenceException.throwNoMatchingClassMethod(@property, reference.name(), arguments, this)
						}
						else if sealed {
							this.addCallee(new SealedMethodCallee(@data, reference.type(), true, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
						}
					}
					else {
						if sealed {
							const type = value.getClassWithInstanceMethod(@property, reference.type())

							if	@data.callee.object.kind == NodeKind::Identifier &&
								(callee ?= @scope.getVariable(@data.callee.object.name)) &&
								(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
							{
								this.addCallee(new SubstituteCallee(@data, substitute, union.type(), this))
							}
							else {
								this.addCallee(new SealedMethodCallee(@data, type, true, methods, union.type(), this))
							}
						}
						else {
							if	@data.callee.object.kind == NodeKind::Identifier &&
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
				}
				else if	@data.callee.object.kind == NodeKind::Identifier &&
						(callee ?= @scope.getVariable(@data.callee.object.name)) &&
						(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
				{
					this.addCallee(new SubstituteCallee(@data, substitute, Type.Any, this))
				}
				else if reference.isExhaustive(this) {
					ReferenceException.throwNotFoundClassMethod(@property, reference.name(), this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is EnumType => {
				if value.hasInstanceMethod(@property) {
					const arguments = [argument.type() for const argument in @arguments]

					const assessment = value.getInstanceAssessment(@property, this)

					const methods = Router.matchArguments(assessment, arguments)

					const union = new UnionType(this.scope())

					for const method in methods {
						union.addType(method.getReturnType())
					}

					if union.length() == 0 {
						if value.isExhaustiveInstanceMethod(@property, this) {
							ReferenceException.throwNoMatchingEnumMethod(@property, reference.name(), arguments, this)
						}
						else {
							this.addCallee(new EnumMethodCallee(@data, reference.discardReference(), `__ks_func_\(@property)`, null, null, this))
						}
					}
					else {
						this.addCallee(new EnumMethodCallee(@data, reference.discardReference(), `__ks_func_\(@property)`, methods, union.type(), this))
					}
				}
				else if reference.isExhaustive(this) {
					ReferenceException.throwNotFoundEnumMethod(@property, reference.name(), this)
				}
				else {
					this.addCallee(new EnumMethodCallee(@data, reference.discardReference(), `__ks_func_\(@property)`, null, null, this))
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
				this.addCallee(new DefaultCallee(@data, @object, null, this))
			}
		}
	} // }}}
	makeNamespaceCallee(property, sealed, name) { // {{{
		if property is FunctionType {
			if sealed {
				this.addCallee(new SealedFunctionCallee(@data, name, property, property.getReturnType(), this))
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
			for const argument in @arguments {
				if argument.isAwaiting() {
					return argument.toFragments(fragments, mode)
				}
			}

			this.toCallFragments(fragments, mode)

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)
			}
			else if this.isNullable() && !@tested {
				fragments.wrapNullable(this).code(' ? ')

				@tested = true

				this.toFragments(fragments, mode)

				fragments.code(' : null')
			}
			else {
				for const argument in @arguments {
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

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
			else if this.isNullable() && !@tested {
				fragments.wrapNullable(this).code(' ? ')

				@tested = true

				this.toFragments(fragments, mode)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}

				fragments.code(' : false')
			}
			else {
				this.toCallFragments(fragments, mode)

				fragments.code(')')

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
		}
	} // }}}
	toCallFragments(fragments, mode) { // {{{
		if @callees.length == 1 {
			@callees[0].toFragments(fragments, mode, this)
		}
		else {
			this.module().flag('Type')

			for const callee in @callees til -1 {
				callee.toPositiveTestFragments(fragments, this)

				fragments.code(' ? ')

				callee.toFragments(fragments, mode, this)

				fragments.code(') : ')

			}

			@callees.last().toFragments(fragments, mode, this)
		}
	} // }}}
	toQuote() { // {{{
		let fragments = ''

		if @object != null {
			fragments += @object.toQuote()
		}
		else if @data.callee.kind == NodeKind::Identifier {
			fragments += @data.callee.name
		}
		else {
			NotImplementedException.throw(this)
		}

		fragments += '()'

		return fragments
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
	private {
		_data
		_nullable: Boolean			= false
		_nullableProperty: Boolean	= false
	}
	constructor(@data) { // {{{
		for const modifier in data.modifiers {
			if modifier.kind == ModifierKind::Nullable {
				@nullable = true
			}
		}
	} // }}}
	acquireReusable(acquire)
	isNullable() => @nullable || @nullableProperty
	isNullableComputed() => @nullable && @nullableProperty
	releaseReusable()
	abstract toFragments(fragments, mode, node)
	abstract translate()
	abstract type(): Type
	validate(type: FunctionType, node) { // {{{
		for const throw in type.throws() {
			Exception.validateReportedError(throw.discardReference(), node)
		}
	} // }}}
}

class DefaultCallee extends Callee {
	private {
		_expression
		_flatten: Boolean
		_methods: Array<FunctionType>?
		_scope: ScopeKind
		_type: Type
	}
	constructor(@data, object! = null, type!: Type = null, node) { // {{{
		super(data)

		if object == null {
			@expression = $compile.expression(data.callee, node)
		}
		else {
			@expression = new MemberExpression(data.callee, node, node.scope(), object)
		}

		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		type ??= @expression.type()

		if type.isClass() {
			TypeException.throwConstructorWithoutNew(type.name(), node)
		}
		else if type is FunctionType {
			this.validate(type, node)

			@type = type.getReturnType()
		}
		else if type.isStruct() || type.isTuple() {
			@type = node.scope().reference(type)
		}
		else {
			@type = AnyType.NullableUnexplicit
		}
	} // }}}
	constructor(@data, object, @methods, @type, node) { // {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), object)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		for method in methods {
			this.validate(method, node)
		}

		if @type.isClass() {
			TypeException.throwConstructorWithoutNew(@type.name(), node)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@expression.acquireReusable(@nullable || (@flatten && @scope == ScopeKind::This))
	} // }}}
	isInitializingInstanceVariable(name: String): Boolean { // {{{
		if @methods? {
			for const method in @methods {
				if !method.isInitializingInstanceVariable(name) {
					return false
				}
			}

			return true
		}
		else {
			return false
		}
	} // }}}
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

					for const argument in node._arguments {
						fragments.code($comma)

						argument.toArgumentFragments(fragments, mode)
					}
				}
				ScopeKind::Null => {
					fragments.wrap(@expression, mode).code('.call(null')

					for const argument in node._arguments {
						fragments.code($comma)

						argument.toArgumentFragments(fragments, mode)
					}
				}
				ScopeKind::This => {
					fragments.wrap(@expression, mode).code('(')

					for const argument, index in node._arguments {
						fragments.code($comma) if index != 0

						argument.toArgumentFragments(fragments, mode)
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
				fragments.code($comma)

				argument.toArgumentFragments(fragments, mode)
			}
		}
	} // }}}
	toNullableFragments(fragments, node) { // {{{
		if @nullable {
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
		_function
		_object
		_property: String
		_type: Type
		_variable: NamedType<NamespaceType>
	}
	constructor(@data, @variable, @function, @type, node) { // {{{
		super(data)

		@object = node._object
		@property = node._property

		@nullableProperty = node._object.isNullable()

		this.validate(function, node)
	} // }}}
	translate() { // {{{
		@object.translate()
	} // }}}
	isInitializingInstanceVariable(name: String): Boolean => @function.isInitializingInstanceVariable(name)
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

					for const argument, index in node._arguments {
						if index != 0 {
							fragments.code($comma)
						}

						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} // }}}
	toPositiveTestFragments(fragments, node) { // {{{
		@type.toPositiveTestFragments(fragments, @object)
	} // }}}
	type() => @type
}

class SealedMethodCallee extends Callee {
	private {
		_instance: Boolean
		_methods: Array
		_node
		_object
		_property: String
		_type: Type
		_variable: NamedType<ClassType>
	}
	constructor(@data, @variable, @instance, @methods = [], @type = AnyType.NullableUnexplicit, @node) { // {{{
		super(data)

		@object = node._object
		@property = node._property

		@nullableProperty = data.callee.modifiers.some(modifier => modifier.kind == ModifierKind::Nullable)

		for const method in methods {
			this.validate(method, node)
		}
	} // }}}
	translate() { // {{{
		@object.translate()
	} // }}}
	isInitializingInstanceVariable(name: String): Boolean { // {{{
		if @methods.length == 0 {
			let class = @variable.type()

			if @instance {
				while true {
					if const methods = class.listInstanceMethods(@property) {
						for const method in methods {
							if !method.isInitializingInstanceVariable(name) {
								return false
							}
						}
					}

					if class.isExtending() {
						class = class.extends().type()
					}
					else {
						break
					}
				}
			}
			else {
				while true {
					if const methods = class.listClassMethods(@property) {
						for const method in methods {
							if !method.isInitializingInstanceVariable(name) {
								return false
							}
						}
					}

					if class.isExtending() {
						class = class.extends().type()
					}
					else {
						break
					}
				}
			}
		}
		else {
			for const method in @methods {
				if !method.isInitializingInstanceVariable(name) {
					return false
				}
			}
		}

		return true
	} // }}}
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

						for const argument in node._arguments {
							fragments.code($comma)

							argument.toArgumentFragments(fragments, mode)
						}
					}
					else {
						fragments.code(`\(@variable.getSealedPath())._cm_\(@property)(`)

						for const argument, index in node._arguments {
							if index != 0 {
								fragments.code($comma)
							}

							argument.toArgumentFragments(fragments, mode)
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
	toPositiveTestFragments(fragments, node) { // {{{
		@node.scope().reference(@variable).toPositiveTestFragments(fragments, @object)
	} // }}}
	type() => @type
}

class SubstituteCallee extends Callee {
	private {
		_substitute
		_type: Type
	}
	constructor(@data, @substitute, node) { // {{{
		super(data)

		@nullableProperty = substitute.isNullable()

		@type = @substitute.type()
	} // }}}
	constructor(@data, @substitute, @type, node) { // {{{
		super(data)

		@nullableProperty = substitute.isNullable()
	} // }}}
	isInitializingInstanceVariable(name: String): Boolean => @substitute.isInitializingInstanceVariable(name)
	toFragments(fragments, mode, node) { // {{{
		@substitute.toFragments(fragments, mode)
	} // }}}
	translate()
	type() => @type
}

class EnumMethodCallee extends Callee {
	private {
		_enum: NamedType<EnumType>
		_expression
		_flatten: Boolean
		_methodName: String
		_methods: Array<FunctionType>?
		_scope: ScopeKind
		_type: Type
	}
	constructor(@data, @enum, @methodName, @methods, type: Type?, node) { // {{{
		super(data)

		@expression = new MemberExpression(data.callee, node, node.scope(), node._object)
		@expression.analyse()
		@expression.prepare()

		@flatten = node._flatten
		@nullableProperty = @expression.isNullable()
		@scope = data.scope.kind

		@type = type ?? @expression.type()

		for method in methods {
			this.validate(method, node)
		}
	} // }}}
	acquireReusable(acquire) { // {{{
		@expression.acquireReusable(@nullable || (@flatten && @scope == ScopeKind::This))
	} // }}}
	isInitializingInstanceVariable(name: String): Boolean { // {{{
		if @methods? {
			for const method in @methods {
				if !method.isInitializingInstanceVariable(name) {
					return false
				}
			}

			return true
		}
		else {
			return false
		}
	} // }}}
	releaseReusable() { // {{{
		@expression.releaseReusable()
	} // }}}
	toFragments(fragments, mode, node) { // {{{
		if @flatten {
			NotImplementedException.throw(node)
		}
		else {
			switch @scope {
				ScopeKind::Argument => {
					NotImplementedException.throw(node)
				}
				ScopeKind::Null => {
					NotImplementedException.throw(node)
				}
				ScopeKind::This => {
					fragments.code(`\(@enum.name()).\(@methodName)(`)

					fragments.wrap(@expression._object, mode)

					for const argument, index in node._arguments {
						fragments.code($comma)

						argument.toArgumentFragments(fragments, mode)
					}
				}
			}
		}
	} // }}}
	toNullableFragments(fragments, node) { // {{{
		NotImplementedException.throw(node)
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	type() => @type
}

class NamedArgument extends Expression {
	private lateinit {
		_name: String
		_value: Expression
	}
	analyse() { // {{{
		@name = @data.name.name

		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} // }}}
	prepare() { // {{{
		@value.prepare()
	} // }}}
	translate() { // {{{
		@value.translate()
	} // }}}
	isAwait() => @value.isAwait()
	isUsingVariable(name) => @value.isUsingVariable(name)
	name() => @name
	toFragments(fragments, mode) { // {{{
		@value.toFragments(fragments, mode)
	} // }}}
}