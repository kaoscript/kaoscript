class CallExpression extends Expression {
	private lateinit {
		_arguments: Array						= []
		_await: Boolean							= false
		_callees: Array<Callee>					= []
		_calleeByHash: Dictionary<Callee>		= {}
		_callScope
		_flatten: Boolean						= false
		_hasDefaultCallee: Boolean				= false
		_named: Boolean							= false
		_nullable: Boolean						= false
		_nullableComputed: Boolean				= false
		_object									= null
		_property: String
		_reusable: Boolean						= false
		_reuseName: String?						= null
		_tested: Boolean						= false
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

		if @data.callee.kind == NodeKind::MemberExpression && !@data.callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind::Computed) {
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

					if const substitute = variable.replaceCall?(@data, @arguments, this) {
						this.addCallee(new SubstituteCallee(@data, substitute, this))
					}
					else {
						this.makeCallee(type, variable.name())
					}
				}
				else {
					ReferenceException.throwUndefinedFunction(@data.callee.name, this)
				}
			}
			else if @data.callee.kind == NodeKind::FunctionExpression {
				throw new NotImplementedException(this)
			}
			else if @data.callee.kind == NodeKind::LambdaExpression {
				const expression = $compile.expression(@data.callee, this)
				expression.analyse()
				expression.prepare()

				const function = expression.type()

				const assessment = function.assessment('', this)

				if const result = Router.matchArguments2(assessment, @arguments, this) {
					if result is LenientCallMatchResult {
						this.addCallee(new DefaultCallee(@data, expression, this))
					}
					else {
						const simplified = new SimplifiedArrowFunctionExpression(expression, result.matches[0])

						this.addCallee(new DefaultCallee(@data, simplified, this))
					}
				}
				else {
					ReferenceException.throwNoMatchingFunction('', @arguments, this)
				}
			}
			else {
				if @named {
					NotImplementedException.throw(this)
				}

				this.addCallee(new DefaultCallee(@data, null, null, this))
			}
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

				if !types.any((item, _, _) => type.equals(item)) {
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
	isSkippable() => @callees.length == 1 && @callees[0].isSkippable()
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
		// console.log('-- call.makeCallee --')
		// console.log(type)
		// console.log(name)

		if type is FunctionType | OverloadedFunctionType {
			const assessment = type.assessment(name!!, this)

			if const result = Router.matchArguments2(assessment, @arguments, this) {
				if result is LenientCallMatchResult {
					this.addCallee(new DefaultCallee(@data, @object, result.possibilities, result.arguments, this))
				}
				else {
					if result.matches.length == 1 {
						const match = result.matches[0]

						if match.function.isAlien() || match.function.index() == -1 {
							this.addCallee(new DefaultCallee(@data, @object, match.function, this))
						}
						else {
							this.addCallee(new FunctionCallee(@data, match, this))
						}
					}
					else {
						const functions = [match.function for const match in result.matches]

						this.addCallee(new DefaultCallee(@data, @object, functions, this))
					}
				}
			}
			else {
				if type.isExhaustive(this) {
					ReferenceException.throwNoMatchingFunction(name, @arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}

		}
		else if type.isEnum() {
			const assessment = type.discardName().assessment(type.reference(@scope), this)

			if const result = Router.matchArguments2(assessment, @arguments, type.isExhaustive(this), this) {
				if result is LenientCallMatchResult {
					this.addCallee(new DefaultCallee(@data, @object, type.setNullable(true), result.arguments, this))
				}
				else {
					this.addCallee(new EnumCallee(@data, result.matches[0], this))
				}
			}
			else {
				if type.isExhaustive(this) {
					ReferenceException.throwNoMatchingStruct(name, @arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, type.setNullable(true), this))
				}
			}
		}
		else if type.isStruct() {
			const assessment = type.discardName().assessment(type.reference(@scope), this)

			if const result = Router.matchArguments2(assessment, @arguments, type.isExhaustive(this), this) {
				if result is LenientCallMatchResult {
					this.addCallee(new DefaultCallee(@data, @object, type, result.arguments, this))
				}
				else {
					this.addCallee(new StructCallee(@data, result.matches[0], this))
				}
			}
			else {
				if type.isExhaustive(this) {
					ReferenceException.throwNoMatchingStruct(name, @arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, type, this))
				}
			}
		}
		else if type.isTuple() {
			const assessment = type.discardName().assessment(type.reference(@scope), this)

			if const result = Router.matchArguments2(assessment, @arguments, this) {
				if result is LenientCallMatchResult {
					this.addCallee(new DefaultCallee(@data, @object, type, result.arguments, this))
				}
				else {
					this.addCallee(new TupleCallee(@data, result.matches[0], this))
				}
			}
			else {
				if type.isExhaustive(this) {
					ReferenceException.throwNoMatchingTuple(name, @arguments, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, type, this))
				}
			}
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
					const assessment = value.getClassAssessment(@property, this)

					if const result = Router.matchArguments2(assessment, @arguments, this) {
						if result is LenientCallMatchResult {
							if result.possibilities.some((function, _, _) => function.isSealed()) {
								this.addCallee(new SealedCallee(@data, name, false, result.possibilities, this))
							}
							else {
								this.addCallee(new DefaultCallee(@data, @object, result.possibilities, this))
							}
						}
						else {
							if result.matches.length == 1 {
								const match = result.matches[0]

								if match.function.isSealed() {
									this.addCallee(new SealedPreciseMethodCallee(@data, @object, @property, match, name, this))
								}
								else {
									@addCallee(new PreciseMethodCallee(@data, @object, @property, match, @scope().reference(name), this))
								}
							}
							else {
								throw new NotImplementedException(this)
							}
						}
					}
					else {
						if value.isExhaustiveClassMethod(@property, this) {
							ReferenceException.throwNoMatchingClassMethod(@property, name.name(), [argument.type() for const argument in @arguments], this)
						}
						else if assessment.sealed {
							this.addCallee(new SealedMethodCallee(@data, name, false, this))
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
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
					const assessment = value.getStaticAssessment(@property, this)

					if const result = Router.matchArguments2(assessment, @arguments, this) {
						if result is LenientCallMatchResult {
							this.addCallee(new EnumMethodCallee(@data, @object, @property, result.possibilities, this))
						}
						else {
							if result.matches.length == 1 {
								@addCallee(new PreciseMethodCallee(@data, @object, @property, result.matches[0], @scope().reference(name), this))
							}
							else {
								throw new NotImplementedException(this)
							}
						}
					}
					else {
						if value.isExhaustiveStaticMethod(@property, this) {
							ReferenceException.throwNoMatchingEnumMethod(@property, name.name(), @arguments, this)
						}
						else {
							this.addCallee(new EnumMethodCallee(@data, @object, @property, null, this))
						}
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
						const assessment = property.assessment(@property, this)

						if const result = Router.matchArguments2(assessment, @arguments, this) {
							if result is LenientCallMatchResult {
								this.addCallee(new DefaultCallee(@data, @object, result.possibilities, this))
							}
							else {
								if result.matches.length == 1 {
									const match = result.matches[0]

									if match.function.isAlien() || match.function.index() == -1 {
										this.addCallee(new DefaultCallee(@data, @object, match.function, this))
									}
									else {
										this.addCallee(new FunctionCallee(@data, match, this))
									}
								}
								else {
									const functions = [match.function for const match in result.matches]

									this.addCallee(new DefaultCallee(@data, @object, functions, this))
								}
							}
						}
						else if property.isExhaustive(this) {
							ReferenceException.throwNoMatchingFunctionInNamespace(@property, name, @arguments, this)
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
						}
					}
					else if property is SealableType {
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
					unless @data.callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind::Nullable) {
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
					const assessment = value.getInstantiableAssessment(@property, this)

					if const result = Router.matchArguments2(assessment, @arguments, this) {
						if result is LenientCallMatchResult {
							if result.possibilities.some((function, _, _) => function.isSealed()) {
								this.addCallee(new SealedCallee(@data, reference.type(), true, result.possibilities, this))
							}
							else {
								this.addCallee(new DefaultCallee(@data, @object, result.possibilities, this))
							}
						}
						else {
							if result.matches.length == 1 {
								const match = result.matches[0]

								if match.function.isSealed() {
									const class = value.getClassWithInstanceMethod(@property, reference.type())

									this.addCallee(new SealedPreciseMethodCallee(@data, @object, @property, match, class, this))
								}
								else {
									this.addCallee(new PreciseMethodCallee(@data, @object, @property, match, reference, this))
								}
							}
							else {
								throw new NotImplementedException(this)
							}
						}
					}
					else {
						if value.isExhaustiveInstanceMethod(@property, this) {
							ReferenceException.throwNoMatchingClassMethod(@property, reference.name(), [argument.type() for const argument in @arguments], this)
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
						}
					}
				}
				else if	@data.callee.object.kind == NodeKind::Identifier &&
						(callee ?= @scope.getVariable(@data.callee.object.name)) &&
						(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
				{
					this.addCallee(new SubstituteCallee(@data, substitute, Type.Any, this))
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotFoundClassMethod(@property, reference.name(), this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is DictionaryType => {
				if const property = value.getProperty(@property) {
					if property is FunctionType || property is OverloadedFunctionType {
						const assessment = property.assessment(@property, this)

						if const result = Router.matchArguments2(assessment, @arguments, this) {
							if result is LenientCallMatchResult {
								this.addCallee(new DefaultCallee(@data, @object, result.possibilities, this))
							}
							else {
								if result.matches.length == 1 {
									const match = result.matches[0]

									if match.function.isAlien() || match.function.index() == -1 {
										this.addCallee(new DefaultCallee(@data, @object, match.function, this))
									}
									else {
										this.addCallee(new FunctionCallee(@data, match, this))
									}
								}
								else {
									const functions = [match.function for const match in result.matches]

									this.addCallee(new DefaultCallee(@data, @object, functions, this))
								}
							}
						}
						else if property.isExhaustive(this) {
							ReferenceException.throwNoMatchingFunction(@property, reference.name(), @arguments, this)
						}
						else {
							this.addCallee(new DefaultCallee(@data, @object, null, this))
						}
					}
					else {
						throw new NotImplementedException(this)
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotDefinedProperty(@property, this)
				}
				else {
					this.addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is EnumType => {
				if value.hasInstanceMethod(@property) {
					const assessment = value.getInstanceAssessment(@property, this)

					if const result = Router.matchArguments2(assessment, @arguments, this) {
						if result is LenientCallMatchResult {
							this.addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, result.possibilities, this))
						}
						else {
							if result.matches.length == 1 {
								const match = result.matches[0]

								this.addCallee(new InvertedPreciseMethodCallee(@data, reference.discardReference() as NamedType, @property, match, this))
							}
							else {
								const functions = [match.function for const match in result.matches]

								this.addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, result.functions, this))
							}
						}
					}
					else {
						if value.isExhaustiveInstanceMethod(@property, this) {
							ReferenceException.throwNoMatchingEnumMethod(@property, reference.name(), @arguments, this)
						}
						else {
							this.addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, null, this))
						}
					}
				}
				else if reference.isExhaustive(this) {
					ReferenceException.throwNotFoundEnumMethod(@property, reference.name(), this)
				}
				else {
					this.addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, null, this))
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
	private addCallee(callee: Callee) { // {{{
		if const hash = callee.hashCode() {
			if const main = @calleeByHash[hash] {
				main.mergeWith(callee)
			}
			else {
				@callees.push(callee)
				@calleeByHash[hash] = callee
			}
		}
		else {
			@callees.push(callee)
		}
	} // }}}
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
	type() => @value.type()
	toFragments(fragments, mode) { // {{{
		@value.toFragments(fragments, mode)
	} // }}}
}

class SimplifiedArrowFunctionExpression extends Expression {
	private {
		_expression
	}
	constructor(@expression, match) {
		super(expression.data(), expression.parent(), expression.scope(), ScopeType::Block)
	}
	analyse() { // {{{
	} // }}}
	prepare() { // {{{
	} // }}}
	translate() { // {{{
		@expression.translate()
	} // }}}
	toFragments(fragments, mode) { // {{{
		fragments.code('((')

		const block = Parameter.toFragments(@expression, fragments, ParameterMode::Default, func(fragments) {
			return fragments.code(') =>').newBlock()
		})

		block.compile(@expression._block)

		if !@expression._awaiting && !@expression._exit && @expression._type.isAsync() {
			block.line('__ks_cb()')
		}

		block.done()

		fragments.code(')')
	} // }}}
}

include {
	'./callee'
	'./callee/default'
	'./callee/enum'
	'./callee/enum-method'
	'./callee/function'
	'./callee/inverted-precise-method'
	'./callee/precise-method'
	'./callee/sealed'
	'./callee/sealed-function'
	'./callee/sealed-method'
	'./callee/sealed-precise-method'
	'./callee/struct'
	'./callee/substitute'
	'./callee/tuple'
}
