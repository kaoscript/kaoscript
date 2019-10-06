enum ParameterMode {
	ArrowFunction
	Default
	HybridConstructor
	OverloadedFunction
}

enum ParameterWrongDoing {
	BadType
	NotNullable
}

class Parameter extends AbstractNode {
	private {
		_anonymous: Boolean
		_arity								= null
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
		}
	}
	static getUntilDifferentTypeIndex(parameters, index) { // {{{
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
	} // }}}
	static toFragments(node, fragments, mode, fn, wrongdoer = Parameter.toWrongDoingFragments) { // {{{
		if node._options.parse.parameters == 'es5' {
			return Parameter.toES5Fragments(node, fragments, fn)
		}
		else if node._options.parse.parameters == 'es6' {
			return Parameter.toES6Fragments(node, fragments, fn)
		}
		else {
			return Parameter.toKSFragments(node, fragments, mode, fn, wrongdoer)
		}
	} // }}}
	static toES5Fragments(node, fragments, fn) { // {{{
		const data = node.data()

		for parameter, i in node.parameters() {
			if parameter.isRest() {
				SyntaxException.throwNoRestParameter(node)
			}
			else if parameter.hasDefaultValue() {
				SyntaxException.throwNoDefaultParameter(node)
			}
			else if parameter.type().isNullable() {
				SyntaxException.throwNoNullParameter(node)
			}
			else if parameter.isAnonymous() {
				SyntaxException.throwNotNamedParameter(node)
			}

			fragments.code($comma) if i != 0

			parameter.toParameterFragments(fragments)
		}

		return fn(fragments)
	} // }}}
	static toES6Fragments(node, fragments, fn) { // {{{
		const data = node.data()
		let rest = false

		for parameter, i in node.parameters() {
			if parameter.isAnonymous() {
				SyntaxException.throwNotNamedParameter(node)
			}

			fragments.code($comma) if i != 0

			if parameter.isRest() {
				parameter.toParameterFragments(fragments)

				rest = true
			}
			else if rest {
				SyntaxException.throwAfterRestParameter()
			}
			else {
				parameter.toParameterFragments(fragments)
			}

			if parameter.hasDefaultValue() {
				fragments.code(' = ').compile(parameter._defaultValue)
			}
		}

		return fn(fragments)
	} // }}}
	static toKSFragments(node, fragments, mode: ParameterMode, fn, wrongdoer) { // {{{
		const parameters = node.parameters()
		const signature = node.type()

		const name = (mode == ParameterMode::Default || mode == ParameterMode::OverloadedFunction) ? 'arguments' : '__ks_arguments'

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

		if mode == ParameterMode::Default {
			lastHeaderParameterIndex = Parameter.toHeaderParameterFragments(fragments, node, parameters, minAfter, context)

			if context.async {
				asyncHeaderParameter = Parameter.toAsyncHeaderParameterFragments(fragments, parameters, lastHeaderParameterIndex)
			}
		}

		fragments = fn(fragments)

		if mode == ParameterMode::Default || mode == ParameterMode::ArrowFunction {
			Parameter.toLengthValidationFragments(fragments, node, name, signature, parameters, asyncHeaderParameter, restIndex, minBefore, minRest, minAfter)
		}

		for const parameter in parameters til lastHeaderParameterIndex {
			parameter.toValidationFragments(fragments, wrongdoer)
		}

		if lastHeaderParameterIndex == parameters.length {
			return fragments
		}

		if restIndex == -1 {
			fragments.line($runtime.scope(node), `__ks_i = \(lastHeaderParameterIndex - 1)`)

			Parameter.toBeforeRestParameterFragments(fragments, name, signature, parameters, lastHeaderParameterIndex, restIndex, context, wrongdoer)

			return fragments
		}
		else if lastHeaderParameterIndex < restIndex {
			fragments.line($runtime.scope(node), `__ks_i = \(lastHeaderParameterIndex - 1)`)

			Parameter.toBeforeRestParameterFragments(fragments, name, signature, parameters, lastHeaderParameterIndex, restIndex, context, wrongdoer)

			Parameter.toRestParameterFragments(fragments, node, name, signature, parameters, true, restIndex, minBefore, minAfter, maxAfter, context, wrongdoer)

			if restIndex + 1 == parameters.length {
				return fragments
			}
		}
		else if lastHeaderParameterIndex == restIndex {
			Parameter.toRestParameterFragments(fragments, node, name, signature, parameters, false, restIndex, restIndex, minAfter, maxAfter, context, wrongdoer)

			if restIndex + 1 == parameters.length {
				return fragments
			}
		}
		else if minAfter != 0 {
			fragments.line($runtime.scope(node), `__ks_i = \(lastHeaderParameterIndex - 1)`)
		}

		Parameter.toAfterRestParameterFragments(fragments, name, parameters, restIndex, context, wrongdoer)

		return fragments
	} // }}}
	static toHeaderParameterFragments(fragments, node, parameters, minAfter, context) { // {{{
		let til = -1

		for const parameter, i in parameters {
			const type = parameter.type()

			if type.max() == Infinity {
				if minAfter == 0 && type.isAny() && node._options.format.parameters == 'es6' {
					fragments.code($comma) if i > 0

					parameter.toParameterFragments(fragments)

					return i + 1
				}
				else {
					return i
				}
			}
			else if type.max() > 1  {
				return i
			}
			else if parameter.isRequired() || i + 1 == parameters.length || i < (til == -1 ? (til = Parameter.getUntilDifferentTypeIndex(parameters, i)) : til) {
				fragments.code($comma) if i > 0

				parameter.toParameterFragments(fragments)

				context.optional += type.max() - type.min()
				context.required -= type.min()
			}
			else {
				return i
			}
		}

		return parameters.length
	} // }}}
	static toAsyncHeaderParameterFragments(fragments, parameters, lastHeader) { // {{{
		if lastHeader == parameters.length {
			fragments.code($comma) if lastHeader > 0

			fragments.code('__ks_cb')

			return true
		}
		else {
			return false
		}
	} // }}}
	static toLengthValidationFragments(fragments, node, name, signature, parameters, asyncHeader, restIndex, minBefore, minRest, minAfter) { // {{{
		if minBefore + minRest + minAfter != 0 {
			if signature.isAsync() {
				node.module().flag('Type')

				if asyncHeader {
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
				else {
					fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)

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
			else {
				fragments
					.newControl()
					.code(`if(\(name).length < \(signature.min()))`)
					.step()
					.line(`throw new SyntaxError("Wrong number of arguments (" + \(name).length + " for \(signature.min()))")`)
					.done()
			}
		}
	} // }}}
	static toAfterRestParameterFragments(fragments, name, parameters, restIndex, beforeContext, wrongdoer) { // {{{
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
	} // }}}
	static toRestParameterFragments(fragments, node, name, signature, parameters, declared, restIndex, minBefore, minAfter, maxAfter, context, wrongdoer) { // {{{
		const parameter = parameters[restIndex]

		if parameter.type().isAny() {
			if minAfter > 0 {
				if !declared {
					fragments.line($runtime.scope(node), `__ks_i = \(restIndex - 1)`)
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

			const ctrl = fragments.newControl()

			if minAfter > 0 {
				ctrl.code('while(__ks__ > ++__ks_i)')
			}
			else {
				ctrl.code('while(arguments.length > ++__ks_i)')
			}

			ctrl.step()

			const ctrl2 = ctrl.newControl().code('if(')

			parameter.type().toTestFragments(ctrl2, new Literal(false, node, node.scope(), 'arguments[__ks_i]'))

			ctrl2.code(')').step()

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
	} // }}}
	static toBeforeRestParameterFragments(fragments, name, signature, parameters, nextIndex, restIndex, context, wrongdoer) { // {{{
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
	} // }}}
	static toWrongDoingFragments(fragments, wrongdoing, data) { // {{{
		switch wrongdoing {
			ParameterWrongDoing::BadType => {
				if data.name? {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("'\(data.name)' is not of type \(data.type.toQuote(false))"))`)
					}
					else {
						fragments.line(`throw new TypeError("'\(data.name)' is not of type \(data.type.toQuote(false))")`)
					}
				}
				else {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("anonymous argument is not of type \(data.type.toQuote(false))"))`)
					}
					else {
						fragments.line(`throw new TypeError("anonymous argument is not of type \(data.type.toQuote(false))")`)
					}
				}
			}
			ParameterWrongDoing::NotNullable => {
				if data.async {
					fragments.line(`return __ks_cb(new TypeError("'\(data.name)' is not nullable"))`)
				}
				else {
					fragments.line(`throw new TypeError("'\(data.name)' is not nullable")`)
				}
			}
		}
	} // }}}
	analyse() { // {{{
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
	} // }}}
	prepare() { // {{{
		@name.prepare()

		let type: Type = null

		if @data.modifiers.length != 0 {
			type = @name.applyModifiers(@data.modifiers, this)
		}

		if @data.type? && type == null {
			type = Type.fromAST(@data.type, this)
		}

		if type == null {
			type = @anonymous ? AnyType.NullableUnexplicit : Type.Any
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
			if !type.isNullable() && @data.defaultValue.kind == NodeKind::Identifier && @data.defaultValue.name == 'null' {
				type = type.setNullable(true)
			}

			if !(@explicitlyRequired && type.isNullable()) {
				@maybeHeadedDefaultValue = @options.format.parameters == 'es6' && type.isNullable() || @name is not IdentifierLiteral

				@defaultValue = $compile.expression(@data.defaultValue, @parent)
				@defaultValue.analyse()

				@hasDefaultValue = true

				if !@explicitlyRequired {
					min = 0
				}
			}
		}

		const name = !@anonymous && @name is IdentifierLiteral ? @name.name() : null
		const default = @hasDefaultValue ? 1 : 0

		@type = new ParameterType(@scope, name, type, min, max, default)

		@name.setDeclaredType(@rest ? Type.arrayOf(type, @scope) : type, true)
	} // }}}
	translate() { // {{{
		@name.translate()

		if @hasDefaultValue {
			@defaultValue.prepare()
			@defaultValue.translate()
		}
	} // }}}
	addAliasParameter(data, name, setter) { // {{{
		const alias = new AliasStatement(data, name, setter, this)

		return @scope.reference(alias.type())
	} // }}}
	arity() => @arity
	hasDefaultValue() => @hasDefaultValue
	isAnonymous() => @anonymous
	isRequired() => @defaultValue == null || @explicitlyRequired
	isRest() => @rest
	isUsingVariable(name) => @hasDefaultValue && @defaultValue.isUsingVariable(name)
	returnType() => @type.returnType()
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)
	} // }}}
	toAfterRestFragments(fragments, context, index, wrongdoer) { // {{{
		@name.toAfterRestFragments(fragments, context, index, wrongdoer, @rest, @arity, this.isRequired(), @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} // }}}
	toBeforeRestFragments(fragments, context, index, rest, wrongdoer) { // {{{
		@name.toBeforeRestFragments(fragments, context, index, wrongdoer, rest, @arity, this.isRequired(), @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} // }}}
	toErrorFragments(fragments, wrongdoer, async) { // {{{
		@name.toErrorFragments(fragments, wrongdoer, async)
	} // }}}
	toParameterFragments(fragments) { // {{{
		fragments.code('...') if @rest

		fragments.compile(@name)

		if @maybeHeadedDefaultValue {
			if @hasDefaultValue {
				fragments.code($equals).compile(@defaultValue)
			}
			else {
				fragments.code(' = null')
			}
		}

		@header = true
	} // }}}
	toValidationFragments(fragments, wrongdoer) { // {{{
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
			@name.toValidationFragments(fragments, wrongdoer, @rest, @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
		}
	} // }}}
	type(): ParameterType => @type
	type(@type) { // {{{
		const t = @type.type()

		@name.setDeclaredType(@rest ? Type.arrayOf(t, @scope) : t, true)
	} // }}}
}

class AliasStatement extends Statement {
	private {
		_name: String
		_identifier: IdentifierParameter
		_parameter: Parameter
		_setter: Boolean
		_type: Type
		_variableName: String
	}
	constructor(@data, @identifier, @setter, @parameter) { // {{{
		super(data, parameter.parent())

		@name = @identifier.name()

		parameter.parent().addAliasStatement(this)

		const class = parameter.parent().parent().type().discardAlias()

		if setter {
			if @type !?= class.getPropertySetter(@name) {
				ReferenceException.throwNotDefinedMember(@name, @parameter)
			}
		}
		else {
			if @type ?= class.getInstanceVariable(@name) {
				@variableName = @name
			}
			else if @type ?= class.getInstanceVariable(`_\(@name)`) {
				@variableName = `_\(@name)`
			}
			else if @type ?= class.getPropertySetter(@name) {
				@setter = true
			}
			else {
				ReferenceException.throwNotDefinedMember(@name, @parameter)
			}
		}
	} // }}}
	analyse()
	prepare()
	translate()
	name() => @name
	toStatementFragments(fragments, mode) { // {{{
		if @setter {
			fragments.newLine().code(`this.\(@name)(`).compile(@identifier).code(')').done()
		}
		else {
			fragments.newLine().code(`this.\(@variableName) = `).compile(@identifier).done()
		}
	} // }}}
	type() => @type
}

class IdentifierParameter extends IdentifierLiteral {
	applyModifiers(modifiers, node) { // {{{
		let thisAlias = false
		let setterAlias = false

		for const modifier in modifiers {
			if modifier.kind == ModifierKind::SetterAlias {
				setterAlias = true
			}
			else if modifier.kind == ModifierKind::ThisAlias {
				thisAlias = true
			}
		}

		if thisAlias {
			return node.addAliasParameter(@data, this, setterAlias)
		}
		else {
			return null
		}
	} // }}}
	setDeclaredType(type, definitive) { // {{{
		const variable = @scope.getVariable(@value)

		variable.setDeclaredType(type).setDefinitive(definitive)

		@declaredType = @realType = type
	} // }}}
	toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { // {{{
		if arity != null {
			const type = @declaredType.parameter()

			if type.isAny() {
				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(this)
					.code(` = Array.prototype.slice.call(\(context.name), \(context.increment ? '++__ks_i' : '__ks_i'), \(index + 1 == context.length ? '' : '__ks_i = ')__ks_i + \(arity.min + (context.increment ? 1 : 0)))`)
					.done()

				context.increment = true
			}
			else {
				if !context.temp {
					fragments.line(`\($runtime.scope(this))__ks__`)

					context.temp = true
				}

				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(this)
					.code(' = []')
					.done()

				if !context.increment {
					fragments.line('--__ks_i')
				}

				const line = fragments.newLine()

				if !context.tempL {
					line.code($runtime.scope(this))

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
						.compile(this).code('.push(null)').done()
						.done()

					ctrl2
						.step()
						.code('else if(!')
				}
				else {
					ctrl2.code('if(__ks__ === void 0 || __ks__ === null || !')
				}

				type.toTestFragments(ctrl2, new Literal(false, this, this.scope(), '__ks__'))

				ctrl2
					.code(')')
					.step()

				if index + 1 == context.length {
					wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
						async: context.async
						name: @value
						type: type
					})
				}
				else {
					const ctrl3 = ctrl2
						.newControl()
						.code('if(')
						.compile(this)
						.code(`.length >= \(arity.min))`)
						.step()

					ctrl3
						.line('break')
						.step()
						.code('else')
						.step()

					wrongdoer(ctrl3, ParameterWrongDoing::BadType, {
						async: context.async
						name: @value
						type: type
					})

					ctrl3.done()
				}

				ctrl2
					.step()
					.code('else')
					.step()
					.newLine()
					.compile(this).code('.push(__ks__)')
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
					.code($runtime.scope(this))
					.compile(this)
					.code($equals)
					.compile(defaultValue)
					.done()
			}
			else {
				if @declaredType.isAny() {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(this)
						.code(` = \(context.name).length > ++__ks_i && (__ks__ = \(context.name)[\(context.increment ? '++' : '')__ks_i]) !== void 0`)

					if !@declaredType.isNullable() {
						line.code(' && __ks__ !== null')
					}

					line
						.code(' ? __ks__ : ')
						.compile(defaultValue)
						.done()
				}
				else {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(this)
						.code(` = \(context.name).length > ++__ks_i && (__ks__ = \(context.name)[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)

					if @declaredType.isNullable() {
						line.code('(__ks__ === null || ')

						@declaredType.toTestFragments(line, new Literal(false, this, @scope:Scope, '__ks__'))

						line.code(')')
					}
					else {
						@declaredType.toTestFragments(line, new Literal(false, this, @scope:Scope, '__ks__'))
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
				.code($runtime.scope(this))
				.compile(this)
				.code(` = \(context.name)[`, context.increment ? '++' : '', '__ks_i]')
				.done()

			this.toValidationFragments(fragments, wrongdoer, rest, defaultValue, header, async)

			context.increment = true
		}
	} // }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { // {{{
		if arity != null {
			context.required -= arity.min

			const type = @declaredType.parameter()

			if type.isAny() {
				if context.required > 0 {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(this)
						.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length - \(context.required), __ks_i + \(arity.max + 1)))`)
						.done()
				}
				else {
					fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(this)
						.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, Math.min(\(context.name).length, __ks_i + \(arity.max + 1)))`)
						.done()
				}

				if index + 1 < context.length {
					fragments
						.newLine()
						.code('__ks_i += ')
						.compile(this)
						.code('.length')
						.done()
				}
			}
			else {
				if !context.temp {
					fragments.line(`\($runtime.scope(this))__ks__`)

					context.temp = true
				}

				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(this)
					.code(' = []')
					.done()

				if !context.increment {
					fragments.line('--__ks_i')
				}

				const line = fragments.newLine()

				if !context.tempL {
					line.code($runtime.scope(this))

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
						.compile(this).code('.push(null)').done()
						.done()

					ctrl2
						.step()
						.code('else if(!')
				}
				else {
					ctrl2.code('if(__ks__ === void 0 || __ks__ === null || !')
				}

				type.toTestFragments(ctrl2, new Literal(false, this, this.scope(), '__ks__'))

				ctrl2
					.code(')')
					.step()

				if index + 1 == context.length {
					wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
						async: context.async
						name: @value
						type: type
					})
				}
				else {
					const ctrl3 = ctrl2
						.newControl()
						.code('if(')
						.compile(this)
						.code(`.length >= \(arity.min))`)
						.step()

					ctrl3
						.line('break')
						.step()
						.code('else')
						.step()

					wrongdoer(ctrl3, ParameterWrongDoing::BadType, {
						async: context.async
						name: @value
						type: type
					})

					ctrl3.done()
				}

				ctrl2
					.step()
					.code('else')
					.step()
					.newLine()
					.compile(this).code('.push(__ks__)')
					.done()

				ctrl2.done()
				ctrl.done()

				context.increment = false
			}

			context.optional += arity.max - arity.min
		}
		else {
			if !required && defaultValue != null {
				if @declaredType.isAny() {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					const line = fragments
						.newLine()
						.code($runtime.scope(this))
						.compile(this)
						.code(` = \(context.name).length > \(context.optional) && (__ks__ = \(context.name)[++__ks_i]) !== void 0`)

					if !@declaredType.isNullable() {
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
						.code($runtime.scope(this))
						.compile(this)
						.done()

					const fixed = (context.max - context.min) == 1

					const ctrl = fragments.newControl()

					if fixed {
						ctrl
							.code(`if(\(context.name).length > \(context.optional) && (`)
							.compile(this)
							.code(` = \(context.name)[++__ks_i]) !== void 0`)
					}
					else if context.required > 0 {
						ctrl
							.code(`if(\(context.name).length > __ks_i + \(context.required + 1) && (`)
							.compile(this)
							.code(` = \(context.name)[++__ks_i]) !== void 0`)
					}
					else {
						ctrl
							.code(`if(\(context.name).length > ++__ks_i && (`)
							.compile(this)
							.code(` = \(context.name)[__ks_i]) !== void 0`)
					}

					if !@declaredType.isNullable() {
						ctrl.code(' && ').compile(this).code(' !== null')
					}

					ctrl.code(')').step()

					const ctrl2 = ctrl.newControl().code('if(')

					if @declaredType.isNullable() {
						ctrl2.compile(this).code(' !== null && !')
					}
					else {
						ctrl2.code('!')
					}

					@declaredType.toTestFragments(ctrl2, this)

					ctrl2
						.code(')')
						.step()

					if fixed || index + 1 == context.length {
						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
							async: context.async
							name: @value
							type: @declaredType
						})
					}
					else if rest {
						ctrl2
							.newLine()
							.compile(this)
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
							.compile(this)
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
							name: @value
							type: @declaredType
						})

						ctrl3.done()
					}

					ctrl2.done()

					ctrl.step().code('else').step()

					ctrl
						.newLine()
						.compile(this)
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
					.code($runtime.scope(this))
					.compile(this)
					.code(` = \(context.name)[++__ks_i]`)
					.done()

				this.toValidationFragments(fragments, wrongdoer, rest, defaultValue, header, async)

				--context.required
			}
		}
	} // }}}
	toErrorFragments(fragments, wrongdoer, async) { // {{{
		wrongdoer(fragments, ParameterWrongDoing::BadType, {
			async
			name: @value
			type: @declaredType.parameter()
		})
	} // }}}
	toValidationFragments(fragments, wrongdoer, rest, defaultValue?, header, async) { // {{{
		let ctrl = null

		if defaultValue != null {
			if !header {
				ctrl = fragments
					.newControl()
					.code('if(').compile(this).code(' === void 0')

				if !@declaredType.isNullable() {
					ctrl.code(' || ').compile(this).code(' === null')
				}

				ctrl.code(')').step()

				ctrl
					.newLine()
					.compile(this)
					.code($equals)
					.compile(defaultValue)
					.done()
			}
		}
		else {
			ctrl = fragments.newControl()

			if @declaredType.isNullable() {
				ctrl.code('if(').compile(this).code(' === void 0').code(')')
					.step()
					.newLine()
					.compile(this).code(' = null')
					.done()
			}
			else {
				ctrl
					.code('if(').compile(this).code(' === void 0').code(' || ').compile(this).code(' === null').code(')')
					.step()

				wrongdoer(ctrl, ParameterWrongDoing::NotNullable, {
					async: async
					name: this.name()
				})
			}
		}

		if !@declaredType.isAny() {
			if ctrl? {
				ctrl.step().code('else ')
			}
			else {
				ctrl = fragments.newControl()
			}

			ctrl.code('if(')

			if @declaredType.isNullable() {
				ctrl.compile(this).code(' !== null && ')
			}

			ctrl.code('!')

			@declaredType.toTestFragments(ctrl, this)

			ctrl
				.code(')')
				.step()

			wrongdoer(ctrl, ParameterWrongDoing::BadType, {
				async: async
				name: this.name()
				type: @declaredType
			})
		}

		if ctrl != null {
			ctrl.done()
		}
	} // }}}
}

class ArrayBindingParameter extends ArrayBinding {
	addAliasParameter(data, name, setter) => @parent.addAliasParameter(data, name, setter)
	newElement(data) => new ArrayBindingParameterElement(data, this, @scope)
	setDeclaredType(type, definitive: Boolean = false) { // {{{
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
	} // }}}
	toValidationFragments(fragments, wrongdoer, rest, defaultValue?, header, async)
}

class ArrayBindingParameterElement extends ArrayBindingElement {
	prepare() { // {{{
		super.prepare()

		if @named && @data.modifiers != 0 {
			@name.applyModifiers(@data.modifiers, this)
		}
	} // }}}
	addAliasParameter(data, name, setter) => @parent.addAliasParameter(data, name, setter)
	compileVariable(data) => Parameter.compileExpression(data, this)
	setDeclaredType(type, definitive) { // {{{
		@name.setDeclaredType(type, definitive)
	} // }}}
}

class ObjectBindingParameter extends ObjectBinding {
	addAliasParameter(data, name, setter) => @parent.addAliasParameter(data, name, setter)
	newElement(data) => new ObjectBindingParameterElement(data, this, @scope)
	setDeclaredType(type, definitive: Boolean = false) { // {{{
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
		else {
			TypeException.throwInvalidBinding('Object', this)
		}
	} // }}}
	toValidationFragments(fragments, wrongdoer, rest, defaultValue?, header, async)
}

class ObjectBindingParameterElement extends ObjectBindingElement {
	prepare() { // {{{
		super.prepare()

		if @data.modifiers != 0 {
			@alias.applyModifiers(@data.modifiers, this)
		}
	} // }}}
	addAliasParameter(data, name, setter) => @parent.addAliasParameter(data, name, setter)
	compileVariable(data) => Parameter.compileExpression(data, this)
	setDeclaredType(type, definitive) { // {{{
		@alias.setDeclaredType(type, definitive)
	} // }}}
}

class AnonymousParameter extends AbstractNode {
	private {
		_name: String
		_type: Type
	}
	analyse()
	prepare() { // {{{
		@name = @scope.acquireTempName(false)
	} // }}}
	translate()
	applyModifiers(modifiers, node) => null
	setDeclaredType(@type, definitive)
	toFragments(fragments, mode) { // {{{
		fragments.code(@name)
	} // }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, required, defaultValue?, header, async) { // {{{
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

				this.toValidationFragments(fragments, wrongdoer, rest, defaultValue, header, async)
			}

			--context.required
		}
	} // }}}
	toValidationFragments(fragments, wrongdoer, rest, defaultValue?, header, async) { // {{{
		if !@type.isAny() {
			let ctrl = fragments
				.newControl()
				.code('if(')

			if @type.isNullable() {
				ctrl.compile(this).code(' !== null && ')
			}

			ctrl.code('!')

			@type.toTestFragments(ctrl, this)

			ctrl
				.code(')')
				.step()

			wrongdoer(ctrl, ParameterWrongDoing::BadType, {
				async: async
				type: @type
			})

			ctrl.done()
		}
	} // }}}
}