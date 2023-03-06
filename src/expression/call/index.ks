class CallExpression extends Expression {
	private late {
		@arguments: Array						= []
		@assessment: CallMatchResult?
		@await: Boolean							= false
		@callees: Callee[]						= []
		@calleeByHash: Object<Callee>			= {}
		@flatten: Boolean						= false
		@hasDefaultCallee: Boolean				= false
		@named: Boolean							= false
		@matchingMode: ArgumentMatchMode		= .BestMatch
		@nullable: Boolean						= false
		@nullableComputed: Boolean				= false
		@object									= null
		@preparedArguments: Boolean				= false
		@property: String
		@reusable: Boolean						= false
		@reuseName: String?						= null
		@tested: Boolean						= false
		@thisScope
		@thisType: Type?						= null
		@type: Type
	}
	static {
		toFlattenArgumentsFragments(fragments, arguments, prefill? = null) { # {{{
			if arguments.length == 0 {
				fragments.code('[]')
			}
			else if arguments.length == 1 && !?prefill && arguments[0] is UnaryOperatorSpread && arguments[0].argument().type().isArray() {
				arguments[0].argument().toArgumentFragments(fragments)
			}
			else {
				if prefill == null {
					fragments.code('[].concat(')
				}
				else {
					fragments.code('[').compile(prefill).code('].concat(')
				}

				var mut opened = false

				for var argument, index in arguments {
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
		} # }}}
	}
	analyse() { # {{{
		var es5 = @data.arguments.length != 1 && @options.format.spreads == 'es5'

		for var data in @data.arguments {
			var argument = $compile.expression(data, this)

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

		if @data.callee.kind == NodeKind.MemberExpression && !@data.callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind.Computed) {
			@object = $compile.expression(@data.callee.object, this)
			@object.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@prepareThisScope()

		if ?@object {
			@object.prepare(AnyType.NullableUnexplicit)

			@property = @data.callee.property.name

			@makeMemberCallee(@object.type())

			if @matchingMode == .BestMatch {
				@object.flagMutating()
			}
		}
		else {
			if @data.callee.kind == NodeKind.Identifier {
				if var variable ?= @scope.getVariable(@data.callee.name) {
					var type = variable.getRealType()

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

					if ?variable.replaceCall {
						@prepareArguments()

						var substitute = variable.replaceCall(@data, @arguments, this)

						@addCallee(new SubstituteCallee(@data, substitute, this))
					}
					else {
						@makeCallee(type, variable.name())
					}
				}
				else {
					ReferenceException.throwUndefinedFunction(@data.callee.name, this)
				}
			}
			else if @data.callee.kind == NodeKind.FunctionExpression {
				throw new NotImplementedException(this)
			}
			else if @data.callee.kind == NodeKind.LambdaExpression {
				var expression = $compile.expression(@data.callee, this)
				expression.analyse()
				expression.prepare(AnyType.NullableUnexplicit)

				var function = expression.type()

				@assessment = function.assessment(expression.toQuote(), this)

				@prepareArguments()

				match Router.matchArguments(@assessment, @thisType, @arguments, @matchingMode, this) {
					is LenientCallMatchResult with result {
						@addCallee(new LenientFunctionCallee(@data, @assessment, result, this))
					}
					is PreciseCallMatchResult with { matches } {
						var callee = new PreciseFunctionCallee(@data, expression, @assessment, matches, this)

						callee.flagDirect()

						@addCallee(callee)
					}
					else {
						ReferenceException.throwNoMatchingFunction(@assessment.name, @arguments, this)
					}
				}
			}
			else if @data.callee.kind == NodeKind.ThisExpression {
				@prepareArguments()

				var expression = $compile.expression(@data.callee, this)
				expression.analyse()
				expression.prepare(AnyType.NullableUnexplicit)

				@property = @data.callee.name.name

				var type = expression.type()
				if type is FunctionType | OverloadedFunctionType {
					@assessment = type.assessment(@property, this)

					match Router.matchArguments(@assessment, @thisType, @arguments, @matchingMode, this) {
						is LenientCallMatchResult with { possibilities } {
							@addCallee(new LenientThisCallee(@data, expression, @property, possibilities, this))
						}
						is PreciseCallMatchResult with { matches } {
							if matches.length == 1 {
								var match = matches[0]
								var class = expression.getClass()
								var reference = @scope.reference(class)

								@addCallee(new PreciseThisCallee(@data, expression, reference, @property, @assessment, match, this))
							}
							else {
								throw new NotImplementedException(this)
							}
						}
						else {
							ReferenceException.throwNoMatchingStaticMethod(@property, expression.getClass().name(), [argument.type() for var argument in @arguments], this)
						}
					}
				}
				else if type.isFunction() {
					@prepareArguments()

					if expression.isSealed() {
						var object = new IdentifierLiteral($ast.identifier('this'), this, @scope)
						var class = expression.getClass()
						var reference = @scope.reference(class)

						@addCallee(new SealedMethodCallee(@data, object, reference, @property, true, this))

					}
					else {
						@addCallee(new DefaultCallee(@data, null, null, this))
					}
				}
				else {
					ReferenceException.throwUndefinedFunction(@property, this)
				}
			}
			else {
				if @named {
					NotImplementedException.throw(this)
				}

				@prepareArguments()

				@addCallee(new DefaultCallee(@data, null, null, this))
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

			var types = [@callees[0].type()]

			for var i from 1 to~ @callees.length {
				var type = @callees[i].type()

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

			@type = Type.union(@scope(), ...types)

		}
		// echo('-- callees --')
		// echo(@callees)
		// echo(@property)
		// echo(@type.hashCode())
	} # }}}
	translate() { # {{{
		for var argument in @arguments {
			argument.translate()
		}

		for var callee in @callees {
			callee.translate()
		}

		@thisScope?.translate()
	} # }}}
	acquireReusable(mut acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}

		if @callees.length > 1 {
			for callee in @callees to~ -1 {
				callee.acquireReusable(true)
			}

			@callees.last().acquireReusable(acquire)
		}
		else {
			for callee in @callees {
				callee.acquireReusable(acquire)
			}
		}

		for argument in @arguments {
			argument.acquireReusable(acquire)
		}
	} # }}}
	arguments() => @arguments
	assessment() => @assessment
	callees() => @callees
	getCallScope(): @thisScope
	inferTypes(inferables) { # {{{
		if @object != null {
			@object.inferTypes(inferables)

			if @nullable && @object.isInferable() {
				inferables[@object.path()] = {
					isVariable: @object is IdentifierLiteral
					type: @object.type().setNullable(false)
				}
			}
		}

		for var argument in @arguments {
			argument.inferTypes(inferables)
		}

		return inferables
	} # }}}
	isAwait() => @await
	isAwaiting() { # {{{
		for argument in @arguments {
			if argument.isAwaiting() {
				return true
			}
		}

		return false
	} # }}}
	isCallable() => !@reusable
	isComposite() => !@reusable
	isComputed() => (@nullable || @callees.length > 1) && !@tested
	isExit() => @type.isNever()
	isExpectingType() => true
	override isInitializingInstanceVariable(name) { # {{{
		for var argument in @arguments {
			if argument.isInitializingInstanceVariable(name) {
				return true
			}
		}

		for var callee in @callees {
			if !callee.isInitializingInstanceVariable(name) {
				return false
			}
		}

		return true
	} # }}}
	isNullable() => @nullable
	isNullableComputed() => @nullableComputed
	isSkippable() => @callees.length == 1 && @callees[0].isSkippable()
	isUsingInstanceVariable(name) { # {{{
		if @object != null {
			if @object.isUsingInstanceVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind.Identifier && @data.callee.name == name {
			return true
		}

		for var argument in @arguments {
			if argument.isUsingInstanceVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override isUsingNonLocalVariables(scope) { # {{{
		if @object != null {
			return true if @object.isUsingNonLocalVariables(scope)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if !scope.hasDeclaredVariable(variable.name()) {
				return true
			}
		}

		for var argument in @arguments {
			return true if argument.isUsingNonLocalVariables(scope)
		}

		return false
	} # }}}
	isUsingStaticVariable(class, varname) { # {{{
		if @object != null {
			if @object.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		for var argument in @arguments {
			if argument.isUsingStaticVariable(class, varname) {
				return true
			}
		}

		return false
	} # }}}
	isUsingVariable(name) { # {{{
		if @object != null {
			if @object.isUsingVariable(name) {
				return true
			}
		}
		else if @data.callee.kind == NodeKind.Identifier && @data.callee.name == name {
			return true
		}

		for var argument in @arguments {
			if argument.isUsingVariable(name) {
				return true
			}
		}

		return false
	} # }}}
	override listLocalVariables(scope, variables) { # {{{
		if @object != null {
			@object.listLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for var argument in @arguments {
			argument.listLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	override listNonLocalVariables(scope, variables) { # {{{
		if @object != null {
			@object.listNonLocalVariables(scope, variables)
		}
		else if @data.callee.kind == NodeKind.Identifier {
			var variable = @scope.getVariable(@data.callee.name)

			if !variable.isModule() && !scope.hasDeclaredVariable(variable.name()) {
				variables.pushUniq(variable)
			}
		}

		for var argument in @arguments {
			argument.listNonLocalVariables(scope, variables)
		}

		return variables
	} # }}}
	makeCallee(type: Type, name: String?) { # {{{
		// echo('-- call.makeCallee --')
		// echo(type)
		// echo(name)

		if type is FunctionType | OverloadedFunctionType {
			@assessment = type.assessment(name!!, this)

			@prepareArguments()

			match Router.matchArguments(@assessment, @thisType, @arguments, @matchingMode, this) {
				is LenientCallMatchResult with result {
					@addCallee(new LenientFunctionCallee(@data, @assessment, result, this))
				}
				is PreciseCallMatchResult with { matches } {
					if matches.length == 1 {
						var match = matches[0]

						if match.function.isAlien() || match.function.index() == -1 || match.function is ClassMethodType {
							@addCallee(new LenientFunctionCallee(@data, @assessment, [match.function], this))
						}
						else {
							@addCallee(new PreciseFunctionCallee(@data, @assessment, matches, this))
						}
					}
					else if @matchingMode == .AllMatches {
						@addCallee(new PreciseFunctionCallee(@data, @assessment, matches, this))
					}
					else {
						var functions = [match.function for var match in matches]

						@addCallee(new LenientFunctionCallee(@data, @assessment, functions, this))
					}
				}
				NoMatchResult.NoArgumentMatch {
					if type.isExhaustive(this) {
						ReferenceException.throwNoMatchingFunction(name, @arguments, this)
					}
					else {
						@addCallee(new DefaultCallee(@data, @object, null, this))
					}
				}
				NoMatchResult.NoThisMatch {
					if ?@thisScope {
						ReferenceException.throwNoMatchingThis(name, this)
					}
					else {
						ReferenceException.throwMissingThisContext(name, this)
					}
				}
			}
		}
		else if type.isEnum() {
			var enum = type.discardName()

			@prepareArguments()

			if @arguments.length != 1 {
				ReferenceException.throwNoMatchingStruct(name, @arguments, this)
			}

			var argument = @arguments[0]

			if !argument.type().isAssignableToVariable(enum.type(), true, true, false) && type.isExhaustive(this) {
				ReferenceException.throwNoMatchingStruct(name, @arguments, this)
			}

			@addCallee(new EnumCreateCallee(@data, type, argument, this))
		}
		else if type.isStruct() {
			TypeException.throwConstructorWithoutNew(name, this)
		}
		else if type.isTuple() {
			TypeException.throwConstructorWithoutNew(name, this)
		}
		else if type.isClass() {
			TypeException.throwConstructorWithoutNew(name, this)
		}
		else if type.canBeFunction() {
			@prepareArguments()

			@addCallee(new DefaultCallee(@data, @object, null, this))
		}
		else {
			@prepareArguments()

			if type.isExhaustive(this) {
				TypeException.throwNotFunction(name, this)
			}
			else {
				@addCallee(new DefaultCallee(@data, @object, null, this))
			}
		}
	} # }}}
	makeMemberCallee(value, mut name: NamedType? = null) { # {{{
		// echo('-- call.makeMemberCallee --')
		// echo(value)
		// echo(@property)

		match value {
			is AliasType {
				@makeMemberCallee(value.type(), name)
			}
			is ArrayType {
				@makeMemberCalleeFromReference(@scope.reference('Array'))
			}
			is ClassVariableType {
				@makeMemberCalleeFromReference(value.type())
			}
			is ClassType {
				name = name as NamedType

				var reference = @scope().reference(name)

				if value.hasStaticMethod(@property) {
					@assessment = value.getStaticAssessment(@property, this)

					@prepareArguments()

					match Router.matchArguments(@assessment, @thisType, @arguments, this) {
						is LenientCallMatchResult with result {
							@addCallee(new LenientMethodCallee(@data, @object, reference, @property, @assessment, result, this))
						}
						is PreciseCallMatchResult with { matches } {
							if matches.length == 1 {
								var match = matches[0]

								if match.function.isSealed() {
									@addCallee(new SealedPreciseMethodCallee(@data, @object, reference, @property, @assessment, match, this))
								}
								else {
									@addCallee(new PreciseMethodCallee(@data, @object, reference, @property, @assessment, matches, this))
								}
							}
							else if @matchingMode == .AllMatches {
								@addCallee(new PreciseMethodCallee(@data, @object, reference, @property, @assessment, matches, this))
							}
							else {
								var functions = [match.function for var match in matches]

								if functions.some((function, _, _) => function.isSealed()) {
									@addCallee(new SealedCallee(@data, name, false, functions, this))
								}
								else {
									@addCallee(new LenientFunctionCallee(@data, @assessment, functions, this))
								}
							}
						}
						else {
							if value.isExhaustiveStaticMethod(@property, this) {
								ReferenceException.throwNoMatchingStaticMethod(@property, name.name(), [argument.type() for var argument in @arguments], this)
							}
							else if @assessment.sealed {
								@addCallee(new SealedMethodCallee(@data, @object, reference, @property, false, this))
							}
							else {
								@addCallee(new DefaultCallee(@data, @object, reference, this))
							}
						}
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotFoundStaticMethod(@property, name.name(), this)
				}
				else {
					@prepareArguments()

					@addCallee(new DefaultCallee(@data, @object, reference, this))
				}
			}
			is EnumType {
				name = name as NamedType

				var reference = @scope().reference(name)

				if value.hasStaticMethod(@property) {
					@assessment = value.getStaticAssessment(@property, this)

					@prepareArguments()

					match Router.matchArguments(@assessment, @thisType, @arguments, this) {
						is LenientCallMatchResult with result {
							@addCallee(new EnumMethodCallee(@data, @object, @property, result.possibilities, this))
						}
						is PreciseCallMatchResult with { matches } {
							if matches.length == 1 {
								@addCallee(new PreciseMethodCallee(@data, @object, reference, @property, @assessment, matches, this))
							}
							else {
								throw new NotImplementedException(this)
							}
						}
						else {
							if value.isExhaustiveStaticMethod(@property, this) {
								ReferenceException.throwNoMatchingEnumMethod(@property, name.name(), @arguments, this)
							}
							else {
								@addCallee(new EnumMethodCallee(@data, @object, @property, null, this))
							}
						}
					}
				}
				else if value.isExhaustive(this) {
					ReferenceException.throwNotFoundEnumMethod(@property, name.name(), this)
				}
				else {
					@prepareArguments()

					@addCallee(new DefaultCallee(@data, @object, reference, this))
				}
			}
			is ExclusionType {
				@makeMemberCallee(value.getMainType())
			}
			is FunctionType {
				@makeMemberCalleeFromReference(@scope.reference('Function'))
			}
			is NamedType {
				@makeMemberCallee(value.type(), value)
			}
			is NamespaceType {
				if var property ?= value.getProperty(@property) {
					if property is FunctionType || property is OverloadedFunctionType {
						@assessment = property.assessment(@property, this)

						@prepareArguments()

						match Router.matchArguments(@assessment, @thisType, @arguments, this) {
							is LenientCallMatchResult with result {
								@addCallee(new LenientFunctionCallee(@data, @assessment, result, this))
							}
							is PreciseCallMatchResult with { matches } {
								if matches.length == 1 {
									var match = matches[0]

									if match.function.isAlien() || match.function.index() == -1 {
										@addCallee(new LenientFunctionCallee(@data, @assessment, [match.function], this))
									}
									else {
										@addCallee(new PreciseFunctionCallee(@data, @assessment, matches, this))
									}
								}
								else {
									var functions = [match.function for var match in matches]

									@addCallee(new LenientFunctionCallee(@data, @assessment, functions, this))
								}
							}
							else {
								if property.isExhaustive(this) {
									ReferenceException.throwNoMatchingFunctionInNamespace(@property, name, @arguments, this)
								}
								else {
									@addCallee(new DefaultCallee(@data, @object, null, this))
								}
							}
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
					@prepareArguments()

					@addCallee(new DefaultCallee(@data, @object, null, this))
				}
			}
			is ObjectType {
				if var property ?= value.getProperty(@property) {
					@makeCallee(property, @property)
				}
				else {
					@makeMemberCalleeFromReference(@scope.reference('Object'))
				}
			}
			is ParameterType {
				@makeMemberCallee(value.type(), name)
			}
			is ReferenceType {
				if value.isNullable() && !@options.rules.ignoreMisfit {
					unless @data.callee.modifiers.some((modifier, _, _) => modifier.kind == ModifierKind.Nullable) {
						TypeException.throwNullableCaller(@property, this)
					}
				}

				@makeMemberCalleeFromReference(value)
			}
			is SealableType {
				@makeMemberCallee(value.type(), name)
			}
			is UnionType {
				for var type in value.types() {
					@makeMemberCallee(type)
				}
			}
			else {
				@prepareArguments()

				@addCallee(new DefaultCallee(@data, @object, null, this))
			}
		}
	} # }}}
	makeMemberCalleeFromReference(value, reference: ReferenceType = value) { # {{{
		// echo('-- call.makeMemberCalleeFromReference --')
		// echo(value)
		// echo(@property)

		match value {
			is AliasType {
				@makeMemberCalleeFromReference(value.type())
			}
			is ClassType {
				if value.hasInstantiableMethod(@property) {
					@assessment = value.getInstantiableAssessment(@property, this)

					@prepareArguments()

					match Router.matchArguments(@assessment, @thisType, @arguments, this) {
						is LenientCallMatchResult with result {
							var class = value.getClassWithInstantiableMethod(@property, reference.type())
							var reference = @scope.reference(class)

							@addCallee(new LenientMethodCallee(@data, @object, reference, @property, @assessment, result, this))
						}
						is PreciseCallMatchResult with { matches } {
							var class = value.getClassWithInstantiableMethod(@property, reference.type())
							var reference = @scope.reference(class)

							if matches.length == 1 {
								var match = matches[0]

								if match.function.isSealed() {
									@addCallee(new SealedPreciseMethodCallee(@data, @object, reference, @property, @assessment, match, this))
								}
								else {
									@addCallee(new PreciseMethodCallee(@data, @object, reference, @property, @assessment, matches, this))
								}
							}
							else if @matchingMode == .AllMatches {
								@addCallee(new PreciseMethodCallee(@data, @object, reference, @property, @assessment, matches, this))
							}
							else {
								var functions = [match.function for var match in matches]

								@addCallee(new LenientMethodCallee(@data, @object, reference, @property, @assessment, functions, this))
							}
						}
						NoMatchResult.NoArgumentMatch {
							if value.isExhaustiveInstanceMethod(@property, this) {
								ReferenceException.throwNoMatchingStaticMethod(@property, reference.name(), [argument.type() for var argument in @arguments], this)
							}
							else {
								@addCallee(new DefaultCallee(@data, @object, reference, this))
							}
						}
						NoMatchResult.NoThisMatch {
							ReferenceException.throwNoAssignableThisInMethod(@property, this)
						}
					}
				}
				else {
					@prepareArguments()

					if	@data.callee.object.kind == NodeKind.Identifier &&
							(callee ?= @scope.getVariable(@data.callee.object.name)) &&
							(substitute ?= callee.replaceMemberCall?(@property, @arguments, this))
					{
						@addCallee(new SubstituteCallee(@data, substitute, Type.Any, this))
					}
					else if value.hasInstanceVariable(@property) {
						@addCallee(new DefaultCallee(@data, @object, reference, this))
					}
					else if value.isExhaustive(this) {
						ReferenceException.throwNotFoundStaticMethod(@property, reference.name(), this)
					}
					else {
						@addCallee(new DefaultCallee(@data, @object, reference, this))
					}
				}
			}
			is EnumType {
				if value.hasInstanceMethod(@property) {
					@assessment = value.getInstanceAssessment(@property, this)

					@prepareArguments()

					match Router.matchArguments(@assessment, @thisType, @arguments, this) {
						is LenientCallMatchResult with result {
							@addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, result.possibilities, this))
						}
						is PreciseCallMatchResult with { matches } {
							if matches.length == 1 {
								var match = matches[0]

								@addCallee(new InvertedPreciseMethodCallee(@data, reference.discardReference() as NamedType, @property, @assessment, match, this))
							}
							else {
								var functions = [match.function for var match in matches]

								@addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, functions, this))
							}
						}
						else {
							if value.isExhaustiveInstanceMethod(@property, this) {
								ReferenceException.throwNoMatchingEnumMethod(@property, reference.name(), @arguments, this)
							}
							else {
								@addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, null, this))
							}
						}
					}
				}
				else if reference.isExhaustive(this) {
					ReferenceException.throwNotFoundEnumMethod(@property, reference.name(), this)
				}
				else {
					@prepareArguments()

					@addCallee(new EnumMethodCallee(@data, reference.discardReference() as NamedType<EnumType>, `__ks_func_\(@property)`, null, this))
				}
			}
			is FunctionType {
				throw new NotImplementedException(this)
			}
			is NamedType {
				@makeMemberCalleeFromReference(value.type(), reference)
			}
			is ObjectType {
				if var property ?= value.getProperty(@property) {
					if property is FunctionType || property is OverloadedFunctionType {
						@assessment = property.assessment(@property, this)

						@prepareArguments()

						match Router.matchArguments(@assessment, @thisType, @arguments, this) {
							is LenientCallMatchResult with result {
								@addCallee(new LenientFunctionCallee(@data, @assessment, result, this))
							}
							is PreciseCallMatchResult with { matches } {
								if matches.length == 1 {
									var match = matches[0]

									if match.function.isAlien() || match.function.index() == -1 {
										@addCallee(new LenientFunctionCallee(@data, @assessment, [match.function], this))
									}
									else {
										@addCallee(new PreciseFunctionCallee(@data, @assessment, matches, this))
									}
								}
								else {
									var functions = [match.function for var match in matches]

									@addCallee(new LenientFunctionCallee(@data, @assessment, functions, this))
								}
							}
							else {
								if property.isExhaustive(this) {
									ReferenceException.throwNoMatchingFunction(@property, reference.name(), @arguments, this)
								}
								else {
									@addCallee(new DefaultCallee(@data, @object, reference, this))
								}
							}
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
					@prepareArguments()

					@addCallee(new DefaultCallee(@data, @object, reference, this))
				}
			}
			is ParameterType {
				throw new NotImplementedException(this)
			}
			is ReferenceType {
				@makeMemberCalleeFromReference(value.type(), value)
			}
			is UnionType {
				for var type in value.types() {
					@makeMemberCallee(type)
				}
			}
			else {
				@prepareArguments()

				@addCallee(new DefaultCallee(@data, @object, reference, this))
			}
		}
	} # }}}
	makeNamespaceCallee(property, sealed, name) { # {{{
		if property is FunctionType {
			if sealed {
				@prepareArguments()

				@addCallee(new SealedFunctionCallee(@data, name, property, property.getReturnType(), this))
			}
			else {
				@makeCallee(property, @property)
			}
		}
		else if property is OverloadedFunctionType {
			@makeCallee(property, @property)
		}
		else {
			@prepareArguments()

			@addCallee(new DefaultCallee(@data, @object, null, property, this))
		}
	} # }}}
	prepareArguments() { # {{{
		return if @preparedArguments

		for var argument in @arguments {
			argument.prepare(AnyType.NullableUnexplicit)

			if argument.type().isInoperative() {
				TypeException.throwUnexpectedInoperative(argument, this)
			}

			argument.flagMutating()
		}

		if @options.format.spreads == 'es5' {
			for var argument in @arguments until @flatten {
				if argument is UnaryOperatorSpread {
					@flatten = true
				}
			}
		}
		else {
			for var argument in @arguments until @flatten {
				if argument is UnaryOperatorSpread && !argument.argument().type().isArray() {
					@flatten = true
				}
			}
		}

		@preparedArguments = true
	} # }}}
	prepareThisScope() { # {{{
		if @data.scope.kind == ScopeKind.Argument {
			@thisScope = $compile.expression(@data.scope.value, this)
			@thisScope.analyse()
			@thisScope.prepare(AnyType.NullableUnexplicit)

			@thisType = @thisScope.type()
		}
	} # }}}
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}

		for callee in @callees {
			callee.releaseReusable()
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if mode == Mode.Async {
			for var argument in @arguments {
				if argument.isAwaiting() {
					return argument.toFragments(fragments, mode)
				}
			}

			@toCallFragments(fragments, mode)

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)
			}
			else if @isNullable() && !@tested {
				fragments.wrapNullable(this).code(' ? ')

				@tested = true

				this.toFragments(fragments, mode)

				fragments.code(' : null')
			}
			else {
				for var argument in @arguments {
					if argument.isAwaiting() {
						return argument.toFragments(fragments, mode)
					}
				}

				@toCallFragments(fragments, mode)

				fragments.code(')')
			}
		}
	} # }}}
	toCallFragments(fragments, mode) { # {{{
		if @callees.length == 1 {
			@callees[0].toFragments(fragments, mode, this)
		}
		else {
			@module().flag('Type')

			for var callee in @callees to~ -1 {
				callee.toPositiveTestFragments(fragments, this)

				fragments.code(' ? ')

				callee.toFragments(fragments, mode, this)

				fragments.code(') : ')

			}

			@callees.last().toFragments(fragments, mode, this)
		}
	} # }}}
	toConditionFragments(fragments, mode, junction) { # {{{
		if mode == Mode.Async {
			@toCallFragments(fragments, mode)

			fragments.code(', ') if @arguments.length != 0
		}
		else {
			if @reusable {
				fragments.code(@reuseName)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
			else if @isNullable() && !@tested {
				fragments.wrapNullable(this).code(' ? ')

				@tested = true

				this.toFragments(fragments, mode)

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}

				fragments.code(' : false')
			}
			else {
				@toCallFragments(fragments, mode)

				fragments.code(')')

				if !@type.isBoolean() || @type.isNullable() {
					fragments.code(' === true')
				}
			}
		}
	} # }}}
	toQuote() { # {{{
		var mut fragments = ''

		if @object != null {
			fragments += `\(@object.toQuote()).\(@property)`
		}
		else if @data.callee.kind == NodeKind.Identifier {
			fragments += @data.callee.name
		}
		else if @data.callee.kind == NodeKind.ThisExpression {
			fragments += `@\(@data.callee.name.name)`
		}
		else {
			NotImplementedException.throw(this)
		}

		fragments += '()'

		return fragments
	} # }}}
	toNullableFragments(fragments) { # {{{
		if !@tested {
			@tested = true

			if @callees.length == 1 {
				@callees[0].toNullableFragments(fragments, this)
			}
			else {
				throw new NotImplementedException(this)
			}
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if !@reusable && ?@reuseName {
			fragments
				.code(@reuseName, $equals)
				.compile(this)

			@reusable = true
		}
		else {
			fragments.compile(this)
		}
	} # }}}
	type() => @type
	walkNode(fn) { # {{{
		return false unless fn(this)

		if ?@object {
			return false unless @object.walkNode(fn)
		}

		for var argument in @arguments {
			return false unless argument.walkNode(fn)
		}

		return true
	} # }}}
	private addCallee(callee: Callee) { # {{{
		if var hash ?= callee.hashCode() {
			if var main ?= @calleeByHash[hash] {
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
	} # }}}
}

class NamedArgument extends Expression {
	private late {
		@name: String
		@value: Expression
	}
	analyse() { # {{{
		@name = @data.name.name

		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	getDefaultValue() => 'void 0'
	isAwait() => @value.isAwait()
	isUsingVariable(name) => @value.isUsingVariable(name)
	name() => @name
	type() => @value.type()
	toFragments(fragments, mode) { # {{{
		@value.toFragments(fragments, mode)
	} # }}}
}

class PlaceholderArgument extends Expression {
	private late {
		@type: Type
	}
	analyse() { # {{{
	} # }}}
	override prepare(target, targetMode) { # {{{
		@type = new PlaceholderType(@scope)

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind.Rest {
				@type.flagRest()

				break
			}
		}

		if ?@data.index {
			@type.index(@data.index.value)
		}
	} # }}}
	translate() { # {{{
	} # }}}
	type() => @type
	toFragments(fragments, mode) { # {{{
	} # }}}
}

class PlaceholderType extends Type {
	private {
		@index: Number?		= null
		@rest: Boolean		= false
	}
	override clone() { # {{{
		throw new NotSupportedException()
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		throw new NotSupportedException()
	} # }}}
	flagRest(): Void { # {{{
		@rest = true
	} # }}}
	index(): @index
	index(@index): Void
	isPlaceholder() => true
	isRest(): @rest
	isSpread(): @rest
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) => true
	parameter(index) => AnyType.NullableUnexplicit
	override toFragments(fragments, node) { # {{{
		throw new NotSupportedException()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotSupportedException()
	} # }}}
	override toQuote() { # {{{
		if @rest {
			return '...'
		}
		else if ?@index {
			return `^\(@index)`
		}
		else {
			return '^'
		}
	} # }}}
	override toVariations(variations) { # {{{
		throw new NotSupportedException()
	} # }}}
}

class PositionalArgument extends Expression {
	private late {
		@value: Expression
	}
	analyse() { # {{{
		@value = $compile.expression(@data.value, this)
		@value.analyse()
	} # }}}
	override prepare(target, targetMode) { # {{{
		@value.prepare(target)
	} # }}}
	translate() { # {{{
		@value.translate()
	} # }}}
	isAwait() => @value.isAwait()
	type() => @value.type()
	toFragments(fragments, mode) { # {{{
		@value.toFragments(fragments, mode)
	} # }}}
}

include {
	'./callee'
	'./callee/default'
	'./callee/enum-create'
	'./callee/enum-method'
	'./callee/inverted-precise-method'
	'./callee/lenient-function'
	'./callee/lenient-method'
	'./callee/lenient-this'
	'./callee/precise-function'
	'./callee/precise-method'
	'./callee/precise-this'
	'./callee/sealed'
	'./callee/sealed-function'
	'./callee/sealed-method'
	'./callee/sealed-precise-method'
	'./callee/substitute'
}
