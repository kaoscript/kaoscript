enum ParameterMode {
	ArrowFunction
	AsyncFunction
	Default
	HelperConstructor
	HybridConstructor
	OverloadedFunction
}

enum ParameterWrongDoing {
	BadType
	NotNullable
}

class Parameter extends AbstractNode {
	private late {
		@arity								= null
		@comprehensive: Boolean				= true
		@defaultValue						= null
		@existential: Boolean				= false
		@explicitlyRequired: Boolean		= false
		@generics: Generic[]
		@hasDefaultValue: Boolean			= false
		@headedDefaultValue: Boolean		= false
		@header: Boolean					= false
		@internal
		@nullable: Boolean					= false
		@retained: Boolean
		@rest: Boolean						= false
		@tempVariables: Array				= []
		@type: ParameterType
		@useLiteral: Boolean				= false
	}
	static {
		compileExpression(data, node) { # {{{
			match data.kind {
				NodeKind.ArrayBinding => return ArrayBindingParameter.new(data, node)
				NodeKind.Identifier => return IdentifierParameter.new(data, node)
				NodeKind.ObjectBinding => return ObjectBindingParameter.new(data, node)
				NodeKind.ThisExpression => return ThisExpressionParameter.new(data, node)
			}
		} # }}}
		getUntilDifferentTypeIndex(parameters, index) { # {{{
			var activeType = parameters[index].type().type().setNullable(false)

			for var parameter, i in parameters from index + 1 {
				var type = parameter.type()

				if type.min() == 0 {
					if !activeType.equals(type.type().setNullable(false)) {
						return 0
					}

					if type.max() > 1 {
						return i + 1
					}
				}
				else {
					return 0
				}
			}

			return parameters.length
		} # }}}
		toFragments(node, fragments, mode, fn) { # {{{
			return Parameter.toKSFragments(node, fragments, mode, fn)
		} # }}}
		toKSFragments(node, mut fragments, mode: ParameterMode, fn) { # {{{
			var parameters = node.parameters()
			var signature = node.type()

			var name = (mode == ParameterMode.Default | ParameterMode.OverloadedFunction | ParameterMode.HelperConstructor) ? 'arguments' : '__ks_arguments'

			var mut {
				restIndex = -1
				minBefore = 0
				maxBefore = 0
				minRest = 0
				minAfter = 0
				maxAfter = 0
			}

			for var parameter, i in parameters {
				var type: ParameterType = parameter.type()

				if restIndex != -1 {
					minAfter += type.min()
					maxAfter += type.max()
				}
				else if type.max() == Infinity {
					restIndex = i
					minRest = type.min()
				}
				else {
					minBefore += type.min()
					maxBefore += type.max()
				}
			}

			if signature.isAsync() {
				if restIndex != -1 {
					minAfter += 1
					maxAfter += 1
				}
				else {
					minBefore += 1
					maxBefore += 1
				}
			}

			var context = {
				name
				async: signature.isAsync()
				required: minBefore
				optional: signature.min()
				temp: false
				tempL: false
				length: parameters.length
				min: minBefore
				max: maxBefore + minRest + minAfter
				increment: true
			}

			var mut lastHeaderParameterIndex = 0
			var mut asyncHeaderParameter = false

			if signature.max() > 0 {
				if mode == ParameterMode.ArrowFunction {
					fragments.code(`...\(name)`)
				}
				else if mode == ParameterMode.HybridConstructor {
					fragments.code(name)
				}
			}

			if mode == ParameterMode.Default | ParameterMode.HelperConstructor {
				var offset = node.getParameterOffset()

				for var parameter, i in parameters {
					fragments.code($comma) if i + offset > 0

					parameter.toParameterFragments(fragments)
				}

				lastHeaderParameterIndex = parameters.length

				if context.async {
					fragments.code($comma) if offset + lastHeaderParameterIndex > 0

					fragments.code('__ks_cb')
				}
			}

			fragments = fn(fragments)

			if mode != ParameterMode.HelperConstructor {
				for var parameter in parameters to~ lastHeaderParameterIndex {
					parameter.toValidationFragments(fragments)
				}
			}

			if lastHeaderParameterIndex == parameters.length {
				return fragments
			}

			return fragments
		} # }}}
		toHeaderParameterFragments(fragments, node, parameters, minAfter, context) { # {{{
			var offset = node.getParameterOffset()

			var mut til = -1

			for var parameter, i in parameters {
				var type = parameter.type()

				if type.max() == Infinity {
					fragments.code($comma) if i + offset > 0

					parameter.toParameterFragments(fragments)
				}
				else if type.max() > 1 {
					fragments.code($comma) if i + offset > 0

					parameter.toParameterFragments(fragments)
				}
				else if parameter.isRequired() || i + 1 == parameters.length || i < (til == -1 ? (til <- Parameter.getUntilDifferentTypeIndex(parameters, i)) : til) {
					fragments.code($comma) if i + offset > 0

					parameter.toParameterFragments(fragments)

					context.optional += type.max() - type.min()
					context.required -= type.min()
				}
				else {
					return i
				}
			}

			return parameters.length
		} # }}}
		toAsyncHeaderParameterFragments(fragments, parameters, lastHeader) { # {{{
			if lastHeader == parameters.length {
				fragments.code($comma) if lastHeader > 0

				fragments.code('__ks_cb')

				return true
			}
			else {
				return false
			}
		} # }}}
		toLengthValidationFragments(fragments, node, name, signature, parameters, asyncHeader, restIndex, minBefore, minRest, minAfter) { # {{{
			if minBefore + minRest + minAfter != 0 {
				if signature.isAsync() {
					node.module().flag('Type')

					if asyncHeader {
						if node.isAssertingParameter() {
							if signature.min() == 0 {
								fragments
									.newControl()
									.code(`if(arguments.length < 1)`)
									.step()
									.line(`throw SyntaxError.new("Wrong number of arguments (" + arguments.length + " for 0 + 1)")`)
									.step()
									.code(`else if(!\($runtime.type(node)).isFunction(__ks_cb))`)
									.step()
									.line(`throw TypeError.new("'callback' must be a function")`)
									.done()
							}
							else {
								var mut ctrl = fragments
									.newControl()
									.code(`if(arguments.length < \(signature.min() + 1))`)
									.step()
									.line(`\($runtime.scope(node))__ks_error = SyntaxError.new("Wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

								ctrl
									.newControl()
									.code(`if(arguments.length > 0 && \($runtime.type(node)).isFunction((__ks_cb = arguments[arguments.length - 1])))`)
									.step()
									.line(`return __ks_cb(__ks_error)`)
									.step()
									.code(`else`)
									.step()
									.line(`throw __ks_error`)
									.done()

								ctrl
									.step()
									.code(`else if(!\($runtime.type(node)).isFunction(__ks_cb))`)
									.step()
									.line(`throw TypeError.new("'callback' must be a function")`)
									.done()
							}
						}
					}
					else {
						fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)

						if node.isAssertingParameter() {
							var mut ctrl = fragments
								.newControl()
								.code(`if(arguments.length < \(signature.min() + 1))`)
								.step()
								.line(`\($runtime.scope(node))__ks_error = SyntaxError.new("Wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

							ctrl
								.newControl()
								.code(`if(\($runtime.type(node)).isFunction(__ks_cb))`)
								.step()
								.line(`return __ks_cb(__ks_error)`)
								.step()
								.code(`else`)
								.step()
								.line(`throw __ks_error`)
								.done()

							ctrl
								.step()
								.code(`else if(!\($runtime.type(node)).isFunction(__ks_cb))`)
								.step()
								.line(`throw TypeError.new("'callback' must be a function")`)

							ctrl.done()
						}
					}
				}
				else if node.isAssertingParameter() {
					fragments
						.newControl()
						.code(`if(\(name).length < \(signature.min() + node.getParameterOffset()))`)
						.step()
						.line(`throw SyntaxError.new("Wrong number of arguments (" + \(name).length + " for \(signature.min()))")`)
						.done()
				}
			}
		} # }}}
		toAfterRestParameterFragments(fragments, name, parameters, restIndex, beforeContext, wrongdoer) { # {{{
			var restParameter = parameters[restIndex]

			var context = {
				name
				any: restParameter.type().isAny()
				increment: false
				temp: beforeContext.temp
				tempL: beforeContext.tempL
				length: parameters.length
			}

			for var parameter, i in parameters from restIndex + 1 {
				parameter.toAfterRestFragments(fragments, context, i, wrongdoer)
			}
		} # }}}
		toRestParameterFragments(fragments, node, name, signature, parameters, declared, restIndex, minBefore, minAfter, maxAfter, context, wrongdoer) { # {{{
			var parameter = parameters[restIndex]

			if parameter.type().isAny() {
				if minAfter > 0 {
					if !declared {
						fragments.line($runtime.scope(node), `__ks_i = \(restIndex - 1 + node.getParameterOffset())`)
					}

					if parameter.isAnonymous() {
						fragments.line(`__ks_i = arguments.length - \(minAfter)`)
					}
					else {
						if parameter.hasDefaultValue() && parameter.type().min() == 0 {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = arguments.length > \(context.increment ? '++__ks_i' : '__ks_i') + \(minAfter) ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length - \(minAfter)) : `)
								.compile(parameter._defaultValue)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = Array.prototype.slice.call(arguments, \(context.increment ? '++__ks_i' : '__ks_i'), __ks_i = arguments.length - \(minAfter))`)
								.done()
						}
					}

					context.increment = true
				}
				else {
					return if parameter.isAnonymous()

					if declared {
						if parameter.hasDefaultValue() && parameter.type().min() == 0 {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = \(name).length > \(context.increment ? '++__ks_i' : '__ks_i') ? Array.prototype.slice.call(\(name), __ks_i, \(name).length) : `)
								.compile(parameter._defaultValue)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = Array.prototype.slice.call(\(name), \(context.increment ? '++__ks_i' : '__ks_i'), \(name).length)`)
								.done()
						}
					}
					else {
						if parameter.hasDefaultValue() && parameter.type().min() == 0 {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = \(name).length > 0 ? Array.prototype.slice.call(\(name), \(minBefore), \(name).length) : `)
								.compile(parameter._defaultValue)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = Array.prototype.slice.call(\(name), \(minBefore), \(name).length)`)
								.done()
						}
					}
				}
			}
			else {
				node.module().flag('Type')

				if !declared {
					fragments.line($runtime.scope(node), `__ks_i = \(restIndex - 1)`)
				}

				if !parameter.isAnonymous() {
					fragments
						.newLine()
						.code($runtime.scope(node))
						.compile(parameter)
						.code(' = []')
						.done()
				}

				if minAfter > 0 {
					var line = fragments.newLine()

					if !context.temp {
						line.code($runtime.scope(node))

						context.temp = true
					}

					line.code(`__ks__ = arguments.length - \(minAfter)`).done()
				}

				if !context.increment {
					fragments.line('--__ks_i')

					context.increment = true
				}

				if parameter.hasDefaultValue() && !parameter.type().isNullable() {
					var ctrl = fragments.newControl()

					if minAfter > 0 {
						ctrl.code('if(__ks__ > ++__ks_i)').step()
					}
					else {
						ctrl.code('if(arguments.length > ++__ks_i)').step()
					}

					var ctrl2 = ctrl.newControl()

					ctrl2.code(`if(arguments[__ks_i] === void 0 || arguments[__ks_i] === null)`).step()

					ctrl2.step().code('else').step().line('--__ks_i').done()

					ctrl.done()
				}

				with var ctrl = fragments.newControl() {
					if minAfter > 0 {
						ctrl.code('while(__ks__ > ++__ks_i)')
					}
					else {
						ctrl.code('while(arguments.length > ++__ks_i)')
					}

					ctrl.step()

					var ctrl2 = ctrl.newControl()

					var literal = Literal.new(false, node, node.scope(), 'arguments[__ks_i]')

					if parameter.type().isNullable() {
						ctrl2.code(`if(arguments[__ks_i] === void 0)`).step()

						ctrl2.newLine().compile(parameter).code('.push(null)').done()

						ctrl2.step()

						ctrl2.code(`else if(arguments[__ks_i] === null || `)

						parameter.type().toPositiveTestFragments(Junction.OR, ctrl2, literal)

						ctrl2.code(')').step()
					}
					else {
						ctrl2.code('if(')

						parameter.type().toPositiveTestFragments(Junction.NONE, ctrl2, literal)

						ctrl2.code(')').step()
					}

					if !parameter.isAnonymous() {
						ctrl2
							.newLine()
							.compile(parameter)
							.code('.push(arguments[__ks_i])')
							.done()
					}

					ctrl2.step().code('else').step()

					if minAfter != 0 || maxAfter != 0 {
						ctrl2.line('--__ks_i').line('break')
					}
					else {
						parameter.toErrorFragments(ctrl2, wrongdoer, signature.isAsync())
					}

					ctrl2.done()
					ctrl.done()
				}

				if parameter.hasDefaultValue() {
					var ctrl = fragments
						.newControl()
						.code('if(')
						.compile(parameter)
						.code('.length === 0)')
						.step()

					ctrl
						.newLine()
						.compile(parameter)
						.code($equals)
						.compile(parameter._defaultValue)
						.done()

					ctrl.done()
				}

				var min = parameter.type().min()
				if min > 0 {
					var ctrl = fragments
						.newControl()
						.code(`if(`)
						.compile(parameter)
						.code(`.length < \(min))`)
						.step()

					if context.async {
						ctrl
							.newLine()
							.code(`return __ks_cb(SyntaxError.new("The rest parameter must have at least \(min) argument\(min > 1 ? 's' : '') (" + `)
							.compile(parameter)
							.code(`.length + ")"))`)
							.done()
					}
					else {
						ctrl
							.newLine()
							.code(`throw SyntaxError.new("The rest parameter must have at least \(min) argument\(min > 1 ? 's' : '') (" + `)
							.compile(parameter)
							.code(`.length + ")")`)
							.done()
					}

					ctrl.done()
				}
			}
		} # }}}
		toBeforeRestParameterFragments(fragments, name, signature, parameters, nextIndex, restIndex, context, wrongdoer) { # {{{
			if restIndex == -1 {
				for var parameter, i in parameters from nextIndex {
					parameter.toBeforeRestFragments(fragments, context, i, false, wrongdoer)
				}
			}
			else {
				for var parameter, i in parameters from nextIndex to~ restIndex {
					parameter.toBeforeRestFragments(fragments, context, i, true, wrongdoer)
				}
			}
		} # }}}
	}
	constructor(@data, @generics = [], @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget.Parameter, super.file())
		@retained = @options.parameters.retain
	} # }}}
	analyse() { # {{{
		if ?@data.internal {
			var overwrite = @parent is AnonymousFunctionExpression | ArrowFunctionExpression || @hasAttribute('overwrite')
			var immutable = !@hasModifier(.Mutable)

			@internal = Parameter.compileExpression(@data.internal, this)
				..setAssignment(AssignmentType.Parameter)
				..flagImmutable() if immutable
				..operator(@data.operator.assignment) if ?@data.operator
				..analyse()

			for var assignment in @internal.listAssignments([], immutable, overwrite) {
				var { name } = assignment

				if !assignment.overwrite && @scope.hasDefinedVariable(name) {
					SyntaxException.throwAlreadyDeclared(name, this)
				}

				@scope.define(name, assignment.immutable, null, false, assignment.overwrite, this)
			}
		}
		else {
			@internal = AnonymousParameter.new(@data, this)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		var mut declaredType = Type.fromAST(@data.type, @generics, this)

		if declaredType.shallBeNamed() {
			var authority = @module().authority()

			declaredType.finalize(@data.type, @generics, this)

			var type = Type.toNamedType(declaredType, false, authority.scope(), this)

			if type.isComplex() {
				authority.addTypeTest(type.name(), type)
			}

			declaredType = type.reference()
		}

		@internal.prepare(declaredType)

		var mut min: Number = 1
		var mut max: Number = 1
		var mut passing = null
		var mut nullable = false

		for var modifier in @data.modifiers {
			match modifier.kind {
				ModifierKind.NameOnly {
					passing = PassingMode.LABELED
				}
				ModifierKind.NonNullable {
					if @internal is ThisExpressionParameter {
						@internal.flagNonNullable()
					}
				}
				ModifierKind.Nullable {
					nullable = true
				}
				ModifierKind.PositionOnly {
					passing = PassingMode.POSITIONAL
				}
				ModifierKind.Rest {
					@rest = true

					if ?modifier.arity {
						@arity = modifier.arity

						min = modifier.arity.min
						max = modifier.arity.max
					}
					else {
						min = 0
						max = Infinity
					}
				}
				ModifierKind.Required {
					@explicitlyRequired = true
				}
			}
		}

		var mut type: Type?

		if @internal is ThisExpressionParameter {
			if @rest {
				type = @internal.type().parameter()
			}
			else {
				type = @internal.type().asReference()
			}
		}
		else {
			type = @internal.type()?.asReference()
		}

		if !type?.isExplicit() {
			type = null
		}

		if ?@data.type {
			type = declaredType
		}

		if nullable {
			type ??= AnyType.NullableUnexplicit
		}

		if type == null {
			type = AnyType.Unexplicit
		}
		else if type.isNull() {
			type = NullType.Explicit
		}

		if ?@data.defaultValue {
			if @explicitlyRequired && type.isNullable() {
				if @data.defaultValue.kind == NodeKind.Identifier && @data.defaultValue.name == 'null' {
					pass
				}
				else if @internal is IdentifierLiteral {
					SyntaxException.throwDeadCodeParameter(@internal.name(), this)
				}
				else {
					SyntaxException.throwDeadCodeParameter(this)
				}
			}

			@defaultValue = $compile.expression(@data.defaultValue, @parent)
			@defaultValue.analyse()

			@internal.setDefaultValue(@defaultValue)

			@hasDefaultValue = true
			@nullable = type.isNullable()

			if !@explicitlyRequired {
				min = 0
			}

			@scope.commitTempVariables(@tempVariables)
		}

		var internal: String? = @internal.name()
		var external: String? = @data.external?.name ?? internal

		if target.isVoid() {
			@type = ParameterType.new(@scope, external, internal, passing, type!?, min, max, @hasDefaultValue)
		}
		else {
			if !type.isExplicit() {
				type = target.type()
			}

			@type = ParameterType.new(@scope, external, internal, passing, type!?, min, max, @hasDefaultValue)

			unless @type.isSubsetOf(target, MatchingMode.Signature) {
				TypeException.throwInvalidParameterType(@type, target, this)
			}
		}

		if @hasDefaultValue && @parent.isOverridableFunction() {
			var scope = @parent.scope()

			@comprehensive = !@defaultValue.isUsingNonLocalVariables(scope)

			if @comprehensive {
				@type.setDefaultValue(@data.defaultValue, true, @explicitlyRequired, this)
			}
			else {
				var variables = [variable.name() for var variable in @defaultValue.listLocalVariables(scope, [])]

				var name = @parent.addIndigentValue(@defaultValue, variables)

				var call = `\(name)(\(variables.join(', ')))`

				@type.setDefaultValue(call, false, @explicitlyRequired, this)

				@defaultValue = Literal.new(`\(@parent.getOverridableVarname()).\(call)`, @parent)
				@useLiteral = true
			}
		}

		if @retained {
			@type.flagRetained()
		}

		if @internal.isBinding() {
			type = @internal.type().asReference().merge(declaredType, null, null, false, this)

			if declaredType is DeferredType {
				declaredType.addConstraint(@internal.type())
			}
		}
		else {
			type = @type.getVariableType()
		}

		@internal.setDeclaredType(@rest ? Type.arrayOf(type, @scope) : type, true)
	} # }}}
	translate() { # {{{
		@internal.translate()

		if @hasDefaultValue {
			if @useLiteral {
				if ?@data.operator -> @data.operator.assignment == AssignmentOperatorKind.Equals {
					@headedDefaultValue = @nullable || @internal.isBinding()
				}
			}
			else {
				@defaultValue.prepare(@type.getVariableType(), TargetMode.Permissive)

				if ?@data.operator -> @data.operator.assignment == AssignmentOperatorKind.Equals {
					@headedDefaultValue = @nullable || @internal.isBinding()
				}
				else {
					@headedDefaultValue = @defaultValue.type().isNull()
				}

				@defaultValue.translate()

				unless @defaultValue.type().isAssignableToVariable(@internal.getDeclaredType(), true, false, false) {
					TypeException.throwInvalidAssignment(@internal, @internal.getDeclaredType(), @defaultValue.type(), this)
				}
			}
		}
	} # }}}
	addAliasParameter(expression: ThisExpressionParameter) { # {{{
		var alias = AliasStatement.new(expression, this)

		return @scope.reference(alias.type())
	} # }}}
	arity() => @arity
	getDefaultValue(): valueof @defaultValue
	getReturnType() => @type.getReturnType()
	hasDefaultValue() => @hasDefaultValue
	isAssertingParameter() => @parent.isAssertingParameter()
	isAssertingParameterType() => @parent.isAssertingParameterType()
	isComprehensive() => @comprehensive
	isRequired() => @explicitlyRequired || !?@defaultValue
	isRest() => @rest
	isUsingVariable(name) => @hasDefaultValue && @defaultValue.isUsingVariable(name)
	listAssignments(array: Array, immutable: Boolean? = null, overwrite: Boolean? = null) => @internal.listAssignments(array, immutable, overwrite)
	max() => @arity?.max ?? 1
	min() => @arity?.min ?? 1
	setDefaultValue(data) { # {{{
		@defaultValue = $compile.expression(data, @parent)
		@defaultValue.analyse()

		@hasDefaultValue = true

		@type.setDefaultValue(data, this)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@internal)
	} # }}}
	toAfterRestFragments(fragments, context, index, wrongdoer) { # {{{
		@internal.toAfterRestFragments(fragments, context, index, wrongdoer, @rest, @arity, @isRequired(), @defaultValue, @header && @headedDefaultValue, @parent.type().isAsync())
	} # }}}
	toBeforeRestFragments(fragments, context, index, rest, wrongdoer) { # {{{
		@internal.toBeforeRestFragments(fragments, context, index, wrongdoer, rest, @arity, @isRequired(), @defaultValue, @header && @headedDefaultValue, @parent.type().isAsync())
	} # }}}
	toErrorFragments(fragments, async) { # {{{
		@internal.toErrorFragments(fragments, async)
	} # }}}
	toParameterFragments(fragments) { # {{{
		@internal.toParameterFragments(fragments)

		if @headedDefaultValue {
			fragments.code($equals).compile(@defaultValue)
		}

		@header = true
	} # }}}
	toQuote() => @type.toQuote()
	toValidationFragments(fragments) { # {{{
		if @tempVariables.length != 0 {
			fragments.newLine().code($runtime.scope(this) + @tempVariables.join(', ')).done()
		}

		if @rest {
			if @hasDefaultValue {
				var ctrl = fragments
					.newControl()
					.code('if(')
					.compile(this)
					.code('.length === 0)')
					.step()

				ctrl
					.newLine()
					.compile(this)
					.code($equals)
					.compile(@defaultValue)
					.done()

				ctrl.done()
			}
		}
		else {
			@internal.toValidationFragments(fragments, @rest, @defaultValue, @header && @headedDefaultValue, @parent.type().isAsync())
		}
	} # }}}
	type(): ParameterType => @type
	type(@type) { # {{{
		if @type.hasDefaultValue() {
			if @hasDefaultValue {
				pass
			}
			else if @type.isComprehensive() {
				@defaultValue = $compile.expression(@type.getDefaultValue(), @parent)
				@defaultValue.analyse()
				@defaultValue.prepare()
			}
			else {
				@defaultValue = Literal.new(`\(@parent.getOverridableVarname()).\(@type.getDefaultValue())`, @parent)
				@useLiteral = true
			}

			@hasDefaultValue = true
		}
		else {
			@hasDefaultValue = false
		}

		if @retained {
			@type.flagRetained()
		}

		var t = @type.getVariableType()

		@internal.setDeclaredType(@rest ? Type.arrayOf(t, @scope) : t, true)
	} # }}}

	proxy @type {
		isRetained
	}
}

