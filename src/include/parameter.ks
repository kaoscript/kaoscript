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
		_type: Type
	}
	static compileExpression(data, node) {
		switch data.kind {
			NodeKind::ArrayBinding => return new ArrayBindingParameter(data, node)
			NodeKind::Identifier => return new IdentifierParameter(data, node)
			NodeKind::ObjectBinding => return new ObjectBindingParameter(data, node)
		}
	}
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
			else if parameter.isNullable() {
				SyntaxException.throwNoNullParameter(node)
			}
			else if parameter.isAnonymous() {
				SyntaxException.throwNotNamedParameter(node)
			}

			fragments.code($comma) if i

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

			fragments.code($comma) if i

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
		const data = node.data()
		const parameters = node.parameters()
		const signature = node.type()
		const async = signature.isAsync()

		const name = (mode == ParameterMode::Default || mode == ParameterMode::OverloadedFunction) ? 'arguments' : '__ks_arguments'

		let parameter, ctrl
		let maxb = 0
		let rb = 0
		let db = 0
		let rr = 0
		let maxa = 0
		let ra = 0
		let fr = false
		let rest = -1

		let type
		for parameter, i in parameters {
			type = parameter.type()

			if rest != -1 {
				if type.min() != 0 {
					ra += type.min()
				}

				maxa += type.max()

				if parameter.isRest() {
					fr = true
				}
			}
			else if type.max() == Infinity {
				rest = i
				rr = type.min()
			}
			else {
				if type.min() == 0 {
					++db
				}
				else {
					rb += type.min()
				}

				maxb += type.max()

				if parameter.isRest() {
					fr = true
				}
			}
		}

		if async {
			if rest != -1 {
				++ra
				++maxa
			}
			else {
				++rb
				++maxb
			}
		}

		let l = rest != -1 ? rest : parameters.length
		let context

		//console.log(signature)
		//console.log(rb, ra)
		//console.log(maxb, maxa)

		if	mode == ParameterMode::Default &&
			(
				(rest != -1 && !fr && (db == 0 || db + 1 == rest)) ||
				(rest == -1 && signature.max() == l && (db == 0 || db == l))
			)
		{ // {{{
			for parameter, i in parameters while i < l {
				fragments.code($comma) if i > 0

				parameter.toParameterFragments(fragments)
			}

			if ra == 0 && rest != -1 && (parameters[rest].type().isAny() || maxa == 0) && node._options.format.parameters == 'es6' {
				parameter = parameters[rest]

				fragments.code($comma) if rest > 0

				parameter.toParameterFragments(fragments)
			}
			else if async && ra == 0 {
				fragments.code($comma) if l > 0

				fragments.code('__ks_cb')
			}

			fragments = fn(fragments)

			if rb + ra > 0 {
				if async {
					node.module().flag('Type')

					if rest != -1 {
						fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)
					}

					let ctrl = fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min() + 1))`)
						.step()
						.line(`\($runtime.scope(node))__ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

					if rest == -1 {
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
					}
					else {
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
					}

					ctrl
						.step()
						.code(`else if(!\($runtime.type(node)).isFunction(__ks_cb))`)
						.step()
						.line(`throw new TypeError("'callback' must be a function")`)

					ctrl.done()
				}
				else {
					fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min()))`)
						.step()
						.line(`throw new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()))")`)
						.done()
				}
			}

			for parameter, i in parameters while i < l {
				parameter.toValidationFragments(fragments, wrongdoer)
			}

			if rest != -1 {
				parameter = parameters[rest]

				if ra > 0 {
					if parameter._anonymous {
						fragments.line(`\($runtime.scope(node)) __ks_i = arguments.length > \(maxb + ra) ? arguments.length - \(ra) : \(maxb)`)
					}
					else {
						fragments.line($runtime.scope(node), '__ks_i')

						if parameter.type().isAny() {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(` = arguments.length > \(maxb + ra) ? Array.prototype.slice.call(arguments, \(maxb), __ks_i = arguments.length - \(ra)) : (__ks_i = \(maxb), [])`)
								.done()
						}
						else {
							fragments
								.newLine()
								.code($runtime.scope(node))
								.compile(parameter)
								.code(' = []')
								.done()
						}
					}
				}
				else if maxa > 0 && !parameter.type().isAny() {
					if maxb > 0 {
						throw new NotImplementedException(node)
					}
					else {
						fragments.line($runtime.scope(node), '__ks_i = -1')
					}

					if parameter._anonymous {
						ctrl = fragments
							.newControl()
							.code('while(')

						parameter.type().toTestFragments(ctrl, new Literal(false, node, node.scope(), 'arguments[++__ks_i]'))

						ctrl
							.code(')')
							.step()
							.done()
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(' = []')
							.done()

						ctrl = fragments
							.newControl()
							.code('while(')

						parameter.type().toTestFragments(ctrl, new Literal(false, node, node.scope(), 'arguments[++__ks_i]'))

						ctrl
							.code(')')
							.step()

						ctrl
							.newLine()
							.compile(parameter)
							.code('.push(arguments[__ks_i])')
							.done()

						ctrl.done()
					}
				}
				else if node._options.format.parameters == 'es5' {
					fragments
						.newLine()
						.code($runtime.scope(node))
						.compile(parameter)
						.code($equals, `Array.prototype.slice.call(arguments, \(maxb), arguments.length)`)
						.done()
				}

				if parameter.hasDefaultValue() {
					ctrl = fragments
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

				if (arity ?= parameter.arity()) && arity.min > 0 {
					ctrl = fragments
						.newControl()
						.code(`if(`)
						.compile(parameter)
						.code(`.length < \(arity.min))`)
						.step()

					if async {
						ctrl
							.newLine()
							.code(`return __ks_cb(new SyntaxError("wrong number of rest values (" + `)
							.compile(parameter)
							.code(`.length + " for at least \(arity.min))"))`)
							.done()
					}
					else {
						ctrl
							.newLine()
							.code(`throw new SyntaxError("wrong number of rest values (" + `)
							.compile(parameter)
							.code(`.length + " for at least \(arity.min))")`)
							.done()
					}

					ctrl.done()
				}
			}
		} // }}}
		else { // {{{
			if mode == ParameterMode::ArrowFunction {
				fragments.code(`...\(name)`)
			}
			else if mode == ParameterMode::HybridConstructor {
				fragments.code(name)
			}

			fragments = fn(fragments)

			if rb + ra > 0 {
				if async {
					node.module().flag('Type')

					fragments.line(`\($runtime.scope(node))__ks_cb = arguments.length > 0 ? arguments[arguments.length - 1] : null`)

					let ctrl = fragments
						.newControl()
						.code(`if(arguments.length < \(signature.min() + 1))`)
						.step()
						.line(`\($runtime.scope(node))__ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for \(signature.min()) + 1)")`)

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
				else if mode == ParameterMode::Default || mode == ParameterMode::ArrowFunction {
					fragments
						.newControl()
						.code(`if(\(name).length < \(signature.min()))`)
						.step()
						.line(`throw new SyntaxError("wrong number of arguments (" + \(name).length + " for \(signature.min()))")`)
						.done()
				}
			}

			fragments.line($runtime.scope(node), '__ks_i = -1')

			context = {
				name: name
				required: rb
				optional: signature.min()
				temp: false
				length: data.parameters.length
				async: async
			}

			for i from 0 til l {
				parameters[i].toBeforeRestFragments(fragments, context, i, wrongdoer)
			}

			if rest != -1 { // {{{
				parameter = parameters[rest]

				if ra > 0 {
					if parameter._anonymous {
						if l + 1 < data.parameters.length {
							fragments
								.newControl()
								.code(`if(\(name).length > __ks_i + \(ra + 1))`)
								.step()
								.line(`__ks_i = \(name).length - \(ra + 1)`)
								.done()
						}
					}
					else {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(` = \(name).length > __ks_i + \(ra + 1) ? Array.prototype.slice.call(\(name), __ks_i + 1, \(name).length - \(ra)) : []`)
							.done()

						if l + 1 < data.parameters.length {
							fragments
								.newLine()
								.code('__ks_i += ')
								.compile(parameter)
								.code('.length')
								.done()
						}
					}
				}
				else {
					if !parameter._anonymous {
						fragments
							.newLine()
							.code($runtime.scope(node))
							.compile(parameter)
							.code(` = \(name).length > ++__ks_i ? Array.prototype.slice.call(\(name), __ks_i, __ks_i = \(name).length) : []`)
							.done()

						if !parameter.type().isAny() && l + 1 < data.parameters.length {
							fragments
								.newLine()
								.code('__ks_i += ')
								.compile(parameter)
								.code('.length')
								.done()
						}
					}
				}
			} // }}}
		} // }}}

		if ra != 0 || maxa != 0 { // {{{
			parameter = parameters[rest]

			if ra != maxa && !parameter.type().isAny() {
				if ra {
					fragments.line($runtime.scope(node), '__ks_m = __ks_i + ', ra)
				}
				else {
					fragments.line($runtime.scope(node), '__ks_m = __ks_i')
				}
			}

			context = {
				name: name
				any: parameter.type().isAny()
				increment: false
				temp: context? ? context.temp : false
				length: parameters.length
			}

			for i from rest + 1 til parameters.length {
				parameters[i].toAfterRestFragments(fragments, context, i, wrongdoer)
			}
		} // }}}

		return fragments
	} // }}}
	static toWrongDoingFragments(fragments, wrongdoing, data) { // {{{
		switch wrongdoing {
			ParameterWrongDoing::BadType => {
				if data.name? {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("'\(data.name)' is not of type \(data.type.toQuote())"))`)
					}
					else {
						fragments.line(`throw new TypeError("'\(data.name)' is not of type \(data.type.toQuote())")`)
					}
				}
				else {
					if data.async {
						fragments.line(`return __ks_cb(new TypeError("anonymous argument is not of type \(data.type.toQuote())"))`)
					}
					else {
						fragments.line(`throw new TypeError("anonymous argument is not of type \(data.type.toQuote())")`)
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

		const definitive = type != null
		if !definitive {
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
				@defaultValue.prepare()

				@hasDefaultValue = true

				if !@explicitlyRequired {
					min = 0
				}
			}
		}

		const name = !@anonymous && @name is IdentifierLiteral ? @name.name() : null
		const default = @hasDefaultValue ? 1 : 0

		@type = new ParameterType(@scope, name, type, min, max, default)

		@name.setDeclaredType(@rest ? Type.arrayOf(type, @scope) : type, definitive)
	} // }}}
	translate() { // {{{
		@name.translate()

		if @hasDefaultValue {
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
	isNullable() => @type.type().isNullable()
	isRest() => @rest
	isUsingVariable(name) => @hasDefaultValue && @defaultValue.isUsingVariable(name)
	returnType() => @type.returnType()
	toFragments(fragments, mode) { // {{{
		fragments.compile(@name)
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
		@name.toValidationFragments(fragments, wrongdoer, @rest, @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} // }}}
	toAfterRestFragments(fragments, context, index, wrongdoer) { // {{{
		@name.toAfterRestFragments(fragments, context, index, wrongdoer, @rest, @arity, @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} // }}}
	toBeforeRestFragments(fragments, context, index, wrongdoer) { // {{{
		@name.toBeforeRestFragments(fragments, context, index, wrongdoer, @rest, @arity, @defaultValue, @header && @maybeHeadedDefaultValue, @parent.type().isAsync())
	} // }}}
	type() => @type
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

		if rest {
			if !@declaredType.isAny() {
				throw new NotImplementedException(this)
			}
		}
		else if !@declaredType.isAny() {
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
	toAfterRestFragments(fragments, context, index, wrongdoer, rest, arity?, defaultValue?, header, async) { // {{{
		if arity != null {
			if @declaredType.parameter().isAny() {
				fragments
					.newLine()
					.code($runtime.scope(this))
					.compile(this)
					.code(` = Array.prototype.slice.call(\(context.name), __ks_i + 1, __ks_i + \(arity.min + 1))`)
					.done()

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
				throw new NotImplementedException(this)
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
						.code(` = \(context.name).length > __ks_m && (__ks__ = \(context.name)[\(context.increment ? '++' : '')__ks_i]) !== void 0`)

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
						.code(` = \(context.name).length > __ks_m && (__ks__ = \(context.name)[__ks_i\(context.increment ? ' + 1' : '')]) !== void 0 && `)

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
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, defaultValue?, header, async) { // {{{
		if arity != null {
			context.required -= arity.min

			if @declaredType.parameter().isAny() {
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
				throw new NotImplementedException(this)
			}

			context.optional += arity.max - arity.min
		}
		else {
			if defaultValue != null {
				if @declaredType.isAny() {
					if !context.temp {
						fragments.line(`\($runtime.scope(this))__ks__`)

						context.temp = true
					}

					let line = fragments
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

					let ctrl = fragments
						.newControl()
						.code(`if(\(context.name).length > \(context.optional) && (`)
						.compile(this)
						.code(` = \(context.name)[++__ks_i]) !== void 0`)

					if !@declaredType.isNullable() {
						ctrl.code(' && ').compile(this).code(' !== null')
					}

					ctrl.code(')').step()

					if @declaredType.isNullable() {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(')
							.compile(this)
							.code(' !== null && !')

						@declaredType.toTestFragments(ctrl2, this)

						ctrl2
							.code(')')
							.step()

						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
							async: context.async
							name: @value
							type: @declaredType
						})

						ctrl2.done()
					}
					else {
						let ctrl2 =	ctrl
							.newControl()
							.code('if(!')

						@declaredType.toTestFragments(ctrl2, this)

						ctrl2
							.code(')')
							.step()

						wrongdoer(ctrl2, ParameterWrongDoing::BadType, {
							async: context.async
							name: @value
							type: @declaredType
						})

						ctrl2.done()
					}

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
		else if type.isObject() {
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
	toBeforeRestFragments(fragments, context, index, wrongdoer, rest, arity?, defaultValue?, header, async) { // {{{
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
}