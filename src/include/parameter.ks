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
	private lateinit {
		_anonymous: Boolean					= false
		_arity								= null
		_comprehensive: Boolean				= true
		_defaultValue						= null
		_explicitlyRequired: Boolean		= false
		_hasDefaultValue: Boolean			= false
		_header: Boolean					= false
		_maybeHeadedDefaultValue: Boolean	= false
		_name
		_rest: Boolean						= false
		_type: ParameterType
	}
	static compileExpression(data, node) {
		switch data.kind {
			NodeKind::ArrayBinding => return new ArrayBindingParameter(data, node)
			NodeKind::Identifier => return new IdentifierParameter(data, node)
			NodeKind::ObjectBinding => return new ObjectBindingParameter(data, node)
			NodeKind::ThisExpression => return new ThisExpressionParameter(data, node)
		}
	}
	static getUntilDifferentTypeIndex(parameters, index) { # {{{
		const activeType = parameters[index].type().type().setNullable(false)

		for const parameter, i in parameters from index + 1 {
			const type = parameter.type()

			if type.min() == 0 {
				if !activeType.equals(type.type().setNullable(false)) {
					return 0
				}

				if type.max() > 1  {
					return i + 1
				}
			}
			else {
				return 0
			}
		}

		return parameters.length
	} # }}}
	static toFragments(node, fragments, mode, fn) { # {{{
		return Parameter.toKSFragments(node, fragments, mode, fn)
	} # }}}
	static toKSFragments(node, fragments, mode: ParameterMode, fn) { # {{{
		const parameters = node.parameters()
		const signature = node.type()

		const name = (mode == ParameterMode::Default | ParameterMode::OverloadedFunction | ParameterMode::HelperConstructor) ? 'arguments' : '__ks_arguments'

		let restIndex = -1
		let minBefore = 0
		let maxBefore = 0
		let minRest = 0
		let minAfter = 0
		let maxAfter = 0

		for const parameter, i in parameters {
			const type = parameter.type()

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
				++minAfter
				++maxAfter
			}
			else {
				++minBefore
				++maxBefore
			}
		}

		const context = {
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

		let lastHeaderParameterIndex = 0
		let asyncHeaderParameter = false

		if signature.max() > 0 {
			if mode == ParameterMode::ArrowFunction {
				fragments.code(`...\(name)`)
			}
			else if mode == ParameterMode::HybridConstructor {
				fragments.code(name)
			}
		}

		if mode == ParameterMode::Default | ParameterMode::HelperConstructor {
			const offset = node.getParameterOffset()

			for const parameter, i in parameters {
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
			for const parameter in parameters til lastHeaderParameterIndex {
				parameter.toValidationFragments(fragments)
			}
		}

		if lastHeaderParameterIndex == parameters.length {
			return fragments
		}

		return fragments
	} # }}}
	static toHeaderParameterFragments(fragments, node, parameters, minAfter, context) { # {{{
		const offset = node.getParameterOffset()

		let til = -1

		for const parameter, i in parameters {
			const type = parameter.type()

			if type.max() == Infinity {
				fragments.code($comma) if i + offset > 0

				parameter.toParameterFragments(fragments)
			}
			else if type.max() > 1  {
				fragments.code($comma) if i + offset > 0

				parameter.toParameterFragments(fragments)
			}
			else if parameter.isRequired() || i + 1 == parameters.length || i < (til == -1 ? (til = Parameter.getUntilDifferentTypeIndex(parameters, i)) : til) {
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
	static toAsyncHeaderParameterFragments(fragments, parameters, lastHeader) { # {{{
		if lastHeader == parameters.length {
			fragments.code($comma) if lastHeader > 0

			fragments.code('__ks_cb')

			return true
		}
		else {
			return false
		}
	} # }}}
	static toLengthValidationFragments(fragments, node, name, signature, parameters, asyncHeader, restIndex, minBefore, minRest, minAfter) { # {{{
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
							let ctrl = fragments
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
						let ctrl = fragments
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
	static toAfterRestParameterFragments(fragments, name, parameters, restIndex, beforeContext, wrongdoer) { # {{{
		parameter = parameters[restIndex]

		const context = {
			name
			any: parameter.type().isAny()
			increment: false
			temp: beforeContext.temp
			tempL: beforeContext.tempL
			length: parameters.length
		}

		for const parameter, i in parameters from restIndex + 1 {
			parameter.toAfterRestFragments(fragments, context, i, wrongdoer)
		}
	} # }}}
	static toRestParameterFragments(fragments, node, name, signature, parameters, declared, restIndex, minBefore, minAfter, maxAfter, context, wrongdoer) { # {{{
		const parameter = parameters[restIndex]

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
				const line = fragments.newLine()

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
				const ctrl = fragments.newControl()

				if minAfter > 0 {
					ctrl.code('if(__ks__ > ++__ks_i)').step()
				}
				else {
					ctrl.code('if(arguments.length > ++__ks_i)').step()
				}

				const ctrl2 = ctrl.newControl()

				ctrl2.code(`if(arguments[__ks_i] === void 0 || arguments[__ks_i] === null)`).step()

				ctrl2.step().code('else').step().line('--__ks_i').done()

				ctrl.done()
			}

			const ctrl = fragments.newControl()

			if minAfter > 0 {
				ctrl.code('while(__ks__ > ++__ks_i)')
			}
			else {
				ctrl.code('while(arguments.length > ++__ks_i)')
			}

			ctrl.step()

			const ctrl2 = ctrl.newControl()

			const literal = new Literal(false, node, node.scope(), 'arguments[__ks_i]')

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
				const ctrl = fragments
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

			const min = parameter.type().min()
			if min > 0 {
				const ctrl = fragments
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
	static toBeforeRestParameterFragments(fragments, name, signature, parameters, nextIndex, restIndex, context, wrongdoer) { # {{{
		if restIndex == -1 {
			for const parameter, i in parameters from nextIndex {
				parameter.toBeforeRestFragments(fragments, context, i, false, wrongdoer)
			}
		}
		else {
			for const parameter, i in parameters from nextIndex til restIndex {
				parameter.toBeforeRestFragments(fragments, context, i, true, wrongdoer)
			}
		}
	} # }}}
	analyse() { # {{{
		@anonymous = !?@data.name

		if @anonymous {
			@name = new AnonymousParameter(@data, this)
		}
		else {
			@name = Parameter.compileExpression(@data.name, this)
			@name.setAssignment(AssignmentType::Parameter)
			@name.analyse()

			for const name in @name.listAssignments([]) {
				if @scope.hasDefinedVariable(name) {
					SyntaxException.throwAlreadyDeclared(name, this)
				}

				@scope.define(name, false, null, this)
			}
		}
	} # }}}
	prepare() { # {{{
		@name.prepare()

		let type: Type? = @name.type()

		if !type?.isExplicit() {
			type = null
		}

		if @data.type? {
			const declaredType = Type.fromAST(@data.type, this)

			if !?type || (type.isObject() && declaredType.isDictionary()) || declaredType.isMorePreciseThan(type) {
				type = declaredType
			}
		}

		if type == null {
			type = AnyType.Unexplicit
		}
		else if type.isNull() {
			type = NullType.Explicit
		}

		let min: Number = 1
		let max: Number = 1

		for modifier in @data.modifiers {
			if modifier.kind == ModifierKind::Rest {
				@rest = true

				if modifier.arity? {
					@arity = modifier.arity

					min = modifier.arity.min
					max = modifier.arity.max
				}
				else {
					min = 0
					max = Infinity
				}
			}
			else if modifier.kind == ModifierKind::Required {
				@explicitlyRequired = true
			}
		}

		if @data.defaultValue? {
			if @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				if !type.isNullable() {
					type = type.setNullable(true)
				}
			}
			else if @explicitlyRequired && type.isNullable() {
				SyntaxException.throwDeadCodeParameter(this)
			}

			if !(@explicitlyRequired && type.isNullable()) {
				@maybeHeadedDefaultValue = @options.format.parameters == 'es6' && (type.isNullable() || @name.isBinding())

				@defaultValue = $compile.expression(@data.defaultValue, @parent)
				@defaultValue.analyse()

				@hasDefaultValue = true

				if !@explicitlyRequired {
					min = 0
				}
			}
		}

		const name: String? = @name.name()

		@type = new ParameterType(@scope, name, type!?, min, max, @hasDefaultValue)

		if @hasDefaultValue && @parent.isOverridableFunction() {
			const scope = @parent.scope()

			@comprehensive = !@defaultValue.isUsingNonLocalVariables(scope)

			if @comprehensive {
				@type.setDefaultValue(@data.defaultValue, true)
			}
			else {
				const variables = [variable.name() for const variable in @defaultValue.listLocalVariables(scope, [])]

				const name = @parent.addIndigentValue(@defaultValue, variables)

				const call = `\(name)(\(variables.join(', ')))`

				@type.setDefaultValue(call, false)

				@defaultValue = new Literal(`\(@parent.getOverridableVarname()).\(call)`, @parent)
			}
		}

		type = @type.getVariableType()

		@name.setDeclaredType(@rest ? Type.arrayOf(type, @scope) : type, true)
	} # }}}
	translate() { # {{{
		@name.translate()

		if @hasDefaultValue {
			@defaultValue.prepare()
			@defaultValue.translate()

			if !@defaultValue.type().isAssignableToVariable(@name.getDeclaredType(), true, true, false) {
				TypeException.throwInvalidAssignement(@name, @name.getDeclaredType(), @defaultValue.type(), this)
			}
		}
	} # }}}
	addAliasParameter(expression: ThisExpressionParameter) { # {{{
		const alias = new AliasStatement(expression, this)

		return @scope.reference(alias.type())
	} # }}}
	arity() => @arity
	getReturnType() => @type.getReturnType()
	hasDefaultValue() => @hasDefaultValue
	isAnonymous() => @anonymous
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
		fragments.compile(@name)
	} # }}}
	toAfterRestFragments(fragments, context, index, wrongdoer) { # {{{
		@name.toAfterRestFragments(fragments, context, index, wrongdoer, @rest, @arity, this.isRequired(), @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} # }}}
	toBeforeRestFragments(fragments, context, index, rest, wrongdoer) { # {{{
		@name.toBeforeRestFragments(fragments, context, index, wrongdoer, rest, @arity, this.isRequired(), @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} # }}}
	toErrorFragments(fragments, async) { # {{{
		@name.toErrorFragments(fragments, async)
	} # }}}
	toParameterFragments(fragments) { # {{{
		@name.toParameterFragments(fragments)

		if @maybeHeadedDefaultValue {
			fragments.code($equals).compile(@defaultValue)
		}

		@header = true
	} # }}}
	toQuote() => @type.toQuote()
	toValidationFragments(fragments) { # {{{
		if @rest {
			if @hasDefaultValue {
				const ctrl = fragments
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
			@name.toValidationFragments(fragments, @rest, @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
		}
	} # }}}
	type(): ParameterType => @type
	type(@type) { # {{{
		if @type.hasDefaultValue() {
			if @type.isComprehensive() {
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

		const t = @type.getVariableType()

		@name.setDeclaredType(@rest ? Type.arrayOf(t, @scope) : t, true)
	} # }}}
}

class AliasStatement extends Statement {
	private {
		_expression: ThisExpressionParameter
		_parameter: Parameter
	}
	constructor(@expression, @parameter) { # {{{
		const parent = parameter.parent()

		super(expression.data(), parent)

		parent.addAtThisParameter(this)
	} # }}}
	analyse()
	prepare()
	translate()
	getVariableName() => @expression.getVariableName()
	name() => @expression.name()
	path() => @expression.path()
	toStatementFragments(fragments, mode) { # {{{
		const variable = @scope.getVariable(@expression.name())

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
	static {
		toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async, that) { # {{{
			if arity != null {
				const type = that.getDeclaredType().parameter()

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

					const line = fragments.newLine()

					if !context.tempL {
						line.code($runtime.scope(that))

						context.tempL = true
					}

					line.code(`__ks_l = __ks_i + \(arity.min + 1)`).done()

					const ctrl = fragments.newControl().code('while(++__ks_i < __ks_l)').step()

					ctrl.line(`__ks__ = \(context.name)[__ks_i]`)

					const ctrl2 = ctrl.newControl()

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
						const ctrl3 = ctrl2
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
					const declaredType = that.getDeclaredType()

					if declaredType.isAny() {
						if !context.temp {
							fragments.line(`\($runtime.scope(that))__ks__`)

							context.temp = true
						}

						let line = fragments
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

						let line = fragments
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

				const type = that.getDeclaredType().parameter()

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

					const line = fragments.newLine()

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

					const ctrl = fragments.newControl().code('while(++__ks_i < __ks_l)').step()

					ctrl.line(`__ks__ = \(context.name)[__ks_i]`)

					const ctrl2 = ctrl.newControl()

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
						const ctrl3 = ctrl2
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
					const declaredType = that.getDeclaredType()

					if declaredType.isAny() {
						if !context.temp {
							fragments.line(`\($runtime.scope(that))__ks__`)

							context.temp = true
						}

						const line = fragments
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

						const fixed = (context.max - context.min) == 1

						const ctrl = fragments.newControl()

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

						const ctrl2 = ctrl.newControl().code('if(')

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
							const ctrl3 = ctrl2
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

					++context.optional
				}
				else {
					fragments
						.newLine()
						.code($runtime.scope(that))
						.compile(that)
						.code(` = \(context.name)[++__ks_i]`)
						.done()

					that.toValidationFragments(fragments, rest, defaultValue, header, async)

					--context.required
				}
			}
		} # }}}
		toValidationFragments(fragments, rest, defaultValue?, header, async, that) { # {{{
			const declaredType = that.getDeclaredType()

			let ctrl = null

			if defaultValue != null {
				if !header {
					ctrl = fragments
						.newControl()
						.code('if(').compile(that).code(' === void 0')

					if !declaredType.isNullable() {
						ctrl.code(' || ').compile(that).code(' === null')
					}

					ctrl.code(')').step()

					ctrl
						.newLine()
						.compile(that)
						.code($equals)
						.compile(defaultValue)
						.done()
				}
			}
			else {
				if declaredType.isNullable() {
					ctrl = fragments
						.newControl()
						.code('if(').compile(that).code(' === void 0').code(')')
						.step()

					ctrl.newLine().compile(that).code(' = null').done()
				}
			}

			if ctrl != null {
				ctrl.done()
			}
		} # }}}
	}
	isBinding() => false
	setDeclaredType(type, definitive) { # {{{
		const variable = @scope.getVariable(@value)

		variable.setDeclaredType(type).setRealType(type).setDefinitive(definitive)

		@declaredType = @realType = type
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
	private lateinit {
		_tempName: Literal
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
	setDeclaredType(type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for const element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isArray() {
			if type.isReference() {
				const elementType = type.parameter()

				for const element in @elements {
					element.setDeclaredType(elementType, definitive)
				}
			}
			else {
				for const element, index in @elements {
					element.setDeclaredType(type.getElement(index), definitive)
				}
			}
		}
		else {
			TypeException.throwInvalidBinding('Array', this)
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
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
		if @flatten {
			const ctrl = fragments
				.newControl()
				.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
				.step()

			if defaultValue != null {
				ctrl
					.newLine()
					.compile(@tempName)
					.code($equals)
					.compile(defaultValue)
					.done()
			}

			ctrl.done()

			const line = fragments.newLine().code($runtime.scope(this))

			@elements[0].toFlatFragments(line, @tempName)

			for const element in @elements from 1 {
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
	private lateinit {
		_tempName: Literal
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
	setDeclaredType(type, definitive: Boolean = false) { # {{{
		if type.isAny() {
			for const element in @elements {
				element.setDeclaredType(type, definitive)
			}
		}
		else if type.isDictionary() {
			if type.isReference() {
				const elementType = type.parameter()

				for const element in @elements {
					element.setDeclaredType(elementType, definitive)
				}
			}
			else {
				for const element in @elements {
					element.setDeclaredType(type.getProperty(element.name()), definitive)
				}
			}
		}
		else if !type.isObject() {
			TypeException.throwInvalidBinding('Object', this)
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
	toValidationFragments(fragments, rest, defaultValue?, header, async) { # {{{
		if @flatten {
			const ctrl = fragments
				.newControl()
				.code('if(').compile(@tempName).code(' === void 0').code(' || ').compile(@tempName).code(' === null').code(')')
				.step()

			if defaultValue != null {
				ctrl
					.newLine()
					.compile(@tempName)
					.code($equals)
					.compile(defaultValue)
					.done()
			}

			ctrl.done()

			const line = fragments.newLine().code($runtime.scope(this))

			@elements[0].toFlatFragments(line, @tempName)

			for const element in @elements from 1 {
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
	private lateinit {
		_name: String
		_type: Type
	}
	analyse()
	prepare() { # {{{
		@name = @scope.acquireTempName(false)
	} # }}}
	translate()
	name() => null
	setDeclaredType(@type, definitive)
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

				this.toValidationFragments(fragments, rest, defaultValue, header, async)
			}

			--context.required
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
	override prepare() { # {{{
		super()

		unless ?@variableName {
			throw new NotSupportedException(this)
		}

		const method = this.statement()

		if method is ClassMethodDeclaration || method is ImplementClassMethodDeclaration {
			const class = method.parent()

			lateinit const variable

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
			const class = method.parent()

			const variable = class.type().type().getInstanceVariable(@variableName)

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
	setDeclaredType(type, definitive) { # {{{
		if !type.matchContentOf(@type) {
			TypeException.throwInvalidAssignement(`@\(@name)`, @type, type, this)
		}

		const variable = @parent.scope().getVariable(@name)

		variable.setDeclaredType(type).setDefinitive(definitive)
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