class AliasStatement extends Statement {
	private late {
		@expression: ThisExpressionParameter
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@parameter: Parameter
		@variable
	}
	constructor(@expression, @parameter) { # {{{
		var parent = parameter.parent()

		super(expression.data(), parent)

		parent.addAtThisParameter(this)
	} # }}}
	analyse()
	override prepare(target, targetMode) { # {{{
		@variable = @scope.getVariable(@expression.name())
	} # }}}
	translate()
	getVariableName() => @expression.getVariableName()
	name() => @expression.name()
	operator(@operator): valueof this
	path() => @expression.path()
	toStatementFragments(fragments, mode) { # {{{
		if @expression.isSealed() && !@parameter.parent().isConstructor() {
			fragments.newLine().code(`\(@expression.getClass().getSealedName()).__ks_set_\(@expression.name())(this, `).compile(@variable).code(')').done()
		}
		else {
			fragments.newLine().code(@expression.fragment(), $equals).compile(@variable).done()
		}
	} # }}}
	type() => @expression.type()
}

class IdentifierParameter extends IdentifierLiteral {
	private {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
	}
	static {
		toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async, that) { # {{{
			if arity != null {
				var type = that.getDeclaredType().parameter()

				if type.isAny() {
					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code(` = Array.prototype.slice.call(\(context.name), \(context.increment ? '++__ks_i' : '__ks_i'), \(index + 1 == context.length ? '' : '__ks_i = ')__ks_i + \(arity.min + (context.increment ? 1 : 0)))`)
						.done()

					context.increment = true
				}
				else {
					if !context.temp {
						fragments.line(`\($runtime.scope(that))__ks__`)

						context.temp = true
					}

					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code(' = []')
						.done()

					if !context.increment {
						fragments.line('--__ks_i')
					}

					var line = fragments.newLine()

					if !context.tempL {
						line.code($runtime.scope(that))

						context.tempL = true
					}

					line.code(`__ks_l = __ks_i + \(arity.min + 1)`).done()

					var ctrl = fragments.newControl().code('while(++__ks_i < __ks_l)').step()

					ctrl.line(`__ks__ = \(context.name)[__ks_i]`)

					var ctrl2 = ctrl.newControl()

					if type.isNullable() {
						ctrl2
							.code('if(__ks__ === void 0 || __ks__ === null)')
							.step()
							.newLine()
							.compile(that).code('.push(null)').done()
							.done()

						ctrl2
							.step()
							.code('else if(')

						type.toNegativeTestFragments(Junction.NONE, ctrl2, Literal.new(false, that, that.scope(), '__ks__'))
					}
					else {
						ctrl2.code('if(__ks__ === void 0 || __ks__ === null || ')

						type.toNegativeTestFragments(Junction.OR, ctrl2, Literal.new(false, that, that.scope(), '__ks__'))
					}

					ctrl2
						.code(')')
						.step()

					if index + 1 == context.length {
						wrongdoer(ctrl2, ParameterWrongDoing.BadType, {
							async: context.async
							name: that.name()
							type: type
						})
					}
					else {
						var ctrl3 = ctrl2
							.newControl()
							.code('if(')
							.compile(that)
							.code(`.length >= \(arity.min))`)
							.step()

						ctrl3
							.line('break')
							.step()
							.code('else')
							.step()

						wrongdoer(ctrl3, ParameterWrongDoing.BadType, {
							async: context.async
							name: that.name()
							type: type
						})

						ctrl3.done()
					}

					ctrl2
						.step()
						.code('else')
						.step()
						.newLine()
						.compile(that).code('.push(__ks__)')
						.done()

					ctrl2.done()
					ctrl.done()

					context.increment = false
				}
			}
			else if defaultValue != null {
				if context.any {
					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code($equals)
						.compile(defaultValue)
						.done()
				}
				else {
					var declaredType = that.getDeclaredType()

					if declaredType.isAny() {
						if !context.temp {
							fragments.line(`\($runtime.scope(that))__ks__`)

							context.temp = true
						}

						var mut line = fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.code(` = \(context.name).length > ++__ks_i && (__ks__ = \(context.name)[\(context.increment ? '++' : '')__ks_i]) !== void 0`)

						if !declaredType.isNullable() {
							line.code(' && __ks__ !== null')
						}

						line
							.code(' ? __ks__ : ')
							.compile(defaultValue)
							.done()
					}
					else {
						if !context.temp {
							fragments.line(`\($runtime.scope(that))__ks__`)

							context.temp = true
						}

						var mut line = fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.code(` = \(context.name).length > ++__ks_i && (__ks__ = \(context.name)[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)

						if declaredType.isNullable() {
							line.code('(__ks__ === null || ')

							declaredType.toPositiveTestFragments(Junction.OR, line, Literal.new(false, that, that.scope(), '__ks__'))

							line.code(')')
						}
						else {
							declaredType.toPositiveTestFragments(Junction.AND, line, Literal.new(false, that, that.scope(), '__ks__'))
						}

						line
							.code(context.increment ? ' ? (++__ks_i, __ks__) : ' : ' ? __ks__ : ')
							.compile(defaultValue)
							.done()
					}

					context.increment = true
				}
			}
			else {
				fragments
					.newLine()
					.code($runtime.scope(that))
					.compile(that)
					.code(` = \(context.name)[`, context.increment ? '++' : '', '__ks_i]')
					.done()

				that.toValidationFragments(fragments, rest, defaultValue, header, async)

				context.increment = true
			}
		} # }}}
		toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async, that) { # {{{
			if arity != null {
				context.required -= arity.min

				var type = that.getDeclaredType().parameter()

				if type.isAny() {
					if context.required > 0 {
						fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length - \(context.required), __ks_i + \(arity.max + 1)))`)
							.done()
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length, __ks_i + \(arity.max + 1)))`)
							.done()
					}

					if index + 1 < context.length {
						fragments
							.newLine()
							.code('__ks_i += ')
							.compile(that)
							.code('.length')
							.done()
					}
				}
				else {
					if !context.temp {
						fragments.line(`\($runtime.scope(that))__ks__`)

						context.temp = true
					}

					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code(' = []')
						.done()

					if !context.increment {
						fragments.line('--__ks_i')
					}

					var line = fragments.newLine()

					if !context.tempL {
						line.code($runtime.scope(that))

						context.tempL = true
					}


					if context.required > 0 {
						line.code(`__ks_l = Math.min(\(context.name).length - \(context.required), __ks_i + \(arity.max + 1))`)
					}
					else {
						line.code(`__ks_l = Math.min(\(context.name).length, __ks_i + \(arity.max + 1))`)
					}

					line.done()

					var ctrl = fragments.newControl().code('while(++__ks_i < __ks_l)').step()

					ctrl.line(`__ks__ = \(context.name)[__ks_i]`)

					var ctrl2 = ctrl.newControl()

					if type.isNullable() {
						ctrl2
							.code('if(__ks__ === void 0 || __ks__ === null)')
							.step()
							.newLine()
							.compile(that).code('.push(null)').done()
							.done()

						ctrl2
							.step()
							.code('else if(')

						type.toNegativeTestFragments(Junction.NONE, ctrl2, Literal.new(false, that, that.scope(), '__ks__'))
					}
					else {
						ctrl2.code('if(__ks__ === void 0 || __ks__ === null || ')

						type.toNegativeTestFragments(Junction.OR, ctrl2, Literal.new(false, that, that.scope(), '__ks__'))
					}

					ctrl2
						.code(')')
						.step()

					if index + 1 == context.length {
						wrongdoer(ctrl2, ParameterWrongDoing.BadType, {
							async: context.async
							name: that.name()
							type: type
						})
					}
					else {
						var ctrl3 = ctrl2
							.newControl()
							.code('if(')
							.compile(that)
							.code(`.length >= \(arity.min))`)
							.step()

						ctrl3
							.line('break')
							.step()
							.code('else')
							.step()

						wrongdoer(ctrl3, ParameterWrongDoing.BadType, {
							async: context.async
							name: that.name()
							type: type
						})

						ctrl3.done()
					}

					ctrl2
						.step()
						.code('else')
						.step()
						.newLine()
						.compile(that).code('.push(__ks__)')
						.done()

					ctrl2.done()
					ctrl.done()

					context.increment = false
				}

				context.optional += arity.max - arity.min
			}
			else {
				if !required && defaultValue != null {
					var declaredType = that.getDeclaredType()

					if declaredType.isAny() {
						if !context.temp {
							fragments.line(`\($runtime.scope(that))__ks__`)

							context.temp = true
						}

						var line = fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.code(` = \(context.name).length > \(context.optional) && (__ks__ = \(context.name)[++__ks_i]) !== void 0`)

						if !declaredType.isNullable() {
							line.code(' && __ks__ !== null')
						}

						line
							.code(' ? __ks__ : ')
							.compile(defaultValue)
							.done()
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(that))
							.compile(that)
							.done()

						var fixed = (context.max - context.min) == 1

						var ctrl = fragments.newControl()

						if fixed {
							ctrl
								.code(`if(\(context.name).length > \(context.optional) && (`)
								.compile(that)
								.code(` = \(context.name)[++__ks_i]) !== void 0`)
						}
						else if context.required > 0 {
							ctrl
								.code(`if(\(context.name).length > __ks_i + \(context.required + 1) && (`)
								.compile(that)
								.code(` = \(context.name)[++__ks_i]) !== void 0`)
						}
						else {
							ctrl
								.code(`if(\(context.name).length > ++__ks_i && (`)
								.compile(that)
								.code(` = \(context.name)[__ks_i]) !== void 0`)
						}

						if !declaredType.isNullable() {
							ctrl.code(' && ').compile(that).code(' !== null')
						}

						ctrl.code(')').step()

						var ctrl2 = ctrl.newControl().code('if(')

						if declaredType.isNullable() {
							ctrl2.compile(that).code(' !== null && ')

							declaredType.toNegativeTestFragments(Junction.AND, ctrl2, that)
						}
						else {
							declaredType.toNegativeTestFragments(Junction.NONE, ctrl2, that)
						}

						ctrl2
							.code(')')
							.step()

						if fixed || index + 1 == context.length {
							wrongdoer(ctrl2, ParameterWrongDoing.BadType, {
								async: context.async
								name: that.name()
								type: declaredType
							})
						}
						else if rest {
							ctrl2
								.newLine()
								.compile(that)
								.code($equals)
								.compile(defaultValue)
								.done()

							ctrl2.line('--__ks_i')
						}
						else {
							var ctrl3 = ctrl2
								.newControl()
								.code(`if(arguments.length - __ks_i < \(context.max - context.optional + context.required))`)
								.step()

							ctrl3
								.newLine()
								.compile(that)
								.code($equals)
								.compile(defaultValue)
								.done()

							ctrl3
								.line('--__ks_i')
								.step()
								.code('else')
								.step()

							wrongdoer(ctrl3, ParameterWrongDoing.BadType, {
								async: context.async
								name: that.name()
								type: declaredType
							})

							ctrl3.done()
						}

						ctrl2.done()

						ctrl.step().code('else').step()

						ctrl
							.newLine()
							.compile(that)
							.code($equals)
							.compile(defaultValue)
							.done()

						ctrl.done()
					}

					context.optional += 1
				}
				else {
					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code(` = \(context.name)[++__ks_i]`)
						.done()

					that.toValidationFragments(fragments, rest, defaultValue, header, async)

					context.required -= 1
				}
			}
		} # }}}
		toValidationFragments(fragments, rest, value?, header, async, that) { # {{{
			var declaredType = that.getDeclaredType()

			if value != null {
				if !header {
					var ctrl = fragments
						.newControl()
						.code('if(').compile(that).code(' === void 0')

					if !declaredType.isNullable() || that.operator() != AssignmentOperatorKind.Equals {
						ctrl.code(' || ').compile(that).code(' === null')
					}

					ctrl.code(')').step()

					if that.operator() == AssignmentOperatorKind.EmptyCoalescing {
						if value.isComposite() {
							ctrl
								.newLine()
								.compileReusable(value)
								.done()

							var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(that)).isNotEmpty(`).compile(value).code('))').step()

							ctrl2.newLine().compile(that).code($equals).compile(value).done()

							ctrl2.done()
						}
						else if value.isNotEmpty() {
							ctrl.newLine().compile(that).code($equals).compile(value).done()
						}
						else {
							var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(that)).isNotEmpty(`).compile(value).code('))').step()

							ctrl2.newLine().compile(that).code($equals).compile(value).done()

							ctrl2.done()
						}
					}
					else {
						ctrl.newLine().compile(that).code($equals).compile(value).done()
					}

					ctrl.done()
				}
			}
			else {
				if declaredType.isNullable() {
					var ctrl = fragments
						.newControl()
						.code('if(').compile(that).code(' === void 0').code(')')
						.step()

					ctrl.newLine().compile(that).code(' = null').done()

					ctrl.done()
				}
			}
		} # }}}
	}
	flagImmutable()
	isBinding() => false
	operator(): valueof @operator
	operator(@operator): valueof this
	setDeclaredType(type, definitive) { # {{{
		var variable = @scope.getVariable(@value)

		variable.setDeclaredType(type).setRealType(type).setDefinitive(definitive)

		@declaredType = @type = type
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind.EmptyCoalescing && value.isComposite() {
			value.acquireReusable(true)
			value.releaseReusable()
		}
	} # }}}
	toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		IdentifierParameter.toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity, required, defaultValue, header, async, this)
	} # }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		IdentifierParameter.toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity, required, defaultValue, header, async, this)
	} # }}}
	toParameterFragments(fragments) { # {{{
		fragments.compile(this)
	} # }}}
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
		IdentifierParameter.toValidationFragments(fragments, rest, defaultValue, header, async, this)
	} # }}}
}

class ArrayBindingParameter extends ArrayBinding {
	private late {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@tempName: Literal
	}
	analyse() { # {{{
		super()

		if @flatten {
			@tempName = Literal.new(@scope.acquireTempName(false), this)
		}
	} # }}}
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	isBinding() => true
	newElement(data) => ArrayBindingParameterElement.new(data, this, @scope)
	operator(@operator): valueof this
	setDeclaredType(mut type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for var element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isBroadArray() {
			type = type.discard()

			if type.isReference() {
				var elementType = type.parameter()

				for var element in @elements {
					element.setDeclaredType(elementType, definitive)
				}
			}
			else if type.isTuple() {
				for var element in @elements {
					if element.isRest() {
						throw NotImplementedException.new()
					}
					else {
						element.setDeclaredType(type.getProperty(element.index()).type(), definitive)
					}
				}
			}
			else {
				for var element, index in @elements {
					element.setDeclaredType(type.getProperty(index), definitive)
				}
			}
		}
		else {
			TypeException.throwInvalidBinding('Array', this)
		}
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind.EmptyCoalescing && value.isComposite() {
			value.acquireReusable(true)
			value.releaseReusable()
		}
	} # }}}
	toParameterFragments(fragments) { # {{{
		if @flatten {
			fragments.compile(@tempName)
		}
		else {
			fragments.compile(this)
		}
	} # }}}
	toValidationFragments(fragments, rest, value?, header, async) { # {{{
		if @flatten {
			if ?value {
				var ctrl = fragments
					.newControl()
					.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
					.step()

				if @operator == AssignmentOperatorKind.EmptyCoalescing {
					if value.isComposite() {
						ctrl
							.newLine()
							.compileReusable(value)
							.done()

						var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(this)).isNotEmpty(`).compile(value).code('))').step()

						ctrl2.newLine().compile(@tempName).code($equals).compile(value).done()

						ctrl2.done()
					}
					else if value.isNotEmpty() {
						ctrl.newLine().compile(@tempName).code($equals).compile(value).done()
					}
					else {
						var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(this)).isNotEmpty(`).compile(value).code('))').step()

						ctrl2.newLine().compile(@tempName).code($equals).compile(value).done()

						ctrl2.done()
					}
				}
				else {
					ctrl.newLine().compile(@tempName).code($equals).compile(value).done()
				}

				ctrl.done()
			}

			var line = fragments.newLine().code($runtime.scope(this))

			@elements[0].toFlatFragments(line, @tempName)

			for var element in @elements from 1 {
				line.code(', ')

				element.toFlatFragments(line, @tempName)
			}

			line.done()
		}
	} # }}}
}

class ArrayBindingParameterElement extends ArrayBindingElement {
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	compileVariable(data) => Parameter.compileExpression(data, this)
	setDeclaredType(type, definitive) { # {{{
		@name?.setDeclaredType(type, definitive)
	} # }}}
}

class ObjectBindingParameter extends ObjectBinding {
	private late {
		@alias: IdentifierLiteral?
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@tempName: Literal
	}
	analyse() { # {{{
		super()

		if ?@data.alias {
			@alias = $compile.expression(@data.alias, this)
				..setAssignment(AssignmentType.Declaration)
				..analyse()
		}
		else if @flatten {
			@tempName = Literal.new(@scope.acquireTempName(false), this)
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		super(target, targetMode)

		if ?@alias {
			@alias
				..type(target, @scope, this)
				..prepare(target, targetMode)
		}
	} # }}}
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	isBinding() => true
	override listAssignments(array, immutable, overwrite) { # {{{
		super(array, immutable, overwrite)

		if ?@alias {
			@alias.listAssignments(array, immutable, overwrite)
		}

		return array
	} # }}}
	newElement(data) => ObjectBindingParameterElement.new(data, this, @scope)
	operator(@operator): valueof this
	setDeclaredType(mut type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for var element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isBroadObject() {
			type = type.discard()

			if type.isReference() {
				var elementType = type.parameter()

				for var element in @elements {
					element.setDeclaredType(elementType, definitive)
				}
			}
			else if type.isStruct() {
				for var element in @elements {
					if element.isRest() {
						throw NotImplementedException.new()
					}
					else {
						element.setDeclaredType(type.getProperty(element.name()).type(), definitive)
					}
				}
			}
			else {
				for var element in @elements {
					if element.isRest() {
						element.setDeclaredType(type.getRestType(), definitive)
					}
					else {
						element.setDeclaredType(type.getProperty(element.name()), definitive)
					}
				}
			}
		}
		else if !type.isObject() {
			TypeException.throwInvalidBinding('Object', this)
		}
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind.EmptyCoalescing && value.isComposite() {
			value.acquireReusable(true)
			value.releaseReusable()
		}
	} # }}}
	toParameterFragments(fragments) { # {{{
		if ?@alias {
			fragments.compile(@alias)
		}
		else if @flatten {
			fragments.compile(@tempName)
		}
		else {
			super(fragments)
		}
	} # }}}
	toValidationFragments(fragments, rest, value?, header, async) { # {{{
		if ?@alias {
			fragments.newLine().code($runtime.scope(@immutable, this)).compile(this).code($equals).compile(@alias).done()
		}
		else if @flatten {
			if ?value {
				var ctrl = fragments
					.newControl()
					.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
					.step()

				if @operator == AssignmentOperatorKind.EmptyCoalescing {
					if value.isComposite() {
						ctrl
							.newLine()
							.compileReusable(value)
							.done()

						var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(this)).isNotEmpty(`).compile(value).code('))').step()

						ctrl2.newLine().compile(@tempName).code($equals).compile(value).done()

						ctrl2.done()
					}
					else if value.isNotEmpty() {
						ctrl.newLine().compile(@tempName).code($equals).compile(value).done()
					}
					else {
						var ctrl2 = ctrl.newControl().code(`if(\($runtime.type(this)).isNotEmpty(`).compile(value).code('))').step()

						ctrl2.newLine().compile(@tempName).code($equals).compile(value).done()

						ctrl2.done()
					}
				}
				else {
					ctrl.newLine().compile(@tempName).code($equals).compile(value).done()
				}

