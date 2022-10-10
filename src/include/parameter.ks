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
		@hasDefaultValue: Boolean			= false
		@headedDefaultValue: Boolean		= false
		@header: Boolean					= false
		@internal
		@nullable: Boolean					= false
		@retained: Boolean
		@rest: Boolean						= false
		@tempVariables: Array				= []
		@type: ParameterType
	}
	static {
		compileExpression(data, node) {
			switch data.kind {
				NodeKind::ArrayBinding => return new ArrayBindingParameter(data, node)
				NodeKind::Identifier => return new IdentifierParameter(data, node)
				NodeKind::ObjectBinding => return new ObjectBindingParameter(data, node)
				NodeKind::ThisExpression => return new ThisExpressionParameter(data, node)
			}
		}
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

			var name = (mode == ParameterMode::Default | ParameterMode::OverloadedFunction | ParameterMode::HelperConstructor) ? 'arguments' : '__ks_arguments'

			// TODO move to `var mut`
			var dyn restIndex = -1
			var dyn minBefore = 0
			var dyn maxBefore = 0
			var dyn minRest = 0
			var dyn minAfter = 0
			var dyn maxAfter = 0

			for var parameter, i in parameters {
				var type = parameter.type()

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
				if mode == ParameterMode::ArrowFunction {
					fragments.code(`...\(name)`)
				}
				else if mode == ParameterMode::HybridConstructor {
					fragments.code(name)
				}
			}

			if mode == ParameterMode::Default | ParameterMode::HelperConstructor {
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

			if mode != ParameterMode::HelperConstructor {
				for var parameter in parameters til lastHeaderParameterIndex {
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
									.line(`throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)")`)
									.step()
									.code(`else if(!\($runtime.type(node)).isFunction(__ks_cb))`)
									.step()
									.line(`throw new TypeError("'callback' must be a function")`)
									.done()
							}
							else {
								var mut ctrl = fragments
									.newControl()
									.code(`if(arguments.length < \(signature.min() + 1))`)
									.step()
									.line(`\($runtime.scope(node))__ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

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
									.line(`throw new TypeError("'callback' must be a function")`)
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
								.line(`\($runtime.scope(node))__ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

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
								.line(`throw new TypeError("'callback' must be a function")`)

							ctrl.done()
						}
					}
				}
				else if node.isAssertingParameter() {
					fragments
						.newControl()
						.code(`if(\(name).length < \(signature.min() + node.getParameterOffset()))`)
						.step()
						.line(`throw new SyntaxError("Wrong number of arguments (" + \(name).length + " for \(signature.min()))")`)
						.done()
				}
			}
		} # }}}
		toAfterRestParameterFragments(fragments, name, parameters, restIndex, beforeContext, wrongdoer) { # {{{
			parameter = parameters[restIndex]

			var context = {
				name
				any: parameter.type().isAny()
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

				var ctrl = fragments.newControl()

				if minAfter > 0 {
					ctrl.code('while(__ks__ > ++__ks_i)')
				}
				else {
					ctrl.code('while(arguments.length > ++__ks_i)')
				}

				ctrl.step()

				var ctrl2 = ctrl.newControl()

				var literal = new Literal(false, node, node.scope(), 'arguments[__ks_i]')

				if parameter.type().isNullable() {
					ctrl2.code(`if(arguments[__ks_i] === void 0)`).step()

					ctrl2.newLine().compile(parameter).code('.push(null)').done()

					ctrl2.step()

					ctrl2.code(`else if(arguments[__ks_i] === null || `)

					parameter.type().toPositiveTestFragments(ctrl2, literal, Junction::OR)

					ctrl2.code(')').step()
				}
				else {
					ctrl2.code('if(')

					parameter.type().toPositiveTestFragments(ctrl2, literal, Junction::NONE)

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
							.code(`return __ks_cb(new SyntaxError("The rest parameter must have at least \(min) argument\(min > 1 ? 's' : '') (" + `)
							.compile(parameter)
							.code(`.length + ")"))`)
							.done()
					}
					else {
						ctrl
							.newLine()
							.code(`throw new SyntaxError("The rest parameter must have at least \(min) argument\(min > 1 ? 's' : '') (" + `)
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
				for var parameter, i in parameters from nextIndex til restIndex {
					parameter.toBeforeRestFragments(fragments, context, i, true, wrongdoer)
				}
			}
		} # }}}
	}
	constructor(@data, @parent, @scope = parent.scope()) { # {{{
		super(data, parent, scope)

		@options = Attribute.configure(data, parent._options, AttributeTarget::Parameter, super.file())
		@retained = @options.parameters.retain
	} # }}}
	analyse() { # {{{
		var mut immutable = true

		for var modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Mutable {
				immutable = false

				break
			}
		}

		if ?@data.internal {
			@internal = Parameter.compileExpression(@data.internal, this)
			@internal.setAssignment(AssignmentType::Parameter)

			if ?@data.operator {
				@internal.operator(@data.operator.assignment)
			}

			@internal.analyse()

			for var name in @internal.listAssignments([]) {
				if @scope.hasDefinedVariable(name) {
					SyntaxException.throwAlreadyDeclared(name, this)
				}

				@scope.define(name, immutable, null, this)
			}
		}
		else {
			@internal = new AnonymousParameter(@data, this)
		}
	} # }}}
	override prepare(target) { # {{{
		@internal.prepare()

		var mut type: Type? = @internal.type()?.asReference()

		if !type?.isExplicit() {
			type = null
		}

		if ?@data.type {
			var declaredType = Type.fromAST(@data.type, this)

			if !?type || (type.isObject() && declaredType.isDictionary()) || declaredType.isMorePreciseThan(type) {
				type = declaredType
			}
		}

		var mut min: Number = 1
		var mut max: Number = 1
		var mut passing = null

		for var modifier in @data.modifiers {
			switch modifier.kind {
				ModifierKind::NameOnly => {
					passing = PassingMode::LABELED
				}
				ModifierKind::Nullable => {
					type ??= AnyType.NullableUnexplicit
				}
				ModifierKind::PositionOnly => {
					passing = PassingMode::POSITIONAL
				}
				ModifierKind::Rest => {
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
				ModifierKind::Required => {
					@explicitlyRequired = true
				}
			}
		}

		if type == null {
			type = AnyType.Unexplicit
		}
		else if type.isNull() {
			type = NullType.Explicit
		}

		if ?@data.defaultValue {
			if @explicitlyRequired && type.isNullable() {
				if @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
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

		@type = new ParameterType(@scope, external, internal, passing, type!?, min, max, @hasDefaultValue)

		if @hasDefaultValue && @parent.isOverridableFunction() {
			var scope = @parent.scope()

			@comprehensive = !@defaultValue.isUsingNonLocalVariables(scope)

			if @comprehensive {
				@type.setDefaultValue(@data.defaultValue, true)
			}
			else {
				var variables = [variable.name() for var variable in @defaultValue.listLocalVariables(scope, [])]

				var name = @parent.addIndigentValue(@defaultValue, variables)

				var call = `\(name)(\(variables.join(', ')))`

				@type.setDefaultValue(call, false)

				@defaultValue = new Literal(`\(@parent.getOverridableVarname()).\(call)`, @parent)
			}
		}

		if @retained {
			@type.flagRetained()
		}

		type = @type.getVariableType()

		@internal.setDeclaredType(@rest ? Type.arrayOf(type, @scope) : type, true)
	} # }}}
	translate() { # {{{
		@internal.translate()

		if @hasDefaultValue {
			@defaultValue.prepare()

			if ?@data.operator -> @data.operator.assignment == AssignmentOperatorKind::Equals {
				@headedDefaultValue = @nullable || @internal.isBinding()
			}
			else {
				@headedDefaultValue = @defaultValue.type().isNull()
			}

			@defaultValue.translate()

			unless @defaultValue.type().isAssignableToVariable(@internal.getDeclaredType(), true, false, false) {
				TypeException.throwInvalidAssignement(@internal, @internal.getDeclaredType(), @defaultValue.type(), this)
			}
		}
	} # }}}
	addAliasParameter(expression: ThisExpressionParameter) { # {{{
		var alias = new AliasStatement(expression, this)

		return @scope.reference(alias.type())
	} # }}}
	arity() => @arity
	getReturnType() => @type.getReturnType()
	hasDefaultValue() => @hasDefaultValue
	isAssertingParameter() => @parent.isAssertingParameter()
	isAssertingParameterType() => @parent.isAssertingParameterType()
	isComprehensive() => @comprehensive
	isRequired() => @defaultValue == null || @explicitlyRequired
	isRest() => @rest
	isUsingVariable(name) => @hasDefaultValue && @defaultValue.isUsingVariable(name)
	max() => @arity?.max ?? 1
	min() => @arity?.min ?? 1
	setDefaultValue(data) { # {{{
		@defaultValue = $compile.expression(data, @parent)
		@defaultValue.analyse()

		@hasDefaultValue = true

		@type.setDefaultValue(data)
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
				@defaultValue = new Literal(`\(@parent.getOverridableVarname()).\(@type.getDefaultValue())`, @parent)
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
	private {
		@expression: ThisExpressionParameter
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
		@parameter: Parameter
	}
	constructor(@expression, @parameter) { # {{{
		var parent = parameter.parent()

		super(expression.data(), parent)

		parent.addAtThisParameter(this)
	} # }}}
	analyse()
	override prepare(target)
	translate()
	getVariableName() => @expression.getVariableName()
	name() => @expression.name()
	operator(@operator): this
	path() => @expression.path()
	toStatementFragments(fragments, mode) { # {{{
		var variable = @scope.getVariable(@expression.name())

		if @expression.isSealed() && !@parameter.parent().isConstructor() {
			fragments.newLine().code(`\(@expression.getClass().getSealedName()).__ks_set_\(@expression.name())(this, `).compile(variable).code(')').done()
		}
		else {
			fragments.newLine().code(@expression.fragment(), $equals).compile(variable).done()
		}
	} # }}}
	type() => @expression.type()
}

class IdentifierParameter extends IdentifierLiteral {
	private {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
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

						type.toNegativeTestFragments(ctrl2, new Literal(false, that, that.scope(), '__ks__'), Junction::NONE)
					}
					else {
						ctrl2.code('if(__ks__ === void 0 || __ks__ === null || ')

						type.toNegativeTestFragments(ctrl2, new Literal(false, that, that.scope(), '__ks__'), Junction::OR)
					}

					ctrl2
						.code(')')
						.step()

					if index + 1 == context.length {
						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
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

						wrongdoer(ctrl3, ParameterWrongDoing::BadType, {
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

							declaredType.toPositiveTestFragments(line, new Literal(false, that, that.scope(), '__ks__'), Junction::OR)

							line.code(')')
						}
						else {
							declaredType.toPositiveTestFragments(line, new Literal(false, that, that.scope(), '__ks__'), Junction::AND)
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

						type.toNegativeTestFragments(ctrl2, new Literal(false, that, that.scope(), '__ks__'), Junction::NONE)
					}
					else {
						ctrl2.code('if(__ks__ === void 0 || __ks__ === null || ')

						type.toNegativeTestFragments(ctrl2, new Literal(false, that, that.scope(), '__ks__'), Junction::OR)
					}

					ctrl2
						.code(')')
						.step()

					if index + 1 == context.length {
						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
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

						wrongdoer(ctrl3, ParameterWrongDoing::BadType, {
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

							declaredType.toNegativeTestFragments(ctrl2, that, Junction::AND)
						}
						else {
							declaredType.toNegativeTestFragments(ctrl2, that, Junction::NONE)
						}

						ctrl2
							.code(')')
							.step()

						if fixed || index + 1 == context.length {
							wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
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

							wrongdoer(ctrl3, ParameterWrongDoing::BadType, {
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

					if !declaredType.isNullable() || that.operator() != AssignmentOperatorKind::Equals {
						ctrl.code(' || ').compile(that).code(' === null')
					}

					ctrl.code(')').step()

					if that.operator() == AssignmentOperatorKind::EmptyCoalescing {
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
	isBinding() => false
	operator(): @operator
	operator(@operator): this
	setDeclaredType(type, definitive) { # {{{
		var variable = @scope.getVariable(@value)

		variable.setDeclaredType(type).setRealType(type).setDefinitive(definitive)

		@declaredType = @realType = type
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind::EmptyCoalescing && value.isComposite() {
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
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
		@tempName: Literal
	}
	analyse() { # {{{
		super()

		if @flatten {
			@tempName = new Literal(@scope.acquireTempName(false), this)
		}
	} # }}}
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	isBinding() => true
	newElement(data) => new ArrayBindingParameterElement(data, this, @scope)
	operator(@operator): this
	setDeclaredType(type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for var element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isArray() {
			if type.isReference() {
				var elementType = type.parameter()

				for var element in @elements {
					element.setDeclaredType(elementType, definitive)
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
		if @operator == AssignmentOperatorKind::EmptyCoalescing && value.isComposite() {
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
			var ctrl = fragments
				.newControl()
				.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
				.step()

			if value != null {
				if @operator == AssignmentOperatorKind::EmptyCoalescing {
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
			}

			ctrl.done()

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
		@name.setDeclaredType(type, definitive)
	} # }}}
}

class ObjectBindingParameter extends ObjectBinding {
	private late {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
		@tempName: Literal
	}
	analyse() { # {{{
		super()

		if @flatten {
			@tempName = new Literal(@scope.acquireTempName(false), this)
		}
	} # }}}
	addAliasParameter(parameter: ThisExpressionParameter) => @parent.addAliasParameter(parameter)
	isBinding() => true
	newElement(data) => new ObjectBindingParameterElement(data, this, @scope)
	operator(@operator): this
	setDeclaredType(type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for var element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isDictionary() {
			if type.isReference() {
				var elementType = type.parameter()

				for var element in @elements {
					element.setDeclaredType(elementType, definitive)
				}
			}
			else {
				for var element in @elements {
					element.setDeclaredType(type.getProperty(element.name()), definitive)
				}
			}
		}
		else if !type.isObject() {
			TypeException.throwInvalidBinding('Object', this)
		}
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind::EmptyCoalescing && value.isComposite() {
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
			var ctrl = fragments
				.newControl()
				.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
				.step()

			if value != null {
				if @operator == AssignmentOperatorKind::EmptyCoalescing {
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
			}

			ctrl.done()

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
		@alias.setDeclaredType(type, definitive)
	} # }}}
}

class AnonymousParameter extends AbstractNode {
	private late {
		@name: String
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
		@type: Type
	}
	analyse()
	override prepare(target) { # {{{
		@name = @scope.acquireTempName(false)
	} # }}}
	translate()
	name() => null
	operator(@operator): this
	setDeclaredType(@type, definitive)
	setDefaultValue(value)
	toFragments(fragments, mode) { # {{{
		fragments.code(@name)
	} # }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { # {{{
		if arity != null {
			throw new NotImplementedException(this)
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
	private {
		@operator: AssignmentOperatorKind	= AssignmentOperatorKind::Equals
	}
	override prepare(target) { # {{{
		super(target)

		unless ?@variableName {
			throw new NotSupportedException(this)
		}

		var method = @statement()

		if method is ClassMethodDeclaration || method is ImplementClassMethodDeclaration {
			var class = method.parent()

			var late variable

			if method.isInstance() {
				variable = class.type().type().getInstanceVariable(@variableName)
			}
			else {
				variable = class.type().type().getClassVariable(@variableName)
			}

			if variable.isImmutable() {
				ReferenceException.throwImmutable(this)
			}
		}
		else if method is ClassConstructorDeclaration || method is ImplementClassConstructorDeclaration {
			var class = method.parent()

			var variable = class.type().type().getInstanceVariable(@variableName)

			if variable.isImmutable() && !variable.isLateInit() {
				ReferenceException.throwImmutable(this)
			}
		}

		@parent.addAliasParameter(this)
	} # }}}
	getDeclaredType() => @type
	isBinding() => false
	listAssignments(array: Array<String>) { # {{{
		array.push(@name)

		return array
	} # }}}
	operator(): @operator
	operator(@operator): this
	setDeclaredType(type, definitive) { # {{{
		if !type.matchContentOf(@type) {
			TypeException.throwInvalidAssignement(`@\(@name)`, @type, type, this)
		}

		var variable = @parent.scope().getVariable(@name)

		variable.setDeclaredType(type).setDefinitive(definitive)
	} # }}}
	setDefaultValue(value) { # {{{
		if @operator == AssignmentOperatorKind::EmptyCoalescing && value.isComposite() {
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
		fragments.compile(@scope.getVariable(@name))
	} # }}}
	toParameterFragments(fragments) { # {{{
		fragments.compile(@scope.getVariable(@name))
	} # }}}
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
		IdentifierParameter.toValidationFragments(fragments, rest, defaultValue, header, async, this)
	} # }}}
	type(type)
}