				ctrl.done()
			}

			var line = fragments.newLine().code($runtime.scope(this))

			@elements[0].toFlatFragments(line, @tempName)

			for var element in @elements from 1 {
				line.code(', ')

				element.toFlatFragments(line, @tempName)
			}

			line.done()
		}
	} # }}}
}

class ObjectBindingParameterElement extends ObjectBindingElement {
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	compileVariable(data) => Parameter.compileExpression(data, this)
	setDeclaredType(type, definitive) { # {{{
		@internal?.setDeclaredType(type, definitive)
	} # }}}
}

class AnonymousParameter extends AbstractNode {
	private late {
		@name: String
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@type: Type
	}
	analyse()
	override prepare(target, targetMode) { # {{{
		@name = @scope.acquireTempName(false)
	} # }}}
	translate()
	getDeclaredType() => @type
	isBinding() => false
	name() => null
	operator(@operator): valueof this
	setDeclaredType(@type, definitive)
	setDefaultValue(value)
	toFragments(fragments, mode) { # {{{
		fragments.code(@name)
	} # }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		if arity != null {
			throw NotImplementedException.new(this)
		}
		else {
			if @type.isAny() {
				fragments.line('++__ks_i')
			}
			else {
				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(this)
					.code(` = \(context.name)[++__ks_i]`)
					.done()

				@toValidationFragments(fragments, rest, defaultValue, header, async)
			}

			context.required -= 1
		}
	} # }}}
	toParameterFragments(fragments) { # {{{
		fragments.compile(this)
	} # }}}
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
	} # }}}
	type() => null
}

class ThisExpressionParameter extends ThisExpression {
	private late {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind.Equals
		@variable
	}
	override prepare(target, targetMode) { # {{{
		super(target)

		unless ?@variableName {
			throw NotSupportedException.new(this)
		}

		var method = @statement()

		if method is ClassMethodDeclaration || method is ImplementDividedClassMethodDeclaration {
			var class = method.parent()

			var late variable

			if method.isInstance() {
				variable = class.type().type().getInstanceVariable(@variableName)
			}
			else {
				variable = class.type().type().getStaticVariable(@variableName)
			}

			if variable.isImmutable() {
				ReferenceException.throwImmutable(this)
			}
		}
		else if method is ClassConstructorDeclaration || method is ImplementDividedClassConstructorDeclaration {
			var class = method.parent()

			var variable = class.type().type().getInstanceVariable(@variableName)

			if variable.isImmutable() && !variable.isLateInit() {
				ReferenceException.throwImmutable(this)
			}
		}

		@variable = @scope.getVariable(@name)

		@parent.addAliasParameter(this)
	} # }}}
	getDeclaredType() => @type
	flagImmutable()
	isBinding() => false
	listAssignments(array: Array, immutable: Boolean? = null, overwrite: Boolean? = null) { # {{{
		array.push({ @name, immutable: true, overwrite: false })

		return array
	} # }}}
	operator(): valueof @operator
	operator(@operator): valueof this
	setDeclaredType(type, definitive) { # {{{
		unless type.isSubsetOf(@type, MatchingMode.Signature) {
			TypeException.throwInvalidAssignment(`@\(@name)`, @type, type, this)
		}

		var variable = @parent.scope().getVariable(@name)

		variable.setDeclaredType(type).setDefinitive(definitive)
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind.EmptyCoalescing && value.isComposite() {
			value.acquireReusable(true)
			value.releaseReusable()
		}
	} # }}}
	toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		IdentifierParameter.toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity, required, defaultValue, header, async, this)
	} # }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		IdentifierParameter.toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity, required, defaultValue, header, async, this)
	} # }}}
	toFragments(fragments, mode) { # {{{
		fragments.compile(@variable)
	} # }}}
	toParameterFragments(fragments) { # {{{
		fragments.compile(@variable)
	} # }}}
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
		IdentifierParameter.toValidationFragments(fragments, rest, defaultValue, header, async, this)
	} # }}}
	type(type)
}
